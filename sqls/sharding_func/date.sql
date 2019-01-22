drop table if exists date_table
create table  date_table(data int,id date)
desc date_table
insert into date_table (data,id) values (1,'201411-11')
insert into date_table (data,id) values (2,'2014/11/11')
insert into date_table (data,id) values (3,'20141111')
insert into date_table (data,id) values (4,'2014-11-11 09:59:59')
insert into date_table (data,id) values (5,'2014-11-11')
insert into date_table (data,id) values (6,'aaaa-01-01')
insert into date_table (data,id) values (7,'999-01-01')
insert into date_table (data,id) values (8,'1000-01-00')
insert into date_table (data,id) values (9,'10000-01-01')
insert into date_table (data,id) values (10,'9999-01-100')
insert into date_table (data,id) values (11,'1000-01-01')
insert into date_table (data,id) values (12,'9999-12-31')
select * from date_table order by data
#==========id is date_columns table insert sql==========
drop table if exists date_table
create table date_table(data int,id date)
insert into date_table values (0,'1000-01-01')
insert into date_table values (1,'9999-12-31')
insert into date_table values (2,'1900-00-00')
insert into date_table values (3,'1900-01-01')
insert into date_table values (4,'')
insert into date_table values (5,0)
insert into date_table values (6,NULL)
#==========id is time_columns table insert sql==========
drop table if exists date_table
create table date_table(data int,id time)
insert into date_table values (0,'-838:59:59')
insert into date_table values (1,'838:59:59')
insert into date_table values (2,'12:12:12')
insert into date_table values (3,'-12:12:12')
insert into date_table values (4,'')
insert into date_table values (5,0)
insert into date_table values (6,NULL)
#==========id is timestamp_columns table insert sql==========
drop table if exists date_table
create table date_table(data int,id timestamp)
insert into date_table values (0,'1970-01-01 08:00:01')
insert into date_table values (1,'2038-01-19 11:14:07')
insert into date_table values (2,'2015-08-12 14:57:05')
insert into date_table values (3,now())
insert into date_table values (4,'')
insert into date_table values (5,0)
insert into date_table values (6,NULL)
#==========id is datetime_columns table insert sql==========
drop table if exists date_table
create table date_table(data int,id datetime)
insert into date_table values (0,'1000-01-01 00:00:00')
insert into date_table values (1,'9999-12-31 23:59:59')
insert into date_table values (2,'1000-01-01 00:00:00.000000')
insert into date_table values (3,'9999-12-31 23:59:59.999999')
insert into date_table values (4,'1900-00-00 00:00:00')
insert into date_table values (5,'1900-03-02 04:06:09')
insert into date_table values (6,'')
insert into date_table values (7,0)
insert into date_table values (8,NULL)
#==========id is year4_columns table insert sql==========
drop table if exists date_table
create table date_table(data int,id year(4))
insert into date_table values (0,1901)
insert into date_table values (1,2155)
insert into date_table values (2,0000)
insert into date_table values (3,'00')
insert into date_table values (4,107)
insert into date_table values (5,'')
insert into date_table values (6,0)
insert into date_table values (7,NULL)
drop table if exists date_table