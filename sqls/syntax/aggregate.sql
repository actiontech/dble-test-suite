# Created by zhaohongjie at 2018/11/8
drop table if exists three_sharding_t1;
create table three_sharding_t1(id int, t timestamp);
select sec_to_time(sum(time_to_sec(t))) from three_sharding_t1;
insert into three_sharding_t1 value(1, '131225'),(2, '2018-11-08 15:16:45'),(null, '131225');
select sec_to_time(sum(time_to_sec(t))) from three_sharding_t1;
SELECT FROM_DAYS(SUM(TO_DAYS(t))) FROM three_sharding_t1;
select id, t, avg(id) from three_sharding_t1 group by id;

#AVG
drop table if exists three_sharding_t1;
create table three_sharding_t1(id int, c float);
insert into three_sharding_t1 values(1, 2.3333333),(2,0),(3,null),(4,0.11111111),(1, 2.3333333);
select avg(id), avg(c) from three_sharding_t1;
select avg(DISTINCT id), avg(DISTINCT c) from three_sharding_t1;
select avg(DISTINCT id) over_clause, avg(DISTINCT c) over_clause from three_sharding_t1;

drop table if exists three_sharding_t1;
create table three_sharding_t1(id int, c binary);
insert into three_sharding_t1 values(1, 0x1),(2,0),(3,null),(4,1),(2,1),(null,0);
select bit_and(id) from three_sharding_t1;
select bit_and(c) from three_sharding_t1;
select bit_and(c) over_clause from three_sharding_t1 where id=4;
select bit_or(id), bit_or(c) from three_sharding_t1;
select bit_or(id) over_clause, bit_or(c) over_clause from three_sharding_t1;
select bit_xor(id), bit_xor(c) from three_sharding_t1;
select bit_xor(id) over_clause, bit_xor(c) over_clause from three_sharding_t1;
select count(*) from three_sharding_t1 group by c;
select count(id) from three_sharding_t1 group by c;
select count(c) from three_sharding_t1 group by c;
select count(distinct id, c) from three_sharding_t1 group by c;

drop table if exists aly_test;
#!multiline
CREATE TABLE `aly_test` (
  `id` int(11) DEFAULT NULL,
  `name` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
#end multiline, before insert and after insert need both test, sharding column and none sharding column need both consider
select max(DISTINCT id) from aly_test;
select min(DISTINCT id) from aly_test;
select *, group_concat(name order by name) from aly_test group by id;
insert into aly_test values(1,'a'),(null,'b'),(2,null),(1,'d'),(null,'c'),(3,'a'),(null,'b'),(null,'c'),(null,'b');
select *, group_concat(name order by name) from aly_test group by id;
select *, group_concat(distinct name order by name desc separator ':') from aly_test group by id;
#group_concat max len check is skipped
select min(id), max(id) from aly_test;
select max(DISTINCT id) from aly_test;
select max(DISTINCT id) over_clause from aly_test;
select min(DISTINCT id) from aly_test;
select min(DISTINCT id) over_clause from aly_test;
drop table if exists aly_test;
create table aly_test(id int, c1 enum('a','b','c'));
select max(c1), min(c1), sum(id) from aly_test;
select var_pop(id),var_samp(id), VARIANCE(id) from aly_test;
select sum(DISTINCT id),sum(DISTINCT c1) from aly_test;
select std(id), stddev(id),STDDEV_POP(id),STDDEV_SAMP(id) from aly_test;
insert into aly_test values(1, 'a'),(2,'b'),(null,null),(4, 'c'),(5,'b');
select max(c1), min(c1) from aly_test;
select sum(DISTINCT id),sum(DISTINCT c1) from aly_test;
select max(c1) over_clause, min(c1) over_clause, sum(id) from aly_test;
select var_pop(id),var_samp(id), VARIANCE(id) from aly_test;
select var_pop(id) over_clause,var_samp(id) over_clause, VARIANCE(id) over_clause from aly_test;
select std(id) over_clause, stddev(id) over_clause,STDDEV_POP(id) over_clause,STDDEV_SAMP(id) over_clause from aly_test;