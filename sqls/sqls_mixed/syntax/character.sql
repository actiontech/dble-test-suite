#!default_db:schema1
#ascii can be transferred to unicode without loss, on the contrary, unicode to ascii maybe loss
#!share_conn
drop table if EXISTS  sharding_4_t1
CREATE TABLE sharding_4_t1 ( id CHAR(1) CHARACTER SET latin1, c2 CHAR(1) CHARACTER SET ascii)
INSERT INTO sharding_4_t1 VALUES (1,'b')
SELECT CONCAT(id,c2) FROM sharding_4_t1
#!share_conn
drop table if EXISTS  sharding_4_t1
SET NAMES ascii
CREATE TABLE sharding_4_t1 (id INT, b VARCHAR(10) CHARACTER SET latin1)
INSERT INTO sharding_4_t1 VALUES (1,'b')
SELECT CONCAT(FORMAT(id, 4), b) FROM sharding_4_t1
#end share_conn
select CONCAT(_ucs2 X'0041', _ucs2 X'0042')
#!share_conn
drop table if exists sharding_4_t1
create table sharding_4_t1(id INT ,c varchar(50) character set latin1) default charset=utf8
insert into sharding_4_t1 select user()
insert into sharding_4_t1 values(1,'汤姆')
SELECT * FROM sharding_4_t1 WHERE c='汤姆'
#!share_conn
drop table if exists sharding_4_t1
CREATE TABLE `sharding_4_t1` (id INT ,`c` char(50) CHARACTER SET gbk DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8
insert into sharding_4_t1 values(1,'你')
select sleep(3) union select `c` int not null` from sharding_4_t1
#end share_conn
SELECT _utf8'abc' COLLATE utf8_danish_ci
select _ascii'asdf' collate ascii_general_ci
select _utf8'你'
#!share_conn
SET NAMES sjis
SELECT HEX('à\n'), HEX(_latin1'à\n')
#!share_conn
set names gbk
select '好'
SELECT N'hello你'
SELECT n'你hello'
SELECT _utf8'hello你'
#!share_conn
set names default
select '好'
SELECT n'hello'
SELECT _utf8'hello你'
#end
drop table if exists sharding_4_t1
create table sharding_4_t1(id int,c nchar(10))
insert into sharding_4_t1 values(1,'你好')
select * from sharding_4_t1
alter table sharding_4_t1 change c c national character varying(20)
insert into sharding_4_t1 values(2,'你好2')
select * from sharding_4_t1
#
drop table if EXISTS  sharding_4_t1
create table sharding_4_t1(id INT,c char(50))
#!share_conn_1
set names 'gbk'
insert into sharding_4_t1 values(1,'a你')
insert into sharding_4_t1 values(2,_utf8'a你')
select * from sharding_4_t1;
select * from sharding_4_t1
alter table sharding_4_t1 modify c varchar(50) character set utf8
insert into sharding_4_t1 values(3,'你')
#!share_conn_2
select * from sharding_4_t1;
set names 'utf8'
insert into sharding_4_t1 values("e")
insert into sharding_4_t1 values(4,"我")
select * from sharding_4_t1;
select * from sharding_4_t1
#!share_conn_1
insert into sharding_4_t1 values(5,"他")
select * from sharding_4_t1 ;
set character set 'gb2312'
insert into sharding_4_t1 values(6,"她")
select * from sharding_4_t1;
#!share_conn_2
insert into sharding_4_t1 values(7,"它")
select * from sharding_4_t1;
set character set 'ascii'
insert into sharding_4_t1 values(8,"它a")
select * from sharding_4_t1;
#!share_conn_1
insert into sharding_4_t1 values(9,"他a")
select * from sharding_4_t1;
truncate sharding_4_t1
set names utf8
insert into sharding_4_t1 values(1,"它");
select * FROM sharding_4_t1
#!share_conn_2
insert into sharding_4_t1 values(2,"她");
select * FROM sharding_4_t1
set @@character_set_results=NULL ;
insert into sharding_4_t1 values(3,"你");
select * FROM sharding_4_t1
#!share_conn_1
insert into sharding_4_t1 values(4,"我");
select * FROM sharding_4_t1
drop table sharding_4_t1;
#
#clear tables
#
drop table if exists sharding_4_t1