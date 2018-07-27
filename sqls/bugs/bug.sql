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