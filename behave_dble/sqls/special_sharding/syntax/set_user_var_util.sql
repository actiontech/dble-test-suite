#!default_db:schema1
# Created by zhaohongjie at 2019/1/16
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
#!share_conn
#-- preprepare and case set
drop table if exists sharding_2_t1;
drop table if exists schema2.sharding_3_t1;
create table sharding_2_t1(id int(4), B float(8,2)) ;
insert into sharding_2_t1 values(1,234.25),(2,67.29),(3,1.25),(12,1),(1,234.25) ;
create table schema2.sharding_3_t1(id int(4), B int(4)) ;
insert into schema2.sharding_3_t1 values (10, 1),(11, 2),(10,2) ;
set @min_price=1.25,@max_price=234.25;
set @id_a=2,@id_b=10,@B=5;
#-- case select
SELECT * FROM sharding_2_t1 WHERE B=@min_price OR B=@max_price;
SELECT * FROM sharding_2_t1 GROUP BY id HAVING id=@id_a;
#-- case join
SELECT * FROM sharding_2_t1 a left join schema2.sharding_3_t1 c  on a.id=c.id and a.id=@id_a;
#-- case union
(SELECT id FROM sharding_2_t1 WHERE id=@id_a AND B=67.29) UNION (SELECT id FROM schema2.sharding_3_t1 WHERE id=@id_b AND B=2) order by @id_a ;
#-- hang for bug 1453:(SELECT id FROM sharding_2_t1 WHERE id=@id_a AND B=67.29) UNION (SELECT id FROM schema2.sharding_3_t1 WHERE id=@id_b AND B=2) UNION (SELECT id FROM sharding_2_t1 WHERE id=@id_a+@id_b AND B=1) order by @id_a ;
#-- case subquery
select (select id from sharding_2_t1 where id=@id_a) as c from (select B from schema2.sharding_3_t1 where id=@id_b) as a;
#-- case update
update schema2.sharding_3_t1 set B=B+@id_a where id=@id_b order by @id_a;
select * from schema2.sharding_3_t1;
#-- case delete
delete from schema2.sharding_3_t1 where id<=@id_b order by @id_a;
select * from schema2.sharding_3_t1;
#-- case insert
insert into schema2.sharding_3_t1 values(10, @id_a-1);
insert into schema2.sharding_3_t1 set id=10, B=@id_a;
select * from schema2.sharding_3_t1;
#-- case replace
REPLACE INTO sharding_2_t1 VALUES (1, @B);
REPLACE INTO sharding_2_t1 set id=1, B=@B;
select * from schema2.sharding_3_t1;
#-- case 'load data'
#-- error for bug 1456:load data infile './conf/test.txt' into table sharding_2_t1 fields terminated by ","(id, @myid, @myB) set B=@myB+1;
#-- error for bug 1456:select * from sharding_2_t1;
#-- error for bug 1456:select @myid,@myB;
#-- case prepare
set @mystmt='insert into sharding_2_t1 values(?,?)';
prepare stmt from @mystmt;
execute stmt using @id_a, @B;
select * from sharding_2_t1;
drop prepare stmt;