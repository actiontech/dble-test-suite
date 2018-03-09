#######################shard tbale test################################
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DROP TABLE if exists aly_test
create TABLE aly_test (id int(11) primary key,R_REGIONKEY int(11) default 10,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO aly_test VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,1, 'Eastern','test001'),(3,5, 'Northern','test003'),(2,6, 'Western','test002'),(4,7, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default
SELECT * FROM aly_test
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM aly_test
INSERT INTO aly_test VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,4, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10,R_COMMENT='test'
SELECT * FROM aly_test
INSERT INTO aly_test VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default,R_COMMENT='test'
SELECT * FROM aly_test
#insert ignore into tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM aly_test
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
insert ignore into aly_test VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM aly_test
#INSERT INTO tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM aly_test
INSERT INTO aly_test set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT * FROM aly_test
INSERT INTO aly_test set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT * FROM aly_test
#insert ignore into tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM aly_test
INSERT INTO aly_test set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM aly_test
INSERT INTO aly_test set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM aly_test
INSERT INTO aly_test set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM aly_test
insert ignore into aly_test set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM aly_test
DROP TABLE if exists aly_test
#######################global tbale test################################
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DROP TABLE if exists global_table1
create TABLE global_table1 (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO global_table1 VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,1, 'Eastern','test001'),(3,5, 'Northern','test003'),(2,6, 'Western','test002'),(4,7, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM global_table1
INSERT INTO global_table1 VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,4, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#insert ignore into tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM global_table1
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
insert ignore into global_table1 VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#INSERT INTO tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM global_table1
INSERT INTO global_table1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
#insert ignore into tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM global_table1
INSERT INTO global_table1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
INSERT INTO global_table1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
insert ignore into global_table1 set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT id,R_REGIONKEY,R_NAME,R_COMMENT FROM global_table1
DROP TABLE if exists global_table1
#######################no_shard tbale test################################
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DROP TABLE if exists test_no_shard
create TABLE test_no_shard (id int(11),R_REGIONKEY int(11) primary key default 10,R_NAME varchar(50),R_COMMENT varchar(50))
INSERT INTO test_no_shard VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,1, 'Eastern','test001'),(3,5, 'Northern','test003'),(2,6, 'Western','test002'),(4,7, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default
SELECT * FROM test_no_shard
#INSERT INTO tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,4, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_NAME='test',R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default(R_REGIONKEY)+10,R_COMMENT='test'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,9, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=default,R_COMMENT='test'
SELECT * FROM test_no_shard
#insert ignore into tbl_name VALUES(expr,expr,...) ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test_no_shard
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
INSERT INTO test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
insert ignore into test_no_shard VALUES(1,8, 'Eastern','test001') ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='test'
SELECT * FROM test_no_shard
#INSERT INTO tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test_no_shard
INSERT INTO test_no_shard set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_NAME='new',R_COMMENT='new'
SELECT * FROM test_no_shard
#insert ignore into tbl_name set col_name=expr,col_name1=default,... ON DUPLICATE KEY UPDATE col_name=expr,col_name1=expr1
DELETE FROM test_no_shard
INSERT INTO test_no_shard set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM test_no_shard
INSERT INTO test_no_shard set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM test_no_shard
insert ignore into test_no_shard set id=1,R_REGIONKEY=default,R_NAME='test',R_COMMENT='test' ON DUPLICATE KEY UPDATE R_REGIONKEY=R_REGIONKEY+1,R_COMMENT='new'
SELECT * FROM test_no_shard
DROP TABLE if exists test_no_shard