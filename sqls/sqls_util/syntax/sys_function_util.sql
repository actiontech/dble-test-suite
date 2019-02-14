#!default_db:schema1
# Created by zhaohongjie at 2019/1/17
drop table if exists test1;
CREATE TABLE test1 (i INT);
INSERT INTO test1 VALUES(1),(2),(3);
SELECT i, RAND() FROM test1 /*allow_diff*/
SELECT i, RAND(3) FROM test1
#
drop table if exists test1
create table test1(a json, b int)
insert into test1 values('{"id": "3", "name": "Barney"}' ,3),('{"id": "4", "name": "Betty"}' ,3), ('{"id": "2", "name": "Wilma"}',2)
#github 484
SELECT a, JSON_EXTRACT(a, "$.id"), b FROM test1 WHERE JSON_EXTRACT(a, "$.id") > 1 ORDER BY JSON_EXTRACT(a, "$.name")
#
SELECT JSON_UNQUOTE(a->'$.name') AS name FROM test1 WHERE b > 2
SELECT a->>'$.name' AS name FROM test1 WHERE b > 2
#
drop table if exists test1
create table test1 (ID int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (ID,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1,'Eastern','test001'),(3,3,'Northern','test003'),(2,2,'Western','test002'),(4,4,'Southern','test004')
# ROW_COUNT sent to default node if exists
SELECT ROW_COUNT()/*allow_diff*/
#
drop table if exists test1
CREATE TABLE `test1` ( `c` json DEFAULT NULL, `g` int(11) DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=latin1
insert into test1 values ('{"id": "3", "name": "Barney"}' ,3),('{"id": "4", "name": "Betty"}' ,3), ('{"id": "2", "name": "Wilma"}',2)
SELECT c, c->"$.id", g FROM test1 WHERE JSON_EXTRACT(c, "$.id") > 1 ORDER BY c->"$.name"
SELECT c, c->"$.id", g FROM test1 WHERE c->"$.id" > 1 ORDER BY c->"$.name"
ALTER TABLE test1 ADD COLUMN n INT;
UPDATE test1 SET n=1 WHERE c->"$.id" = "4"
SELECT c, c->"$.id", g, n FROM test1 WHERE JSON_EXTRACT(c, "$.id") > 1 ORDER BY c->"$.name"
DELETE FROM test1 WHERE c->"$.id" = "4"
SELECT c->>'$.name' AS name FROM test1 WHERE g > 2
#
drop table if exists test1
CREATE TABLE test1 (a JSON, b INT)
INSERT INTO test1 VALUES ("[3,10,5,17,44]", 33), ("[3,10,5,17,[22,44,66]]", 0)
SELECT a->"$[4]" FROM test1
SELECT a,b FROM test1 WHERE a->"$[0]" = 3
SELECT a,b FROM test1 WHERE a->"$[4][1]" IS NOT NULL
SELECT a->"$[4][1]" FROM test1
SELECT JSON_EXTRACT(a, "$[4][1]") FROM test1
drop table if exists test1
#
##case::Miscellaneous Functions
drop table if exists test1
create table test1(a json, b int default 0)
insert into test1 values('{"id": "3", "name": "Barney"}' ,3),('{"id": "4", "name": "Bearney"}' ,3), ('{"id": "2", "name": "Wilma"}',2)
select a, max(b) from test1 group by(b)
select any_value(a), max(b) from test1 group by(b)
UPDATE test1 SET b = DEFAULT(b)+1 WHERE b < 100
drop table if exists test1
#
drop table if exists test1 
create table test1(a int, b int, c int) 
INSERT INTO test1 (a,b,c) VALUES (1,2,3),(4,5,6) ON DUPLICATE KEY UPDATE c=VALUES(a)+VALUES(b) 
##case3::Aggregate (GROUP BY) Function Descriptions
drop table if exists test1 
create table test1 (id int, test_score int) 
insert into test1 values(1,1),(2,2),(3,1),(4,8),(5,2) 
SELECT id, AVG(test_score) FROM test1 GROUP BY id 
SELECT id, AVG(distinct test_score) FROM test1 GROUP BY id 
select count(distinct test_score) from test1 
select count(distinct id, test_score) from test1 
select id, group_concat(test_score) from test1 group by id 
#select id, group_concat(distinct test_score order by test_score DESC SEPARATOR ' ') from test1 group by id
select bit_and(test_score) from test1 group by id 
select bit_or(test_score) from test1 group by id 
select bit_xor(test_score) from test1 group by id 
select min(test_score), max(test_score) from test1 
select std(test_score) from test1 
select stddev(test_score) from test1 
select stddev_pop(test_score) from test1 
select stddev_samp(test_score) from test1 
select sum(test_score) from test1 
select sum(distinct test_score) from test1 
select var_pop(test_score) from test1 
select var_samp(test_score) from test1 
select variance(test_score) from test1 
SELECT id, FLOOR(test_score/100) AS val from test1 group by val, id
#
#clear tables
#
drop table if exists test1