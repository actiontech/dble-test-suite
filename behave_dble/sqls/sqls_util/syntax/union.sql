#!default_db:schema1
# Created by zhaohongjie at 2019/1/17
drop table if exists  test1
CREATE TABLE  test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
insert into  test1 values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18)
insert into  test1(id,k,pad) values(19,19,19)
#
#no-table-select at last
#
select id from  test1 union SELECT 1
select id from  test1 union SELECT CASE BINARY 'B' WHEN 'a' THEN 1 WHEN 'b' THEN 2 END
select id from  test1 union SELECT IF(1>2,2,3)
select id from  test1 union SELECT IF(STRCMP('test','test1'),'no','yes')
select id from  test1 union SELECT IFNULL(1,0)
select id from  test1 union SELECT IFNULL(1/0,10)
select id from  test1 union SELECT IFNULL(1/0,'yes')
select id from  test1 union SELECT NULLIF(1,1)
select id from  test1 union SELECT ASCII('2')
select id from  test1 union SELECT ASCII('dx')
select id from  test1 union SELECT BIN(12)
select id from  test1 union SELECT BIT_LENGTH('text')
select id from  test1 union SELECT CHAR(77,121,83,81,'76')
select id from  test1 union SELECT HEX(CHAR(1,0))
select id from  test1 union SELECT HEX(CHAR(256*256))
select id from  test1 union SELECT CHARSET(CHAR(X'65' USING utf8))
select id from  test1 union select CHAR_LENGTH("abc")
select id from  test1 union select CHARACTER_LENGTH("abc")
select id from  test1 union SELECT 'My' 'S' 'QL'
select id from  test1 union SELECT CONCAT('My', 'S', 'QL')
select id from  test1 union SELECT CONCAT_WS(',','First name','Second name','Last Name')
select id from  test1 union SELECT ELT(1, 'ej', 'Heja', 'hej', 'foo')
select id from  test1 union SELECT EXPORT_SET(6,'1','0',',',10)
select id from  test1 union SELECT FIELD('ej', 'Hej', 'ej', 'Heja', 'hej', 'foo')
select id from  test1 union SELECT FIND_IN_SET('b','a,b,c,d')
select id from  test1 union SELECT FORMAT(12332.123456, 4)
select id from  test1 union SELECT TO_BASE64('abc')
select id from  test1 union SELECT FROM_BASE64(TO_BASE64('abc'))
select id from  test1 union SELECT HEX(255)
select id from  test1 union SELECT CONV(HEX(255),16,10)
select id from  test1 union SELECT INSERT('Quadratic', 3, 4, 'What')
select id from  test1 union SELECT INSTR('foobarbar', 'bar')
select id from  test1 union SELECT LCASE('QUADRATICALLY')
select id from  test1 union SELECT LEFT('foobarbar', 5)
select id from  test1 union SELECT LENGTH('text')
select id from  test1 union SELECT LOCATE('bar', 'foobarbar')
select id from  test1 union SELECT LOCATE('bar', 'foobarbar', 5)
select id from  test1 union SELECT LOWER('QUADRATICALLY')
select id from  test1 union SELECT LPAD('hi',4,'??')
select id from  test1 union SELECT LTRIM('  barbar')
select id from  test1 union SELECT MAKE_SET(1 | 4,'hello','nice','world')
select id from  test1 union SELECT Mid('Quadratically',5,6)
select id from  test1 union SELECT OCT(12)
select id from  test1 union SELECT OCTET_LENGTH('text')
select id from  test1 union SELECT ORD('2')
select id from  test1 union SELECT POSITION('bar' IN 'foobarbar')
select id from  test1 union SELECT QUOTE('Don\'t!')
select id from  test1 union SELECT REPEAT('MySQL', 3)
select id from  test1 union SELECT REPLACE('www.mysql.com', 'w', 'Ww')
select id from  test1 union SELECT REVERSE('abc')
select id from  test1 union SELECT RIGHT('foobarbar', 4)
select id from  test1 union SELECT RPAD('hi',5,'?')
select id from  test1 union SELECT RTRIM('barbar   ')
select id from  test1 union SELECT SOUNDEX('Hello')
select id from  test1 union SELECT SPACE(6)
select id from  test1 union SELECT STRCMP('text', 'text2')
select id from  test1 union SELECT SUBSTR('Quadratically',5)
select id from  test1 union SELECT SUBSTR('Quadratically',5,6)
select id from  test1 union SELECT SUBSTRING('Quadratically',5)
select id from  test1 union SELECT SUBSTRING('foobarbar' FROM 4)
select id from  test1 union SELECT SUBSTRING('Quadratically',5,6)
select id from  test1 union SELECT SUBSTRING('Sakila' FROM -4 FOR 2)
select id from  test1 union SELECT SUBSTRING_INDEX('www.mysql.com', '.', 2)
select id from  test1 union SELECT TO_BASE64('abc')
select id from  test1 union SELECT TRIM('  bar   ')
select id from  test1 union SELECT TRIM(LEADING 'x' FROM 'xxxbarxxx')
select id from  test1 union SELECT TRIM(BOTH 'x' FROM 'xxxbarxxx')
select id from  test1 union SELECT TRIM(TRAILING 'xyz' FROM 'barxxyz')
select id from  test1 union SELECT UCASE('Hej')
select id from  test1 union SELECT UNHEX('4D7953514C')
select id from  test1 union SELECT UPPER('Hej')
select id from  test1 union SELECT CHARSET(BINARY 'a')
select id from  test1 union SELECT COLLATION(BINARY 'a')
select id from  test1 union SELECT USER()
select id from  test1 union SELECT CHARSET(USER())
select id from  test1 union SELECT COLLATION(USER())
select id from  test1 union SELECT CHARSET(COMPRESS('abc'))
select id from  test1 union SELECT COLLATION(COMPRESS('abc'))
select id from  test1 union select ABS(-32)
select id from  test1 union SELECT ACOS(1)
select id from  test1 union SELECT ACOS(1.0001)
select id from  test1 union SELECT ASIN(0.2)
select id from  test1 union SELECT ATAN(-2)
select id from  test1 union SELECT ATAN(-2,2)
select id from  test1 union  SELECT ATAN2(PI(),0)
select id from  test1 union  SELECT CEIL(-1.23)
select id from  test1 union SELECT CEILING(1.23)
select id from  test1 union SELECT CONV('a',16,2)
select id from  test1 union SELECT CONV('6E',18,8)
select id from  test1 union SELECT CONV(-17,10,-18)
select id from  test1 union SELECT CONV(10+'10'+'10'+X'0a',10,10)
select id from  test1 union SELECT COS(PI())
select id from  test1 union SELECT COT(12)
select id from  test1 union SELECT CRC32('MySQL')
select id from  test1 union SELECT DEGREES(PI())
select id from  test1 union SELECT DEGREES(PI() / 2)
select id from  test1 union SELECT EXP(2)
select id from  test1 union SELECT FLOOR(1.23)
select id from  test1 union SELECT FLOOR(-1.23)
select id from  test1 union SELECT FORMAT(12332.123456, 4)
select id from  test1 union SELECT FORMAT(12332.2,2,'de_DE')
select id from  test1 union SELECT HEX(255)
select id from  test1 union SELECT CONV(HEX(255),16,10)
select id from  test1 union SELECT X'616263'
select id from  test1 union SELECT HEX('abc')
select id from  test1 union SELECT LN(2)
select id from  test1 union SELECT LN(-2)
select id from  test1 union SELECT LOG(2)
select id from  test1 union SELECT LOG(2,65536)
select id from  test1 union SELECT LOG2(65536)
select id from  test1 union SELECT LOG10(100)
select id from  test1 union SELECT MOD(234, 10)
select id from  test1 union SELECT 253 % 7
select id from  test1 union SELECT PI()
select id from  test1 union SELECT POW(2,-2)
select id from  test1 union SELECT POWER(2,2)
select id from  test1 union SELECT RADIANS(90)
select id from  test1 union SELECT ROUND(-1.23)
select id from  test1 union SELECT ROUND(1.298, 0)
select id from  test1 union SELECT ROUND(150.000,2)
select id from  test1 union SELECT ROUND(150,2)
select id from  test1 union SELECT ROUND(2.5)
select id from  test1 union SELECT ROUND(25E-1)
select id from  test1 union SELECT SIGN(-32)
select id from  test1 union SELECT ROUND(SIN(PI()))
select id from  test1 union SELECT SQRT(20)
select id from  test1 union SELECT TAN(PI())
select id from  test1 union SELECT TRUNCATE(122,-2)
select id from  test1 union SELECT TRUNCATE(1.999,1)
select id from  test1 union SELECT DATE_ADD('2008-01-02', INTERVAL 31 DAY)
select id from  test1 union SELECT ADDDATE('2008-01-02', INTERVAL 31 DAY)
select id from  test1 union SELECT ADDDATE('2008-01-02', 31)
select id from  test1 union SELECT ADDTIME('2007-12-31 23:59:59.999999', '1 1:1:1.000002')
select id from  test1 union SELECT ADDTIME('01:00:00.999999', '02:00:00.999998')
select id from  test1 union SELECT CONVERT_TZ('2004-01-01 12:00:00','GMT','MET')
select id from  test1 union SELECT CONVERT_TZ('2004-01-01 12:00:00','+00:00','+10:00')
select id from  test1 union SELECT CURDATE()
select id from  test1 union SELECT CURDATE() + 0
select id from  test1 union SELECT CURRENT_DATE
select id from  test1 union SELECT CURRENT_DATE()
select id from  test1 union SELECT CURRENT_TIME /*allow_diff*/
select id from  test1 union SELECT CURRENT_TIME() /*allow_diff*/
select id from  test1 union SELECT CURTIME() /*allow_diff*/
select id from  test1 union SELECT CURRENT_TIMESTAMP /*allow_diff*/
select id from  test1 union SELECT CURRENT_TIMESTAMP() /*allow_diff*/
select id from  test1 union SELECT NOW() /*allow_diff*/
select id from  test1 union SELECT LOCALTIME /*allow_diff*/
select id from  test1 union SELECT LOCALTIME() /*allow_diff*/
select id from  test1 union SELECT LOCALTIMESTAMP /*allow_diff*/
select id from  test1 union SELECT LOCALTIMESTAMP() /*allow_diff*/
select id from  test1 union SELECT DATE('2003-12-31 01:02:03')
select id from  test1 union SELECT DATEDIFF('2007-12-31 23:59:59','2007-12-30')
select id from  test1 union SELECT DATEDIFF('2010-11-30 23:59:59','2010-12-31')
select id from  test1 union SELECT '2008-12-31 23:59:59' + INTERVAL 1 SECOND
select id from  test1 union SELECT INTERVAL 1 DAY + '2008-12-31'
select id from  test1 union SELECT '2005-01-01' - INTERVAL 1 SECOND
select id from  test1 union SELECT DATE_ADD('2000-12-31 23:59:59',INTERVAL 1 SECOND)
select id from  test1 union SELECT DATE_ADD('2010-12-31 23:59:59',INTERVAL 1 DAY)
select id from  test1 union SELECT DATE_ADD('2100-12-31 23:59:59',INTERVAL '1:1' MINUTE_SECOND)
select id from  test1 union SELECT DATE_SUB('2005-01-01 00:00:00', INTERVAL '1 1:1:1' DAY_SECOND)
select id from  test1 union SELECT DATE_ADD('1900-01-01 00:00:00', INTERVAL '-1 10' DAY_HOUR)
select id from  test1 union SELECT DATE_SUB('1998-01-02', INTERVAL 31 DAY)
select id from  test1 union SELECT DATE_ADD('1992-12-31 23:59:59.000002',INTERVAL '1.999999' SECOND_MICROSECOND)
select id from  test1 union SELECT DATE_ADD('2009-01-01', INTERVAL 6/4 HOUR_MINUTE)
select id from  test1 union SELECT DATE_ADD('1970-01-01 12:00:00',INTERVAL CAST(6/4 AS DECIMAL(3,1)) HOUR_MINUTE)
select id from  test1 union SELECT DATE_ADD('2013-01-01', INTERVAL 1 DAY)
select id from  test1 union SELECT DATE_ADD('2013-01-01', INTERVAL 1 HOUR)
select id from  test1 union SELECT DATE_ADD('2009-01-30', INTERVAL 1 MONTH)
select id from  test1 union SELECT DATE_ADD('2006-07-00', INTERVAL 1 DAY)
select id from  test1 union SELECT '2005-03-32' + INTERVAL 1 MONTH
select id from  test1 union SELECT DATE_FORMAT('2009-10-04 22:23:00', '%W %M %Y')
select id from  test1 union SELECT DATE_FORMAT('2007-10-04 22:23:00', '%H:%i:%s')
select id from  test1 union SELECT DATE_FORMAT('1900-10-04 22:23:00','%D %y %a %d %m %b %j')
select id from  test1 union SELECT DATE_FORMAT('1997-10-04 22:23:00','%H %k %I %r %T %S %w')
select id from  test1 union SELECT DATE_FORMAT('1999-01-01', '%X %V')
select id from  test1 union SELECT DATE_FORMAT('2006-06-00', '%d')
select id from  test1 union SELECT DAY('2007-02-03')
select id from  test1 union SELECT DAYOFMONTH('2007-02-03')
select id from  test1 union SELECT DAYNAME('2007-02-03')
select id from  test1 union SELECT DAYOFWEEK('2007-02-03')
select id from  test1 union SELECT DAYOFYEAR('2007-02-03')
select id from  test1 union SELECT EXTRACT(YEAR FROM '2009-07-02')
select id from  test1 union SELECT EXTRACT(YEAR_MONTH FROM '2009-07-02 01:02:03')
select id from  test1 union SELECT EXTRACT(DAY_MINUTE FROM '2009-07-02 01:02:03')
select id from  test1 union SELECT EXTRACT(MICROSECOND FROM '2003-01-02 10:30:00.000123')
select id from  test1 union SELECT FROM_DAYS(730669)
select id from  test1 union SELECT FROM_UNIXTIME(1447430881)
select id from  test1 union SELECT FROM_UNIXTIME(1447430881) + 0
select id from  test1 union SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(),'%Y %D %M %h:%i:%s %x')
select id from  test1 union SELECT DATE_FORMAT('2003-10-03',GET_FORMAT(DATE,'EUR'))
select id from  test1 union SELECT STR_TO_DATE('10.31.2003',GET_FORMAT(DATE,'USA'))
select id from  test1 union SELECT HOUR('10:05:03')
select id from  test1 union SELECT HOUR('272:59:59')
select id from  test1 union SELECT LAST_DAY('2003-02-05')
select id from  test1 union SELECT MAKEDATE(2011,31)
select id from  test1 union SELECT MAKEDATE(2011,32)
select id from  test1 union SELECT MAKETIME(12,15,30)
select id from  test1 union SELECT MICROSECOND('12:00:00.123456')
select id from  test1 union SELECT MINUTE('2008-02-03 10:05:03')
select id from  test1 union SELECT MONTH('2008-02-03')
select id from  test1 union SELECT MONTHNAME('2008-02-03')
select id from  test1 union SELECT NOW() /*allow_diff*/
select id from  test1 union SELECT PERIOD_ADD(200801,2)
select id from  test1 union SELECT PERIOD_DIFF(200802,200703)
select id from  test1 union SELECT QUARTER('2008-04-01')
select id from  test1 union SELECT SECOND('10:05:03')
select id from  test1 union SELECT SEC_TO_TIME(2378)
select id from  test1 union SELECT STR_TO_DATE('01,5,2013','%d,%m,%Y')
select id from  test1 union SELECT STR_TO_DATE('May 1, 2013','%M %d,%Y')
select id from  test1 union SELECT STR_TO_DATE('a09:30:17','a%h:%i:%s')
select id from  test1 union SELECT SUBDATE('2008-01-02', INTERVAL 31 DAY)
select id from  test1 union SELECT SUBDATE('2008-01-02 12:00:00', 31)
select id from  test1 union SELECT SUBTIME('2007-12-31 23:59:59.999999','1 1:1:1.000002')
select id from  test1 union SELECT TIME('2003-12-31 01:02:03')
select id from  test1 union SELECT TIMEDIFF('2000:01:01 00:00:00','2000:01:01 00:00:00.000001')
select id from  test1 union SELECT TIMESTAMP('2003-12-31')
select id from  test1 union SELECT TIMESTAMP('2003-12-31 12:00:00','12:00:00')
select id from  test1 union SELECT TIMESTAMPADD(MINUTE,1,'2003-01-02')
select id from  test1 union SELECT TIMESTAMPDIFF(MONTH,'2003-02-01','2003-05-01')
select id from  test1 union SELECT TIME_FORMAT('100:00:00', '%H %k %h %I %l')
select id from  test1 union SELECT TIME_TO_SEC('22:23:00')
select id from  test1 union SELECT TO_DAYS(950501)
select id from  test1 union SELECT TO_SECONDS(950501)
select id from  test1 union SELECT UNIX_TIMESTAMP('2015-11-13 10:20:19')
select id from  test1 union SELECT UNIX_TIMESTAMP()
select id from  test1 union SELECT UTC_DATE()
select id from  test1 union SELECT UTC_DATE() + 0
select id from  test1 union SELECT UTC_TIME() /*allow_diff*/
select id from  test1 union SELECT UTC_TIME() + 0 /*allow_diff*/
select id from  test1 union SELECT UTC_TIMESTAMP() /*allow_diff*/
select id from  test1 union SELECT UTC_TIMESTAMP() + 0 /*allow_diff*/
select id from  test1 union SELECT WEEK('2008-02-20')
select id from  test1 union SELECT WEEK('2008-12-31',1)
select id from  test1 union SELECT WEEKDAY('2008-02-03 22:23:00')
select id from  test1 union SELECT WEEKOFYEAR('2008-02-20')
select id from  test1 union SELECT YEAR('1987-01-01')
select id from  test1 union SELECT YEARWEEK('1987-01-01')
select id from  test1 union  SELECT BINARY 'a' = 'A'
select id from  test1 union  select cast('a'='A' as binary)
select id from  test1 union SELECT CONCAT('hello you ',2)
select id from  test1 union SELECT _binary 'a' = 'A'
select id from  test1 union SELECT ExtractValue('<a><b/></a>', 'count(/a/b)')
select id from  test1 union SELECT BIT_COUNT(b'101010')
select id from  test1 union SELECT BIT_COUNT(29)
select id from  test1 union SELECT 29 & 15
select id from  test1 union SELECT 5 & ~1
select id from  test1 union SELECT 29 | 15
select id from  test1 union SELECT 1 ^ 0
select id from  test1 union SELECT 1 << 2
select id from  test1 union SELECT 4 >> 2
select id from  test1 union SELECT AES_DECRYPT('text',UNHEX('F3229A0B371ED2D9441B830D21A390C3'))
select id from  test1 union SELECT LENGTH(COMPRESS(REPEAT('a',1000)))
select id from  test1 union select decode(ENCODE('cleartext', CONCAT('my_random_salt','my_secret_password')), 'abc')
select id from  test1 union SELECT ENCRYPT('hello') /*allow_diff*/
select id from  test1 union SELECT ENCRYPT('hello','abc')
select id from  test1 union SELECT MD5('testing')
select id from  test1 union SELECT PASSWORD('mypass')
select id from  test1 union SELECT PASSWORD('mypass')
select id from  test1 union SELECT OLD_PASSWORD('mypass')
select id from  test1 union SELECT SHA('abc')
select id from  test1 union SELECT SHA1('abc')
select id from  test1 union SELECT SHA2('abc', 224)
select id from  test1 union SELECT UNCOMPRESS(COMPRESS('any string'))
select id from  test1 union SELECT UNCOMPRESSED_LENGTH(COMPRESS(REPEAT('a',30)))
select id from  test1 union SELECT BENCHMARK(1000000,AES_ENCRYPT('hello','goodbye'))
select id from  test1 union SELECT CHARSET('abc')
select id from  test1 union SELECT COLLATION('abc')
select id from  test1 union SELECT CONNECTION_id()
select id from  test1 union SELECT CURRENT_USER()
select id from  test1 union SELECT CURRENT_USER
select id from  test1 union SELECT DATABASE()
select id from  test1 union select schema()
select id from  test1 union SELECT SESSION_USER()
select id from  test1 union SELECT USER()
select id from  test1 union SELECT LAST_INSERT_id()
select id from  test1 union SELECT ROW_COUNT()
select id from  test1 union SELECT VERSION()
select id from  test1 union SELECT GET_LOCK('lock1',10)
select id from  test1 union SELECT RELEASE_LOCK('lock2')
select id from  test1 union SELECT INET_ATON('10.0.5.9')
select id from  test1 union SELECT INET_NTOA(167773449)
select id from  test1 union SELECT HEX(INET6_ATON(INET_NTOA(167773449)))
select id from  test1 union select IS_FREE_LOCK('abc')
select id from  test1 union SELECT IS_IPV4('10.0.5.9')
select id from  test1 union SELECT IS_IPV4_COMPAT(INET6_ATON('::10.0.5.9'))
select id from  test1 union SELECT HEX(INET6_ATON('192.168.0.1'))
select id from  test1 union select IS_IPV4_COMPAT(INET6_ATON('::192.168.0.1'))
select id from  test1 union SELECT IS_IPV4_MAPPED(INET6_ATON('::10.0.5.9'))
select id from  test1 union SELECT IS_IPV6('10.0.5.9')
select id from  test1 union select IS_USED_LOCK('abc')
select id from  test1 union SELECT NAME_CONST('myname', 14)
select id from  test1 union SELECT RELEASE_ALL_LOCKS()
select id from  test1 union SELECT SLEEP(1)
select id from  test1 union SELECT UUid()
#
#no-table-select at frist
#
SELECT 1 union select id from  test1
SELECT 4 >> 2 union select id from  test1
SELECT AES_DECRYPT('text',UNHEX('F3229A0B371ED2D9441B830D21A390C3')) union select id from  test1
SELECT LENGTH(COMPRESS(REPEAT('a',1000))) union select id from  test1
select decode(ENCODE('cleartext', CONCAT('my_random_salt','my_secret_password')), 'abc') union select id from  test1
SELECT ENCRYPT('hello') union select id from  test1
SELECT ENCRYPT('hello','abc') union select id from  test1
SELECT MD5('testing') union select id from  test1
SELECT PASSWORD('mypass') union select id from  test1
SELECT PASSWORD('mypass') union select id from  test1
SELECT OLD_PASSWORD('mypass') union select id from  test1
SELECT SHA('abc') union select id from  test1
SELECT SHA1('abc') union select id from  test1
SELECT SHA2('abc', 224) union select id from  test1
SELECT UNCOMPRESS(COMPRESS('any string')) union select id from  test1
SELECT UNCOMPRESSED_LENGTH(COMPRESS(REPEAT('a',30))) union select id from  test1
SELECT BENCHMARK(1000000,AES_ENCRYPT('hello','goodbye')) union select id from  test1
SELECT CHARSET('abc') union select id from  test1
SELECT COLLATION('abc') union select id from  test1
SELECT CONNECTION_id() union select id from  test1
SELECT CURRENT_USER() union select id from  test1
SELECT CURRENT_USER union select id from  test1
SELECT DATABASE() union select id from  test1
select schema() union select id from  test1
SELECT SESSION_USER() union select id from  test1
SELECT USER() union select id from  test1
SELECT LAST_INSERT_id() union select id from  test1
SELECT ROW_COUNT() union select id from  test1
SELECT VERSION() union select id from  test1
SELECT GET_LOCK('lock1',10) union select id from  test1
SELECT RELEASE_LOCK('lock2') union select id from  test1
SELECT INET_ATON('10.0.5.9') union select id from  test1
SELECT INET_NTOA(167773449) union select id from  test1
SELECT HEX(INET6_ATON(INET_NTOA(167773449))) union select id from  test1
select IS_FREE_LOCK('abc') union select id from  test1
SELECT IS_IPV4('10.0.5.9') union select id from  test1
SELECT IS_IPV4_COMPAT(INET6_ATON('::10.0.5.9')) union select id from  test1
SELECT HEX(INET6_ATON('192.168.0.1')) union select id from  test1
select IS_IPV4_COMPAT(INET6_ATON('::192.168.0.1')) union select id from  test1
SELECT IS_IPV4_MAPPED(INET6_ATON('::10.0.5.9')) union select id from  test1
SELECT IS_IPV6('10.0.5.9') union select id from  test1
select IS_USED_LOCK('abc') union select id from  test1
SELECT NAME_CONST('myname', 14) union select id from  test1
SELECT RELEASE_ALL_LOCKS() union select id from  test1
SELECT SLEEP(1) union select id from  test1
SELECT UUid() union select id from  test1
#!share_conn
select id from  test1 union SELECT OLD_PASSWORD('mypass')
select id from  test1 union SELECT SHA('abc')
#
#clear tables
#
drop table if exists  test1