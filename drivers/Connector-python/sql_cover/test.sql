# create table
select * from test2
drop table if exists test
drop table if exists test1
create table test(id int, name varchar(40), depart varchar(40),role varchar(30),company varchar(50),code int(4) not null,salary float(8,2))
create table test1(id int not null, name varchar(40), depart varchar(40),role varchar(30),code int(4))
# insert values
insert into test values(1,'Amy','R&D','developer','ePay',1001,'27000.22'),(2,'Emily','R&D','developer','ePay',1002,'27000.22'),(3,'ALex','R&D','QA','ePay',1003,'17000.00'),(4,'Lily','R&D','QA','ePay',1004,'20000.00'),(5,'Joe','Finance','Manager','ePay',1005,'35000.00'),(6,'Benny','Human Resources','Manager','ePay',1006,'30000.00')
insert into test1 values(1,'Amy','R&D','developer',1001),(2,'Emily','R&D','developer',1002),(3,'Ray','R&D','QA',1003),(4,'Lily','R&D','QA',1004),(5,'Penny','Finance','Manager',1005),(6,'Benny','Human Resources','Manager',1006)
#select
#select * from test where name like 'A%%'
show full tables from schema1
select * from test1
#update
update test1 set depart='QA',role='tester' where id in(3,4)
select * from test1 where role = 'tester'
#delete
delete from test1 where id=4
select * from test1 where id=4