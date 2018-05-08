drop table if exists test_global
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
insert into test_global values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18)
insert into test_global(id,k,pad) values(19,19,19)
drop table if exists testdb.tb_test
CREATE TABLE testdb.tb_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))DEFAULT CHARSET=UTF8
insert into testdb.tb_test values(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15)
#
#select select_expr
#
select 1+1
SELECT ABS(2)
select id,k,c,pad from test_global
select avg(pad) from test_global 
select BIT_AND(pad) from test_global 
select BIT_OR(pad) from test_global 
select BIT_XOR(pad) from test_global 
select count(pad) from test_global 
select count(distinct pad) from test_global 
select group_concat(pad) from test_global 
select max(pad) from test_global 
select min(pad) from test_global 
select std(pad) from test_global 
select stddev(pad) from test_global 
select stddev_pop(pad) from test_global 
select stddev_samp(pad) from test_global 
select sum(pad) from test_global 
select var_pop(pad) from test_global 
select var_samp(pad) from test_global 
select variance(pad) from test_global 
select test_global.pad from test_global
select pad t1 from test_global
select pad as t1 from test_global
select test_global.pad as t1 from test_global
select test_global.pad t1 from test_global
select k,pad from test_global
#
#from table_references
#
select 1+1 from dual
select id,k,c,pad from test_global
select id,k,c,pad from test_global t1
select id,k,c,pad from test_global as t1
select id,k,c,pad from mytest.test_global
select * from testdb.tb_test
#
#where
#
select id,k,c,pad from test_global where pad<10
select id,k,c,pad from test_global where id>(SELECT ABS(2)) order by id
select id,k,c,pad from test_global t1 where t1.pad<5
#
#group by
#
select avg(id),pad from test_global group by pad
select BIT_AND(id),pad from test_global group by pad
select BIT_OR(id),pad from test_global group by pad
select BIT_XOR(id),pad from test_global group by pad
select count(id),pad from test_global group by pad
select count(distinct pad) from test_global group by pad
select group_concat(id),pad from test_global group by pad
select max(id),pad from test_global group by pad
select min(id),pad from test_global group by pad
select std(id),pad from test_global group by pad
select stddev(id),pad from test_global group by pad
select stddev_pop(id),pad from test_global group by pad
select stddev_samp(id),pad from test_global group by pad
select sum(id),pad from test_global group by pad
select var_pop(id),pad from test_global group by pad
select var_samp(id),pad from test_global group by pad
select variance(id),pad from test_global group by pad
select sum(id) from test_global a group by a.pad
select id ,pad from test_global group by id
drop table if exists mytest_auto_test1
create table mytest_auto_test1 (id int(11),R_REGIONKEY bigint primary key AUTO_INCREMENT,R_NAME varchar(50),R_COMMENT varchar(50))
insert into mytest_auto_test1(id,R_NAME,R_COMMENT) values(1,1,1),(2,2,2),(3,3,3),(4,4,4)
select count(*) from mytest_auto_test1 group by R_REGIONKEY
select id,k,c,pad from test_global group by id desc
select id,k,c,pad from test_global group by id asc
select pad,count(id) t from test_global group by pad having t>1
select pad,count(id) t from test_global group by pad limit 1
select pad,count(id) t from test_global group by pad order by pad
select pad,count(id) t from test_global group by pad with rollup
#
#having
#
select id,pad from test_global having pad=(select min(id) from test_global)
select pad,count(*) a from test_global group by pad having a>1
select id,pad from test_global having pad<6
#
#order by
#
select id,k,c,pad from test_global order by null
select id,k,c,pad from test_global order by id desc
select id,k,c,pad from test_global order by id asc
select id t,pad from test_global order by t
select id,pad from test_global order by pad
select id,pad from test_global a order by a.id
select id,pad from test_global a order by a.pad
#
#limit
#
select id,k,c,pad from test_global order by id limit 1,3
prepare select_table from 'select * from test_global order by id limit ?'
select id,k,c,pad from test_global order by id limit 3
select id,k,c,pad from test_global order by id limit 3 offset 1
#
#select + keyword
#
select all id,k,c,pad from test_global
select distinct pad from test_global
select Distinctrow pad,id,k,c from test_global
select distinct pad,id from test_global order by id
select distinct pad,id from test_global where pad>2 order by id
select distinct pad,id from test_global group by id,pad
select count(distinct id),pad from test_global group by pad
select distinct SQL_BIG_RESULT pad from test_global
select distinct SQL_BIG_RESULT pad from test_global order by pad
select distinctrow SQL_BIG_RESULT pad from test_global
select distinctrow SQL_BIG_RESULT pad from test_global order by pad
select SQL_BIG_RESULT count(*),pad from test_global group by pad
select distinct SQL_SMALL_RESULT pad from test_global
select distinct SQL_SMALL_RESULT pad from test_global order by pad
select distinctrow SQL_SMALL_RESULT pad from test_global
select distinctrow SQL_SMALL_RESULT pad from test_global order by id
select SQL_SMALL_RESULT count(*),pad from test_global group by pad
select SQL_BUFFER_RESULT pad from test_global
select SQL_BUFFER_RESULT pad from test_global order by id
select straight_join pad from test_global
select straight_join pad from test_global order by id
select sql_cache pad from test_global
select sql_cache pad from test_global order by id
select sql_no_cache pad from test_global
select sql_no_cache pad from test_global order by id
select SQL_CALC_FOUND_ROWS pad from test_global order by id
select SQL_CALC_FOUND_ROWS pad from test_global
#
#Operator
#
select id,k,c,pad from test_global where id=1+1
select id,k,c,pad from test_global where id=2*3
select id,k,c,pad from test_global where id=9/3
select id,k,c,pad from test_global where id=12 div 4
select id,k,c,pad from test_global where id=10-4
select id,k,c,pad from test_global where id=1+2*3-9/3+12 div 4
select id,k,c,pad from test_global where id=-3
select id,k,c,pad from test_global where id=6|3
select id,k,c,pad from test_global where id=2&3
select id,k,c,pad from test_global where id=7^3
select id,k,c,pad from test_global where id=1<<2
select id,k,c,pad from test_global where id=4>>2
select id,k,c,pad from test_global where id=5 & ~1
select id,k,c,pad from test_global where id=BIT_COUNT(29)
select id,k,c,pad from test_global where id>=1
select id,k,c,pad from test_global where id<=3
select id,k,c,pad from test_global where id<5
select id,k,c,pad from test_global where id>6
select id,k,c,pad from test_global where id!=7
select id,k,c,pad from test_global where id between 2 and 4
select id,k,c,pad from test_global where id not between 3 and 5
select id,k,c,pad from test_global where id is true
select id,k,c,pad from test_global where id is false
select id,k,c,pad from test_global where id is unknown
select id,k,c,pad from test_global where id is not true
select id,k,c,pad from test_global where id is not false
select id,k,c,pad from test_global where id is not unknown
select id,k,c,pad from test_global where c is not null
select id,k,c,pad from test_global where c is null
select id,k,c,pad from test_global where c like '中'
select id,k,c,pad from test_global where c like '%3'
select id,k,c,pad from test_global where c like 'i%'
select id,k,c,pad from test_global where c like '$%$'
select id,k,c,pad from test_global where c like 'id_'
select id,k,c,pad from test_global where c like '_d3'
select id,k,c,pad from test_global where c like 'i_4'
select id,k,c,pad from test_global where c like '20\%'
select id,k,c,pad from test_global where c like 'a\_1'
select id,k,c,pad from test_global where c not like '中'
select id,k,c,pad from test_global where id<>2
select id,k,c,pad from test_global where id <=>1
select id,k,c,pad from test_global where 1 <=> 1
select id,k,c,pad from test_global where NULL <=> NULL
select id,k,c,pad from test_global where 1 <=> NULL
select id,k,c,pad from test_global where id=@var1 := 1
select id,k,c,pad from test_global where id=COALESCE(2,3)
select id,k,c,pad from test_global where id=COALESCE(null,3)
select id,k,c,pad from test_global where id=GREATEST(2,3,6.4,7,12)
select id,k,c,pad from test_global where id in(2,3,6.4,7,12)
select id,k,c,pad from test_global where pad in(2,3,6.4,7,12)
select id,k,c,pad from test_global where id not in(2,3)
select id,k,c,pad from test_global where id=INTERVAL(23, 1, 15, 17, 30, 44, 200)
select id,k,c,pad from test_global where id=LEAST(23, 1, 15, 17, 30, 44, 200)
select id,k,c,pad from test_global where id not in(2,3,6.4,7,12)
select id,k,c,pad from test_global where pad=strcmp('test','test')
select id,k,c,pad from test_global where pad=strcmp('test1','test')
select id,k,c,pad from test_global where pad=strcmp('test','test1')
select id,k,c,pad from test_global where c regexp '.id,k,c,pad'
select id,k,c,pad from test_global where c regexp 'new\\id,k,c,pad.\\id,k,c,padline'
select id,k,c,pad from test_global where c regexp 'A'
select id,k,c,pad from test_global where c regexp BINARY 'A'
select id,k,c,pad from test_global where c regexp '^[a-d]'
select id,k,c,pad from test_global where c not regexp '.id,k,c,pad'
select id,k,c,pad from test_global where c rlike '^[a-d]'
select id,k,c,pad from test_global where 1 AND 1
select id,k,c,pad from test_global where 1 AND 0
select id,k,c,pad from test_global where 1 AND NULL
select id,k,c,pad from test_global where 0 AND NULL
select id,k,c,pad from test_global where NULL AND 0
select id,k,c,pad from test_global where 1 && 1
select id,k,c,pad from test_global where NOT 10
select id,k,c,pad from test_global where NOT 0
select id,k,c,pad from test_global where  NOT NULL
select id,k,c,pad from test_global where  ! (1+1)
select id,k,c,pad from test_global where  ! 1+1
select id,k,c,pad from test_global where 1 OR 1
select id,k,c,pad from test_global where 1 OR 0
select id,k,c,pad from test_global where 0 OR 0
select id,k,c,pad from test_global where 0 || NULL
select id,k,c,pad from test_global where 1 || NULL
select id,k,c,pad from test_global where 1 XOR 1
select id,k,c,pad from test_global where 1 XOR 0
select id,k,c,pad from test_global where 1 XOR NULL
select id,k,c,pad from test_global where 1 XOR 1 XOR 1
#
#clauses(order by/group by/having)
#
drop table if exists test_global
create table test_global (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_global (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test_global (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test_global values(3,3,'','string'),(4,4,'a','b'),(5,3,'','string'),(6,4,'a','b'),(7,3,'','string'),(8,4,'a','b'),(9,4,'a','b')
select count(*) from test_global group by R_COMMENT,1+1
select count(*) from test_global group by R_COMMENT asc
select count(*) from test_global group by R_COMMENT desc
select count(*) from test_global group by 1+1
select count(*) from test_global group by R_COMMENT,R_NAME order by null
select count(*) al from test_global group by R_COMMENT,R_NAME order by al asc
select count(*) from test_global group by 1+1,1*5 order by 2*2 asc
select count(*) from test_global group by R_COMMENT,R_NAME having count(*) order by 1+1
select count(*) from test_global group by R_COMMENT,R_NAME having count(*) order by 1+1 limit 2
select count(*) from test_global where id<8 group by R_COMMENT,R_NAME having count(*) order by 1+1 asc  limit 2 offset 2
select count(*) from test_global where id<8 group by R_COMMENT,R_NAME having count(*) order by 1+1 limit 2 ,2
select R_comment,count(*) a from test_global group by R_comment having a>1+1
select R_comment,count(*) a from test_global group by R_comment having count(*)>1+1
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global order by R_COMMENT+1 asc
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global order by R_COMMENT,1+1
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global order by id,R_COMMENT
#
#special_scene(null,Accuracy)
#
drop table if exists test_global
create table test_global (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_global (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test_global (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test_global values(3,3,'','string'),(4,4,'a','b'),(5,3,'','string'),(6,4,'a','b'),(7,3,'','string'),(8,4,'a','b'),(9,4,'a','b')
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global order by R_comment
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global where id =2 order by R_comment
select count(*),R_COMMENT from test_global group by R_comment
select count(*),R_COMMENT from test_global where id=2 group by R_comment
select count(R_COMMENT) from test_global
select count(R_COMMENT) from test_global where id=2
select sum(R_COMMENT) from test_global
select sum(R_COMMENT) from test_global where id=2
select distinct R_COMMENT from test_global
select distinct R_COMMENT from test_global where id=2
select avg(R_REGIONKEY) from test_global
drop table if exists test_global
create table test_global (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT date)
insert into test_global (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test_global (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test_global values(3,3,'','1983-01-01'),(4,4,'a','1967-09-12'),(5,3,'','1776-04-30'),(6,4,'b','1963-12-09')
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global order by R_COMMENT
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global order by R_NAME
select R_NAME,max(R_REGIONKEY) from test_global group by R_name
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global limit 2,3
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global limit 1,1
select id,R_REGIONKEY,R_NAME,R_COMMENT from test_global limit 1,2
select id,R_REGIONKEY from test_global order by id,R_REGIONKEY limit 2,3
select id,R_REGIONKEY from test_global group by id,R_REGIONKEY limit 2,3
select id,R_REGIONKEY from test_global group by id,R_REGIONKEY order by id,R_REGIONKEY limit 2,3
