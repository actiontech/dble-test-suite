drop table if exists aly_test
create table aly_test(id int, data char(10))
show create table aly_test
desc aly_test
insert into aly_test values (1,'a'),(2,'b'),(3,'c')
select * from aly_test
alter table aly_test add COLUMN data1 varchar(10)
insert into aly_test values (4,'aaa','bbbb')
select * from aly_test
delete from aly_test
select * from aly_test
drop table aly_test