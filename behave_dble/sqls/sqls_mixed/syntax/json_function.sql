#!default_db:schema2
# Created by wangjuan at 2022/09/27
#
drop table if exists sharding_4_t2;
drop table if exists sharding_1_t3;
drop table if exists global_4_t1;
CREATE TABLE sharding_1_t3(user_id int, user_name varchar(64), mobile varchar(12), user_type tinyint(2), user_status tinyint(2), user_info json, user_source tinyint(2), create_time datetime, modify_time datetime, des varchar(512), PRIMARY KEY (`user_id`)) DEFAULT CHARSET=utf8mb4;
CREATE TABLE global_4_t1(goods_id int, goods_name varchar(100), goods_desc varchar(2000), goods_status tinyint(2), goods_price double(9,2), create_time datetime,  modify_time datetime, auditor varchar(40), audit_time datetime,audit_option varchar(512), online_start_date date, online_end_date date, PRIMARY KEY (`goods_id`)) DEFAULT CHARSET=utf8mb4;
CREATE TABLE sharding_4_t2(id int, goods_id int, goods_name varchar(64), user_id int, mobile varchar(12), order_type tinyint(2), order_status tinyint(2), order_price json, order_source tinyint(2), addr varchar(512), pay_time datetime, create_time datetime, modify_time datetime, PRIMARY KEY (`id`)) DEFAULT CHARSET=utf8mb4;
insert into sharding_1_t3 values (1, 'user1', '13112345678', 10, 10,'{"age":20, "sex":"女", "name":"Anna", "address":"Shanghai"}', 10, '2022-08-01 14:23:11', null, null);
insert into sharding_1_t3 values (2, 'user2', '13212345678', 10, 10,'{"age":22, "sex":"男", "name":"Alex", "address":"Beijing"}', 10, '2022-08-21 14:23:11', null, null);
insert into sharding_1_t3 values (3, 'user3', '13312345678', 20, 10,'{"age":30, "sex":"女", "name":"Tina", "address":"GuangZhou"}', 20, '2022-08-08 14:23:11', null, null);
insert into sharding_1_t3 values (4, 'user4', '13412345678', 10, 10,'{"age":24, "sex":"女", "name":"Lily", "address":"Shanghai"}', 30, '2022-07-01 14:23:11', null, null);
insert into global_4_t1 values (1,'goods1','{"product_date":"2022-10-01", "product_addr":"Beijing", "exp_date":"2023-10-01"}', 40, 100,'2022-09-03 12:23:45',null,'auditor1','2022-09-23 12:23:45','{"success": "true","code": 0,"message": "","data": {"name": "Lucy","age": 22,"sex": "女"}}', '2022-09-03', '2022-12-01');
insert into global_4_t1 values (2,'goods2','{"product_date":"2022-09-01", "product_addr":"Beijing", "exp_date":"2023-08-31"}', 30, 500,'2022-09-03 12:23:45',null,'auditor1','2022-10-13 12:23:45','{"success": "true","code": 0,"message": "","data": {"name": "Lucy","age": 22,"sex": "女"}}', '2022-09-03', '2022-12-01');
insert into global_4_t1 values (3,'goods3','{"product_date":"2022-10-08", "product_addr":"Beijing", "exp_date":"2022-12-31"}', 40, 180,'2022-09-03 12:23:45',null,'auditor1','2022-09-30 12:23:45','{"success": "true","code": 0,"message": "","data": {"name": "Tim", "age": 28,"sex": "男"}}', '2022-09-03', '2022-12-01');
insert into global_4_t1 values (4,'goods4','{"product_date":"2022-09-21", "product_addr":"Shanghai", "exp_date":"2022-12-31"}', 40, 600,'2022-09-03 12:23:45',null,'auditor1','2022-10-03 12:23:45','{"success": "true","code": 0,"message": "","data": {"name": "Kevin","age": 20,"sex":"男"}}', '2022-09-03', '2022-12-01');
insert sharding_4_t2 values (1, 1,'goods1', 1,'13112345678', 10, 99,'{"cash":{"amt":10,"unitDesc": "元"},"point": {"amt": 1000, "unitDesc": "积分"}}', 10,'[{"provice":"Shanghai", "city":"Shanghai"},{"provice":"Zhejiang","city":"Hangzhou"}]', '2022-09-05 13:20:14', '2022-09-05 13:00:23', '2022-09-05 13:18:26');
insert sharding_4_t2 values (2, 3,'goods3', 3,'13312345678', 10, 10,'{"cash":{"amt":100,"unitDesc": "元"},"point": {"amt": 288, "unitDesc": "积分"}}', 10,'[{"provice":"Shanghai", "city":"Shanghai"},{"provice":"Guangdong","city":"Shenzhen"}]', '2022-09-15 13:20:14', '2022-09-15 13:00:23', '2022-09-15 13:18:26');
insert sharding_4_t2 values (3, 4,'goods4', 3,'13312345678', 20, 99,'{"cash":{"amt":50,"unitDesc": "元"},"point": {"amt": 388, "unitDesc": "积分"}}', 10,'[{"provice":"Beijing", "city":"Beijing"},{"provice":"Zhejiang","city":"Hangzhou"}]', '2022-09-06 13:20:14', '2022-09-06 13:00:23', '2022-09-06 13:18:26');
insert sharding_4_t2 values (4, 2,'goods2', 4,'13412345678', 10, 20,'{"cash":{"amt":150,"unitDesc": "元"},"point": {"amt": 299, "unitDesc": "积分"}}', 10,'[{"provice":"GuangDong", "city":"Guangzhou"},{"provice":"Zhejiang","city":"Hangzhou"}]', '2022-09-06 13:20:14', '2022-09-06 13:00:23', '2022-09-06 13:18:26');
insert sharding_4_t2 values (5, 1,'goods1', 4,'13412345678', 10, 10,'{"cash":{"amt":40,"unitDesc": "元"},"point": {"amt": 488, "unitDesc": "积分"}}', 10,'[{"provice":"GuangDong", "city":"Shenzhen"},{"provice":"Zhejiang","city":"Hangzhou"}]', '2022-09-12 13:20:14', '2022-09-12 13:00:23', '2022-09-12 13:18:26');
insert sharding_4_t2 values (6, 2,'goods2', 4,'13412345678', 0,  99,'{"cash":{"amt":310,"unitDesc": "元"},"point": {"amt": 388, "unitDesc": "积分"}}', 10,'[{"provice":"Beijing", "city":"Beijing"},{"provice":"GuangDong","city":"Shenzhen"}]', '2022-09-12 13:20:14', '2022-09-12 13:00:23', '2022-09-12 13:18:26');
insert sharding_4_t2 values (7, 2,'goods2', 4,'13412345678', 20, 99,'{"cash":{"amt":120,"unitDesc": "元"},"point": {"amt": 1200, "unitDesc": "积分"}}', 10,'[{"provice":"Shanghai", "city":"Shanghai"},{"provice":"Zhejiang","city":"Hangzhou"}]', '2022-09-10 13:20:14', '2022-09-10 13:00:23', '2022-09-10 13:18:26');
insert sharding_4_t2 values (8, 4,'goods4', 1,'13112345678', 10, 10,'{"cash":{"amt":70,"unitDesc": "元"},"point": {"amt": 580, "unitDesc": "积分"}}', 10,'[{"provice":"GuangDong", "city":"Shenzhen"},{"provice":"Zhejiang","city":"Hangzhou"}]', '2022-09-05 13:20:14', '2022-09-05 13:00:23', '2022-09-05 13:18:26');
select goods_id from global_4_t1 where goods_status=40 and JSON_EXTRACT(goods_desc,'$.product_date') <= DATE_FORMAT("2022-10-01",'%Y-%m-%d') AND DATE_FORMAT("2022-10-01",'%Y-%m-%d') <= JSON_EXTRACT(goods_desc,'$.exp_date');
select id,goods_id,goods_name,user_id,mobile,order_type,order_status,JSON_UNQUOTE(order_price) AS orderPrice,json_extract(addr,'$.provice[0]') AS firstAddr from sharding_4_t2 where user_id=1;
#!multiline
SELECT a.goods_id AS goodsId,b.goods_name AS goodsName,if(a.order_type=0,"00",cast(a.order_type as CHAR)) AS orderType,SUM(a.order_price->'$.point.amt') AS pointAmount,SUM(a.order_price->'$.cash.amt') AS cashAmount,count(*) AS orderCount
FROM sharding_4_t2 a,global_4_t1 b WHERE a.order_status>='60' AND a.goods_id=b.goods_id AND a.create_time >= '2022-10-01' AND a.create_time < DATE_ADD('2022-10-01',INTERVAL 1 DAY ) GROUP BY b.goods_id;
#end multiline
#!multiline
SELECT t1.goods_id as goodsId,t2.user_id as userId,t3.goods_name as goodsName,JSON_UNQUOTE(t3.goods_desc) AS goodsDesc,count(0) as orderCount FROM sharding_4_t2 t1, sharding_1_t3 t2, global_4_t1 t3
WHERE t1.goods_id = t3.goods_id AND (t1.order_status=99 or (t1.order_status=10 AND DATE_FORMAT(t3.audit_time,'%Y-%c-%d')>='2022-10-01'))
AND JSON_EXTRACT(goods_desc,'$.product_date') <= DATE_FORMAT('2022-10-01','%Y-%m-%d') AND DATE_FORMAT('2022-10-01','%Y-%m-%d') <= JSON_EXTRACT(goods_desc,'$.exp_date') AND t1.user_id=t2.user_id
GROUP BY t3.goods_id,t2.user_id ORDER BY  CONVERT(t3.goods_name USING gbk),t2.user_id ASC;
#end multiline
#!multiline
select goodsId, goodsName, userId, pointAmount, cashAmount, orderCnt from (
select g1.goods_id goodsId, g1.goods_name goodsName, s1.user_id userId, SUM(s1.order_price->'$.point.amt') AS pointAmount,SUM(s1.order_price->'$.cash.amt') AS cashAmount,count(0) orderCnt
from global_4_t1 g1 right join sharding_4_t2 s1 on g1.goods_id=s1.goods_id
WHERE (s1.order_status=99 or (s1.order_status=10 AND DATE_FORMAT(g1.online_start_date,'%Y-%c-%d')>='2022-10-01'))
AND JSON_EXTRACT(g1.goods_desc,'$.product_date') <= DATE_FORMAT('2022-10-01','%Y-%m-%d') AND DATE_FORMAT('2022-10-01','%Y-%m-%d') <= JSON_EXTRACT(g1.goods_desc,'$.exp_date')
group by g1.goods_id,s1.user_id) u1 where u1.userId not in (select user_id from sharding_1_t3 where user_source=20)
union
select goodsId, goodsName, userId, pointAmount, cashAmount, orderCnt from (
select t1.goods_id goodsId, t1.goods_name goodsName, t1.user_id userId, SUM(t1.order_price->'$.point.amt') AS pointAmount,SUM(t1.order_price->'$.cash.amt') AS cashAmount,count(0) orderCnt
from sharding_4_t2 t1 left join sharding_1_t3 t2 on t1.user_id = t2.user_id
WHERE (t1.order_status=99 or (t1.order_status=10 AND DATE_FORMAT(t2.create_time,'%Y-%c-%d')>='2022-08-01'))
AND JSON_EXTRACT(t1.order_price,'$.cash.amt') >= 100 OR JSON_EXTRACT(t1.order_price,'$.point.amt') <= 500 group by t1.goods_id,t1.user_id) u2
order by goodsId,cashAmount,pointAmount,orderCnt;
#end multiline
#
# from mysql-test
drop table if exists schema1.test1;
CREATE TABLE schema1.test1(id int primary key, f1 JSON);
INSERT INTO schema1.test1 VALUES (1,'{"a":1}'), (2,'{"a":3}'), (3,'{"a":2}'), (4,'{"a":11, "b":3}'), (5,'{"a":33, "b":1}'), (6,'{"a":22,"b":2}');
SELECT t1.f1->"$.a",t1.f1->"$.b",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id and t1.f1->"$.b" > 1 order by t1.id;
SELECT MAX(t1.f1->"$.a"), t1.f1->"$.b",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id GROUP BY t1.f1->"$.b";
INSERT INTO schema1.test1 VALUES (7,'{"t":"a"}'),(8,'{"t":"b"}'),(9,'{"t":"c"}');
SELECT t1.f1->"$.t",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id AND t1.f1->"$.t" <> 'NULL' order by t1.id;
SELECT t1.f1->>"$.t",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id AND t1.f1->>"$.t" <> 'NULL' order by t1.id;
SELECT t1.f1 ->> "NULL",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT t1.f1->>"NULL",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT t1.f1->>"!@#",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT json_extract(t1.f1,NULL),t2.addr->>'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT t1.f1->>NULL,t2.addr->>'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT json_extract(COUNT(t1.*),"$.t"),t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT COUNT(t1.*)->>"$.t",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT json_extract(MIN(t1.f1),"$[1]"),t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
SELECT MIN(t1.f1)->>"$[1]",t2.addr->'$.city[1]' FROM schema1.test1 t1,sharding_4_t2 t2 WHERE t1.id=t2.id;
INSERT INTO schema1.test1 VALUES (10,'[{"a":1}, {"a": 2}]'), (11,'{ "a":"foo", "b":[true, {"c":123, "c":456}]}'), (12,'{"a":"foo", "b":[true, {"c":"123"}]}'),(13,'{"a":"foo", "b":[true, {"c":123}]}');
SELECT t1.f1->>"$**.b",cast(json_unquote(json_extract(t1.f1,"$**.b")) as char),cast(t1.f1->>"$**.b" as char) <=> cast(json_unquote(json_extract(t1.f1,"$**.b")) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>"$.c",cast(json_unquote(json_extract(t1.f1,"$.c")) as char),cast(t1.f1->>"$.c" as char) <=> cast(json_unquote(json_extract(t1.f1,"$.c")) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$.b[1].c',cast(json_unquote(json_extract(t1.f1,'$.b[1].c')) as char),cast(t1.f1->>'$.b[1].c' as char)<=>cast(json_unquote(json_extract(t1.f1,'$.b[1].c')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->'$.b[1].c',cast(json_extract(t1.f1,'$.b[1].c') as char), cast(t1.f1->'$.b[1].c' as char)<=>cast(json_extract(t1.f1,'$.b[1].c') as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$.b[1]',cast(json_unquote(json_extract(t1.f1,'$.b[1]')) as char), cast(t1.f1->>'$.b[1]' as char) <=> cast(json_unquote(json_extract(t1.f1,'$.b[1]')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$[0][0]',cast(json_unquote(json_extract(t1.f1,'$[0][0]')) as char),cast(t1.f1->>'$[0][0]' as char) <=> cast(json_unquote(json_extract(t1.f1,'$[0][0]')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$**[0]',cast(json_unquote(json_extract(t1.f1,'$**[0]')) as char),cast(t1.f1->>'$**[0]' as char) <=> cast(json_unquote(json_extract(t1.f1,'$**[0]')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->> '$.a[0]',cast(json_unquote(json_extract(t1.f1, '$.a[0]')) as char),cast(t1.f1->> '$.a[0]' as char) <=> cast(json_unquote(json_extract(t1.f1,'$.a[0]')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$[0].a[0]',cast(json_unquote(json_extract(t1.f1,'$[0].a[0]')) as char),cast(t1.f1->>'$[0].a[0]' as char) <=> cast(json_unquote(json_extract(t1.f1,'$[0].a[0]')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$**.a',cast(json_unquote(json_extract(t1.f1,'$**.a')) as char),cast(t1.f1->>'$**.a' as char) <=> cast(json_unquote(json_extract(t1.f1,'$**.a')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$[0][0][0].a',cast(json_unquote(json_extract(t1.f1,'$[0][0][0].a')) as char),cast(t1.f1->>'$[0][0][0].a' as char) <=> cast(json_unquote(json_extract(t1.f1,'$[0][0][0].a')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$[*].b',cast(json_unquote(json_extract(t1.f1,'$[*].b')) as char),cast(t1.f1->>'$[*].b' as char) <=> cast(json_unquote(json_extract(t1.f1,'$[*].b')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
SELECT t1.f1->>'$[*].a',cast(json_unquote(json_extract(t1.f1,'$[*].a')) as char),cast(t1.f1->>'$[*].a' as char) <=> cast(json_unquote(json_extract(t1.f1,'$[*].a')) as char),t2.addr->'$.province[0]' FROM schema1.test1 t1,sharding_4_t2 t2 where t1.id=t2.id order by t1.id;
#drop table if exists sharding_4_t2;
#drop table if exists sharding_1_t3;
#drop table if exists global_4_t1;
#drop table if exists schema1.test1;