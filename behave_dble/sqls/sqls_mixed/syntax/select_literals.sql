#!default_db:schema1
# Created by zhaohongjie at 2019/1/15
#!share_conn
#String Literals
select _latin1'a string'
#select _latin1"a string" COLLATE latin1_danish_ci
select _latin1'a string' COLLATE latin1_danish_ci
select _utf8'a' ' ' 'string'
#select 'a string' COLLATE utf8_general_ci
select 'a\'b', 'a\"b', 'a\0b', 'a\bb', 'a\nb', 'a\rb', 'a\tb', 'a\Zb', 'a\\b', 'a\%b', 'a\_b'
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
#Bit-Field Literals
SET @v1 = 0b1000001
SET @v2 = CAST(0b1000001 AS UNSIGNED), @v3 = 0b1000001+0
SELECT @v1, @v2, @v3
SET @v1 = b'1000001'
SET @v2 = CAST(b'1000001' AS UNSIGNED), @v3 = b'1000001'+0
SELECT @v1, @v2, @v3
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
use schema1
select 1