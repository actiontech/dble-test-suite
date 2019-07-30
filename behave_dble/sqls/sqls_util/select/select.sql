#!default_db:schema1
# Created by zhaohongjie at 2019/1/17
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
insert into test1 values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18)
insert into test1(id,k,pad) values(19,19,19)



#
#select select_expr
#
select 1+1
SELECT ABS(2)
select id,k,c,pad from test1
select avg(pad) from test1
select BIT_AND(pad) from test1
select BIT_OR(pad) from test1
select BIT_XOR(pad) from test1
select count(pad) from test1
select count(distinct pad) from test1
select group_concat(pad) from test1 group by pad
select max(pad) from test1
select min(pad) from test1
select std(pad) from test1
select stddev(pad) from test1
select stddev_pop(pad) from test1
select stddev_samp(pad) from test1
select sum(pad) from test1
select var_pop(pad) from test1
select var_samp(pad) from test1
select variance(pad) from test1
select test1.pad from test1
select pad t1 from test1
select pad as t1 from test1
select test1.pad as t1 from test1
select test1.pad t1 from test1
select k,pad from test1
#
#from table_references
#
select 1+1 from dual
select id,k,c,pad from test1
select id,k,c,pad from test1 t1
select id,k,c,pad from test1 as t1
select id,k,c,pad from schema1.test1
#
#where
#
select id,k,c,pad from test1 where pad<10
select id,k,c,pad from test1 where id>(SELECT ABS(2)) order by id
select id,k,c,pad from test1 t1 where t1.pad<5
#
#group by
#
select avg(id),pad from test1 group by pad
select BIT_AND(id),pad from test1 group by pad
select BIT_OR(id),pad from test1 group by pad
select BIT_XOR(id),pad from test1 group by pad
select count(id),pad from test1 group by pad
select count(distinct pad) from test1 group by pad
select group_concat(id),pad from test1 group by pad order by pad
select max(id),pad from test1 group by pad
select min(id),pad from test1 group by pad
select std(id),pad from test1 group by pad
select stddev(id),pad from test1 group by pad
select stddev_pop(id),pad from test1 group by pad
select stddev_samp(id),pad from test1 group by pad
select sum(id),pad from test1 group by pad
select var_pop(id),pad from test1 group by pad
select var_samp(id),pad from test1 group by pad
select variance(id),pad from test1 group by pad
select sum(id) from test1 a group by a.pad
select id ,pad from test1 group by id
select count(*) from test1 group by k
select id,k,c,pad from test1 group by id desc
select id,k,c,pad from test1 group by id asc
select pad,count(id) t from test1 group by pad having t>1
select pad,count(id) t from test1 group by pad limit 1
select pad,count(id) t from test1 group by pad order by pad
select pad,count(id) t from test1 group by pad with rollup
#
#having
#
select id,pad from test1 having pad=(select min(id) from test1)
select pad,count(*) a from test1 group by pad having a>1
select id,pad from test1 having pad<6
#
#order by
#
select id,k,c,pad from test1 order by null
select id,k,c,pad from test1 order by id desc
select id,k,c,pad from test1 order by id asc
select id t,pad from test1 order by t
select id,pad from test1 order by pad
select id,pad from test1 a order by a.id
select id,pad from test1 a order by a.pad
#issue 1256
select test1.id,test1.id+1 as `rpda_0` from test1 order by `rpda_0` ASC
#
#limit
#
select id,k,c,pad from test1 order by id limit 1,3
prepare select_table from 'select * from test1 order by id limit ?'
select id,k,c,pad from test1 order by id limit 3
select id,k,c,pad from test1 order by id limit 3 offset 1
#
#select + keyword
#
select all id,k,c,pad from test1
select distinct pad from test1
select Distinctrow pad,id,k,c from test1
select distinct pad,id from test1 order by id
select distinct pad,id from test1 where pad>2 order by id
select distinct pad,id from test1 group by id,pad
select count(distinct id),pad from test1 group by pad
select distinct SQL_BIG_RESULT pad from test1
select distinct SQL_BIG_RESULT pad from test1 order by pad
select distinctrow SQL_BIG_RESULT pad from test1
select distinctrow SQL_BIG_RESULT pad from test1 order by pad
select SQL_BIG_RESULT count(*),pad from test1 group by pad
select distinct SQL_SMALL_RESULT pad from test1
select distinct SQL_SMALL_RESULT pad from test1 order by pad
select distinctrow SQL_SMALL_RESULT pad from test1
select distinctrow SQL_SMALL_RESULT pad from test1 order by id
select SQL_SMALL_RESULT count(*),pad from test1 group by pad
select SQL_BUFFER_RESULT pad from test1
select SQL_BUFFER_RESULT pad from test1 order by id
select straight_join pad from test1
select straight_join pad from test1 order by id
select sql_cache pad from test1
select sql_cache pad from test1 order by id
select sql_no_cache pad from test1
select sql_no_cache pad from test1 order by id
select SQL_CALC_FOUND_ROWS pad from test1 order by id
select SQL_CALC_FOUND_ROWS pad from test1
#
#Operator
#
select id,k,c,pad from test1 where id=1+1
select id,k,c,pad from test1 where id=2*3
select id,k,c,pad from test1 where id=9/3
select id,k,c,pad from test1 where id=12 div 4
select id,k,c,pad from test1 where id=10-4
select id,k,c,pad from test1 where id=1+2*3-9/3+12 div 4
select id,k,c,pad from test1 where id=-3
select id,k,c,pad from test1 where id=6|3
select id,k,c,pad from test1 where id=2&3
select id,k,c,pad from test1 where id=7^3
select id,k,c,pad from test1 where id=1<<2
select id,k,c,pad from test1 where id=4>>2
select id,k,c,pad from test1 where id=5 & ~1
select id,k,c,pad from test1 where id=BIT_COUNT(29)
select id,k,c,pad from test1 where id>=1
select id,k,c,pad from test1 where id<=3
select id,k,c,pad from test1 where id<5
select id,k,c,pad from test1 where id>6
select id,k,c,pad from test1 where id!=7
select id,k,c,pad from test1 where id between 2 and 4
select id,k,c,pad from test1 where id not between 3 and 5
select id,k,c,pad from test1 where id is true
select id,k,c,pad from test1 where id is false
select id,k,c,pad from test1 where id is unknown
select id,k,c,pad from test1 where id is not true
select id,k,c,pad from test1 where id is not false
select id,k,c,pad from test1 where id is not unknown
select id,k,c,pad from test1 where c is not null
select id,k,c,pad from test1 where c is null
select id,k,c,pad from test1 where c like '中'
select id,k,c,pad from test1 where c like '%3'
select id,k,c,pad from test1 where c like 'i%'
select id,k,c,pad from test1 where c like '$%$'
select id,k,c,pad from test1 where c like 'id_'
select id,k,c,pad from test1 where c like '_d3'
select id,k,c,pad from test1 where c like 'i_4'
select id,k,c,pad from test1 where c like '20\%'
select id,k,c,pad from test1 where c like 'a\_1'
select id,k,c,pad from test1 where c not like '中'
select id,k,c,pad from test1 where id<>2
select id,k,c,pad from test1 where id <=>1
select id,k,c,pad from test1 where 1 <=> 1
select id,k,c,pad from test1 where NULL <=> NULL
select id,k,c,pad from test1 where 1 <=> NULL
select id,k,c,pad from test1 where id=@var1 := 1
select id,k,c,pad from test1 where id=COALESCE(2,3)
select id,k,c,pad from test1 where id=COALESCE(null,3)
select id,k,c,pad from test1 where id=GREATEST(2,3,6.4,7,12)
select id,k,c,pad from test1 where id in(2,3,6.4,7,12)
select id,k,c,pad from test1 where pad in(2,3,6.4,7,12)
select id,k,c,pad from test1 where id not in(2,3)
select id,k,c,pad from test1 where id=INTERVAL(23, 1, 15, 17, 30, 44, 200)
select id,k,c,pad from test1 where id=LEAST(23, 1, 15, 17, 30, 44, 200)
select id,k,c,pad from test1 where id not in(2,3,6.4,7,12)
select id,k,c,pad from test1 where pad=strcmp('test','test')
select id,k,c,pad from test1 where pad=strcmp('test1','test')
select id,k,c,pad from test1 where pad=strcmp('test','test1')
select id,k,c,pad from test1 where c regexp '.id,k,c,pad'
select id,k,c,pad from test1 where c regexp 'new\\id,k,c,pad.\\id,k,c,padline'
select id,k,c,pad from test1 where c regexp 'A'
select id,k,c,pad from test1 where c regexp BINARY 'A'
select id,k,c,pad from test1 where c regexp '^[a-d]'
select id,k,c,pad from test1 where c not regexp '.id,k,c,pad'
select id,k,c,pad from test1 where c rlike '^[a-d]'
select id,k,c,pad from test1 where 1 AND 1
select id,k,c,pad from test1 where 1 AND 0
select id,k,c,pad from test1 where 1 AND NULL
select id,k,c,pad from test1 where 0 AND NULL
select id,k,c,pad from test1 where NULL AND 0
select id,k,c,pad from test1 where 1 && 1
select id,k,c,pad from test1 where NOT 10
select id,k,c,pad from test1 where NOT 0
select id,k,c,pad from test1 where  NOT NULL
select id,k,c,pad from test1 where  ! (1+1)
select id,k,c,pad from test1 where  ! 1+1
select id,k,c,pad from test1 where 1 OR 1
select id,k,c,pad from test1 where 1 OR 0
select id,k,c,pad from test1 where 0 OR 0
select id,k,c,pad from test1 where 0 || NULL
select id,k,c,pad from test1 where 1 || NULL
select id,k,c,pad from test1 where 1 XOR 1
select id,k,c,pad from test1 where 1 XOR 0
select id,k,c,pad from test1 where 1 XOR NULL
select id,k,c,pad from test1 where 1 XOR 1 XOR 1
#
#clauses(order by/group by/having)
#
drop table if exists test1
create table test1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test1 (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test1 values(3,3,'','string'),(4,4,'a','b'),(5,3,'','string'),(6,4,'a','b'),(7,3,'','string'),(8,4,'a','b'),(9,4,'a','b')
select count(*) from test1 group by R_COMMENT,1+1
select count(*) from test1 group by R_COMMENT asc
select count(*) from test1 group by R_COMMENT desc
select count(*) from test1 group by 1+1
select count(*) from test1 group by R_COMMENT,R_NAME order by null
select count(*) al from test1 group by R_COMMENT,R_NAME order by al asc
select count(*) from test1 group by 1+1,1*5 order by 2*2 asc
select count(*) from test1 group by R_COMMENT,R_NAME having count(*) order by 1+1
select count(*) from test1 group by R_COMMENT,R_NAME having count(*) order by 1+1 limit 2
select count(*) from test1 where id<8 group by R_COMMENT,R_NAME having count(*) order by 1+1 asc  limit 2 offset 2
select count(*) from test1 where id<8 group by R_COMMENT,R_NAME having count(*) order by 1+1 limit 2 ,2
select R_comment,count(*) a from test1 group by R_comment having a>1+1
select R_comment,count(*) a from test1 group by R_comment having count(*)>1+1
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by R_COMMENT+1 asc
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by R_COMMENT,1+1
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by id,R_COMMENT
#
#special_scene(null,Accuracy)
#
drop table if exists test1
create table test1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test1 (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test1 values(3,3,'','string'),(4,4,'a','b'),(5,3,'','string'),(6,4,'a','b'),(7,3,'','string'),(8,4,'a','b'),(9,4,'a','b')
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by R_comment
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 where id =2 order by R_comment
select count(*),R_COMMENT from test1 group by R_comment
select count(*),R_COMMENT from test1 where id=2 group by R_comment
select count(R_COMMENT) from test1
select count(R_COMMENT) from test1 where id=2
select sum(R_COMMENT) from test1
select sum(R_COMMENT) from test1 where id=2
select distinct R_COMMENT from test1
select distinct R_COMMENT from test1 where id=2
select avg(R_REGIONKEY) from test1
drop table if exists test1
create table test1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT date)
insert into test1 (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test1 values (2,1, 'a','1983-01-02')
insert into test1 values(3,3,'','1983-01-01'),(4,4,'a1','1967-09-12'),(5,3,'b1','1776-04-30'),(6,4,'b','1963-12-09')
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by R_COMMENT
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by R_NAME
select R_NAME,max(R_REGIONKEY) from test1 group by R_name
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by id limit 2,3
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by id limit 1,1
select id,R_REGIONKEY,R_NAME,R_COMMENT from test1 order by id limit 1,2
select id,R_REGIONKEY from test1 order by id,R_REGIONKEY limit 2,3
select id,R_REGIONKEY from test1 group by id,R_REGIONKEY limit 2,3
select id,R_REGIONKEY from test1 group by id,R_REGIONKEY order by id,R_REGIONKEY limit 2,3
#
#clear tables
#
drop table if exists test1