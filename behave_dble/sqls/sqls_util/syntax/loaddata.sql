#!default_db:schema1
#!share_conn
drop table if exists test1
create table test1(id int, c1 char(30), c2 bool, c3 binary, c4 float,c5 datetime)ENGINE=InnoDB DEFAULT CHARSET=utf8
#!share_conn , empty in test1.txt
load data local infile "./test1.txt" into table test1 fields terminated by ',' lines terminated by '\n'
select id,c1,c2,c3,c4,c5 from test1 order by id
truncate table test1
load data infile "./test1.txt" into table test1 fields terminated by ',' lines terminated by '\n'
select id,c1,c2,c3,c4,c5 from test1 order by id
truncate table test1
#!share_conn , 1 empty line in test2.txt
load data local infile "./test2.txt" into table test1 fields terminated by ',' lines terminated by '\n'
select id,c1,c2,c3,c4,c5 from test1 order by id
truncate table test1
load data infile "./test2.txt" into table test1 fields terminated by ',' lines terminated by '\n'
select id,c1,c2,c3,c4,c5 from test1 order by id
truncate table test1
#!share_conn , multile data lines in test3.txt
load data local infile "./test3.txt" into table test1 character set 'utf8' fields terminated by ',' lines terminated by '\n'
select id,c1,c2,c3,c4,c5 from test1 order by id
truncate table test1
load data infile "./test3.txt" into table test1 character set 'utf8' fields terminated by ',' lines terminated by '\n'
select id,c1,c2,c3,c4,c5 from test1 order by id
##github #774
drop table if exists test1
create table test1(id int, c1 char(5), c2 char(5), c3 char(5));
load data infile "./test4.txt" replace into table test1 fields terminated by ',' lines terminated by '\n' (id,c1) set c2='c2', c3='c3';
select id,c1,c2,c3 from test1;
##more than 10000+ line in test.txt
load data infile "./test.txt" into table test1 character set 'utf8' fields terminated by ',' lines terminated by '\n'
select count(*) from test1 order by id
update test1 set c2=id
##github #768, column type int lacked fills 0 not null
#drop table if exists test1
#create table test1(id int, c1 int);
#load data infile "./test5.txt" into table test1 fields terminated by ',' lines terminated by '\n';
#select id,c1 from test1;

##lack column or/and lack terminated
#-- drop table if exists test1
#-- #!multiline
#-- CREATE TABLE `test1` (
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
#-- load data local infile "./test5.txt" into table test1 character set 'utf8' fields terminated by ',' lines terminated by '\n'
#-- select id,c1,c2,c3,c4,c5 from test1 order by id
#-- truncate table test1
#-- load data infile "./test5.txt" into table test1 character set 'utf8' fields terminated by ',' lines terminated by '\n'
#-- select id,c1,c2,c3,c4,c5 from test1 order by id