drop table if exists test_global
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
insert into test_global values(1,1,'id1',1),(2,2,'id2',2),(3,3,'id3',3),(4,4,'id4',4),(5,5,'id5',1),(6,6,'id6',2),(7,7,'id7',3),(8,8,'$id8$',4),(9,9,'test',3),(10,10,'中',3),(11,11,'i_',4),(12,12,'_g',5),(13,13,'y_u',6),(14,14,'20%',14),(15,15,'a_1',15),(16,16,16,-1),(0,0,0,0),(17,17,'new*\n*line',17),(18,18,'a',18)
insert into test_global(id,k,pad) values(19,19,19)
#
#no-table-select at last
#
select id from test_global union SELECT 1
select id from test_global union SELECT CASE BINARY 'B' WHEN 'a' THEN 1 WHEN 'b' THEN 2 END
select id from test_global union SELECT IF(1>2,2,3)
select id from test_global union SELECT IF(STRCMP('test','test1'),'no','yes')
select id from test_global union SELECT IFNULL(1,0)
select id from test_global union SELECT IFNULL(1/0,10)
select id from test_global union SELECT IFNULL(1/0,'yes')
select id from test_global union SELECT NULLIF(1,1)
select id from test_global union SELECT ASCII('2')
select id from test_global union SELECT ASCII('dx')
select id from test_global union SELECT BIN(12)
select id from test_global union SELECT BIT_LENGTH('text')
select id from test_global union SELECT CHAR(77,121,83,81,'76')
select id from test_global union SELECT HEX(CHAR(1,0))
select id from test_global union SELECT HEX(CHAR(256*256))
select id from test_global union SELECT CHARSET(CHAR(X'65' USING utf8))
select id from test_global union select CHAR_LENGTH("abc")
select id from test_global union select CHARACTER_LENGTH("abc")
select id from test_global union SELECT 'My' 'S' 'QL'
select id from test_global union SELECT CONCAT('My', 'S', 'QL')
select id from test_global union SELECT CONCAT_WS(',','First name','Second name','Last Name')
select id from test_global union SELECT ELT(1, 'ej', 'Heja', 'hej', 'foo')
select id from test_global union SELECT EXPORT_SET(6,'1','0',',',10)
select id from test_global union SELECT FIELD('ej', 'Hej', 'ej', 'Heja', 'hej', 'foo')
select id from test_global union SELECT FIND_IN_SET('b','a,b,c,d')
select id from test_global union SELECT FORMAT(12332.123456, 4)
select id from test_global union SELECT TO_BASE64('abc')
select id from test_global union SELECT FROM_BASE64(TO_BASE64('abc'))
select id from test_global union SELECT HEX(255)
select id from test_global union SELECT CONV(HEX(255),16,10)
select id from test_global union SELECT INSERT('Quadratic', 3, 4, 'What')
select id from test_global union SELECT INSTR('foobarbar', 'bar')
select id from test_global union SELECT LCASE('QUADRATICALLY')
select id from test_global union SELECT LEFT('foobarbar', 5)
select id from test_global union SELECT LENGTH('text')
select id from test_global union SELECT LOCATE('bar', 'foobarbar')
select id from test_global union SELECT LOCATE('bar', 'foobarbar', 5)
select id from test_global union SELECT LOWER('QUADRATICALLY')
select id from test_global union SELECT LPAD('hi',4,'??')
select id from test_global union SELECT LTRIM('  barbar')
select id from test_global union SELECT MAKE_SET(1 | 4,'hello','nice','world')
select id from test_global union SELECT Mid('Quadratically',5,6)
select id from test_global union SELECT OCT(12)
select id from test_global union SELECT OCTET_LENGTH('text')
select id from test_global union SELECT ORD('2')
select id from test_global union SELECT POSITION('bar' IN 'foobarbar')
select id from test_global union SELECT QUOTE('Don\'t!')
select id from test_global union SELECT REPEAT('MySQL', 3)
select id from test_global union SELECT REPLACE('www.mysql.com', 'w', 'Ww')
select id from test_global union SELECT REVERSE('abc')
select id from test_global union SELECT RIGHT('foobarbar', 4)
select id from test_global union SELECT RPAD('hi',5,'?')
select id from test_global union SELECT RTRIM('barbar   ')
select id from test_global union SELECT SOUNDEX('Hello')
select id from test_global union SELECT SPACE(6)
select id from test_global union SELECT STRCMP('text', 'text2')
select id from test_global union SELECT SUBSTR('Quadratically',5)
select id from test_global union SELECT SUBSTR('Quadratically',5,6)
select id from test_global union SELECT SUBSTRING('Quadratically',5)
select id from test_global union SELECT SUBSTRING('foobarbar' FROM 4)
select id from test_global union SELECT SUBSTRING('Quadratically',5,6)
select id from test_global union SELECT SUBSTRING('Sakila' FROM -4 FOR 2)
select id from test_global union SELECT SUBSTRING_INDEX('www.mysql.com', '.', 2)
select id from test_global union SELECT TO_BASE64('abc')
select id from test_global union SELECT TRIM('  bar   ')
select id from test_global union SELECT TRIM(LEADING 'x' FROM 'xxxbarxxx')
select id from test_global union SELECT TRIM(BOTH 'x' FROM 'xxxbarxxx')
select id from test_global union SELECT TRIM(TRAILING 'xyz' FROM 'barxxyz')
select id from test_global union SELECT UCASE('Hej')
select id from test_global union SELECT UNHEX('4D7953514C')
select id from test_global union SELECT UPPER('Hej')
select id from test_global union SELECT CHARSET(BINARY 'a')
select id from test_global union SELECT COLLATION(BINARY 'a')
select id from test_global union SELECT USER()
select id from test_global union SELECT CHARSET(USER())
select id from test_global union SELECT COLLATION(USER())
select id from test_global union SELECT CHARSET(COMPRESS('abc'))
select id from test_global union SELECT COLLATION(COMPRESS('abc'))
select id from test_global union select ABS(-32)
select id from test_global union SELECT ACOS(1)
select id from test_global union SELECT ACOS(1.0001)
select id from test_global union SELECT ASIN(0.2)
select id from test_global union SELECT ATAN(-2)
select id from test_global union SELECT ATAN(-2,2)
select id from test_global union  SELECT ATAN2(PI(),0)
select id from test_global union  SELECT CEIL(-1.23)
select id from test_global union SELECT CEILING(1.23)
select id from test_global union SELECT CONV('a',16,2)
select id from test_global union SELECT CONV('6E',18,8)
select id from test_global union SELECT CONV(-17,10,-18)
select id from test_global union SELECT CONV(10+'10'+'10'+X'0a',10,10)
select id from test_global union SELECT COS(PI())
select id from test_global union SELECT COT(12)
select id from test_global union SELECT CRC32('MySQL')
select id from test_global union SELECT DEGREES(PI())
select id from test_global union SELECT DEGREES(PI() / 2)
select id from test_global union SELECT EXP(2)
select id from test_global union SELECT FLOOR(1.23)
select id from test_global union SELECT FLOOR(-1.23)
select id from test_global union SELECT FORMAT(12332.123456, 4)
select id from test_global union SELECT FORMAT(12332.2,2,'de_DE')
select id from test_global union SELECT HEX(255)
select id from test_global union SELECT CONV(HEX(255),16,10)
select id from test_global union SELECT X'616263'
select id from test_global union SELECT HEX('abc')
select id from test_global union SELECT LN(2)
select id from test_global union SELECT LN(-2)
select id from test_global union SELECT LOG(2)
select id from test_global union SELECT LOG(2,65536)
select id from test_global union SELECT LOG2(65536)
select id from test_global union SELECT LOG10(100)
select id from test_global union SELECT MOD(234, 10)
select id from test_global union SELECT 253 % 7
select id from test_global union SELECT PI()
select id from test_global union SELECT POW(2,-2)
select id from test_global union SELECT POWER(2,2)
select id from test_global union SELECT RADIANS(90)
select id from test_global union SELECT ROUND(-1.23)
select id from test_global union SELECT ROUND(1.298, 0)
select id from test_global union SELECT ROUND(150.000,2)
select id from test_global union SELECT ROUND(150,2)
select id from test_global union SELECT ROUND(2.5)
select id from test_global union SELECT ROUND(25E-1)
select id from test_global union SELECT SIGN(-32)
select id from test_global union SELECT ROUND(SIN(PI()))
select id from test_global union SELECT SQRT(20)
select id from test_global union SELECT TAN(PI())
select id from test_global union SELECT TRUNCATE(122,-2)
select id from test_global union SELECT TRUNCATE(1.999,1)
select id from test_global union SELECT DATE_ADD('2008-01-02', INTERVAL 31 DAY)
select id from test_global union SELECT ADDDATE('2008-01-02', INTERVAL 31 DAY)
select id from test_global union SELECT ADDDATE('2008-01-02', 31)
select id from test_global union SELECT ADDTIME('2007-12-31 23:59:59.999999', '1 1:1:1.000002')
select id from test_global union SELECT ADDTIME('01:00:00.999999', '02:00:00.999998')
select id from test_global union SELECT CONVERT_TZ('2004-01-01 12:00:00','GMT','MET')
select id from test_global union SELECT CONVERT_TZ('2004-01-01 12:00:00','+00:00','+10:00')
select id from test_global union SELECT CURDATE()
select id from test_global union SELECT CURDATE() + 0
select id from test_global union SELECT CURRENT_DATE
select id from test_global union SELECT CURRENT_DATE()
select id from test_global union SELECT CURRENT_TIME /*allow_diff*/
select id from test_global union SELECT CURRENT_TIME() /*allow_diff*/
select id from test_global union SELECT CURTIME() /*allow_diff*/
select id from test_global union SELECT CURRENT_TIMESTAMP /*allow_diff*/
select id from test_global union SELECT CURRENT_TIMESTAMP() /*allow_diff*/
select id from test_global union SELECT NOW() /*allow_diff*/
select id from test_global union SELECT LOCALTIME /*allow_diff*/
select id from test_global union SELECT LOCALTIME() /*allow_diff*/
select id from test_global union SELECT LOCALTIMESTAMP /*allow_diff*/
select id from test_global union SELECT LOCALTIMESTAMP() /*allow_diff*/
select id from test_global union SELECT DATE('2003-12-31 01:02:03')
select id from test_global union SELECT DATEDIFF('2007-12-31 23:59:59','2007-12-30')
select id from test_global union SELECT DATEDIFF('2010-11-30 23:59:59','2010-12-31')
select id from test_global union SELECT '2008-12-31 23:59:59' + INTERVAL 1 SECOND
select id from test_global union SELECT INTERVAL 1 DAY + '2008-12-31'
select id from test_global union SELECT '2005-01-01' - INTERVAL 1 SECOND
select id from test_global union SELECT DATE_ADD('2000-12-31 23:59:59',INTERVAL 1 SECOND)
select id from test_global union SELECT DATE_ADD('2010-12-31 23:59:59',INTERVAL 1 DAY)
select id from test_global union SELECT DATE_ADD('2100-12-31 23:59:59',INTERVAL '1:1' MINUTE_SECOND)
select id from test_global union SELECT DATE_SUB('2005-01-01 00:00:00', INTERVAL '1 1:1:1' DAY_SECOND)
select id from test_global union SELECT DATE_ADD('1900-01-01 00:00:00', INTERVAL '-1 10' DAY_HOUR)
select id from test_global union SELECT DATE_SUB('1998-01-02', INTERVAL 31 DAY)
select id from test_global union SELECT DATE_ADD('1992-12-31 23:59:59.000002',INTERVAL '1.999999' SECOND_MICROSECOND)
select id from test_global union SELECT DATE_ADD('2009-01-01', INTERVAL 6/4 HOUR_MINUTE)
select id from test_global union SELECT DATE_ADD('1970-01-01 12:00:00',INTERVAL CAST(6/4 AS DECIMAL(3,1)) HOUR_MINUTE)
select id from test_global union SELECT DATE_ADD('2013-01-01', INTERVAL 1 DAY)
select id from test_global union SELECT DATE_ADD('2013-01-01', INTERVAL 1 HOUR)
select id from test_global union SELECT DATE_ADD('2009-01-30', INTERVAL 1 MONTH)
select id from test_global union SELECT DATE_ADD('2006-07-00', INTERVAL 1 DAY)
select id from test_global union SELECT '2005-03-32' + INTERVAL 1 MONTH
select id from test_global union SELECT DATE_FORMAT('2009-10-04 22:23:00', '%W %M %Y')
select id from test_global union SELECT DATE_FORMAT('2007-10-04 22:23:00', '%H:%i:%s')
select id from test_global union SELECT DATE_FORMAT('1900-10-04 22:23:00','%D %y %a %d %m %b %j')
select id from test_global union SELECT DATE_FORMAT('1997-10-04 22:23:00','%H %k %I %r %T %S %w')
select id from test_global union SELECT DATE_FORMAT('1999-01-01', '%X %V')
select id from test_global union SELECT DATE_FORMAT('2006-06-00', '%d')
select id from test_global union SELECT DAY('2007-02-03')
select id from test_global union SELECT DAYOFMONTH('2007-02-03')
select id from test_global union SELECT DAYNAME('2007-02-03')
select id from test_global union SELECT DAYOFWEEK('2007-02-03')
select id from test_global union SELECT DAYOFYEAR('2007-02-03')
select id from test_global union SELECT EXTRACT(YEAR FROM '2009-07-02')
select id from test_global union SELECT EXTRACT(YEAR_MONTH FROM '2009-07-02 01:02:03')
select id from test_global union SELECT EXTRACT(DAY_MINUTE FROM '2009-07-02 01:02:03')
select id from test_global union SELECT EXTRACT(MICROSECOND FROM '2003-01-02 10:30:00.000123')
select id from test_global union SELECT FROM_DAYS(730669)
select id from test_global union SELECT FROM_UNIXTIME(1447430881)
select id from test_global union SELECT FROM_UNIXTIME(1447430881) + 0
select id from test_global union SELECT FROM_UNIXTIME(UNIX_TIMESTAMP(),'%Y %D %M %h:%i:%s %x')
select id from test_global union SELECT DATE_FORMAT('2003-10-03',GET_FORMAT(DATE,'EUR'))
select id from test_global union SELECT STR_TO_DATE('10.31.2003',GET_FORMAT(DATE,'USA'))
select id from test_global union SELECT HOUR('10:05:03')
select id from test_global union SELECT HOUR('272:59:59')
select id from test_global union SELECT LAST_DAY('2003-02-05')
select id from test_global union SELECT MAKEDATE(2011,31)
select id from test_global union SELECT MAKEDATE(2011,32)
select id from test_global union SELECT MAKETIME(12,15,30)
select id from test_global union SELECT MICROSECOND('12:00:00.123456')
select id from test_global union SELECT MINUTE('2008-02-03 10:05:03')
select id from test_global union SELECT MONTH('2008-02-03')
select id from test_global union SELECT MONTHNAME('2008-02-03')
select id from test_global union SELECT NOW() /*allow_diff*/
select id from test_global union SELECT PERIOD_ADD(200801,2)
select id from test_global union SELECT PERIOD_DIFF(200802,200703)
select id from test_global union SELECT QUARTER('2008-04-01')
select id from test_global union SELECT SECOND('10:05:03')
select id from test_global union SELECT SEC_TO_TIME(2378)
select id from test_global union SELECT STR_TO_DATE('01,5,2013','%d,%m,%Y')
select id from test_global union SELECT STR_TO_DATE('May 1, 2013','%M %d,%Y')
select id from test_global union SELECT STR_TO_DATE('a09:30:17','a%h:%i:%s')
select id from test_global union SELECT SUBDATE('2008-01-02', INTERVAL 31 DAY)
select id from test_global union SELECT SUBDATE('2008-01-02 12:00:00', 31)
select id from test_global union SELECT SUBTIME('2007-12-31 23:59:59.999999','1 1:1:1.000002')
select id from test_global union SELECT TIME('2003-12-31 01:02:03')
select id from test_global union SELECT TIMEDIFF('2000:01:01 00:00:00','2000:01:01 00:00:00.000001')
select id from test_global union SELECT TIMESTAMP('2003-12-31')
select id from test_global union SELECT TIMESTAMP('2003-12-31 12:00:00','12:00:00')
select id from test_global union SELECT TIMESTAMPADD(MINUTE,1,'2003-01-02')
select id from test_global union SELECT TIMESTAMPDIFF(MONTH,'2003-02-01','2003-05-01')
select id from test_global union SELECT TIME_FORMAT('100:00:00', '%H %k %h %I %l')
select id from test_global union SELECT TIME_TO_SEC('22:23:00')
select id from test_global union SELECT TO_DAYS(950501)
select id from test_global union SELECT TO_SECONDS(950501)
select id from test_global union SELECT UNIX_TIMESTAMP('2015-11-13 10:20:19')
select id from test_global union SELECT UNIX_TIMESTAMP()
select id from test_global union SELECT UTC_DATE()
select id from test_global union SELECT UTC_DATE() + 0
select id from test_global union SELECT UTC_TIME() /*allow_diff*/
select id from test_global union SELECT UTC_TIME() + 0 /*allow_diff*/
select id from test_global union SELECT UTC_TIMESTAMP() /*allow_diff*/
select id from test_global union SELECT UTC_TIMESTAMP() + 0 /*allow_diff*/
select id from test_global union SELECT WEEK('2008-02-20')
select id from test_global union SELECT WEEK('2008-12-31',1)
select id from test_global union SELECT WEEKDAY('2008-02-03 22:23:00')
select id from test_global union SELECT WEEKOFYEAR('2008-02-20')
select id from test_global union SELECT YEAR('1987-01-01')
select id from test_global union SELECT YEARWEEK('1987-01-01')
select id from test_global union  SELECT BINARY 'a' = 'A'
select id from test_global union  select cast('a'='A' as binary)
select id from test_global union SELECT CONCAT('hello you ',2)
select id from test_global union SELECT _binary 'a' = 'A'
select id from test_global union SELECT ExtractValue('<a><b/></a>', 'count(/a/b)')
select id from test_global union SELECT BIT_COUNT(b'101010')
select id from test_global union SELECT BIT_COUNT(29)
select id from test_global union SELECT 29 & 15
select id from test_global union SELECT 5 & ~1
select id from test_global union SELECT 29 | 15
select id from test_global union SELECT 1 ^ 0
select id from test_global union SELECT 1 << 2
select id from test_global union SELECT 4 >> 2
select id from test_global union SELECT AES_DECRYPT('text',UNHEX('F3229A0B371ED2D9441B830D21A390C3'))
select id from test_global union SELECT LENGTH(COMPRESS(REPEAT('a',1000)))
select id from test_global union select decode(ENCODE('cleartext', CONCAT('my_random_salt','my_secret_password')), 'abc')
select id from test_global union SELECT ENCRYPT('hello')
select id from test_global union SELECT ENCRYPT('hello','abc')
select id from test_global union SELECT MD5('testing')
select id from test_global union SELECT PASSWORD('mypass')
select id from test_global union SELECT PASSWORD('mypass')
select id from test_global union SELECT OLD_PASSWORD('mypass')
select id from test_global union SELECT SHA('abc')
select id from test_global union SELECT SHA1('abc')
select id from test_global union SELECT SHA2('abc', 224)
select id from test_global union SELECT UNCOMPRESS(COMPRESS('any string'))
select id from test_global union SELECT UNCOMPRESSED_LENGTH(COMPRESS(REPEAT('a',30)))
select id from test_global union SELECT BENCHMARK(1000000,AES_ENCRYPT('hello','goodbye'))
select id from test_global union SELECT CHARSET('abc')
select id from test_global union SELECT COLLATION('abc')
select id from test_global union SELECT CONNECTION_id()
select id from test_global union SELECT CURRENT_USER()
select id from test_global union SELECT CURRENT_USER
select id from test_global union SELECT DATABASE()
select id from test_global union select schema()
select id from test_global union SELECT SESSION_USER()
select id from test_global union SELECT USER()
select id from test_global union SELECT LAST_INSERT_id()
select id from test_global union SELECT ROW_COUNT()
select id from test_global union SELECT VERSION()
select id from test_global union SELECT GET_LOCK('lock1',10)
select id from test_global union SELECT RELEASE_LOCK('lock2')
select id from test_global union SELECT INET_ATON('10.0.5.9')
select id from test_global union SELECT INET_NTOA(167773449)
select id from test_global union SELECT HEX(INET6_ATON(INET_NTOA(167773449)))
select id from test_global union select IS_FREE_LOCK('abc')
select id from test_global union SELECT IS_IPV4('10.0.5.9')
select id from test_global union SELECT IS_IPV4_COMPAT(INET6_ATON('::10.0.5.9'))
select id from test_global union SELECT HEX(INET6_ATON('192.168.0.1'))
select id from test_global union select IS_IPV4_COMPAT(INET6_ATON('::192.168.0.1'))
select id from test_global union SELECT IS_IPV4_MAPPED(INET6_ATON('::10.0.5.9'))
select id from test_global union SELECT IS_IPV6('10.0.5.9')
select id from test_global union select IS_USED_LOCK('abc')
select id from test_global union SELECT NAME_CONST('myname', 14)
select id from test_global union SELECT RELEASE_ALL_LOCKS()
select id from test_global union SELECT SLEEP(1)
select id from test_global union SELECT UUid()
#
#no-table-select at frist
#
SELECT 1 union select id from test_global
SELECT 4 >> 2 union select id from test_global
SELECT AES_DECRYPT('text',UNHEX('F3229A0B371ED2D9441B830D21A390C3')) union select id from test_global
SELECT LENGTH(COMPRESS(REPEAT('a',1000))) union select id from test_global
select decode(ENCODE('cleartext', CONCAT('my_random_salt','my_secret_password')), 'abc') union select id from test_global
SELECT ENCRYPT('hello') union select id from test_global
SELECT ENCRYPT('hello','abc') union select id from test_global
SELECT MD5('testing') union select id from test_global
SELECT PASSWORD('mypass') union select id from test_global
SELECT PASSWORD('mypass') union select id from test_global
SELECT OLD_PASSWORD('mypass') union select id from test_global
SELECT SHA('abc') union select id from test_global
SELECT SHA1('abc') union select id from test_global
SELECT SHA2('abc', 224) union select id from test_global
SELECT UNCOMPRESS(COMPRESS('any string')) union select id from test_global
SELECT UNCOMPRESSED_LENGTH(COMPRESS(REPEAT('a',30))) union select id from test_global
SELECT BENCHMARK(1000000,AES_ENCRYPT('hello','goodbye')) union select id from test_global
SELECT CHARSET('abc') union select id from test_global
SELECT COLLATION('abc') union select id from test_global
SELECT CONNECTION_id() union select id from test_global
SELECT CURRENT_USER() union select id from test_global
SELECT CURRENT_USER union select id from test_global
SELECT DATABASE() union select id from test_global
select schema() union select id from test_global
SELECT SESSION_USER() union select id from test_global
SELECT USER() union select id from test_global
SELECT LAST_INSERT_id() union select id from test_global
SELECT ROW_COUNT() union select id from test_global
SELECT VERSION() union select id from test_global
SELECT GET_LOCK('lock1',10) union select id from test_global
SELECT RELEASE_LOCK('lock2') union select id from test_global
SELECT INET_ATON('10.0.5.9') union select id from test_global
SELECT INET_NTOA(167773449) union select id from test_global
SELECT HEX(INET6_ATON(INET_NTOA(167773449))) union select id from test_global
select IS_FREE_LOCK('abc') union select id from test_global
SELECT IS_IPV4('10.0.5.9') union select id from test_global
SELECT IS_IPV4_COMPAT(INET6_ATON('::10.0.5.9')) union select id from test_global
SELECT HEX(INET6_ATON('192.168.0.1')) union select id from test_global
select IS_IPV4_COMPAT(INET6_ATON('::192.168.0.1')) union select id from test_global
SELECT IS_IPV4_MAPPED(INET6_ATON('::10.0.5.9')) union select id from test_global
SELECT IS_IPV6('10.0.5.9') union select id from test_global
select IS_USED_LOCK('abc') union select id from test_global
SELECT NAME_CONST('myname', 14) union select id from test_global
SELECT RELEASE_ALL_LOCKS() union select id from test_global
SELECT SLEEP(1) union select id from test_global
SELECT UUid() union select id from test_global
