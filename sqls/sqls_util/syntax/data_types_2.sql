#!default_db:schema1
#
#CHAR[(length)] [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data char)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,0)
INSERT INTO test1 ( id,data) VALUES (2,10)
INSERT INTO test1 ( id,data) VALUES (2,'a')
INSERT INTO test1 ( id,data) VALUES (3,'aaaaaaaaaaaa,aaaaaaaaaaaa_aaaaaaaaa%%aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa*aa')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data char BINARY)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,0)
INSERT INTO test1 ( id,data) VALUES (2,10)
INSERT INTO test1 ( id,data) VALUES (2,'a')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data char(5))
desc test1
INSERT INTO test1 ( id,data) VALUES (1,123456)
INSERT INTO test1 ( id,data) VALUES (1,'abcdef')
INSERT INTO test1 ( id,data) VALUES (1,'abcde')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data char(255) CHARACTER SET 'utf8' COLLATE utf8_bin )
desc test1
INSERT INTO test1 ( id,data) VALUES (111,''),(112,'a'),(113,0),(114,'1_23'),(115,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data char(255))
desc test1
INSERT INTO test1 ( id,data) VALUES (111,''),(112,'a'),(113,0),(114,'1_23'),(115,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#VARCHAR(length) [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data varchar(0))
INSERT INTO test1 ( id,data) VALUES (1,123456)
INSERT INTO test1 ( id,data) VALUES (1,'abcdef')
INSERT INTO test1 ( id,data) VALUES (1,'abcde')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data varchar(0) BINARY)
INSERT INTO test1 ( id,data) VALUES (1,123456)
INSERT INTO test1 ( id,data) VALUES (1,'abcdef')
INSERT INTO test1 ( id,data) VALUES (1,'abcde')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data varchar(30))
INSERT INTO test1 ( id,data) VALUES (1,123456)
INSERT INTO test1 ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdefg')
INSERT INTO test1 ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdef')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data varchar(30) CHARACTER SET 'utf8' COLLATE utf8_bin )
INSERT INTO test1 ( id,data) VALUES (1,123456)
INSERT INTO test1 ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdefg')
INSERT INTO test1 ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdef')
SELECT * FROM test1
drop table if exists test1
create table test1(id int(16) not null primary key auto_increment, b varchar(255))
insert into test1 values(1, 'a\'b')
insert into test1 values(2, 'a\"b')
insert into test1 values(3, 'a\0b')
insert into test1 values(4, 'a\bb')
insert into test1 values(5, 'a\nb')
insert into test1 values(6, 'a\rb')
insert into test1 values(7, 'a\test1')
insert into test1 values(8, 'a\Zb')
insert into test1 values(9, 'a\\b')
insert into test1 values(10, 'a\%b')
insert into test1 values(11, 'a\_b')
select data from test1
#
#DATE
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data date)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'201411-11')
INSERT INTO test1 ( id,data) VALUES (2,'2014/11/11')
INSERT INTO test1 ( id,data) VALUES (3,'20141111')
INSERT INTO test1 ( id,data) VALUES (4,'2014-11-11 09:59:59')
INSERT INTO test1 ( id,data) VALUES (5,'2014-11-11')
INSERT INTO test1 ( id,data) VALUES (6,'aaaa-01-01')
INSERT INTO test1 ( id,data) VALUES (7,'999-01-01')
INSERT INTO test1 ( id,data) VALUES (8,'1000-01-00')
INSERT INTO test1 ( id,data) VALUES (9,'10000-01-01')
INSERT INTO test1 ( id,data) VALUES (10,'9999-01-100')
INSERT INTO test1 ( id,data) VALUES (11,'1000-01-01')
INSERT INTO test1 ( id,data) VALUES (12,'9999-12-31')
INSERT INTO test1( id,date) VALUES (13,'20170201')
INSERT INTO test1( id,date) VALUES (14,'170202')
SELECT * FROM test1
#
#TIME[(fsp)]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data time)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'201411-11')
INSERT INTO test1 ( id,data) VALUES (2,'000:00:00')
INSERT INTO test1 ( id,data) VALUES (2,'00000')
INSERT INTO test1 ( id,data) VALUES (3,'121212')
INSERT INTO test1 ( id,data) VALUES (4,'2014-11-11 09:59:59')
INSERT INTO test1 ( id,data) VALUES (5,'23:59:59')
INSERT INTO test1 ( id,data) VALUES (6,'24:00:00')
INSERT INTO test1 ( id,data) VALUES (7,'24:00:01')
INSERT INTO test1 ( id,data) VALUES (8,'00:00:00')
INSERT INTO test1 ( id,data) VALUES (9,'23:59:59')
SELECT * FROM test1
#
#TIMESTAMP[(fsp)]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data timestamp)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'1970-01-01 00:00:01'),(2,'2038-01-19 03:14:07')
SELECT * FROM test1
#
#DATETIME[(fsp)]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data datetime)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'1000-01-01 00:00:00'),(2,'9999-12-31 23:59:59')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE test1( id int,data1 time(2), data2 datetime(2), data3 timestamp(2))
desc test1
INSERT INTO test1 VALUES(1,'17:51:04.777', '2014-09-08 17:51:04.777', '2014-09-08 17:51:04.777')
SELECT * FROM test1
#
#YEAR
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data year)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,1900)
INSERT INTO test1 ( id,data) VALUES (2,2156)
INSERT INTO test1 ( id,data) VALUES (3,'2038-01-19 03:14:07')
INSERT INTO test1 ( id,data) VALUES (4,1901),(5,2156),(6,0000)
SELECT * FROM test1
#TIMESTAMP
drop table if exists test1
create table test1(id int(16) not null primary key auto_increment, b TIMESTAMP)
insert into test1 values(1, '2012-12-31 11:30:45')
insert into test1 values(2, TIMESTAMP'1970-12-31 11:30:45')
insert into test1 values(3, TIMESTAMP '2037^12^31 11+30+45')
insert into test1 values(4, TIMESTAMP'2012/12/31 11*30*45')
insert into test1 values(5, TIMESTAMP'2012@12@31 11^30^45')
insert into test1 values(6, '2012-2-1 2:3:4')
#durid bug
#insert into test1 values(7, {ts'2012-2-1 2:3:4'})
#insert into test1 values(8, {ts'2012+12+31 11+30+45'})
#insert into test1 values(9, {ts '2012/2/1 6*5*8'})
#insert into test1 values(10, {ts  '1970@12@31 11^30^45'})
#insert into test1 values(11, {ts '2037/2/1T6*5*8'})
#insert into test1 values(12, {ts '2012@12@31T11^30^45'})
insert into test1 values(13, TIMESTAMP'20121231113045')
insert into test1 values(14, TIMESTAMP'121231113045')
#insert into test1 values(15, {ts'20121231113045'})
#insert into test1 values(16, {ts'121231113045'})
insert into test1 values(17, 19830905132800)
insert into test1 values(18, 830905132800)
insert into test1 values(19, 20160302)
insert into test1 values(20, 161214)
select b from test1
drop table if exists test1
create table test1(id int(16) not null primary key auto_increment, b DATE)
insert into test1 values(1, '2012^12^31')
insert into test1 values(2, DATE '2012-12-31')
#insert into test1 values(3, {d'2012@12@31'})
#insert into test1 values(4, {d '2012`12`31'})
insert into test1 values(5, DATE'20381231')
Insert into test1 values(6, DATE'701231')
insert into test1 values(7, DATE'991231')
insert into test1 values(8, DATE'001231')
insert into test1 values(9, DATE'691231')
#durid bug
#insert into test1 values(10, {d'19701231'})
#insert into test1 values(11, {d'00381231'})
#insert into test1 values(12, {d'991231'})
insert into test1 values(13, 371231)
insert into test1 values(14, 19121231)
select b from test1
drop table if exists test1
create table test1(id int(16) not null primary key auto_increment, b TIME)
insert into test1 values(1, '0 10:11:12')
insert into test1 values(2, '34 10:11:12')
insert into test1 values(3, '34 10:11')
insert into test1 values(4, '34 10')
insert into test1 values(5, '10')
insert into test1 values(20, '0 10:11:12.100005')
insert into test1 values(21, '0 3:5:2')
insert into test1 values(22, '0 03:05:02')
#insert into test1 values(6, TIME'0 10:11:12')
#insert into test1 values(7, TIME'34 10:11:12')
#insert into test1 values(8, TIME'34 10:11')
#insert into test1 values(9, TIME'34 10')
#insert into test1 values(10, TIME'10')
#insert into test1 values(15, TIME'101112')
#insert into test1 values(11, {test1'0 10:11:12'})
#insert into test1 values(12, {test1'34 10:11:12'})
#insert into test1 values(13, {test1'34 10:11'})
#insert into test1 values(14, {test1'34 10'})
#insert into test1 values(16, {test1'101112'})
insert into test1 values(17, 101112)
insert into test1 values(18, 1011)
insert into test1 values(19, 10)
select b from test1
#boolean
drop table if exists test1
create table test1(a int(16) not null primary key auto_increment, b BOOL)
insert into test1 values(1,TRUE)
insert into test1 values(2,True)
insert into test1 values(3,true)
insert into test1 values(4,trUe)
insert into test1 values(5,FALSE)
insert into test1 values(6,False)
insert into test1 values(7,fAlSe)
insert into test1 values(8,false)
insert into test1 values(9,0)
insert into test1 values(10,1)
select b from test1
#
#BINARY[(length)]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data binary)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'a')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data binary(5))
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'abcdef')
INSERT INTO test1 ( id,data) VALUES (2,'abcde')
SELECT * FROM test1
#
#VARBINARY(length)
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data varbinary(5))
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'abcdef')
INSERT INTO test1 ( id,data) VALUES (1,'abcde')
SELECT * FROM test1
#
#TINYBLOB
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data tinyblob)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#BLOB
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data blob)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a')
SELECT * FROM test1
#
#MEDIUMBLOB
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data mediumblob)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#LONGBLOB
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data longblob)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#TINYTEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data tinytext CHARACTER SET 'utf8' COLLATE utf8_bin)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data tinytext)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data tinytext binary)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#TEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data text)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data text CHARACTER SET 'utf8' COLLATE utf8_bin )
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data text binary)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#MEDIUMTEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data mediumtext)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1 ORDER BY id
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data mediumtext CHARACTER SET 'utf8' COLLATE utf8_bin )
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1 ORDER BY id
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data mediumtext)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#LONGTEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data longtext)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data longtext CHARACTER SET 'utf8' COLLATE utf8_bin )
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data longtext binary)
desc test1
INSERT INTO test1 ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM test1
#
#ENUM(value1,value2,value3,...)
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data enum('enum1','enum2','test_%%%00','enum3','abcd_007'))
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'enum1'),(2,'test_%%%00'),(3,'abcd_007')
SELECT * FROM test1
#
#SET(value1,value2,value3,...)
DROP TABLE IF EXISTS  test1
CREATE TABLE  test1( id int,data set('enum1','enum2','test_%%%00','enum3','abcd_007'))
desc test1
INSERT INTO test1 ( id,data) VALUES (1,'enum1'),(2,'test_%%%00'),(3,'abcd_007')
SELECT * FROM test1
#
#JSON
DROP TABLE IF EXISTS  test1
CREATE TABLE test1( id int,data json)
INSERT INTO test1 VALUES(1,'["abc", 10, null, true, false]')
INSERT INTO test1 VALUES(1,'{"k1": "value", "k2": 10}')
INSERT INTO test1 VALUES(1,'["12:18:29.000000", "2015-07-29", "2015-07-29 12:18:29.000000"]')
SELECT * FROM test1
#
#spatial_type
DROP TABLE IF EXISTS  test1
CREATE TABLE test1( id int,data GEOMETRY)
INSERT INTO test1 VALUES(1,POINT(15,20))
SELECT * FROM test1
#
#
#set character and collation
DROP TABLE IF EXISTS test1
CREATE TABLE test1(id int, data varchar(50)character set ascii)
SHOW CREATE TABLE test1
INSERT INTO test1 VALUES (1,'a'),(2,'\'')
SELECT * FROM test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50))character set utf8
SHOW CREATE TABLE test1
INSERT INTO test1 VALUES (1,'a'),(2,'\'')
SELECT * FROM test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50)character set ascii)character set = 'utf8'
SHOW CREATE TABLE test1
INSERT INTO test1 VALUES (1,'a'),(2,'\'')
SELECT * FROM test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50)character set ascii)character set = 'utf8' collate utf8_bin
SHOW CREATE TABLE test1
INSERT INTO test1 VALUES (1,'a'),(2,'\'')
SELECT * FROM test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50)character set big5)
SHOW CREATE TABLE test1
INSERT INTO test1 VALUES (1,'a'),(2,'\'')
DROP TABLE test1
CREATE TABLE test1(id int, data1 varchar(50)character set dec8, data2 varchar(50)character set cp850, data3 varchar(50)character set hp8, data4 varchar(50)character set koi8r)
INSERT INTO test1 VALUES (1,'a','b','c','d')
SELECT * FROM test1
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data1 varchar(50) character set euckr, data2 varchar(50) character set swe7, data3 varchar(50) character set latin2, data4 varchar(50) character set ujis, data5 varchar(50) character set sjis, data6 varchar(50) character set hebrew, data7 varchar(50) character set tis620, data8 varchar(50) character set koi8u, data9 varchar(50) character set cp1250,data10 varchar(50) character set cp866)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data1 varchar(50) character set keybcs2, data2 varchar(50) character set macce, data3 varchar(50) character set macroman, data4 varchar(50) character set cp852, data5 varchar(50) character set cp1251, data6 varchar(50) character set cp1256, data7 varchar(50) character set cp1257, data8 varchar(50) character set geostd8, data9 varchar(50) character set cp932,data10 varchar(50) character set eucjpms)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set latin1)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set latin1 collate latin1_swedish_ci)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set latin1 collate latin1_bin )
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set gb2312)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set gbk)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set gbk collate gbk_chinese_ci )
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set gbk collate gbk_bin)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set latin5)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf8)
INSERT INTO test1 VALUES (1,'a'),(2,'\''),(3,'\test1'),(4,NULL)
SELECT * FROM test1 where data = 'a'
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf8 collate utf8_bin)
INSERT INTO test1 VALUES (1,'a'),(2,'\''),(3,'\test1'),(4,NULL)
SELECT * FROM test1 where data = 'a'
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf8 collate utf8_unicode_ci)
INSERT INTO test1 VALUES (1,'a'),(2,'\''),(3,'\test1'),(4,NULL)
SELECT * FROM test1 where data = 'a'
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf8mb4)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set latin7)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf16)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf16le)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set utf32)
SHOW CREATE TABLE test1
DROP TABLE test1
CREATE TABLE test1(id int, data varchar(50) character set gb18030)
SHOW CREATE TABLE test1
#
#clear tables
#
DROP TABLE IF EXISTS test1