##case1::Functions Used with Global Transaction IDs
SELECT GTID_SUBSET('3E11FA47-71CA-11E1-9E33-C80AA9429562:23','3E11FA47-71CA-11E1-9E33-C80AA9429562:21-57')
SELECT GTID_SUBTRACT('3E11FA47-71CA-11E1-9E33-C80AA9429562:21-57','3E11FA47-71CA-11E1-9E33-C80AA9429562:21')
##case2::Miscellaneous Functions
drop table if exists global_table1 
create table global_table1(a json, b int default 0) 
insert into global_table1 values('{"id": "3", "name": "Barney"}' ,3),('{"id": "4", "name": "Beglobal_table1y"}' ,3), ('{"id": "2", "name": "Wilma"}',2) 
#select a, max(b) from global_table1 group by(b)
select any_value(a), max(b) from global_table1 group by(b)  
UPDATE global_table1 SET b = DEFAULT(b)+1 WHERE b < 100 
drop table if exists global_table1
SELECT GET_LOCK('lock1',10)
SELECT RELEASE_LOCK('lock2') 
SELECT INET_ATON('10.0.5.9') 
SELECT INET_NTOA(167773449) 
SELECT HEX(INET6_ATON(INET_NTOA(167773449))) 
drop table if exists global_table1 
select IS_FREE_LOCK('abc') 
SELECT IS_IPV4('10.0.5.9'), IS_IPV4('10.0.5.256') 
SELECT IS_IPV4_COMPAT(INET6_ATON('::10.0.5.9')) 
SELECT HEX(INET6_ATON('192.168.0.1')) 
select IS_IPV4_COMPAT(INET6_ATON('::192.168.0.1')) 
SELECT IS_IPV4_MAPPED(INET6_ATON('::10.0.5.9')) 
SELECT IS_IPV6('10.0.5.9'), IS_IPV6('::1') 
select IS_USED_LOCK('abc') 
SELECT NAME_CONST('myname', 14)
#RELEASE_ALL_LOCKS sent to default node if exists
SELECT RELEASE_ALL_LOCKS()/*allow_diff*/
SELECT SLEEP(1) 
SELECT /*+ MAX_EXECUTION_TIME(1) */ SLEEP(1000) 
SELECT UUID() 
SELECT UUID_SHORT() 
drop table if exists global_table1 
create table global_table1(a int, b int, c int) 
INSERT INTO global_table1 (a,b,c) VALUES (1,2,3),(4,5,6) ON DUPLICATE KEY UPDATE c=VALUES(a)+VALUES(b) 
##case3::Aggregate (GROUP BY) Function Descriptions
drop table if exists global_table1 
create table global_table1 (id int, test_score int) 
insert into global_table1 values(1,1),(2,2),(3,1),(4,8),(5,2) 
SELECT id, AVG(test_score) FROM global_table1 GROUP BY id 
SELECT id, AVG(distinct test_score) FROM global_table1 GROUP BY id 
select count(distinct test_score) from global_table1 
select count(distinct id, test_score) from global_table1 
select id, group_concat(test_score) from global_table1 group by id 
#select id, group_concat(distinct test_score order by test_score DESC SEPARATOR ' ') from global_table1 group by id
select bit_and(test_score) from global_table1 group by id 
select bit_or(test_score) from global_table1 group by id 
select bit_xor(test_score) from global_table1 group by id 
select min(test_score), max(test_score) from global_table1 
select std(test_score) from global_table1 
select stddev(test_score) from global_table1 
select stddev_pop(test_score) from global_table1 
select stddev_samp(test_score) from global_table1 
select sum(test_score) from global_table1 
select sum(distinct test_score) from global_table1 
select var_pop(test_score) from global_table1 
select var_samp(test_score) from global_table1 
select variance(test_score) from global_table1 
SELECT id, FLOOR(test_score/100) AS val from global_table1 group by val, id
#
#clear tables
#
drop table if exists global_table1