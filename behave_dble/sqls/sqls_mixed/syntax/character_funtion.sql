#!default_db:schema1
#
#prepare table
drop table if exists sharding_2_t2
drop table if exists sharding_3_t1
create table sharding_2_t2 (id decimal(10,0) NOT NULL,id2 bigint(20) NOT NULL,name varchar(250) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8
create table sharding_3_t1 (id decimal(10,0) NOT NULL,id2 bigint(20) NOT NULL,name varchar(250) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8
insert into sharding_2_t2 values (1,1,'测试1')
insert into sharding_3_t1 values (1,1,'测试1')
select (case a.id when 1 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2
insert into sharding_2_t2 values (2,2,'测试2')
insert into sharding_3_t1 values (2,2,'测试2')
select (case a.id when 1 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2
insert into sharding_3_t1 values (2,3,'测试3')
select (case a.id when 2 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id
select (case a.id when 3 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id
select (case a.id when 3 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2
# case 2 function : concat/cast
select concat(a.name,b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id
select cast(b.name as char) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id
#
#clear tables
drop table if exists sharding_4_t1