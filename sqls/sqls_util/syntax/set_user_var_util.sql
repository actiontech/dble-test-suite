#!default_db:schema1
# Created by zhaohongjie at 2019/1/16
drop table if exists test1
drop table if exists schema2.test2
drop table if exists schema3.test3
create table test1(a int(4), B int(4))
insert into test1 values (10, 1),(10, 1),(11,1),(10, 1)
create table schema2.test2(a int(4), B int(4))
insert into schema2.test2 values (10, 1),(11, 2),(10,2)
create table schema3.test3(a int(4), B int(4))
insert into schema3.test3 values (12, 1),(11, 1),(10,11)
(SELECT @vara:=a FROM test1 WHERE a=10 AND B=1) UNION (SELECT @varb:=B FROM schema2.test2 WHERE a=@vara AND B=2) UNION (SELECT a FROM schema3.test3 WHERE a=@vara+@varb AND B=1)

drop table if exists test1
drop table if exists schema2.test2
create table test1(id int(4), datetime timestamp, widgetID int(8), message varchar(255), active boolean)
create table schema2.test2(id int(4), datetime timestamp, widgetID int(8), message varchar(255), active boolean)
insert into test1 values(1, 20160825174312, 90, 'hello world', 0),(2, 20160823174313, 100, 'hello python', 1),(3, 20160822174314, 100, 'hello java', 1)
insert into schema2.test2 values(1, 20160825174312, 90, 'hello world', 0),(2, 20160823174313, 100, 'hello php', 1),(3, 20160822174314, 100, 'hello c++', 0)
#!share_conn
set @vara=9
set @varb=9
SELECT @vara,  @varb, mydata.message FROM( (SELECT @vara := 99, datetime, message FROM test1 WHERE widgetID = 100 AND active = 1) UNION (SELECT @varb := 100, datetime, message FROM schema2.test2 WHERE widgetID = 100 AND active = 0) ) mydata ORDER BY mydata.datetime, @vara ASC /*allow_diff_sequence*/

DROP TABLE IF EXISTS test1
create table test1(article int(4), dealer varchar(10), price float(8,2))
insert into test1 values(1, 'D', 234.25),(2, 'D', 67.29),(3, 'D', 1.25),(4,'D',19.95)
SELECT @min_price:=MIN(price),@max_price:=MAX(price) FROM test1
SELECT * FROM test1 WHERE price=@min_price OR price=@max_price
SELECT (@aa:=article) AS a, (@aa+3) AS b FROM test1 HAVING b=5

drop table if exists test1
create table test1(id int)
insert into test1 values(1),(3),(5),(7)
UPDATE test1 SET id = 2 WHERE id = @var1:= 1
SELECT @var1 := 1, @var2
SELECT @var1, @var2 := @var1

SET @total_tax = (SELECT SUM(id) FROM aly_test)
SELECT @total_tax