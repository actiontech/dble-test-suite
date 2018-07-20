drop table if exists aly_test_1_2
create table aly_test_1_2 (id int, data varchar(50))

#INSERT
insert into aly_test_1_2 (id,data) values(1,'a')
insert into aly_test_1_2 set id = 2,data='b'

#REPLACE
replace into aly_test_1_2 values (3, 'c')
replace into aly_test_1_2 set id = 4, data='d'

#SELECT
select * from aly_test_1_2 order by id limit 4
select id,data from aly_test_1_2 order by id limit 4

#UPDATE
update aly_test_1_2 set data = 'aa' where id =1

#LOCK
lock tables aly_test_1_2 read
unlock tables

#clear tables
drop table if exists aly_test_1_2


