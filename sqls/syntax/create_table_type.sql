#BIT[(length)]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bit)
INSERT INTO aly_test VALUES (1,0)
INSERT INTO aly_test VALUES (2,2)
INSERT INTO aly_test VALUES (3,b'1')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bit(8) )
INSERT INTO aly_test VALUES (1,01010)
INSERT INTO aly_test VALUES (2,2)
INSERT INTO aly_test VALUES (3,b'11111')
SELECT * FROM aly_test
#
#TINYINT[(length)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint)
INSERT INTO aly_test ( id,data) VALUES (1,-129)
INSERT INTO aly_test ( id,data) VALUES (2,128)
INSERT INTO aly_test ( id,data) VALUES (222,-129),(222,-128),(222,0),(222,127),(222,128)
INSERT INTO aly_test ( id,data) VALUES (1111,-128),(1112,0),(1113,127)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint(2))
INSERT INTO aly_test ( id,data) VALUES (1111,-128),(1112,0),(1113,127)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,256)
INSERT INTO aly_test ( id,data) VALUES (111,-1),(112,0),(113,256)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,255)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint(2) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,255)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint(3) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,-10000)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,255),(114,256),(1112,2555),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,255)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,255)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint(3) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,-10000)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,255),(114,256),(1112,2555),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,255)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyint UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,255)
SELECT * FROM aly_test
#
#SMALLINT[(length)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint)
INSERT INTO aly_test ( id,data) VALUES (1,-32769)
INSERT INTO aly_test ( id,data) VALUES (2,32768)
INSERT INTO aly_test ( id,data) VALUES (222,-32769),(222,-32768),(222,0),(222,32767),(222,32768)
INSERT INTO aly_test ( id,data) VALUES (1111,-32768),(1112,0),(1113,32767)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint(3))
INSERT INTO aly_test ( id,data) VALUES (1111,-32768),(1112,0),(1113,32767)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,65536)
INSERT INTO aly_test ( id,data) VALUES (111,-1),(112,0),(113,65536)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,65535)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint(3) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,65535)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint(6) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,-65536)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,65535),(114,655355),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,65535)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,65535)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint(6) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,-65536)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,65535),(114,655355),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,65535)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data smallint UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,65535)
SELECT * FROM aly_test
#
#MEDIUMINT[(length)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint)
INSERT INTO aly_test ( id,data) VALUES (1,-8388609)
INSERT INTO aly_test ( id,data) VALUES (2,8388607)
INSERT INTO aly_test ( id,data) VALUES (222,-8388609),(222,-8388608),(222,0),(222,8388607),(222,8388608)
INSERT INTO aly_test ( id,data) VALUES (1111,-8388608),(1112,0),(1113,8388607)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint(5))
INSERT INTO aly_test ( id,data) VALUES (1111,-8388608),(1112,0),(1113,8388607)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,16777216)
INSERT INTO aly_test ( id,data) VALUES (111,-1),(112,0),(113,16777216)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,16777215)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint(5) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,16777215)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint(6) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,16777216)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,16777215),(114,16777216),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,16777215)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,16777215)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint(6) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,16777216)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,16777215),(114,16777216),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,16777215)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumint UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,16777215)
SELECT * FROM aly_test
#
#INT[(length)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int)
INSERT INTO aly_test ( id,data) VALUES (1,-2147483649)
INSERT INTO aly_test ( id,data) VALUES (2,2147483648)
INSERT INTO aly_test ( id,data) VALUES (222,-2147483649),(222,-2147483648),(222,0),(222,2147483647),(222,2147483648)
INSERT INTO aly_test ( id,data) VALUES (1111,-2147483648),(1112,0),(1113,2147483647)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int(5))
INSERT INTO aly_test ( id,data) VALUES (1111,-2147483648),(1112,0),(1113,2147483647)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,4294967296)
INSERT INTO aly_test ( id,data) VALUES (111,-1),(112,0),(113,4294967296)
INSERT INTO aly_test ( id,data) VALUES (1111,4294967295),(1112,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int(11) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1111,4294967295),(1112,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int(5) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,-10000)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,10000),(114,100000),(115,-1),(116,-10000)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,1),(1113,10000),(1114,100000)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,1),(1113,10000),(1114,100000)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int(5) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,4294967296)
INSERT INTO aly_test ( id,data) VALUES (3,-1),(4,0),(5,4294967296)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,10),(114,-1000),(115,-10000),(116,-100000),(117,10000),(118,4294967295)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data int UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,10),(114,-1000),(115,-10000),(116,-100000),(117,10000),(118,4294967295)
SELECT * FROM aly_test
#
#INTEGER[(length)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER)
INSERT INTO aly_test ( id,data) VALUES (1,-2147483649)
INSERT INTO aly_test ( id,data) VALUES (2,2147483648)
INSERT INTO aly_test ( id,data) VALUES (222,-2147483649),(222,-2147483648),(222,0),(222,2147483647),(222,2147483648)
INSERT INTO aly_test ( id,data) VALUES (1111,-2147483648),(1112,0),(1113,2147483647)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER(5))
INSERT INTO aly_test ( id,data) VALUES (1111,-2147483648),(1112,0),(1113,2147483647)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,4294967296)
INSERT INTO aly_test ( id,data) VALUES (111,-1),(112,0),(113,4294967296)
INSERT INTO aly_test ( id,data) VALUES (1111,4294967295),(1112,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER(5) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1111,4294967295),(1112,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER(5) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,-10000)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,10000),(114,100000),(115,-1),(116,-10000)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,1),(1113,10000),(1114,100000)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,1),(1113,10000),(1114,100000)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER(5) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,4294967296)
INSERT INTO aly_test ( id,data) VALUES (3,-1),(4,0),(5,4294967296)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,1),(1113,10000),(1114,100000)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data INTEGER UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,1),(1113,10000),(1114,100000)
SELECT * FROM aly_test
#
#BIGINT[(length)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint)
INSERT INTO aly_test ( id,data) VALUES (1,-9223372036854775809)
INSERT INTO aly_test ( id,data) VALUES (2,9223372036854775808)
INSERT INTO aly_test ( id,data) VALUES (222,-9223372036854775809),(222,-9223372036854775808),(222,0),(222,9223372036854775807),(222,9223372036854775808)
INSERT INTO aly_test ( id,data) VALUES (1111,-9223372036854775808),(1112,0),(1113,9223372036854775807)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint(3))
INSERT INTO aly_test ( id,data) VALUES (1111,-9223372036854775808),(1112,0),(1113,9223372036854775807)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (111,-1),(112,0),(113,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,18446744073709551615)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint(3) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,18446744073709551615)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint(6) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,18446744073709551615)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,18446744073709551615),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,18446744073709551615)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,18446744073709551615)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint(6) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1),(2,18446744073709551615)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1),(113,18446744073709551615),(115,-1)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,18446744073709551615)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data bigint UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1111,0),(1112,18446744073709551615)
SELECT * FROM aly_test
#
#FLOAT[(length,decimals)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float)
INSERT INTO aly_test ( id,data) VALUES (1,-123456789012345678901234567890123456789.01234567890)
INSERT INTO aly_test ( id,data) VALUES (2,1234567890123456789012345678901234567890.1234567890)
INSERT INTO aly_test ( id,data) VALUES (222,-1234567890123456789012345678901234567890.12345678901234),(222,-1234567890123456789012345678901234567890.1234567890123),(222,0),(222,1234567890123456789012345678901234567890.12345678901234),(222,-1234567890123456789012345678901234567890.12345678901234)
INSERT INTO aly_test ( id,data) VALUES (1111,-12345678901234567890123.4567890),(1112,0),(1113,12345678901234567890123.4567890)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float(7,3))
INSERT INTO aly_test ( id,data) VALUES (221,0.7777),(222,7777.777),(223,77777.77),(224,0),(225,7777777),(226,777777)
INSERT INTO aly_test ( id,data) VALUES (1111,0.7777),(1112,7777.777),(1114,0),(1116,7777)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616),(3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float(5,3) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float(6,1) ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float(6,1) UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data float UNSIGNED ZEROFILL)
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
#
#DOUBLE[(length,decimals)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1111,-1234567890123456789012345678901234567890.1234567890123),(1112,0),(1113,1234567890123456789012345678901234567890.1234567890123)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double(7,3))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (221,0.7777),(222,7777.777),(223,77777.77),(224,0),(225,7777777),(226,777777)
INSERT INTO aly_test ( id,data) VALUES (1111,0.7777),(1112,7777.777),(1114,0),(1116,7777)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double UNSIGNED)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616),(3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double(5,3) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double(6,1) ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double(6,1) UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data double UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
#
#DECIMAL[(length[,decimals])] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1111,-1234567890123456789012345678901234567890.1234567890123),(1112,0),(1113,1234567890123456789012345678901234567890.1234567890123)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal(7,3))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (221,0.7777),(222,7777.777),(223,77777.77),(224,0),(225,7777777),(226,777777)
INSERT INTO aly_test ( id,data) VALUES (1111,0.7777),(1112,7777.777),(1114,0),(1116,7777)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal UNSIGNED)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616),(3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal(5,3) UNSIGNED)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal(6,1) ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal(6,1) UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data decimal UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
#
#NUMERIC[(length[,decimals])] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'a')
INSERT INTO aly_test ( id,data) VALUES (2,1234567890123456789012345678901234567890123456789012345678901234567)
INSERT INTO aly_test ( id,data) VALUES (2,0.012345678901234567890123456789)
INSERT INTO aly_test ( id,data) VALUES (222,-1234567890123456789012345678901234567890.12345678901234),(222,-1234567890123456789012345678901234567890.1234567890123),(222,0),(222,1234567890123456789012345678901234567890.12345678901234),(222,-1234567890123456789012345678901234567890.12345678901234)
INSERT INTO aly_test ( id,data) VALUES (1111,-12345678901234567890123.4567890),(1112,0),(1113,12345678901234567890123.4567890)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric(7,3))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (221,0.7777),(222,7777.777),(223,77777.77),(224,0),(225,7777777),(226,777777)
INSERT INTO aly_test ( id,data) VALUES (1111,0.7777),(1112,7777.777),(1114,0),(1116,7777)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric UNSIGNED)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616),(3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric(5,3) UNSIGNED)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric(6,1) ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric(6,1) UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data numeric UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
#
#REAL[(length,decimals)] [UNSIGNED] [ZEROFILL]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'a')
INSERT INTO aly_test ( id,data) VALUES (2,1234567890123456789012345678901234567890123456789012345678901234567)
INSERT INTO aly_test ( id,data) VALUES (2,0.012345678901234567890123456789)
INSERT INTO aly_test ( id,data) VALUES (222,-1234567890123456789012345678901234567890.12345678901234),(222,-1234567890123456789012345678901234567890.1234567890123),(222,0),(222,1234567890123456789012345678901234567890.12345678901234),(222,-1234567890123456789012345678901234567890.12345678901234)
INSERT INTO aly_test ( id,data) VALUES (1111,-12345678901234567890123.4567890),(1112,0),(1113,12345678901234567890123.4567890)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real(7,3))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (221,0.7777),(222,7777.777),(223,77777.77),(224,0),(225,7777777),(226,777777)
INSERT INTO aly_test ( id,data) VALUES (1111,0.7777),(1112,7777.777),(1114,0),(1116,7777)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real UNSIGNED)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616),(3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real(5,3) UNSIGNED)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (2,18446744073709551616)
INSERT INTO aly_test ( id,data) VALUES (3,0)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real(6,1) ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real(6,1) UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data real UNSIGNED ZEROFILL)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,-1)
INSERT INTO aly_test ( id,data) VALUES (111,0),(112,1)
SELECT * FROM aly_test
#
#CHAR[(length)] [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data char)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,0)
INSERT INTO aly_test ( id,data) VALUES (2,10)
INSERT INTO aly_test ( id,data) VALUES (2,'a')
INSERT INTO aly_test ( id,data) VALUES (3,'aaaaaaaaaaaa,aaaaaaaaaaaa_aaaaaaaaa%%aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa*aa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data char BINARY)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,0)
INSERT INTO aly_test ( id,data) VALUES (2,10)
INSERT INTO aly_test ( id,data) VALUES (2,'a')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data char(5))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,123456)
INSERT INTO aly_test ( id,data) VALUES (1,'abcdef')
INSERT INTO aly_test ( id,data) VALUES (1,'abcde')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data char(255) CHARACTER SET 'utf8' COLLATE utf8_bin )
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (111,''),(112,'a'),(113,0),(114,'1_23'),(115,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data char(255))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (111,''),(112,'a'),(113,0),(114,'1_23'),(115,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#VARCHAR(length) [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data varchar(0))
INSERT INTO aly_test ( id,data) VALUES (1,123456)
INSERT INTO aly_test ( id,data) VALUES (1,'abcdef')
INSERT INTO aly_test ( id,data) VALUES (1,'abcde')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data varchar(0) BINARY)
INSERT INTO aly_test ( id,data) VALUES (1,123456)
INSERT INTO aly_test ( id,data) VALUES (1,'abcdef')
INSERT INTO aly_test ( id,data) VALUES (1,'abcde')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data varchar(30))
INSERT INTO aly_test ( id,data) VALUES (1,123456)
INSERT INTO aly_test ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdefg')
INSERT INTO aly_test ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdef')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data varchar(30) CHARACTER SET 'utf8' COLLATE utf8_bin )
INSERT INTO aly_test ( id,data) VALUES (1,123456)
INSERT INTO aly_test ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdefg')
INSERT INTO aly_test ( id,data) VALUES (1,'aaaaaaaaaaaaaaaaaaaaaaaaabcdef')
SELECT * FROM aly_test
#
#DATE
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data date)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'201411-11')
INSERT INTO aly_test ( id,data) VALUES (2,'2014/11/11')
INSERT INTO aly_test ( id,data) VALUES (3,'20141111')
INSERT INTO aly_test ( id,data) VALUES (4,'2014-11-11 09:59:59')
INSERT INTO aly_test ( id,data) VALUES (5,'2014-11-11')
INSERT INTO aly_test ( id,data) VALUES (6,'aaaa-01-01')
INSERT INTO aly_test ( id,data) VALUES (7,'999-01-01')
INSERT INTO aly_test ( id,data) VALUES (8,'1000-01-00')
INSERT INTO aly_test ( id,data) VALUES (9,'10000-01-01')
INSERT INTO aly_test ( id,data) VALUES (10,'9999-01-100')
INSERT INTO aly_test ( id,data) VALUES (11,'1000-01-01')
INSERT INTO aly_test ( id,data) VALUES (12,'9999-12-31')
INSERT INTO aly_test( id,date) VALUES (13,'20170201')
INSERT INTO aly_test( id,date) VALUES (14,'170202')
SELECT * FROM aly_test
#
#TIME[(fsp)]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data time)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'201411-11')
INSERT INTO aly_test ( id,data) VALUES (2,'000:00:00')
INSERT INTO aly_test ( id,data) VALUES (2,'00000')
INSERT INTO aly_test ( id,data) VALUES (3,'121212')
INSERT INTO aly_test ( id,data) VALUES (4,'2014-11-11 09:59:59')
INSERT INTO aly_test ( id,data) VALUES (5,'23:59:59')
INSERT INTO aly_test ( id,data) VALUES (6,'24:00:00')
INSERT INTO aly_test ( id,data) VALUES (7,'24:00:01')
INSERT INTO aly_test ( id,data) VALUES (8,'00:00:00')
INSERT INTO aly_test ( id,data) VALUES (9,'23:59:59')
SELECT * FROM aly_test
#
#TIMESTAMP[(fsp)]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data timestamp)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'1970-01-01 00:00:01'),(2,'2038-01-19 03:14:07')
SELECT * FROM aly_test
#
#DATETIME[(fsp)]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data datetime)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'1000-01-01 00:00:00'),(2,'9999-12-31 23:59:59')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test( id int,data1 time(2), data2 datetime(2), data3 timestamp(2))
desc aly_test
INSERT INTO aly_test VALUES(1,'17:51:04.777', '2014-09-08 17:51:04.777', '2014-09-08 17:51:04.777')
SELECT * FROM aly_test
#
#YEAR
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data year)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,1900)
INSERT INTO aly_test ( id,data) VALUES (2,2156)
INSERT INTO aly_test ( id,data) VALUES (3,'2038-01-19 03:14:07')
INSERT INTO aly_test ( id,data) VALUES (4,1901),(5,2156),(6,0000)
SELECT * FROM aly_test
#
#BINARY[(length)]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data binary)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'a')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data binary(5))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'abcdef')
INSERT INTO aly_test ( id,data) VALUES (2,'abcde')
SELECT * FROM aly_test
#
#VARBINARY(length)
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data varbinary(5))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'abcdef')
INSERT INTO aly_test ( id,data) VALUES (1,'abcde')
SELECT * FROM aly_test
#
#TINYBLOB
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinyblob)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#BLOB
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data blob)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a')
SELECT * FROM aly_test
#
#MEDIUMBLOB
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumblob)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#LONGBLOB
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data longblob)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#TINYTEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinytext CHARACTER SET 'utf8' COLLATE utf8_bin)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinytext)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data tinytext binary)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#TEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data text)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data text CHARACTER SET 'utf8' COLLATE utf8_bin )
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data text binary)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#MEDIUMTEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumtext)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test ORDER BY id
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumtext CHARACTER SET 'utf8' COLLATE utf8_bin )
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test ORDER BY id
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data mediumtext)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#LONGTEXT [BINARY] [CHARACTER SET charset_name] [COLLATE collation_name]
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data longtext)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data longtext CHARACTER SET 'utf8' COLLATE utf8_bin )
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data longtext binary)
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,''),(2,'abc'),(3,'123'),(4,'a..a'),(5,'abc 1'),(6,'a_bcdeg'),(7,'__%%%\\'),(8,'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa')
SELECT * FROM aly_test
#
#ENUM(value1,value2,value3,...)
DROP TABLE IF EXISTS  aly_test
CREATE TABLE  aly_test( id int,data enum('enum1','enum2','test_%%%00','enum3','abcd_007'))
desc aly_test
INSERT INTO aly_test ( id,data) VALUES (1,'enum1'),(2,'test_%%%00'),(3,'abcd_007')
SELECT * FROM aly_test
#
#SET(value1,value2,value3,...)
#CREATE TABLE  aly_test( id int,data set('enum1','enum2','test_%%%00','enum3','abcd_007'))
#
#JSON
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test( id int,data json)
INSERT INTO aly_test VALUES(1,'["abc", 10, null, true, false]')
INSERT INTO aly_test VALUES(1,'{"k1": "value", "k2": 10}')
INSERT INTO aly_test VALUES(1,'["12:18:29.000000", "2015-07-29", "2015-07-29 12:18:29.000000"]')
SELECT * FROM aly_test
#
#spatial_type
DROP TABLE IF EXISTS  aly_test
CREATE TABLE aly_test( id int,data GEOMETRY)
INSERT INTO aly_test VALUES(1,POINT(15,20))
SELECT * FROM aly_test
#
#
#set character and collation
DROP TABLE IF EXISTS aly_test
CREATE TABLE aly_test(id int, data varchar(50)character set ascii)
SHOW CREATE TABLE aly_test
INSERT INTO aly_test VALUES (1,'a'),(2,'\'')
SELECT * FROM aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50))character set utf8
SHOW CREATE TABLE aly_test
INSERT INTO aly_test VALUES (1,'a'),(2,'\'')
SELECT * FROM aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50)character set ascii)character set = 'utf8'
SHOW CREATE TABLE aly_test
INSERT INTO aly_test VALUES (1,'a'),(2,'\'')
SELECT * FROM aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50)character set ascii)character set = 'utf8' collate utf8_bin
SHOW CREATE TABLE aly_test
INSERT INTO aly_test VALUES (1,'a'),(2,'\'')
SELECT * FROM aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50)character set big5)
SHOW CREATE TABLE aly_test
INSERT INTO aly_test VALUES (1,'a'),(2,'\'')
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data1 varchar(50)character set dec8, data2 varchar(50)character set cp850, data3 varchar(50)character set hp8, data4 varchar(50)character set koi8r)
INSERT INTO aly_test VALUES (1,'a','b','c','d')
SELECT * FROM aly_test
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data1 varchar(50) character set euckr, data2 varchar(50) character set swe7, data3 varchar(50) character set latin2, data4 varchar(50) character set ujis, data5 varchar(50) character set sjis, data6 varchar(50) character set hebrew, data7 varchar(50) character set tis620, data8 varchar(50) character set koi8u, data9 varchar(50) character set cp1250,data10 varchar(50) character set cp866)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data1 varchar(50) character set keybcs2, data2 varchar(50) character set macce, data3 varchar(50) character set macroman, data4 varchar(50) character set cp852, data5 varchar(50) character set cp1251, data6 varchar(50) character set cp1256, data7 varchar(50) character set cp1257, data8 varchar(50) character set geostd8, data9 varchar(50) character set cp932,data10 varchar(50) character set eucjpms)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set latin1)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set latin1 collate latin1_swedish_ci)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set latin1 collate latin1_bin )
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set gb2312)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set gbk)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set gbk collate gbk_chinese_ci )
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set gbk collate gbk_bin)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set latin5)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf8)
INSERT INTO aly_test VALUES (1,'a'),(2,'\''),(3,'\t'),(4,NULL)
SELECT * FROM aly_test where data = 'a'
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf8 collate utf8_bin)
INSERT INTO aly_test VALUES (1,'a'),(2,'\''),(3,'\t'),(4,NULL)
SELECT * FROM aly_test where data = 'a'
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf8 collate utf8_unicode_ci)
INSERT INTO aly_test VALUES (1,'a'),(2,'\''),(3,'\t'),(4,NULL)
SELECT * FROM aly_test where data = 'a'
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf8mb4)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set latin7)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf16)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf16le)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set utf32)
SHOW CREATE TABLE aly_test
DROP TABLE aly_test
CREATE TABLE aly_test(id int, data varchar(50) character set gb18030)
SHOW CREATE TABLE aly_test
DROP TABLE IF EXISTS aly_test

