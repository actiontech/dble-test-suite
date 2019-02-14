#!default_db:schema1
# Created by zhaohongjie at 2018/11/8
drop table if exists test1;
create table test1(id int, t timestamp);
select sec_to_time(sum(time_to_sec(t))) from test1;
insert into test1 value(1, '131225'),(2, '2018-11-08 15:16:45'),(null, '131225');
select sec_to_time(sum(time_to_sec(t))) from test1;
SELECT FROM_DAYS(SUM(TO_DAYS(t))) FROM test1;
select id, t, avg(id) from test1 group by id;

#AVG
drop table if exists test1;
create table test1(id int, c float);
insert into test1 values(1, 2.3333333),(2,0),(3,null),(4,0.11111111),(1, 2.3333333);
select avg(id), avg(c) from test1;
select avg(DISTINCT id), avg(DISTINCT c) from test1;
select avg(DISTINCT id) over_clause, avg(DISTINCT c) over_clause from test1;

drop table if exists test1;
create table test1(id int, c binary);
insert into test1 values(1, 0x1),(2,0),(3,null),(4,1),(2,1),(null,0);
select bit_and(id) from test1;
select bit_and(c) from test1;
select bit_and(c) over_clause from test1 where id=4;
select bit_or(id), bit_or(c) from test1;
select bit_or(id) over_clause, bit_or(c) over_clause from test1;
select bit_xor(id), bit_xor(c) from test1;
select bit_xor(id) over_clause, bit_xor(c) over_clause from test1;
select count(*) from test1 group by c;
select count(id) from test1 group by c;
select count(c) from test1 group by c;
select count(distinct id, c) from test1 group by c;

drop table if exists test1;
#!multiline
CREATE TABLE `test1` (
  `id` int(11) DEFAULT NULL,
  `name` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
#end multiline, before insert and after insert need both test, sharding column and none sharding column need both consider
select max(DISTINCT id) from test1;
select min(DISTINCT id) from test1;
select *, group_concat(name order by name) from test1 group by id;
insert into test1 values(1,'a'),(null,'b'),(2,null),(1,'d'),(null,'c'),(3,'a'),(null,'b'),(null,'c'),(null,'b');
select *, group_concat(name order by name) from test1 group by id;
select *, group_concat(distinct name order by name desc separator ':') from test1 group by id;
#group_concat max len check is skipped
select min(id), max(id) from test1;
select max(DISTINCT id) from test1;
select max(DISTINCT id) over_clause from test1;
select min(DISTINCT id) from test1;
select min(DISTINCT id) over_clause from test1;
drop table if exists test1;
create table test1(id int, c1 enum('a','b','c'));
select max(c1), min(c1), sum(id) from test1;
select var_pop(id),var_samp(id), VARIANCE(id) from test1;
select sum(DISTINCT id),sum(DISTINCT c1) from test1;
select std(id), stddev(id),STDDEV_POP(id),STDDEV_SAMP(id) from test1;
insert into test1 values(1, 'a'),(2,'b'),(null,null),(4, 'c'),(5,'b');
select max(c1), min(c1) from test1;
select sum(DISTINCT id),sum(DISTINCT c1) from test1;
select max(c1) over_clause, min(c1) over_clause, sum(id) from test1;
select var_pop(id),var_samp(id), VARIANCE(id) from test1;
select var_pop(id) over_clause,var_samp(id) over_clause, VARIANCE(id) over_clause from test1;
select std(id) over_clause, stddev(id) over_clause,STDDEV_POP(id) over_clause,STDDEV_SAMP(id) over_clause from test1;