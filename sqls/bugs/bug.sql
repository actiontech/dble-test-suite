#github issue #599
drop table if exists a_two;
CREATE TABLE a_two (id int(11) NOT NULL,c_flag char(255) DEFAULT NULL,c_decimal decimal(16,4) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
SELECT a.id, sum(a.c_decimal) AS c_decimal FROM a_two a GROUP BY a.id HAVING sum(a.c_decimal) != 0;
#github issue #600
drop table if exists test1;
drop table if exists test2;
CREATE TABLE test1 (id bigint(11) NOT NULL,c_char char(255) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE test2 (id bigint(11) NOT NULL,c_char char(255) DEFAULT NULL,PRIMARY KEY (id)) ENGINE=InnoDB DEFAULT CHARSET=utf8;
insert into test1 values(1,'1');
insert into test1(id) values(2);
insert into test2 values(1,'1');
insert into test2(id) values(2);
select * from test1 a inner join test2 b on a.c_char =b.c_char order by a.id;
select * from test1 a right join test2 b on a.c_char =b.c_char order by a.id;
select * from test1 a left join test2 b on a.c_char =b.c_char order by a.id;
#case from gonghang
drop table if exists a_test;
drop table if exists a_order;
create table a_test(id int, trancode varchar(20), RETCODE char(2), OAPP varchar(20));
create table a_order(id int, trancode varchar(20), RETCODE char(2), OAPP varchar(20));
#!multiline
SELECT COUNT(*) FROM (
     select test1.*
     from mytest.a_test test1
     where test1.trancode = 'ATS000010CHGEBUSSPTBNK'
     AND test1.RETCODE = '0'
     AND test1.OAPP != 'F-CLMS'

     UNION

     SELECT test2.*
     FROM mytest.a_order test2
     WHERE test2.trancode = 'ATS000008QRYBUSSPTGIFTLIST'
     AND test2.RETCODE = '0'
     AND test2.OAPP != 'F-CLMS'
     ) t3;
#end multiline
#github issue #535
drop table if exists test_global;
drop table if exists global_table2;
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8;
CREATE TABLE global_table2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8;
insert into test_global values(1,1,'test中id为1',1),(2,2,'test_2',2),(3,3,'test中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6);
insert into global_table2 values(1,1,'order中id为1',1),(2,2,'test_2',2),(3,3,'order中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1);
(select a.id,a.t_id,a.name,a.pad from test_global a where a.pad=1) union (select c.id,c.o_id,c.name,c.pad from global_table2 c where c.pad=1) order by id limit 2;