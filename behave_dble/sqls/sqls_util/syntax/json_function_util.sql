#!default_db:schema1
# Created by wangjuan at 2022/09/27
#
drop table if exists test1;
create table test1 (id int, data json) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO test1 VALUES (1, '{"Tel": "13222323244", "name": "2022-09-20 13:00:00", "address": "Beijing","sex": "男"}');
INSERT INTO test1 VALUES (2, '{"Tel": true, "name": "Mike", "address": "Guangzhou","sex": "男"}');
INSERT INTO test1 VALUES (3, '{"Tel": "13012345678", "name": "Tim", "address": ""}');
INSERT INTO test1 VALUES (4, '{"Tel": 13312389765, "name": "Lucy", "address": "Shenzhen","sex": "女"}');
# JSON_EXTRACT
SELECT id, JSON_EXTRACT(data, "$.Tel"),JSON_EXTRACT(data, "$.name"),JSON_EXTRACT(data, "$.address") FROM test1;
SELECT id, JSON_EXTRACT(data, "$.Tel","$.name","$.address") FROM test1 order by data;
SELECT id, JSON_EXTRACT(data, "$.Tel"),JSON_EXTRACT(data, "$.name"),JSON_EXTRACT(data, "$.address") FROM test1 order by cast(data as char);
SELECT id, JSON_EXTRACT(data, "$.Tel","$.name","$.address") FROM test1 WHERE id=3;
SELECT id, JSON_EXTRACT(data, "$.Tel"),JSON_EXTRACT(data, "$.name"),JSON_EXTRACT(data, "$.address") FROM test1 WHERE JSON_EXTRACT(data, "$.address")="Guangzhou" ORDER BY JSON_EXTRACT(data, "$.Tel") DESC;
SELECT JSON_EXTRACT(data,'$.address'),count(0) FROM test1 GROUP BY JSON_EXTRACT(data, '$.address') ORDER BY count(0) DESC,JSON_EXTRACT(data, '$.address');
SELECT JSON_EXTRACT(data,'$.address'),count(0) FROM test1 GROUP BY JSON_EXTRACT(data, '$.address') ORDER BY JSON_EXTRACT(data,'$.address') DESC;
SELECT MIN(JSON_EXTRACT(data,'$.name')) FROM test1;
SELECT MIN(JSON_EXTRACT(data,'$.address')) FROM test1 WHERE JSON_EXTRACT(data,'$.address') != "";
SELECT JSON_EXTRACT(MIN(data), "$.sex") FROM test1;
SELECT JSON_EXTRACT(MIN(cast(data as char)), "$.sex") FROM test1;
# ->
SELECT id, data->"$.Tel",data->"$.name",data->"$.address" FROM test1;
SELECT id, data->"$.Tel",data->"$.name",data->"$.address" FROM test1 order by data;
SELECT id, data->"$.Tel",data->"$.name",data->"$.address" FROM test1 order by cast(data as char);
SELECT id, data->"$.Tel",data->"$.name",data->"$.address" FROM test1 WHERE id=3;
SELECT id, data->"$.Tel",data->"$.name",data->"$.address" FROM test1 WHERE data->"$.address"="Guangzhou" ORDER BY data->"$.Tel" DESC;
SELECT data -> '$.address',count(0) FROM test1 GROUP BY data-> '$.address' ORDER BY count(0) DESC,data ->'$.address';
SELECT data -> '$.address',count(0) FROM test1 GROUP BY data-> '$.address' ORDER BY data ->'$.address' DESC;
SELECT MIN(data->'$.name') FROM test1;
SELECT MIN(data->'$.address') FROM test1 WHERE data->'$.address' != "";
SELECT MIN(data)->"$[0]" FROM test1;
SELECT MIN(cast(data as char))->"$[0]" FROM test1;
# issue SELECT JSON_EXTRACT(MIN(cast(data as char)),"$[0]") FROM test1;
# JSON_UNQUOTE
SELECT id, JSON_UNQUOTE(data->"$.Tel"),JSON_UNQUOTE(data->"$.name"),data->"$.address" FROM test1 order by id;
SELECT id, JSON_UNQUOTE(data->"$.Tel"),data->"$.name",JSON_UNQUOTE(data->"$.address") FROM test1 order by cast(data as char);
SELECT id, JSON_UNQUOTE(JSON_EXTRACT(data, "$.Tel", "$.name", "$.address")) FROM test1 WHERE id=3;
SELECT id, JSON_UNQUOTE(data->"$.Tel"),JSON_UNQUOTE(JSON_EXTRACT(data,'$.name')),data->"$.address" FROM test1 WHERE JSON_UNQUOTE(data->"$.address")="Guangzhou" ORDER BY data->"$.Tel" DESC;
SELECT JSON_UNQUOTE(data -> '$.address'),count(0) FROM test1 GROUP BY JSON_UNQUOTE(data-> '$.address') ORDER BY count(0) DESC,JSON_UNQUOTE(data ->'$.address');
SELECT MIN(JSON_UNQUOTE(data->'$.name')) FROM test1;
SELECT MIN(JSON_EXTRACT(data,'$.address')) FROM test1 WHERE JSON_UNQUOTE(data->'$.address') != "";
SELECT JSON_UNQUOTE(MIN(data)->"$[0]") FROM test1;
# issue SELECT JSON_UNQUOTE(JSON_EXTRACT(MIN(data),"$[0]")) FROM test1;
SELECT JSON_UNQUOTE(MIN(cast(data as char))->"$[0]") FROM test1;
# issue SELECT JSON_UNQUOTE(JSON_EXTRACT(MIN(cast(data as char)),"$[0]")) FROM test1;
# ->>
SELECT id, data->>"$.Tel",data->>"$.name",data->"$.address" FROM test1 order by id;
SELECT id, data->>"$.Tel",data->"$.name",data->>"$.address" FROM test1 order by cast(data as char);
SELECT id, JSON_EXTRACT(data, "$.Tel"),data->>"$.name",data->>"$.address" FROM test1 WHERE id=3;
SELECT id, data->>"$.Tel",data->>"$.name",data->>"$.address" FROM test1 WHERE data->>"$.address"="Guangzhou" ORDER BY data->"$.Tel" DESC;
SELECT data ->> '$.address',count(0) FROM test1 GROUP BY data->> '$.address' ORDER BY count(0) DESC,data ->'$.address';
SELECT MIN(data->>'$.name') FROM test1;
SELECT MIN(JSON_EXTRACT(data,'$.address')) FROM test1 WHERE data->>'$.address' != "";
SELECT MIN(data)->>"$[0]" FROM test1;
SELECT MIN(cast(data as char))->>"$[0]" FROM test1;
drop table if exists test1;
#
create table test1 (id int, data varchar(200)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO test1 VALUES (1, '{"success": true,"code": "0","message": "","data": {"name": "Kate","age": "16","sex": "女"}}');
INSERT INTO test1 VALUES (2, '{"success": false,"code": "1","message": "no no no","data": {"name": "Lucy","age": "27","sex": "女"}}');
INSERT INTO test1 VALUES (3, '{"success": "true","code": 0,"message": "","data": {"name": "Tim","age": 20,"sex": "男"}}');
INSERT INTO test1 VALUES (4, '{"success": "false","code": 1,"message": "why why","data": {"name": "Lily","age": 30,"sex": "女"}}');
# JSON_EXTRACT
SELECT t1.id, t2.id, JSON_EXTRACT(t1.data, "$.name") FROM test1 t1,test1 t2 WHERE JSON_EXTRACT(t1.data, "$.name") = JSON_EXTRACT(JSON_EXTRACT(t2.data, "$.data"), "$.name");
SELECT t1.id, t2.id, JSON_EXTRACT(t1.data, "$.name") FROM test1 t1 JOIN test1 t2 ON JSON_EXTRACT(t1.data, "$.name") = JSON_EXTRACT(JSON_EXTRACT(t2.data, "$.data"), "$.name");
SELECT id, JSON_EXTRACT(data, "$.code"),JSON_EXTRACT(data, "$.data"),JSON_EXTRACT(data, "$.data.name") FROM test1 WHERE JSON_EXTRACT(data, "$.success")="true";
SELECT JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.name'),JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.age') FROM test1 WHERE JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.age')>18 ORDER BY JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.age') DESC;
SELECT JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.name'),JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.age') FROM test1 WHERE JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.age')>18 ORDER BY cast(JSON_EXTRACT(JSON_EXTRACT(data,'$.data'),'$.age') as char) DESC;
SELECT JSON_EXTRACT(data,'$.data.name'),JSON_EXTRACT(data,'$.data.age') FROM test1 WHERE JSON_EXTRACT(data,'$.data.age')>18 order by cast(JSON_EXTRACT(data,'$.data.age') as char);
SELECT JSON_EXTRACT(data,'$.data.sex'),COUNT(0) FROM test1 GROUP BY JSON_EXTRACT(data, '$.data.sex') ORDER BY COUNT(0) DESC,JSON_EXTRACT(data, '$.data.sex');
SELECT t1.id, JSON_EXTRACT(t1.data, "$.name") FROM test1 t1 WHERE JSON_EXTRACT(t1.data, "$.name") in (select JSON_EXTRACT(JSON_EXTRACT(t2.data, "$.data"), "$.name") FROM test1 t2);
SELECT t1.id, JSON_EXTRACT(t1.data, "$.name") FROM test1 t1 WHERE JSON_EXTRACT(t1.data, "$.name") in (select JSON_EXTRACT(t2.data, "$.data.name") FROM test1 t2);
# ->
SELECT t1.id, t2.id, t1.data->"$.name" FROM test1 t1,test1 t2 WHERE t1.data->"$.name" = t2.data->"$.data.name";
SELECT t1.id, t2.id, t1.data->"$.name" FROM test1 t1 JOIN test1 t2 ON t1.data->"$.name" = t2.data->"$.data.name";
SELECT id, data->"$.code",data->"$.data",data->"$.data.name" FROM test1 WHERE data->"$.success"="true";
SELECT JSON_EXTRACT(data,'$.data.name'),data->'$.data.age' FROM test1 WHERE data->'$.data.age'>18 ORDER BY data->'$.data.age' DESC;
SELECT data->'$.data.name',data->'$.data.age' FROM test1 WHERE data->'$.data.age'>18 ORDER BY cast(data->'$.data.age' as char) DESC;
SELECT data->'$.data.sex',COUNT(0) FROM test1 GROUP BY data->'$.data.sex' ORDER BY COUNT(0) DESC,data->'$.data.sex';
SELECT t1.id, t1.data->"$.name" FROM test1 t1 WHERE t1.data->"$.name" in (select t2.data->"$.data.name" FROM test1 t2);
# JSON_UNQUOTE
SELECT t1.id, t2.id, JSON_EXTRACT(t1.data, "$.name") FROM test1 t1,test1 t2 WHERE JSON_UNQUOTE(JSON_EXTRACT(t1.data, "$.name")) = JSON_UNQUOTE(JSON_EXTRACT(JSON_EXTRACT(t2.data, "$.data"), "$.name"));
SELECT t1.id, t2.id, JSON_UNQUOTE(t1.data->"$.name") FROM test1 t1 JOIN test1 t2 ON JSON_UNQUOTE(t1.data->"$.name") = JSON_UNQUOTE(t2.data->"$.data.name");
SELECT JSON_UNQUOTE(JSON_EXTRACT(data,'$.data.name')),JSON_UNQUOTE(data->'$.data.age') FROM test1 WHERE JSON_UNQUOTE(data->'$.data.age')>18 ORDER BY JSON_UNQUOTE(data->'$.data.age') DESC;
SELECT JSON_UNQUOTE(data->'$.data.name'),JSON_UNQUOTE(data->'$.data.age') FROM test1 WHERE JSON_UNQUOTE(data->'$.data.age')>18 ORDER BY cast(JSON_UNQUOTE(data->'$.data.age') as char) DESC;
SELECT JSON_UNQUOTE(data->'$.data.sex'),count(0) FROM test1 GROUP BY data->'$.data.sex' ORDER BY count(0) DESC,JSON_UNQUOTE(data->'$.data.sex');
SELECT t1.id, t1.data->"$.name" FROM test1 t1 WHERE JSON_UNQUOTE(t1.data->"$.name") in (select JSON_UNQUOTE(t2.data->"$.data.name") FROM test1 t2);
# ->>
SELECT t1.id, t2.id, JSON_EXTRACT(t1.data, "$.name") FROM test1 t1,test1 t2 WHERE t1.data->>"$.name" = t2.data->>"$.data.name";
SELECT t1.id, t2.id, t1.data->>"$.name" FROM test1 t1 JOIN test1 t2 ON t1.data->>"$.name" = t2.data->>"$.data.name";
SELECT JSON_EXTRACT(data,'$.data.name'),data->>'$.data.age' FROM test1 WHERE data->>'$.data.age'>18 ORDER BY data->>'$.data.age' DESC;
SELECT data->>'$.data.name',data->>'$.data.age' FROM test1 WHERE data->>'$.data.age'>18 ORDER BY cast(data->>'$.data.age' as char) DESC;
SELECT data->>'$.data.sex',count(0) FROM test1 GROUP BY data->'$.data.sex' ORDER BY count(0) DESC, data->>'$.data.sex';
SELECT t1.id, t1.data->"$.name" FROM test1 t1 WHERE t1.data->>"$.name" in (select t2.data->>"$.data.name" FROM test1 t2);
drop table if exists test1;
#
create table `test1` (`id` int, `data` text);
INSERT INTO test1 VALUES (1, '{"a": 1, "b": 2, "c": [3, 4, 5]}');
INSERT INTO test1 VALUES (2, '{"a": {"b": 1}, "c": {"b": 2}}');
INSERT INTO test1 VALUES (3, '{"a": 1, "b": 2, "c": [{"cid": 2, "cname": "222"},{"cid": 4, "cname": "444"}]}');
INSERT INTO test1 VALUES (4, '{"a": {"b": 1}, "b": 3 ,"c": {"b": 2}, "d":{"e":{"f":4, "b":5}, "g":6}}');
INSERT INTO test1 VALUES (5, '[[1, 2, [11, 22, 33], 4], ["a", "b", ["aa", "bb", "cc"], "d"],[1, 2, ["a", 2, "c"], "b"]]');
INSERT INTO test1 VALUES (6, '[{"cid": 1, "cname": "111"},{"cid": 2, "cname": "222"},{"cid": "4", "cname": "444"}]');
INSERT INTO test1 VALUES (7, '[{"cid": 2, "cname": "222"},{"cid": 3, "cname": "333"}]');
INSERT INTO test1 VALUES (8, '[{"cid": 1, "cname": "111"},{"cid": 4, "cname": "444"},{"cid": 2, "cname": "222"}]');
# JSON_EXTRACT
# issue SELECT JSON_EXTRACT(MIN(cast(data as char)), "$[1]") FROM test1 ORDER BY id;
SELECT JSON_EXTRACT(data, '$.*'), COUNT(0) FROM test1 GROUP BY JSON_EXTRACT(data, '$.*') HAVING COUNT(0)>1;
SELECT id,JSON_EXTRACT(data, '$.c[*]', '$[0].cid','$.c[1].cid') FROM test1 WHERE id>8 ORDER BY id;
SELECT JSON_EXTRACT(data, '$**.b') FROM test1 WHERE JSON_EXTRACT(data, '$**.b') is not null ORDER BY JSON_EXTRACT(data, '$**.b');
SELECT JSON_EXTRACT(data, '$**.b') FROM test1 WHERE JSON_EXTRACT(data, '$**.b') is not null ORDER BY cast(JSON_EXTRACT(data, '$**.b') as char);
SELECT JSON_EXTRACT(data, '$[2]') FROM test1 WHERE JSON_EXTRACT(data, '$[2]') is not null;
SELECT JSON_EXTRACT(data, '$[2][1]') FROM test1 WHERE JSON_EXTRACT(data, "$[2]") is not null;
# ->
# issue SELECT a.min_data->"$[1]" FROM (SELECT MIN(cast(data as char)) as min_data FROM test1 ORDER BY id) as a;
SELECT data->'$.*', COUNT(0) FROM test1 GROUP BY data->'$.*' HAVING COUNT(0)>1;
SELECT data->'$.c[*]',data->'$[0].cid',data->'$.c[1].cid' FROM test1 WHERE id>8 ORDER BY id;
SELECT data->'$**.b' FROM test1 WHERE data->'$**.b' is not null ORDER BY data->'$**.b';
SELECT data->'$**.b' FROM test1 WHERE data->'$**.b' is not null ORDER BY cast(data->'$**.b' as char);
SELECT data->'$[2]' FROM test1 WHERE data->'$[2]' is not null;
SELECT data->'$[2][1]' FROM test1 WHERE data->'$[2]' is not null;
# JSON_UNQUOTE
# issue SELECT JSON_UNQUOTE(a.min_data->"$[1]") FROM (SELECT MIN(cast(data as char)) as min_data FROM test1 ORDER BY id) as a;
SELECT JSON_UNQUOTE(JSON_EXTRACT(data, '$.*')), count(0) FROM test1 group by JSON_UNQUOTE(JSON_EXTRACT(data, '$.*')) having count(0)>1;
SELECT JSON_UNQUOTE(JSON_EXTRACT(data, '$.c[*]')),JSON_UNQUOTE(JSON_EXTRACT(data, '$[0].cid')),JSON_UNQUOTE(data->'$.c[1].cid') FROM test1 WHERE id>8 ORDER BY id;
SELECT JSON_UNQUOTE(data->'$**.b') FROM test1 where JSON_UNQUOTE(data->'$**.b') is not null order by JSON_UNQUOTE(data->'$**.b');
SELECT JSON_UNQUOTE(JSON_EXTRACT(data, '$[2]')) FROM test1 where JSON_EXTRACT(data, '$[2]') is not null;
SELECT JSON_UNQUOTE(JSON_EXTRACT(data, '$[2][1]')) FROM test1 WHERE data->'$[2]' is not null;
# ->>
# issue SELECT a.min_data->>"$[1]" FROM (SELECT MIN(cast(data as char)) as min_data FROM test1 ORDER BY id) as a;
SELECT JSON_EXTRACT(data, '$.*'), count(0) FROM test1 group by data->>'$.*' having count(0)>1;
SELECT data->>'$.c[*]',data->>'$[0].cid',data->>'$.c[1].cid' FROM test1 WHERE id>8 ORDER BY id;
SELECT data->>'$**.b' FROM test1 where data->>'$**.b' is not null order by data->>'$**.b',id;
SELECT data->>'$[2]' FROM test1 where JSON_EXTRACT(data, '$[2]') is not null;
SELECT data->>'$[2][1]' FROM test1 WHERE data->>'$[2]' is not null;
ALTER TABLE test1 ADD COLUMN n INT;
UPDATE test1 SET n=1 WHERE data->"$.*.cid" = "4";
SELECT id, data->"$.*.cid", n FROM test1 WHERE JSON_EXTRACT(data, "$.*.cid") > 1 ORDER BY data->"$.*.cname";
DELETE FROM test1 WHERE data->"$.*.cid" = "4";
SELECT data->>'$.*.cname' AS name FROM test1 WHERE id > 2;
DROP TABLE if EXISTS test1;
#
# from mysql-test
CREATE TABLE test1(id int primary key, f1 JSON);
INSERT INTO test1 VALUES (1,'{"a":1}'), (2,'{"a":3}'), (3,'{"a":2}'), (4,'{"a":11, "b":3}'), (5,'{"a":33, "b":1}'), (6,'{"a":22,"b":2}');
SELECT f1->"$.a",f1->"$.b" FROM test1 WHERE f1->"$.b" > 1 order by id;
SELECT MAX(f1->"$.a"), f1->"$.b" FROM test1 GROUP BY f1->"$.b";
INSERT INTO test1 VALUES (7,'{"t":"a"}'),(8,'{"t":"b"}'),(9,'{"t":"c"}');
SELECT f1->"$.t" FROM test1 WHERE f1->"$.t" <> 'NULL' order by id;
SELECT f1->>"$.t" FROM test1 WHERE f1->>"$.t" <> 'NULL' order by id;
SELECT f1 ->> "NULL" FROM test1;
SELECT f1->>"NULL" FROM test1;
SELECT f1->>"!@#" FROM test1;
SELECT json_extract(f1,NULL) FROM test1;
SELECT f1->>NULL FROM test1;
SELECT json_extract(COUNT(*),"$.t") FROM test1;
SELECT COUNT(*)->>"$.t" FROM test1;
SELECT json_extract(MIN(f1),"$[1]") FROM test1;
SELECT MIN(f1)->>"$[1]" FROM test1;
INSERT INTO test1 VALUES (10,'[{"a":1}, {"a": 2}]'), (11,'{ "a":"foo", "b":[true, {"c":123, "c":456}]}'), (12,'{"a":"foo", "b":[true, {"c":"123"}]}'),(13,'{"a":"foo", "b":[true, {"c":123}]}');
SELECT f1->>"$**.b",cast(json_unquote(json_extract(f1,"$**.b")) as char),cast(f1->>"$**.b" as char) <=> cast(json_unquote(json_extract(f1,"$**.b")) as char) FROM test1 order by id;
SELECT f1->>"$.c",cast(json_unquote(json_extract(f1,"$.c")) as char),cast(f1->>"$.c" as char) <=> cast(json_unquote(json_extract(f1,"$.c")) as char) FROM test1 order by id;
SELECT f1->>'$.b[1].c',cast(json_unquote(json_extract(f1,'$.b[1].c')) as char),cast(f1->>'$.b[1].c' as char)<=>cast(json_unquote(json_extract(f1,'$.b[1].c')) as char) FROM test1 order by id;
SELECT f1->'$.b[1].c',cast(json_extract(f1,'$.b[1].c') as char), cast(f1->'$.b[1].c' as char)<=>cast(json_extract(f1,'$.b[1].c') as char) FROM test1 order by id;
SELECT f1->>'$.b[1]',cast(json_unquote(json_extract(f1,'$.b[1]')) as char), cast(f1->>'$.b[1]' as char) <=> cast(json_unquote(json_extract(f1,'$.b[1]')) as char) FROM test1 order by id;
SELECT f1->>'$[0][0]',cast(json_unquote(json_extract(f1,'$[0][0]')) as char),cast(f1->>'$[0][0]' as char) <=> cast(json_unquote(json_extract(f1,'$[0][0]')) as char) FROM test1 order by id;
SELECT f1->>'$**[0]',cast(json_unquote(json_extract(f1,'$**[0]')) as char),cast(f1->>'$**[0]' as char) <=> cast(json_unquote(json_extract(f1,'$**[0]')) as char) FROM test1 order by id;
SELECT f1->> '$.a[0]',cast(json_unquote(json_extract(f1, '$.a[0]')) as char),cast(f1->> '$.a[0]' as char) <=> cast(json_unquote(json_extract(f1,'$.a[0]')) as char) FROM test1 order by id;
SELECT f1->>'$[0].a[0]',cast(json_unquote(json_extract(f1,'$[0].a[0]')) as char),cast(f1->>'$[0].a[0]' as char) <=> cast(json_unquote(json_extract(f1,'$[0].a[0]')) as char) FROM test1 order by id;
SELECT f1->>'$**.a',cast(json_unquote(json_extract(f1,'$**.a')) as char),cast(f1->>'$**.a' as char) <=> cast(json_unquote(json_extract(f1,'$**.a')) as char) FROM test1 order by id;
SELECT f1->>'$[0][0][0].a',cast(json_unquote(json_extract(f1,'$[0][0][0].a')) as char),cast(f1->>'$[0][0][0].a' as char) <=> cast(json_unquote(json_extract(f1,'$[0][0][0].a')) as char) FROM test1 order by id;
SELECT f1->>'$[*].b',cast(json_unquote(json_extract(f1,'$[*].b')) as char),cast(f1->>'$[*].b' as char) <=> cast(json_unquote(json_extract(f1,'$[*].b')) as char) FROM test1 order by id;
SELECT f1->>'$[*].a',cast(json_unquote(json_extract(f1,'$[*].a')) as char),cast(f1->>'$[*].a' as char) <=> cast(json_unquote(json_extract(f1,'$[*].a')) as char) FROM test1 order by id;
DROP TABLE if exists test1;