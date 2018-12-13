#!share_conn
drop table if exists aly_test
create table aly_test(id int, c1 char(30), c2 bool, c3 binary, c4 float,c5 datetime)ENGINE=InnoDB DEFAULT CHARSET=utf8
#!share_conn , empty in test1.txt
load data local infile "./test1.txt" into table aly_test fields terminated by ',' lines terminated by '\n'
select * from aly_test order by id
truncate table aly_test
load data infile "./test1.txt" into table aly_test fields terminated by ',' lines terminated by '\n'
select * from aly_test order by id
truncate table aly_test
#!share_conn , 1 empty line in test2.txt
load data local infile "./test2.txt" into table aly_test fields terminated by ',' lines terminated by '\n'
select * from aly_test order by id
truncate table aly_test
load data infile "./test2.txt" into table aly_test fields terminated by ',' lines terminated by '\n'
select * from aly_test order by id
truncate table aly_test
#!share_conn , multile data lines in test3.txt
load data local infile "./test3.txt" into table aly_test character set 'utf8' fields terminated by ',' lines terminated by '\n'
select * from aly_test order by id
truncate table aly_test
load data infile "./test3.txt" into table aly_test character set 'utf8' fields terminated by ',' lines terminated by '\n'
select * from aly_test order by id
##github #774
drop table if exists aly_test
create table aly_test(id int, c1 char(5), c2 char(5), c3 char(5));
load data infile "./test4.txt" replace into table aly_test fields terminated by ',' lines terminated by '\n' (id,c1) set c2='c2', c3='c3';
select * from aly_test;
##github #768, column type int lacked fills 0 not null
drop table if exists aly_test
create table aly_test(id int, c1 int);
load data infile "./test5.txt" into table aly_test fields terminated by ',' lines terminated by '\n';
select * from aly_test;

##lack column or/and lack terminated
#-- drop table if exists aly_test
#-- #!multiline
#-- CREATE TABLE `aly_test` (
#--   `c1` char(2) DEFAULT NULL,
#--   `id` int(11) DEFAULT NULL,
#--   `c2` varchar(5) DEFAULT NULL,
#--   `c3` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
#--   `c4` date DEFAULT NULL,
#--   `c5` time DEFAULT NULL,
#--   `c6` tinyint(1) DEFAULT NULL,
#--   `c7` bit(1) DEFAULT NULL
#-- ) ENGINE=InnoDB DEFAULT CHARSET=latin1
#-- #end multiline
#-- load data local infile "./test5.txt" into table aly_test character set 'utf8' fields terminated by ',' lines terminated by '\n'
#-- select * from aly_test order by id
#-- truncate table aly_test
#-- load data infile "./test5.txt" into table aly_test character set 'utf8' fields terminated by ',' lines terminated by '\n'
#-- select * from aly_test order by id