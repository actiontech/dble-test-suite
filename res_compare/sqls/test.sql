drop table if exists test1
CREATE TABLE test1(ID INT NOT NULL,FirstName VARCHAR(20),LastName VARCHAR(20),Department VARCHAR(20),Salary INT)
create index ID_index on test1(ID)
INSERT INTO test1 VALUES(201,'Mazojys','Fxoj','Finance',7800),(202,'Jozzh','Lnanyo','Finance',45800),(203,'Syllauu','Dfaafk','Finance',57000),(204,'Gecrrcc','Srlkrt','Finance',62000),(205,'Jssme','Bdnaa','Development',75000),(206,'Dnnaao','Errllov','Development',55000),(207,'Tyoysww','Osk','Development',49000)
select id,FirstName,lastname,department,salary from test1 use index(ID_index) where  Department ='Finance'
select id,FirstName,lastname,department,salary from test1 force index(ID_index) where ID= 205
SELECT FirstName, LastName,Department = CASE Department WHEN 'F' THEN 'Financial' WHEN 'D' THEN 'Development'  ELSE 'Other' END FROM test1
select id,FirstName,lastname,department,salary from test1 where Salary >'40000' and Salary <'70000' and Department ='Finance'
SELECT count(*), Department  FROM (SELECT * FROM test1 ORDER BY FirstName DESC) AS Actions GROUP BY Department ORDER BY ID DESC
SELECT id,FirstName,lastname,department,salary FROM test1 ORDER BY FIELD( ID, 203, 207,206)
SELECT Department, COUNT(ID) FROM test1 GROUP BY Department HAVING COUNT(ID)>3
select id,FirstName,lastname,department,salary from test1 order by ID ASC
select id,FirstName,lastname,department,salary from test1 group by Department
SELECT Department, MIN(Salary) FROM test1  GROUP BY Department HAVING MIN(Salary)>46000
select Department,max(Salary) from test1 group by Department order by Department asc
select Department,min(Salary) from test1 group by Department order by Department asc
select Department,avg(Salary) from test1 group by Department order by Department asc
select Department,sum(Salary) from test1 group by Department order by Department asc
select ID,Department,Salary from test1 order by 2,3
select id,FirstName,lastname,department,salary from test1 order by Department ,ID desc
SELECT Department, COUNT(Salary) FROM test1 GROUP BY Department
SELECT Department, COUNT(Salary) FROM test1 GROUP BY Department DESC
select Department,count(Salary) as a from test1 group by Department having a=3
select Department,count(Salary) as a from test1 group by Department having a>0
select Department,count(Salary) from test1 group by Department having count(ID) >2
select Department,count(*) as num from test1 group by Department having count(*) >1
select Department,count(*) as num from test1 group by Department having count(*) <=3
select Department from test1 having Department >3
select Department from test1 where Department >0
select Department,max(salary) from test1 group by Department having max(salary) >10
select 12 as Department, Department from test1 group by Department
select id,FirstName,lastname,department,salary from test1 limit 2,10
select id,FirstName,lastname,department,salary from test1 order by FirstName in ('Syllauu','Dnnaao') desc
select max(salary) from test1 group by department order by department asc
select min(salary) from test1 group by department order by department asc
select avg(salary) from test1 group by department order by department asc
select sum(salary) from test1 group by department order by department asc
select count(salary) from test1 group by department order by department asc
select Department,sum(Salary) a from test1 group by Department having a >=1 order by Department DESC
select Department,count(*) as num from test1 group by Department having count(*) >=4 order by Department ASC
select FirstName,LastName,Department,ABS(salary) from test1 order by Department
select FirstName,LastName,Department,ACOS(salary) from test1 order by Department
select FirstName,LastName,Department,ASIN(salary) from test1 order by Department
select FirstName,LastName,Department,ATAN(salary) from test1 order by Department
select FirstName,LastName,Department,ATAN(salary,100) from test1 order by Department
select FirstName,LastName,Department,ATAN2(salary,100) from test1 order by Department
select FirstName,LastName,Department,CEIL(salary) from test1 order by Department
select FirstName,LastName,Department,CEILING(salary) from test1 order by Department
select FirstName,LastName,Department,COT(salary) from test1 order by Department
select FirstName,LastName,Department,CRC32(Department) from test1 order by Department
select FirstName,LastName,Department,FLOOR(salary) from test1 order by Department
select FirstName,LN(FirstName),LastName,Department from test1 order by Department
select FirstName,LastName,Department,LOG(salary) from test1 order by Department
select FirstName,LastName,Department,LOG2(salary) from test1 order by Department
select FirstName,LastName,Department,LOG10(salary) from test1 order by Department
select FirstName,LastName,Department,MOD(salary,2) from test1 order by Department
select FirstName,LastName,Department,RADIANS(salary) from test1 order by Department
select FirstName,LastName,Department,ROUND(salary) from test1 order by Department
select FirstName,LastName,Department,SIGN(salary) from test1 order by Department
select FirstName,LastName,Department,SIN(salary) from test1 order by Department
select FirstName,LastName,Department,SQRT(salary) from test1 order by Department
select FirstName,LastName,Department,TAN(salary) from test1 order by Department
select FirstName,LastName,Department,TRUNCATE(salary,1) from test1 order by Department
select FirstName,LastName,Department,TRUNCATE(salary*100,0) from test1 order by Department
select FirstName,LastName,Department,SIN(salary) from test1 order by Department
select id,FirstName,lastname,department,salary from test1 where Department is Null
select id,FirstName,lastname,department,salary from test1 where Department is not Null
select id,FirstName,lastname,department,salary from test1 where NOT (ID < 200)
select id,FirstName,lastname,department,salary from test1 where ID <300
select id,FirstName,lastname,department,salary from test1 where ID <1
select id,FirstName,lastname,department,salary from test1 where ID <> 0
select id,FirstName,lastname,department,salary from test1 where ID <> 0 and ID <=1
select id,FirstName,lastname,department,salary from test1 where ID >=205
select id,FirstName,lastname,department,salary from test1 where ID <=205
select id,FirstName,lastname,department,salary from test1 where ID >=205 and ID <=205
select id,FirstName,lastname,department,salary from test1 where ID >1 and ID <=203
select id,FirstName,lastname,department,salary from test1 where ID >=1 and ID=205
select id,FirstName,lastname,department,salary from test1 where ID=(ID>>1)<<1
select id,FirstName,lastname,department,salary from test1 where ID&1
select id,FirstName,lastname,department,salary from test1 where Salary >'40000' and Salary <'70000' and Department ='Finance' order by Salary ASC
select id,FirstName,lastname,department,salary from test1 where (Salary >'50000' and Salary <'70000') or Department ='Finance' order by Salary ASC
select id,FirstName,lastname,department,salary from test1 where FirstName like 'J%'
select count(*) FROM test1 WHERE Salary is null or FirstName not like '%M%'
SELECT id,FirstName,lastname,department,salary FROM test1  WHERE ID IN (SELECT ID FROM test1 WHERE ID >0)
SELECT distinct salary,id,FirstName,lastname,department FROM test1 WHERE ID IN ( SELECT ID FROM test1 WHERE ID >0)
select id,FirstName,lastname,department,salary from test1 where FirstName in ('Mazojys','Syllauu','Tyoysww')
select id,FirstName,lastname,department,salary from test1 where Salary between 40000 and 50000
select sum(salary) from test1 where department = 'Finance'
select max(salary) from test1 where department = 'Finance'
select min(salary) from test1 where department = 'Finance'
select avg(salary) from test1 where department = 'Finance'
drop table if exists test1
create table test1 (id int(11),R_REGIONKEY int(11) primary key,R_NAME varchar(50),R_COMMENT varchar(50))
insert into test1 (id,R_REGIONKEY,R_NAME,R_COMMENT) values (1,1, 'Eastern','test001'),(3,3, 'Northern','test003'),(2,2, 'Western','test002'),(4,4, 'Southern','test004')
select CURRENT_USER FROM test1
select sum(distinct id) from test1
select sum(all id) from test1
select id, R_REGIONKEY from test1
select id,'user is user' from test1
select id*5,'user is user',10 from test1
select ALL id, R_REGIONKEY, R_NAME, R_COMMENT from test1
select DISTINCT id, R_REGIONKEY, R_NAME, R_COMMENT from test1
select DISTINCTROW id, R_REGIONKEY, R_NAME, R_COMMENT from test1
select ALL HIGH_PRIORITY id,'ID' as detail  from test1
drop table if exists test1
create table test1 (id int(11),O_ORDERKEY varchar(20) primary key,O_CUSTKEY varchar(20),O_TOTALPRICE int(20),MYDATE date)
insert into test1 (id,O_ORDERKEY,O_CUSTKEY,O_TOTALPRICE,MYDATE) values (1,'ORDERKEY_001','CUSTKEY_003',200000,'20141022'),(2,'ORDERKEY_002','CUSTKEY_003',100000,'19920501'),(4,'ORDERKEY_004','CUSTKEY_111',500,'20080105'),(5,'ORDERKEY_005','CUSTKEY_132',100,'19920628'),(10,'ORDERKEY_010','CUSTKEY_333',88888888,'19920720'),(11,'ORDERKEY_011','CUSTKEY_012',323456,'19920822'),(7,'ORDERKEY_007','CUSTKEY_980',12000,'19920910'),(6,'ORDERKEY_006','CUSTKEY_420',231,'19921111')
select id, O_ORDERKEY, O_TOTALPRICE,MYDATE from test1 where id=1
select id, O_ORDERKEY, O_TOTALPRICE,MYDATE from test1 where id=1 or not id=1
select id, O_ORDERKEY, O_TOTALPRICE,MYDATE from test1 where id=1 and not id=1
select id,O_ORDERKEY,O_CUSTKEY,O_TOTALPRICE,MYDATE from test1 where id=1
select count(*) counts from test1 a where MYDATE is null
select count(*) counts from test1 a where id is null
select count(*) counts from test1 a where id is not null
select count(*) counts from test1 a where not (id is null)
select count(O_ORDERKEY) counts from test1 a where O_ORDERKEY like 'ORDERKEY_00%'
select count(O_ORDERKEY) counts from test1 a where O_ORDERKEY not like '%00%'
select sum(O_TOTALPRICE) as sums,O_CUSTKEY,count(O_ORDERKEY) counts from test1 a where O_ORDERKEY<'ORDERKEY_010' and O_CUSTKEY between 'CUSTKEY_002' and 'CUSTKEY_300' group by o_custkey
select sum(O_TOTALPRICE) as sums,O_CUSTKEY,count(O_ORDERKEY) counts from test1 a where O_ORDERKEY<'ORDERKEY_010' or O_CUSTKEY between 'CUSTKEY_002' and 'CUSTKEY_300' group by o_custkey
select sum(O_TOTALPRICE) as sums,O_CUSTKEY,count(O_ORDERKEY) counts from test1 a where O_CUSTKEY in ('CUSTKEY_003','CUSTKEY_420','CUSTKEY_980') group by o_custkey
select sum(O_TOTALPRICE) as sums,count(O_ORDERKEY) counts from test1 a where O_CUSTKEY not in ('CUSTKEY_003','CUSTKEY_420','CUSTKEY_980')
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT id,O_ORDERKEY,O_CUSTKEY,O_TOTALPRICE,MYDATE from test1 where id=1
select O_CUSTKEY,case when sum(O_TOTALPRICE)<100000 then 'D' when sum(O_TOTALPRICE)>100000 and sum(O_TOTALPRICE)<1000000 then 'C' when sum(O_TOTALPRICE)>1000000 and sum(O_TOTALPRICE)<5000000 then 'B' else 'A' end as jibie  from test1 a group by O_CUSTKEY order by jibie, O_CUSTKEY limit 10
select sum(O_TOTALPRICE) as sums,count(O_ORDERKEY) counts from test1 a where not O_CUSTKEY ='CUSTKEY_003'
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT id,O_ORDERKEY,O_CUSTKEY,O_TOTALPRICE,MYDATE from test1 where id=1
select count(*) from test1 where MYDATE between concat(date_format('1992-05-01','%Y-%m'),'-00') and concat(date_format(date_add('1992-05-01',interval 2 month),'%Y-%m'),'-00')
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT count(*) from test1 where mydate between concat(date_format('1992-05-01','%Y-%m'),'-00') and concat(date_format(date_add('1992-05-01',interval 2 month),'%Y-%m'),'-00')
select id,sum(O_TOTALPRICE) from test1 where id>1 and id<50 group by  id
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE id,sum(O_TOTALPRICE) from test1 where id>1 and id<50 group by  id
select count(id) as counts,date_format(MYDATE,'%Y-%m') as mouth from test1 where id>1 and id<50 group by date_format(id,'%Y-%m')
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE SQL_CALC_FOUND_ROWS count(id) as counts,date_format(MYDATE,'%Y-%m') as mouth from test1 where id>1 and id<50 group by date_format(MYDATE,'%Y-%m')
select count(id) as counts,date_format(MYDATE,'%Y-%m') as mouth from test1 where id>1 and id<50 group by 2 asc
select id, O_ORDERKEY, O_TOTALPRICE,MYDATE from test1 group by id,O_ORDERKEY,MYDATE
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE SQL_CALC_FOUND_ROWS count(id) as counts,date_format(MYDATE,'%Y-%m') as mouth from test1 where id>1 and id<50 group by 2 asc
select count(id) as counts,date_format(MYDATE,'%Y-%m') as mouth,id from test1 where id>1 and id<50 group by 2 asc ,id desc
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE SQL_CALC_FOUND_ROWS count(id) as counts,date_format(MYDATE,'%Y-%m') as mouth,id from test1 where id>1 and id<50 group by 2 asc ,id desc
select sum(O_TOTALPRICE) as sums,id from test1 where id>1 and id<50 group by 2 asc
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE SQL_CALC_FOUND_ROWS sum(O_TOTALPRICE) as sums,id from test1 where id>1 and id<50 group by 2 asc
select sum(O_TOTALPRICE ) as sums,id from test1 where id>1 and id<50 group by 2 asc having sums>2000000
select sum(O_TOTALPRICE ) as sums,id from test1 where id>1 and id<50 group by 2 asc   having sums>2000000
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE SQL_CALC_FOUND_ROWS sum(O_TOTALPRICE ) as sums,id from test1 where id>1 and id<50 group by 2 asc   having sums>2000000
select sum(O_TOTALPRICE ) as sums,id,count(O_ORDERKEY) counts from test1 where id>1 and id<50 group by 2 asc   having count(O_ORDERKEY)>2
select ALL HIGH_PRIORITY STRAIGHT_JOIN SQL_SMALL_RESULT SQL_BIG_RESULT SQL_BUFFER_RESULT SQL_CACHE SQL_CALC_FOUND_ROWS sum(O_TOTALPRICE ) as sums,id,count(O_ORDERKEY) counts from test1 where id>1 and id<50 group by 2 asc   having count(O_ORDERKEY)>2
select sum(O_TOTALPRICE ) as sums,id,count(O_ORDERKEY) counts from test1 where id>1 and id<50 group by 2 asc   having min(O_ORDERKEY)>10 and max(O_ORDERKEY)<10000000
select sum(O_TOTALPRICE ) from test1 where id>1 and id<50 having min(O_ORDERKEY)<10000
select id,O_ORDERKEY,O_TOTALPRICE from test1 where id>36900 and id<36902 group by O_ORDERKEY  having O_ORDERKEY in (select O_ORDERKEY from test1 group by id having sum(id)>10000)
select sum(O_TOTALPRICE) as sums,O_CUSTKEY,count(O_ORDERKEY) counts from test1 a where O_CUSTKEY between 'CUSTKEY_002' and 'CUSTKEY_300' group by o_custkey
select sum(O_TOTALPRICE) as sums,O_CUSTKEY,count(O_ORDERKEY) counts from test1 a where O_CUSTKEY not between 'CUSTKEY_002' and 'CUSTKEY_300' group by o_custkey
select sum(O_TOTALPRICE) as sums,O_CUSTKEY,count(O_ORDERKEY) counts from test1 a where not (O_CUSTKEY between 'CUSTKEY_002' and 'CUSTKEY_300') group by o_custkey
