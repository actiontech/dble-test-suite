#!share_conn
drop table if exists a_test
create table a_test(id int, c1 char(20), c2 bool, c3 binary, c4 float,c5 datetime)ENGINE=InnoDB DEFAULT CHARSET=utf8
#!share_conn , empty in test1.txt
#load data local infile "./test1.txt" into table a_test character set utf8 fields terminated by',' lines terminated by '\n'
load data local infile "./test1.txt" into table a_test fields terminated by',' lines terminated by '\n'
select * from a_test order by id
truncate table a_test
#load data infile "./test1.txt" into table a_test character set utf8 fields terminated by',' lines terminated by '\n'
load data infile "./test1.txt" into table a_test fields terminated by',' lines terminated by '\n'
select * from a_test order by id
truncate table a_test
#!share_conn , 1 empty line in test2.txt
#load data local infile "./test2.txt" into table a_test character set utf8 fields terminated by',' lines terminated by '\n'
load data local infile "./test2.txt" into table a_test fields terminated by',' lines terminated by '\n'
select * from a_test order by id
truncate table a_test
#load data infile "./test2.txt" into table a_test character set utf8 fields terminated by',' lines terminated by '\n'
load data infile "./test2.txt" into table a_test fields terminated by',' lines terminated by '\n'
select * from a_test order by id
truncate table a_test
#!share_conn , multile data lines in test2.txt
#load data local infile "./test3.txt" into table a_test character set utf8 fields terminated by',' lines terminated by '\n'
load data local infile "./test3.txt" into table a_test fields terminated by',' lines terminated by '\n'
select * from a_test order by id
truncate table a_test
#load data infile "./test3.txt" into table a_test character set utf8 fields terminated by',' lines terminated by '\n'
load data infile "./test3.txt" into table a_test fields terminated by',' lines terminated by '\n'
select * from a_test order by id