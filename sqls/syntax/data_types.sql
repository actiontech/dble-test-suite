#!share_conn
#String Literals
select _latin1'a string'
#select _latin1"a string" COLLATE latin1_danish_ci
select _latin1'a string' COLLATE latin1_danish_ci
select _utf8'a' ' ' 'string'
#select 'a string' COLLATE utf8_general_ci
select 'a\'b', 'a\"b', 'a\0b', 'a\bb', 'a\nb', 'a\rb', 'a\tb', 'a\Zb', 'a\\b', 'a\%b', 'a\_b'
drop table if exists ta
create table ta(id int(16) not null primary key auto_increment, b varchar(255))
insert into ta values(1, 'a\'b')
insert into ta values(2, 'a\"b')
insert into ta values(3, 'a\0b')
insert into ta values(4, 'a\bb')
insert into ta values(5, 'a\nb')
insert into ta values(6, 'a\rb')
insert into ta values(7, 'a\tb')
insert into ta values(8, 'a\Zb')
insert into ta values(9, 'a\\b')
insert into ta values(10, 'a\%b')
insert into ta values(11, 'a\_b')
select b from ta
SELECT 'hello', '"hello"', '""hello""', 'hel''lo', '\'hello'
SELECT "hello", "'hello'", "''hello''", "hel""lo", "\"hello"
SELECT 'This\nIs\nFour\nLines'
SELECT 'disappearing\ backslash'
#Number Literals
select 1, .2, 3.4, -5, -.8, -6.78, +9, +.55, +9.10
select 1.2E3, 1.2E-3, -1.2E3, -1.2E-3
#Date and Time Literals
select DATE'2012^12^31'
select DATE '2012-12-31'
#MySQL recognizes those constructions and also the corresponding ODBC syntax
#BUT dble not supported this rule
#select {d'2012@12@31'}
#select {d '2012`12`31'}
#select {d'19701231'}
#select {d'00371231'}
#select {d'121231'}
#select {ts'2012-2-1 2:3:4'}
#select {ts'2012+12+31 11+30+45'}
#select {ts '2012/2/1 6*5*8'}
#select {ts  '2012@12@31 11^30^45'}
#select {ts '2012/2/1T6*5*8'}
#select {ts '2012@12@31T11^30^45'}
#select {ts'20121231113045'}
#select {ts'121231113045'}
#select {t'0 10:11:12'}
#select {t'34 10:11:12'}
select DATE'20131231'
select DATE'00121231'
select DATE'121231'
select TIMESTAMP'2012-12-31 11:30:45'
select TIMESTAMP '2012^12^31 11+30+45'
select TIMESTAMP'2012/12/31 11*30*45'
select TIMESTAMP'2012@12@31 11^30^45'
select TIMESTAMP'20121231113045'
select TIMESTAMP'121231113045'
select TIME'0 10:11:12'
select TIME'34 10:11:12'
drop table if exists ta
create table ta(id int(16) not null primary key auto_increment, b TIMESTAMP)
insert into ta values(1, '2012-12-31 11:30:45')
#insert into ta values(2, TIMESTAMP'1970-12-31 11:30:45')
#insert into ta values(3, TIMESTAMP '2037^12^31 11+30+45')
#insert into ta values(4, TIMESTAMP'2012/12/31 11*30*45')
#insert into ta values(5, TIMESTAMP'2012@12@31 11^30^45')
insert into ta values(6, '2012-2-1 2:3:4')
#insert into ta values(7, {ts'2012-2-1 2:3:4'})
#insert into ta values(8, {ts'2012+12+31 11+30+45'})
#insert into ta values(9, {ts '2012/2/1 6*5*8'})
#insert into ta values(10, {ts  '1970@12@31 11^30^45'})
#insert into ta values(11, {ts '2037/2/1T6*5*8'})
#insert into ta values(12, {ts '2012@12@31T11^30^45'})
#insert into ta values(13, TIMESTAMP'20121231113045')
#insert into ta values(14, TIMESTAMP'121231113045')
#insert into ta values(15, {ts'20121231113045'})
#insert into ta values(16, {ts'121231113045'})
insert into ta values(17, 19830905132800)
insert into ta values(18, 830905132800)
insert into ta values(19, 20160302)
insert into ta values(20, 161214)
select b from ta
drop table if exists tb
create table tb(id int(16) not null primary key auto_increment, b DATE)
insert into tb values(1, '2012^12^31')
#insert into tb values(2, DATE '2012-12-31')
#insert into tb values(3, {d'2012@12@31'})
#insert into tb values(4, {d '2012`12`31'})
#insert into tb values(5, DATE'20381231')
#insert into tb values(6, DATE'701231')
#insert into tb values(7, DATE'991231')
#insert into tb values(8, DATE'001231')
#insert into tb values(9, DATE'691231')
#insert into tb values(10, {d'19701231'})
#insert into tb values(11, {d'00381231'})
#insert into tb values(12, {d'991231'})
insert into tb values(13, 371231)
insert into tb values(14, 19121231)
select b from tb
drop table if exists tc
create table tc(id int(16) not null primary key auto_increment, b TIME)
insert into tc values(1, '0 10:11:12')
insert into tc values(2, '34 10:11:12')
insert into tc values(3, '34 10:11')
insert into tc values(4, '34 10')
insert into tc values(5, '10')
insert into tc values(20, '0 10:11:12.100005')
insert into tc values(21, '0 3:5:2')
insert into tc values(22, '0 03:05:02')
#insert into tc values(6, TIME'0 10:11:12')
#insert into tc values(7, TIME'34 10:11:12')
#insert into tc values(8, TIME'34 10:11')
#insert into tc values(9, TIME'34 10')
#insert into tc values(10, TIME'10')
#insert into tc values(15, TIME'101112')
#insert into tc values(11, {t'0 10:11:12'})
#insert into tc values(12, {t'34 10:11:12'})
#insert into tc values(13, {t'34 10:11'})
#insert into tc values(14, {t'34 10'})
#insert into tc values(16, {t'101112'})
insert into tc values(17, 101112)
insert into tc values(18, 1011)
insert into tc values(19, 10)
select b from tc
#Hexadecimal Literals
select X'4D7953514C', x'4D7953514C', 0x4D7953514C
select X'4d7953514c', x'4d7953514c', 0x4d7953514c
select x'0a'+0, X'0a'+0, 0x0a+0
select 0xa, 0x0a, x'0a', X'0a'
select 0x0A, x'0A', X'0A'
select x'41', X'41', 0x41
select x'ac', X'AC', 0xAc
select X'41', CAST(X'41' AS UNSIGNED)
select X'41', CAST(x'41' AS UNSIGNED)
select 0x41, CAST(0x41 AS UNSIGNED)
select HEX('cat')
#boolean-literals
select TRUE, True, true, trUe
select FALSE, False, fAlSe, false
select 0
select 1
drop table if exists ta
create table ta(a int(16) not null primary key auto_increment, b BOOL)
insert into ta values(1,TRUE)
insert into ta values(2,True)
insert into ta values(3,true)
insert into ta values(4,trUe)
insert into ta values(5,FALSE)
insert into ta values(6,False)
insert into ta values(7,fAlSe)
insert into ta values(8,false)
insert into ta values(9,0)
insert into ta values(10,1)
select b from ta
#Bit-Field Literals
SET @v1 = 0b1000001
SET @v2 = CAST(0b1000001 AS UNSIGNED), @v3 = 0b1000001+0
SELECT @v1, @v2, @v3
SET @v1 = b'1000001'
SET @v2 = CAST(b'1000001' AS UNSIGNED), @v3 = b'1000001'+0
SELECT @v1, @v2, @v3
drop table if exists t
create table t(b BIT(8))
INSERT INTO t SET b = b'11111111'
INSERT INTO t SET b = b'00000000'
INSERT INTO t SET b = b'1010'
INSERT INTO t SET b = b'0101'
INSERT INTO t SET b = b'01010'
INSERT INTO t SET b = 0b11111111
INSERT INTO t SET b = 0b00000000
INSERT INTO t SET b = 0b1010
INSERT INTO t SET b = 0b0101
INSERT INTO t SET b = 0b01010
SELECT b, b+0, BIN(b+0), OCT(b+0), HEX(b+0) FROM t
#NULL Values
select null
select NULL
select \N
#load data infile 'file.txt' into table \n
##case issue81
select '\ba\bb\b'
select '\ta\tb\t'
select '\ra\rb\r'
select '\na\nb\n'
select '\fa\fb\f'
##case use db
#!share_conn
use mytest
select 1
#
#clear tables
#
drop table if EXISTS t
drop table if exists ta
drop table if exists tc
drop table if exists tb