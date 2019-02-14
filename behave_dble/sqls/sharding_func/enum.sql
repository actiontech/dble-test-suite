drop table if exists enum_table
create table  enum_table(data int,id int)
insert into enum_table (data,id) values (1,-2147483649)
insert into enum_table (data,id) values (2,2147483648)
insert into enum_table (data,id) values (222,-2147483649),(222,-2147483648),(222,0),(222,2147483647),(222,2147483648)
insert into enum_table (data,id) values (1111,-2147483648),(1112,0),(1113,2147483647)
select * from enum_table order by id
drop table if exists enum_table
create table  enum_table(data int(5),id varchar(10))
insert into enum_table (data,id) values (1111,-2147483648),(1112,0),(1113,2147483647)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id int(5) ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,-10000)
insert into enum_table (data,id) values (111,0),(112,1),(113,10000),(114,100000),(115,-1),(116,-10000)
insert into enum_table (data,id) values (1111,0),(1112,1),(1113,10000),(1114,100000)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id int ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,1),(1113,10000),(1114,100000)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id int(5) UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1,-1)
insert into enum_table (data,id) values (2,4294967296)
insert into enum_table (data,id) values (3,-1),(4,0),(5,4294967296)
insert into enum_table (data,id) values (111,0),(112,1),(113,10),(114,-1000),(115,-10000),(116,-100000),(117,10000),(118,4294967295)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id int UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (111,0),(112,1),(113,10),(114,-1000),(115,-10000),(116,-100000),(117,10000),(118,4294967295)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id INTEGER)
insert into enum_table (data,id) values (1,-2147483649)
insert into enum_table (data,id) values (2,2147483648)
insert into enum_table (data,id) values (222,-2147483649),(222,-2147483648),(222,0),(222,2147483647),(222,2147483648)
insert into enum_table (data,id) values (1111,-2147483648),(1112,0),(1113,2147483647)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id INTEGER(5))
insert into enum_table (data,id) values (1111,-2147483648),(1112,0),(1113,2147483647)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id INTEGER(5) ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,-10000)
insert into enum_table (data,id) values (111,0),(112,1),(113,10000),(114,100000),(115,-1),(116,-10000)
insert into enum_table (data,id) values (1111,0),(1112,1),(1113,10000),(1114,100000)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id INTEGER ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,1),(1113,10000),(1114,100000)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id INTEGER(5) UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1,-1)
insert into enum_table (data,id) values (2,4294967296)
insert into enum_table (data,id) values (3,-1),(4,0),(5,4294967296)
insert into enum_table (data,id) values (1111,0),(1112,1),(1113,10000),(1114,100000)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id INTEGER UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,1),(1113,10000),(1114,100000)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyint)
insert into enum_table (data,id) values (1,-129)
insert into enum_table (data,id) values (2,128)
insert into enum_table (data,id) values (222,-129),(222,-128),(222,0),(222,127),(222,128)
insert into enum_table (data,id) values (1111,-128),(1112,0),(1113,127)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyint(2))
insert into enum_table (data,id) values (1111,-128),(1112,0),(1113,127)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyint(3) ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,-10000)
insert into enum_table (data,id) values (111,0),(112,1),(113,255),(114,256),(1112,2555),(115,-1)
insert into enum_table (data,id) values (1111,0),(1112,255)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyint ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,255)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyint(3) UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,-10000)
insert into enum_table (data,id) values (111,0),(112,1),(113,255),(114,256),(1112,2555),(115,-1)
insert into enum_table (data,id) values (1111,0),(1112,255)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyint UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,255)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id smallint)
insert into enum_table (data,id) values (1,-32769)
insert into enum_table (data,id) values (2,32768)
insert into enum_table (data,id) values (222,-32769),(222,-32768),(222,0),(222,32767),(222,32768)
insert into enum_table (data,id) values (1111,-32768),(1112,0),(1113,32767)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id smallint(3))
insert into enum_table (data,id) values (1111,-32768),(1112,0),(1113,32767)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id smallint(6) ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,-65536)
insert into enum_table (data,id) values (111,0),(112,1),(113,65535),(114,655355),(115,-1)
insert into enum_table (data,id) values (1111,0),(1112,65535)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id smallint ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,65535)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id smallint(6) UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,-65536)
insert into enum_table (data,id) values (111,0),(112,1),(113,65535),(114,655355),(115,-1)
insert into enum_table (data,id) values (1111,0),(1112,65535)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id smallint UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,65535)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumint)
insert into enum_table (data,id) values (1,-8388609)
insert into enum_table (data,id) values (2,8388607)
insert into enum_table (data,id) values (222,-8388609),(222,-8388608),(222,0),(222,8388607),(222,8388608)
insert into enum_table (data,id) values (1111,-8388608),(1112,0),(1113,8388607)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumint(5))
insert into enum_table (data,id) values (1111,-8388608),(1112,0),(1113,8388607)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumint(6) ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,16777216)
insert into enum_table (data,id) values (111,0),(112,1),(113,16777215),(114,16777216),(115,-1)
insert into enum_table (data,id) values (1111,0),(1112,16777215)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumint ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,16777215)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumint(6) UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1,-1),(2,16777216)
insert into enum_table (data,id) values (111,0),(112,1),(113,16777215),(114,16777216),(115,-1)
insert into enum_table (data,id) values (1111,0),(1112,16777215)
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumint UNSIGNED ZEROFILL)
insert into enum_table (data,id) values (1111,0),(1112,16777215)
select * from enum_table order by data
drop table if exists enum_table
drop table if exists enum_table
create table  enum_table(data int,id char)
desc enum_table
insert into enum_table (data,id) values (1,0)
insert into enum_table (data,id) values (2,10)
insert into enum_table (data,id) values (2,'a')
insert into enum_table (data,id) values (3,'aaaaaaaaaaaa,aaaaaaaaaaaa_aaaaaaaaa%%aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa*aa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id char(5))
desc enum_table
insert into enum_table (data,id) values (1,123456)
insert into enum_table (data,id) values (1,'abcdef')
insert into enum_table (data,id) values (1,'abcde')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id char(255))
desc enum_table
insert into enum_table (data,id) values (111,''),(112,'a'),(113,0),(114,'1_23'),(115,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id varchar(0))
insert into enum_table (data,id) values (1,123456)
insert into enum_table (data,id) values (1,'abcdef')
insert into enum_table (data,id) values (1,'abcde')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id varchar(30))
insert into enum_table (data,id) values (1,123456)
insert into enum_table (data,id) values (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdefg')
insert into enum_table (data,id) values (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdef')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id binary)
desc enum_table
insert into enum_table (data,id) values (1,'a')
select hex(id),data='a',id='a',id='a\0\0' from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id binary(5))
desc enum_table
insert into enum_table (data,id) values (1,'abcdef')
insert into enum_table (data,id) values (2,'abcde')
select * from enum_table order by data
select hex(id),data='abcde',id='abcde',id='a' from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id varbinary(5))
desc enum_table
insert into enum_table (data,id) values (1,'abcdef')
insert into enum_table (data,id) values (1,'abcde')
select hex(id),data='abcde',id='abcde',id='a' from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinyblob)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id blob)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumblob)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id longblob)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinytext)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id tinytext binary)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
select hex(id),data='abc',id='abc',id='a\0\0' from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id text)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id text binary)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
select hex(id),data='abc',id='abc',id='a\0\0' from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumtext)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id mediumtext)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
select hex(id),data='abc',id='abc',id='a\0\0' from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id longtext)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
drop table if exists enum_table
create table  enum_table(data int,id longtext binary)
desc enum_table
insert into enum_table (data,id) values (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
select * from enum_table order by data
select hex(id),data='abc',id='abc',id='a\0\0' from enum_table order by data
drop table if exists enum_table
create table enum_table(id enum('x-small','small','medium'),data int)
insert into enum_table (id,data) values ('small',1),('medium',2)
select * from enum_table order by data
drop table if exists enum_table


