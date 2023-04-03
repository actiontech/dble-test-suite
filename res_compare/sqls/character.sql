#!share_conn
drop DATABASE if EXISTS mytest  ;
create database mytest ;
#ascii can be transferred to unicode without loss, on the contrary, unicode to ascii maybe loss
#!share_conn
drop table if EXISTS  t1 ;
CREATE TABLE t1 ( c1 CHAR(1) CHARACTER SET latin1, c2 CHAR(1) CHARACTER SET ascii) ;
INSERT INTO t1 VALUES ('a','b') ;
SELECT CONCAT(c1,c2) FROM t1 ;

#!share_conn
drop table if EXISTS  t1 ;
SET NAMES ascii ;
CREATE TABLE t1 (a INT, b VARCHAR(10) CHARACTER SET latin1) ;
INSERT INTO t1 VALUES (1,'b') ;
SELECT CONCAT(FORMAT(a, 4), b) FROM t1 ;
#end share_conn
select CONCAT(_ucs2 X'0041', _ucs2 X'0042') ;
#!share_conn
drop table if exists t ;
create table t(c character(50) character set latin1) default charset=utf8 ;
insert into t select user() ;
insert into t values('汤姆') ;
SELECT * FROM t WHERE c='汤姆' ;
#!share_conn
drop table if exists t ;
CREATE TABLE `t` ( `c` char(50) CHARACTER SET gbk DEFAULT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;
insert into t values('你') ;
select sleep(3) union select * from schema1.t ;
#end share_conn
SELECT _utf8'abc' COLLATE utf8_danish_ci ;
select _ascii'asdf' collate ascii_general_ci ;
select _utf8'你' ;
#!share_conn
SET NAMES sjis ;
SELECT HEX('à\n'), HEX(_latin1'à\n') ;
#!share_conn
set names gbk ;
select '好' ;
SELECT N'hello你' ;
SELECT n'你hello' ;
SELECT _utf8'hello你' ;
#!share_conn
set names default ;
select '好' ;
SELECT n'hello' ;
SELECT _utf8'hello你' ;
#end
drop table if exists t ;
create table t(c nchar(10)) ;
insert into t values('你好') ;
select * from t ;
alter table t change c c national character varying(20) ;
insert into t values('你好2') ;
select * from t ;

#!restart-dble:: {"smp":1,"default_bconn_limit":3}
drop table if EXISTS  t ;
create table t(c char(50)) ;
#!share_conn_1
set names 'gbk' ;
insert into t values('a你')  ;
insert into t values(_utf8'a你')  ;
select * from t ;
select * from t ;
alter table t modify c varchar(50) character set utf8  ;
insert into t values('你')  ;
#!share_conn_2
select * from t ;
set names 'utf8'  ;
insert into t values("e")  ;
insert into t values("我")  ;
select * from t ;
select * from t ;
#!share_conn_1
insert into t values("他")  ;
select * from t/* master */ ;
set character set 'gb2312'  ;
insert into t values("她")  ;
select * from t ;
#!share_conn_2
insert into t values("它")  ;
select * from t ;
set character set 'ascii'  ;
insert into t values("它a")  ;
select * from t ;
#!share_conn_1
insert into t values("他a")  ;
select * from t ;
truncate t  ;
set names utf8  ;
insert into t values("它");
select * FROM t ;
#!share_conn_2
insert into t values("她");
select * FROM t ;
set @@character_set_results=NULL ;
insert into t values("你");
select * FROM t ;
#!share_conn_1
insert into t values("我");
select * FROM t ;
drop table t;
#!restart-dble:: {"smp":4,"default_bconn_limit":64}