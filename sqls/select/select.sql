drop table if exists test_shard
CREATE TABLE test_shard(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
insert into test_shard values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18)
insert into test_shard(id,k,pad) values(19,19,19)
drop table if exists testdb.tb_test
CREATE TABLE testdb.tb_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))DEFAULT CHARSET=UTF8
insert into testdb.tb_test values(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15)
#
#select select_expr
#
select 1+1
SELECT ABS(2)
select * from test_shard
select avg(pad) from test_shard
select BIT_AND(pad) from test_shard
select BIT_OR(pad) from test_shard
select BIT_XOR(pad) from test_shard
select count(pad) from test_shard
select count(distinct pad) from test_shard
select group_concat(pad) from test_shard
select max(pad) from test_shard
select min(pad) from test_shard
select std(pad) from test_shard
select stddev(pad) from test_shard
select stddev_pop(pad) from test_shard
select stddev_samp(pad) from test_shard
select sum(pad) from test_shard
select var_pop(pad) from test_shard
select var_samp(pad) from test_shard
select variance(pad) from test_shard
select test_shard.pad from test_shard
select pad t1 from test_shard
select pad as t1 from test_shard
select test_shard.pad as t1 from test_shard
select test_shard.pad t1 from test_shard
select k,pad from test_shard
select !1 from test_shard;
select !id from test_shard;
#select !(select pad from sbtest2 where id=1) from test_shard;
select id=1 from test_shard;
select 1=id from test_shard;
select id=BIT_COUNT(29) from test_shard;
#select pad=(select pad from sbtest2 where id=1) from test_shard;
#
#from table_references
#
select 1+1 from dual
select * from test_shard
select * from test_shard t1
select * from test_shard as t1
select * from mytest.test_shard
select * from testdb.tb_test
#
#where
#
select * from test_shard where pad<10
select * from test_shard where id>(SELECT ABS(2)) order by id
select * from test_shard t1 where t1.pad<5
select * from test_shard where 1;
select * from test_shard where now();
select * from test_shard where id;
select * from test_shard where (select pad from test_shard where id>3 limit 1);
select * from test_shard where !id;
select * from test_shard where 1=id;
#
#group by
#
select avg(id),pad from test_shard group by pad
select BIT_AND(id),pad from test_shard group by pad
select BIT_OR(id),pad from test_shard group by pad
select BIT_XOR(id),pad from test_shard group by pad
select count(id),pad from test_shard group by pad
select count(distinct pad) from test_shard group by pad
select group_concat(id),pad from test_shard group by pad
select max(id),pad from test_shard group by pad
select min(id),pad from test_shard group by pad
select std(id),pad from test_shard group by pad
select stddev(id),pad from test_shard group by pad
select stddev_pop(id),pad from test_shard group by pad
select stddev_samp(id),pad from test_shard group by pad
select sum(id),pad from test_shard group by pad
select var_pop(id),pad from test_shard group by pad
select var_samp(id),pad from test_shard group by pad
select variance(id),pad from test_shard group by pad
select sum(id) from test_shard a group by a.pad
select id ,pad from test_shard group by id
drop table if exists mytest_auto_test1
create table mytest_auto_test1 (id int(11),R_REGIONKEY bigint primary key AUTO_INCREMENT,R_NAME varchar(50),R_COMMENT varchar(50))
insert into mytest_auto_test1(id,R_NAME,R_COMMENT) values(1,1,1),(2,2,2),(3,3,3),(4,4,4)
select count(*) from mytest_auto_test1 group by R_REGIONKEY
select * from test_shard group by id desc
select * from test_shard group by id asc
select pad,count(id) t from test_shard group by pad having t>1
select pad,count(id) t from test_shard group by pad limit 1
select pad,count(id) t from test_shard group by pad order by pad
#########################unsupport now ##########################
##select pad,count(id) t from test_shard group by pad with rollup
#
#having
#
select id,pad from test_shard having pad=(select min(id) from test_shard)
select pad,count(*) a from test_shard group by pad having a>1
select id,pad from test_shard having pad<6
#
#order by
#
select * from test_shard order by null
select * from test_shard order by id desc
select * from test_shard order by id asc
select id t,pad from test_shard order by t
select id,pad from test_shard order by pad
select id,pad from test_shard a order by a.id
select id,pad from test_shard a order by a.pad
#
#limit
#
select * from test_shard order by id limit 1,3
select * from test_shard order by id limit 3
select * from test_shard order by id limit 3 offset 1
#
#select + keyword
#
select all * from test_shard
select distinct pad from test_shard
select Distinctrow * from test_shard
select distinct pad,id from test_shard order by id
select distinct pad,id from test_shard where pad>2 order by id
select distinct pad,id from test_shard group by id,pad
select count(distinct id),pad from test_shard group by pad
select distinct SQL_BIG_RESULT pad from test_shard
select distinct SQL_BIG_RESULT pad from test_shard order by pad
select distinctrow SQL_BIG_RESULT * from test_shard
select distinctrow SQL_BIG_RESULT * from test_shard order by id
select SQL_BIG_RESULT count(*),pad from test_shard group by pad
select distinct SQL_SMALL_RESULT pad from test_shard
select distinct SQL_SMALL_RESULT pad from test_shard order by pad
select distinctrow SQL_SMALL_RESULT * from test_shard
select distinctrow SQL_SMALL_RESULT * from test_shard order by id
select SQL_SMALL_RESULT count(*),pad from test_shard group by pad
select SQL_BUFFER_RESULT * from test_shard
select SQL_BUFFER_RESULT * from test_shard order by id
select straight_join * from test_shard
select straight_join * from test_shard order by id
select sql_cache * from test_shard
select sql_cache * from test_shard order by id
select sql_no_cache * from test_shard
select sql_no_cache * from test_shard order by id
select SQL_CALC_FOUND_ROWS * from test_shard order by id
select SQL_CALC_FOUND_ROWS * from test_shard
#
#Operator
#
select * from test_shard where id=1+1
select * from test_shard where id=2*3
select * from test_shard where id=9/3
select * from test_shard where id=12 div 4
select * from test_shard where id=10-4
select * from test_shard where id=1+2*3-9/3+12 div 4
select * from test_shard where id=-3
select * from test_shard where id=6|3
select * from test_shard where id=2&3
select * from test_shard where id=7^3
select * from test_shard where id=1<<2
select * from test_shard where id=4>>2
select * from test_shard where id=5 & ~1
select * from test_shard where id=BIT_COUNT(29)
select * from test_shard where id>=1
select * from test_shard where id<=3
select * from test_shard where id<5
select * from test_shard where id>6
select * from test_shard where id!=7
select * from test_shard where id between 2 and 4
select * from test_shard where id not between 3 and 5
select * from test_shard where id is true
select * from test_shard where id is false
select * from test_shard where id is unknown
select * from test_shard where id is not true
select * from test_shard where id is not false
select * from test_shard where id is not unknown
select * from test_shard where c is not null
select * from test_shard where c is null
select * from test_shard where c like '中'
select * from test_shard where c like '%3'
select * from test_shard where c like 'i%'
select * from test_shard where c like '$%$'
select * from test_shard where c like 'id_'
select * from test_shard where c like '_d3'
select * from test_shard where c like 'i_4'
select * from test_shard where c like '20\%'
select * from test_shard where c like 'a\_1'
select * from test_shard where c not like '中'
select * from test_shard where id<>2
select * from test_shard where id <=>1
select * from test_shard where 1 <=> 1
select * from test_shard where NULL <=> NULL
select * from test_shard where 1 <=> NULL
select * from test_shard where id=@var1 := 1
select * from test_shard where id=COALESCE(2,3)
select * from test_shard where id=COALESCE(null,3)
select * from test_shard where id=GREATEST(2,3,6.4,7,12)
#####################UNsupport now######################
##select * from test_shard where id in(2,3,6.4,7,12)
select * from test_shard where pad in(2,3,6.4,7,12)
select * from test_shard where id not in(2,3)
select * from test_shard where id=INTERVAL(23, 1, 15, 17, 30, 44, 200)
select * from test_shard where id=LEAST(23, 1, 15, 17, 30, 44, 200)
select * from test_shard where id not in(2,3,6.4,7,12)
select * from test_shard where pad=strcmp('test','test')
select * from test_shard where pad=strcmp('test1','test')
select * from test_shard where pad=strcmp('test','test1')
select * from test_shard where c regexp '.*'
select * from test_shard where c regexp 'new\\*.\\*line'
select * from test_shard where c regexp 'A'
select * from test_shard where c regexp BINARY 'A'
select * from test_shard where c regexp '^[a-d]'
select * from test_shard where c not regexp '.*'
select * from test_shard where c rlike '^[a-d]'
select * from test_shard where 1 AND 1
select * from test_shard where 1 AND 0
select * from test_shard where 1 AND NULL
select * from test_shard where 0 AND NULL
select * from test_shard where NULL AND 0
select * from test_shard where 1 && 1
select * from test_shard where NOT 10
select * from test_shard where NOT 0
select * from test_shard where  NOT NULL
select * from test_shard where  ! (1+1)
select * from test_shard where  ! 1+1
select * from test_shard where 1 OR 1
select * from test_shard where 1 OR 0
select * from test_shard where 0 OR 0
select * from test_shard where 0 || NULL
select * from test_shard where 1 || NULL
select * from test_shard where 1 XOR 1
select * from test_shard where 1 XOR 0
select * from test_shard where 1 XOR NULL
select * from test_shard where 1 XOR 1 XOR 1
#
#clauses(order by/group by/having)
#
drop table if exists test_shard
create table test_shard (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_shard (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test_shard (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test_shard values(3,3,'','string'),(4,4,'a','b'),(5,3,'','string'),(6,4,'a','b'),(7,3,'','string'),(8,4,'a','b'),(9,4,'a','b')
select count(*) from test_shard group by R_COMMENT,1+1
select count(*) from test_shard group by R_COMMENT asc
select count(*) from test_shard group by R_COMMENT desc
select count(*) from test_shard group by 1+1
select count(*) from test_shard group by R_COMMENT,R_NAME order by null
select count(*) from test_shard group by R_COMMENT,R_NAME order by R_NAME asc
select count(*) from test_shard group by 1+1,1*5 order by 2*2 asc
select count(*) from test_shard group by R_COMMENT,R_NAME having count(*) order by 1+1
select count(*) from test_shard group by R_COMMENT,R_NAME having count(*) order by 1+1 limit 2
select count(*) from test_shard where id<8 group by R_COMMENT,R_NAME having count(*) order by 1+1 asc  limit 2 offset 2
select count(*) from test_shard where id<8 group by R_COMMENT,R_NAME having count(*) order by 1+1 limit 2 ,2
select R_comment,count(*) a from test_shard group by R_comment having a>1+1
select R_comment,count(*) a from test_shard group by R_comment having count(*)>1+1
select * from test_shard order by R_COMMENT+1 asc
select * from test_shard order by R_COMMENT,1+1
select * from test_shard order by id,R_COMMENT
#
#special_scene(col_name contains null,Accuracy)
#
drop table if exists test_shard
create table test_shard (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test_shard (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test_shard (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test_shard values(3,3,'','string'),(4,4,'a','b'),(5,3,'','string'),(6,4,'a','b'),(7,3,'','string'),(8,4,'a','b'),(9,4,'a','b')
select * from test_shard order by R_comment
select * from test_shard where id =2 order by R_comment
select count(*),R_COMMENT from test_shard group by R_comment
select count(*),R_COMMENT from test_shard where id=2 group by R_comment
select count(R_COMMENT) from test_shard
select count(R_COMMENT) from test_shard where id=2
select sum(R_COMMENT) from test_shard
select sum(R_COMMENT) from test_shard where id=2
select distinct R_COMMENT from test_shard
select distinct R_COMMENT from test_shard where id=2
select avg(R_REGIONKEY) from test_shard
drop table if exists test_shard
create table test_shard (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT date)
insert into test_shard (id,R_REGIONKEY,R_NAME) values (1,1, 'a sting')
insert into test_shard (id,R_REGIONKEY,R_NAME) values (2,1, 'a')
insert into test_shard values(3,3,'','1983-01-01'),(4,4,'a','1967-09-12'),(5,3,'','1776-04-30'),(6,4,'b','1963-12-09')
select * from test_shard order by R_COMMENT
select * from test_shard order by R_NAME
select R_NAME,max(R_REGIONKEY) from test_shard group by R_name
select * from test_shard limit 2,3
select * from test_shard limit 1,1
select * from test_shard limit 1,2
select id,R_REGIONKEY from test_shard order by id,R_REGIONKEY limit 2,3
select id,R_REGIONKEY from test_shard group by id,R_REGIONKEY limit 2,3
select id,R_REGIONKEY from test_shard group by id,R_REGIONKEY order by id,R_REGIONKEY limit 2,3
#
#Rewrite the rules
#
drop table if exists test_shard;
CREATE TABLE test_shard(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8;
insert into test_shard values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18);
insert into test_shard(id,k,pad) values(19,19,19);
select count(distinct pad),sum(distinct id) from test_shard group by pad;
select count(distinct pad,k),sum(distinct id) from test_shard group by pad;
select distinct pad from test_shard limit 4;
select * from test_shard limit 2,3;
select id,pad from test_shard order by id,pad limit 2,3;
select id,pad from test_shard group by id,pad  order by id limit 2,3;
select id,pad,sum(id) from test_shard group by id,pad  order by id,pad limit 2,3;
#
# table_factor
#
drop table if exists test_shard
CREATE TABLE test_shard(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`));
insert into test_shard values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6);
create index pad_index on test_shard(pad)
select * from test_shard t use index();
select * from test_shard t use key();
select * from test_shard use index(k_1);
select * from test_shard ignore index(k_1);
select * from test_shard force index(k_1);
select * from test_shard use index(pad_index,k_1);
select * from test_shard ignore index(pad_index,k_1);
select * from test_shard force index(pad_index,k_1);
select * from test_shard use key for join(k_1);
select * from test_shard ignore key for join(k_1);
select * from test_shard force key for join(k_1);
select * from test_shard use key for order by(k_1);
select * from test_shard ignore key for order by(k_1);
select * from test_shard force key for order by(k_1);
select count(*) from test_shard use key for group by(k_1);
select count(*) from test_shard ignore key  for group by(k_1);
select count(*) from test_shard force key for group by(k_1);
select * from test_shard use index for join(pad_index,k_1);
select * from test_shard ignore index for join(pad_index,k_1);
select * from test_shard force index for join(pad_index,k_1);
select * from test_shard use key(k_1);
select * from test_shard ignore key(k_1);
select * from test_shard force key(k_1);
select * from test_shard t use key(k_1) use index(pad_index) use index();
select * from test_shard t ignore key(k_1) use index(pad_index) use index();
select * from test_shard t ignore key(k_1) ignore index(pad_index) use index();
select * from test_shard t force key(k_1) force index(pad_index) ;
select * from test_shard t ignore key(k_1) force index(pad_index);