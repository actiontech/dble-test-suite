#!default_db:schema1
#prepare
drop table if exists test1
create table test1 (id int(11) primary key,R_REGIONKEY float,R_NAME varchar(50),R_COMMENT varchar(50))DEFAULT CHARSET=UTF8
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'a string','test001'),(3,3, 'another string','test003'),(2,2, 'a\nstring','test002'),(4,4, '中','test004'),(5,5, 'a\'string\'','test005'),(6,6, 'a\""string\""','test006'),(7,7, 'a\bstring','test007'),(8,8, 'a\nstring','test008'),(9,9, 'a\rstring','test009'),(10,10, 'a\tstring','test010'),(11,11, 'a\zstring','test011'),(12,12, 'a\\string','test012'),(13,13, 'a\%string','test013'),(14,14, 'a\_string','test014'),(15,15, 'MySQL','test015'),(16,16, 'binary','test016'),(65,16, 'binary','test016'),(17,12345678901234567890123.4567890,17,17),(18,18, 'A','test018'),(19,19, '','test019')
#test
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a string'
select id,'a  string' from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME="another string"
select id,"another string" from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a' ' ' 'string'
select id,'a' ' ' 'string' from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=_utf8'中'
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,_utf8'中' from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=_utf8'中'COLLATE utf8_danish_ci
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,_utf8'中'COLLATE utf8_danish_ci from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\'string\''
select id,'\'string\'',R_NAME from test1
select * from test1 where R_NAME='a\"string\"'
select id,'\"string\"',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\bstring'
select id,'\b',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\nstring'
select id,'\n',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\rstring'
select id,'\r',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\tstring'
select id,'\t',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\zstring'
select id,'\z',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\\string'
select id,'\\',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\%string'
select id,'\%',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME='a\_string'
select id,'\_',R_NAME from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=(select X'4D7953514C')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,X'4D7953514C' from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=(select CHARSET(X'4D7953514C'))
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id=(select X'41'+0)
select id,R_REGIONKEY+0 from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=(SELECT CHARSET(b''))
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,b'' from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=_latin1 b'1000001'
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=_utf8 0b1000001 COLLATE utf8_danish_ci
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,_latin1 b'1000001' from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where R_NAME=B'1000001'
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id=(select true)
select true from test1
select TRUE from test1
select false from test1
select FALSE from test1
select R_NAME from test1
select test1.R_NAME from test1
select schema1.test1.R_NAME from test1
select R_NAME as a from test1
select R_NAME a from test1
SELECT (@aa:=id) AS a, (@aa+3) AS b FROM test1
SELECT @@global.sql_mode
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id=1||id=3
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where +id=1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where ~id=1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where !id=1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where ~(id=1)
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where !(id=10)
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where binary id=1
select a.id,a.R_REGIONKEY,a.R_NAME,a.R_COMMENT from (select * from test1)a
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where exists(select * from test1 where id>1)
select R_name name from test1
select DATE_SUB(CURDATE(),INTERVAL 30 DAY)
select * from test1 where DATE_SUB(CURDATE(),INTERVAL 30 DAY)=2017-08-13
#
#bit_expr
#
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' | B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' | B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 | B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 | B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' & B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' & B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 & B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 & B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' << B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' << B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 << B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 << B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' >> B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' >> B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 >> B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 >> B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' + B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' + B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 + B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 + B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' - B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' - B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 - B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 - B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' * B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' * B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 * B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 * B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' / B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' / B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 / B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 / B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' div B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' div B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 div B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 div B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' mod B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' mod B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 mod B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 mod B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' % B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' % B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 % B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 % B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' ^ B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' ^ B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 ^ B'11')
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 ^ B'11') from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' + interval 30 day)
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' + interval 30 day) from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 + interval 1 year)
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 + interval 1 year) from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (b'01' - interval 30 day)
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(b'01' - interval 30 day) from test1
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT from test1 where id= (0b01 - interval 1 year)
select test1.id,test1.R_REGIONKEY,test1.R_NAME,test1.R_COMMENT,(0b01 - interval 1 year) from test1
#
#predicate
#
drop table if exists test1
create table test1 (id int(11) primary key,R_bit bit(64),R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_bit,R_NAME,R_COMMENT) values (1,b'0001', 'a','test001'),(2,b'0010', 'a string','test002'),(3,b'0011', '1','test001'),(4,b'1010', '1','test001')
-- select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where b'1000001' not in (select R_NAME from test1 where id =1)
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where b'1000001'  in (select R_NAME from test1 where id =18)
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where 0b01  in (select R_NAME from test1 where id =18)
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where b'01' not in (1,'string')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where b'01' not in (10,'string')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where 0b01 in (1,'string')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where 0b01 in (10,'string')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where HEX(R_bit) not between 0b11+0 and (select HEX(R_bit) from test1 where HEX(R_bit) not in (select HEX(R_bit) from test1 where id <4))
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where HEX(R_bit) between 0b10+0 and (select HEX(R_bit) from test1 where HEX(R_bit) not in (1,2,3))
select HEX(R_bit) not like (select 1) from test1
select HEX(R_bit) like (select 1) from test1
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where HEX(R_bit) like (select '%A%') escape (select '%')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where HEX(R_bit) not like (select '%A%') escape (select '%')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where HEX(R_bit)  not regexp '^A'
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where HEX(R_bit)  regexp '^A'
#
#boolean_primary
#
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true is not null
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where false is null
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true <=> (HEX(R_bit) not in (select HEX(R_bit) from test1 where id <4))
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true = (HEX(R_bit) not in (select HEX(R_bit) from test1 where id <4))
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true >= (HEX(R_bit) not in (select HEX(R_bit) from test1 where id <4))
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true > (HEX(R_bit) between 0b10+0 and (select HEX(R_bit) from test1 where HEX(R_bit) not in (1,2,3)))
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true <=(select HEX(R_bit) not like (select 2) from test1 order by id limit 1) order by test1.id
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where false <(select HEX(R_bit) like (select 1) a from test1 order by a limit 1)
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where false <> (select HEX(R_bit) from test1 where HEX(R_bit)  not regexp '^A' limit 1 )
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true != (select HEX(R_bit) from test1 where HEX(R_bit) regexp '^A' limit 1 )
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true is not true
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where !(true is not true)
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where false is false
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where !(false is false)
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where true is unknown
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where !(true is unknown)
#
#expr
#
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where (HEX(R_bit) like (select 1))or(HEX(R_bit) regexp '^A')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where (HEX(R_bit) like (select 1))||(HEX(R_bit) regexp '^A')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where (HEX(R_bit) like (select 1))XOR(HEX(R_bit) regexp '^A')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where (HEX(R_bit) not like (select 1))and(HEX(R_bit) regexp '^A')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where (HEX(R_bit) not like (select 1))&&(HEX(R_bit) regexp '^A')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where not(HEX(R_bit) regexp '^A')
select test1.id,test1.R_bit,test1.R_NAME,test1.R_COMMENT from test1 where !(HEX(R_bit) regexp '^A')
#
#clear tables
#
drop table if exists test1