# The include statement below is a temp one for tests that are yet to
#be ported to run with InnoDB,
#but needs to be kept for tests that would need MyISAM in future.
#--source include/force_myisam_default.inc

#
# Initialization
#--disable_warnings
use schema1;
drop table if exists t1;
drop table if exists t2;
drop table if exists t3;
#--enable_warnings

#
# Test different join syntaxes
#


CREATE TABLE t1 (id INT);
CREATE TABLE t2 (id INT);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (2);
SELECT * FROM t1 JOIN t2;
SELECT * FROM t1 INNER JOIN t2;
SELECT * from t1 JOIN t2 USING (id);
SELECT * FROM t1 INNER JOIN t2 USING (id);
SELECT * from t1 CROSS JOIN t2;
SELECT * from t1 LEFT JOIN t2 USING(id);
SELECT * from t1 LEFT JOIN t2 ON(t2.id=2);
SELECT * from t1 RIGHT JOIN t2 USING(id);
SELECT * from t1 RIGHT JOIN t2 ON(t1.id=1);
drop table t1;
drop table t2;

#
# This failed for lia Perminov
#

create table t1 (id int primary key);
create table t2 (id int);
insert into t1 values (75);
insert into t1 values (79);
insert into t1 values (78);
insert into t1 values (77);
replace into t1 values (76);
replace into t1 values (76);
insert into t1 values (104);
insert into t1 values (103);
insert into t1 values (102);
insert into t1 values (101);
insert into t1 values (105);
insert into t1 values (106);
insert into t1 values (107);

insert into t2 values (107),(75),(1000);

select t1.id, t2.id from t1, t2 where t2.id = t1.id;
select t1.id, count(t2.id) from t1,t2 where t2.id = t1.id group by t1.id;
# We see the functional dependency implied by WHERE!
select t1.id, count(t2.id) from t1,t2 where t2.id = t1.id group by t2.id;

#
# Test problems with impossible ON or WHERE
#
select t1.id,t2.id from t2 left join t1 on t1.id>=74 and t1.id<=0 where t2.id=75 and t1.id is null;
# -- explain select t1.id,t2.id from t2 left join t1 on t1.id>=74 and t1.id<=0 where t2.id=75 and t1.id is null;
# -- explain select t1.id, t2.id from t1, t2 where t2.id = t1.id and t1.id <0 and t1.id > 0;
drop table t1;
drop table t2;

#
# problem with join
#
SET sql_mode = 'NO_ENGINE_SUBSTITUTION';
CREATE TABLE t1 (id int(11) NOT NULL auto_increment,token varchar(100) DEFAULT '' NOT NULL,count int(11) DEFAULT '0' NOT NULL,qty int(11),phone char(1) DEFAULT '' NOT NULL,timestamp datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,PRIMARY KEY (id),KEY token (token(15)),KEY timestamp (timestamp),UNIQUE token_2 (token(75),count,phone));
SET sql_mode = default;
INSERT INTO t1 VALUES (21,'e45703b64de71482360de8fec94c3ade',3,7800,'n','1999-12-23 17:22:21');
INSERT INTO t1 VALUES (22,'e45703b64de71482360de8fec94c3ade',4,5000,'y','1999-12-23 17:22:21');
INSERT INTO t1 VALUES (18,'346d1cb63c89285b2351f0ca4de40eda',3,13200,'b','1999-12-23 11:58:04');
INSERT INTO t1 VALUES (17,'ca6ddeb689e1b48a04146b1b5b6f936a',4,15000,'b','1999-12-23 11:36:53');
INSERT INTO t1 VALUES (16,'ca6ddeb689e1b48a04146b1b5b6f936a',3,13200,'b','1999-12-23 11:36:53');
INSERT INTO t1 VALUES (26,'a71250b7ed780f6ef3185bfffe027983',5,1500,'b','1999-12-27 09:44:24');
INSERT INTO t1 VALUES (24,'4d75906f3c37ecff478a1eb56637aa09',3,5400,'y','1999-12-23 17:29:12');
INSERT INTO t1 VALUES (25,'4d75906f3c37ecff478a1eb56637aa09',4,6500,'y','1999-12-23 17:29:12');
INSERT INTO t1 VALUES (27,'a71250b7ed780f6ef3185bfffe027983',3,6200,'b','1999-12-27 09:44:24');
INSERT INTO t1 VALUES (28,'a71250b7ed780f6ef3185bfffe027983',3,5400,'y','1999-12-27 09:44:36');
INSERT INTO t1 VALUES (29,'a71250b7ed780f6ef3185bfffe027983',4,17700,'b','1999-12-27 09:45:05');

CREATE TABLE t2 (id int(11) NOT NULL auto_increment,category int(11) DEFAULT '0' NOT NULL,county int(11) DEFAULT '0' NOT NULL,state int(11) DEFAULT '0' NOT NULL,phones int(11) DEFAULT '0' NOT NULL,nophones int(11) DEFAULT '0' NOT NULL,PRIMARY KEY (id),KEY category (category,county,state));
INSERT INTO t2 VALUES (3,2,11,12,5400,7800);
INSERT INTO t2 VALUES (4,2,25,12,6500,11200);
INSERT INTO t2 VALUES (5,1,37,6,10000,12000);
select a.id, b.category as catid, b.state as stateid, b.county as countyid from t1 a, t2 b ignore index (primary) where (a.token ='a71250b7ed780f6ef3185bfffe027983') and (a.count = b.id);
select a.id, b.category as catid, b.state as stateid, b.county as countyid from t1 a, t2 b where (a.token ='a71250b7ed780f6ef3185bfffe027983') and (a.count = b.id) order by a.id;

drop table t1;
drop table t2;

#
# Test of join of many tables.

create table t1 (id int primary key);
insert into t1 values(1),(2);
select t1.id from t1 as t1 left join t1 as t2 using (id) left join t1 as t3 using (id) left join t1 as t4 using (id) left join t1 as t5 using (id) left join t1 as t6 using (id) left join t1 as t7 using (id) left join t1 as t8 using (id) left join t1 as t9 using (id) left join t1 as t10 using (id) left join t1 as t11 using (id) left join t1 as t12 using (id) left join t1 as t13 using (id) left join t1 as t14 using (id) left join t1 as t15 using (id) left join t1 as t16 using (id) left join t1 as t17 using (id) left join t1 as t18 using (id) left join t1 as t19 using (id) left join t1 as t20 using (id) left join t1 as t21 using (id) left join t1 as t22 using (id) left join t1 as t23 using (id) left join t1 as t24 using (id) left join t1 as t25 using (id) left join t1 as t26 using (id) left join t1 as t27 using (id) left join t1 as t28 using (id) left join t1 as t29 using (id) left join t1 as t30 using (id) left join t1 as t31 using (id);
#--replace_result "31 tables" "XX tables" "61 tables" "XX tables"
#--error 1116
select t1.a from t1 as t1 left join t1 as t2 using (id) left join t1 as t3 using (id) left join t1 as t4 using (id) left join t1 as t5 using (id) left join t1 as t6 using (id) left join t1 as t7 using (id) left join t1 as t8 using (id) left join t1 as t9 using (id) left join t1 as t10 using (id) left join t1 as t11 using (id) left join t1 as t12 using (id) left join t1 as t13 using (id) left join t1 as t14 using (id) left join t1 as t15 using (id) left join t1 as t16 using (id) left join t1 as t17 using (id) left join t1 as t18 using (id) left join t1 as t19 using (id) left join t1 as t20 using (id) left join t1 as t21 using (id) left join t1 as t22 using (id) left join t1 as t23 using (id) left join t1 as t24 using (id) left join t1 as t25 using (id) left join t1 as t26 using (id) left join t1 as t27 using (id) left join t1 as t28 using (id) left join t1 as t29 using (id) left join t1 as t30 using (id) left join t1 as t31 using (id) left join t1 as t32 using (id) left join t1 as t33 using (id) left join t1 as t34 using (id) left join t1 as t35 using (id) left join t1 as t36 using (id) left join t1 as t37 using (id) left join t1 as t38 using (id) left join t1 as t39 using (id) left join t1 as t40 using (id) left join t1 as t41 using (id) left join t1 as t42 using (id) left join t1 as t43 using (id) left join t1 as t44 using (id) left join t1 as t45 using (id) left join t1 as t46 using (id) left join t1 as t47 using (id) left join t1 as t48 using (id) left join t1 as t49 using (id) left join t1 as t50 using (id) left join t1 as t51 using (id) left join t1 as t52 using (id) left join t1 as t53 using (id) left join t1 as t54 using (id) left join t1 as t55 using (id) left join t1 as t56 using (id) left join t1 as t57 using (id) left join t1 as t58 using (id) left join t1 as t59 using (id) left join t1 as t60 using (id) left join t1 as t61 using (id) left join t1 as t62 using (id) left join t1 as t63 using (id) left join t1 as t64 using (id) left join t1 as t65 using (id);
select a from t1 as t1 left join t1 as t2 using (id) left join t1 as t3 using (id) left join t1 as t4 using (id) left join t1 as t5 using (id) left join t1 as t6 using (id) left join t1 as t7 using (id) left join t1 as t8 using (id) left join t1 as t9 using (id) left join t1 as t10 using (id) left join t1 as t11 using (id) left join t1 as t12 using (id) left join t1 as t13 using (id) left join t1 as t14 using (id) left join t1 as t15 using (id) left join t1 as t16 using (id) left join t1 as t17 using (id) left join t1 as t18 using (id) left join t1 as t19 using (id) left join t1 as t20 using (id) left join t1 as t21 using (id) left join t1 as t22 using (id) left join t1 as t23 using (id) left join t1 as t24 using (id) left join t1 as t25 using (id) left join t1 as t26 using (id) left join t1 as t27 using (id) left join t1 as t28 using (id) left join t1 as t29 using (id) left join t1 as t30 using (id) left join t1 as t31 using (id);
#--replace_result "31 tables" "XX tables" "61 tables" "XX tables"
#--error 1116
select a from t1 as t1 left join t1 as t2 using (id) left join t1 as t3 using (id) left join t1 as t4 using (id) left join t1 as t5 using (id) left join t1 as t6 using (id) left join t1 as t7 using (id) left join t1 as t8 using (id) left join t1 as t9 using (id) left join t1 as t10 using (id) left join t1 as t11 using (id) left join t1 as t12 using (id) left join t1 as t13 using (id) left join t1 as t14 using (id) left join t1 as t15 using (id) left join t1 as t16 using (id) left join t1 as t17 using (id) left join t1 as t18 using (id) left join t1 as t19 using (id) left join t1 as t20 using (id) left join t1 as t21 using (id) left join t1 as t22 using (id) left join t1 as t23 using (id) left join t1 as t24 using (id) left join t1 as t25 using (id) left join t1 as t26 using (id) left join t1 as t27 using (id) left join t1 as t28 using (id) left join t1 as t29 using (id) left join t1 as t30 using (id) left join t1 as t31 using (id) left join t1 as t32 using (id) left join t1 as t33 using (id) left join t1 as t34 using (id) left join t1 as t35 using (id) left join t1 as t36 using (id) left join t1 as t37 using (id) left join t1 as t38 using (id) left join t1 as t39 using (id) left join t1 as t40 using (id) left join t1 as t41 using (id) left join t1 as t42 using (id) left join t1 as t43 using (id) left join t1 as t44 using (id) left join t1 as t45 using (id) left join t1 as t46 using (id) left join t1 as t47 using (id) left join t1 as t48 using (id) left join t1 as t49 using (id) left join t1 as t50 using (id) left join t1 as t51 using (id) left join t1 as t52 using (id) left join t1 as t53 using (id) left join t1 as t54 using (id) left join t1 as t55 using (id) left join t1 as t56 using (id) left join t1 as t57 using (id) left join t1 as t58 using (id) left join t1 as t59 using (id) left join t1 as t60 using (id) left join t1 as t61 using (id) left join t1 as t62 using (id) left join t1 as t63 using (id) left join t1 as t64 using (id) left join t1 as t65 using (id);
drop table t1;

#
# TEST LEFT JOIN with DATE columns
#

CREATE TABLE d1 (id DATE NOT NULL);
CREATE TABLE d2 (id DATE NOT NULL);
INSERT INTO d1 (id) VALUES ('2001-08-01'),('0000-00-00');
SELECT * FROM d1 LEFT JOIN d2 USING (id) WHERE d2.id IS NULL;
SELECT * FROM d1 LEFT JOIN d2 USING (id) WHERE id IS NULL;
SELECT * from d1 WHERE d1.id IS NULL;
SELECT * FROM d1 WHERE 1/0 IS NULL;
drop table d1;
drop table d2;

#
# Problem with reference from const tables
#
CREATE TABLE ct1 (Document_ID varchar(50) NOT NULL default '',Contractor_ID varchar(6) NOT NULL default '',Language_ID char(3) NOT NULL default '',Expiration_Date datetime default NULL,Publishing_Date datetime default NULL,Title text,Column_ID varchar(50) NOT NULL default '',PRIMARY KEY  (Language_ID,Document_ID,Contractor_ID));

INSERT INTO ct1 VALUES ('xep80','1','ger','2001-12-31 20:00:00','2001-11-12 10:58:00','Kartenbestellung - jetzt auch online','anle'),('','999998','',NULL,NULL,NULL,'');

CREATE TABLE ct2 (Contractor_ID char(6) NOT NULL default '',Language_ID char(3) NOT NULL default '',Document_ID char(50) NOT NULL default '',CanRead char(1) default NULL,Customer_ID int(11) NOT NULL default '0',PRIMARY KEY  (Contractor_ID,Language_ID,Document_ID,Customer_ID));
INSERT INTO ct2 VALUES ('5','ger','xep80','1',999999),('1','ger','xep80','1',999999);

CREATE TABLE ct3 (Language_ID char(3) NOT NULL default '',Column_ID char(50) NOT NULL default '',Contractor_ID char(6) NOT NULL default '',CanRead char(1) default NULL,Active char(1) default NULL,PRIMARY KEY  (Language_ID,Column_ID,Contractor_ID));
INSERT INTO ct3 VALUES ('ger','home','1','1','1'),('ger','Test','1','0','0'),('ger','derclu','1','0','0'),('ger','clubne','1','0','0'),('ger','philos','1','0','0'),('ger','clubko','1','0','0'),('ger','clubim','1','1','1'),('ger','progra','1','0','0'),('ger','progvo','1','0','0'),('ger','progsp','1','0','0'),('ger','progau','1','0','0'),('ger','progku','1','0','0'),('ger','progss','1','0','0'),('ger','nachl','1','0','0'),('ger','mitgli','1','0','0'),('ger','mitsu','1','0','0'),('ger','mitbus','1','0','0'),('ger','ergmar','1','1','1'),('ger','home','4','1','1'),('ger','derclu','4','1','1'),('ger','clubne','4','0','0'),('ger','philos','4','1','1'),('ger','clubko','4','1','1'),('ger','clubim','4','1','1'),('ger','progra','4','1','1'),('ger','progvo','4','1','1'),('ger','progsp','4','1','1'),('ger','progau','4','0','0'),('ger','progku','4','1','1'),('ger','progss','4','1','1'),('ger','nachl','4','1','1'),('ger','mitgli','4','0','0'),('ger','mitsu','4','0','0'),('ger','mitbus','4','0','0'),('ger','ergmar','4','1','1'),('ger','progra2','1','0','0'),('ger','archiv','4','1','1'),('ger','anmeld','4','1','1'),('ger','thema','4','1','1'),('ger','edito','4','1','1'),('ger','madis','4','1','1'),('ger','enma','4','1','1'),('ger','madis','1','1','1'),('ger','enma','1','1','1'),('ger','vorsch','4','0','0'),('ger','veranst','4','0','0'),('ger','anle','4','1','1'),('ger','redak','4','1','1'),('ger','nele','4','1','1'),('ger','aukt','4','1','1'),('ger','callcenter','4','1','1'),('ger','anle','1','0','0');
delete from ct1 where Contractor_ID='999998';
insert into ct1 (Contractor_ID) Values ('999998');
SELECT DISTINCT COUNT(ct1.Title) FROM ct1,ct2, ct3 WHERE ct1.Document_ID='xep80' AND ct1.Contractor_ID='1' AND ct1.Language_ID='ger' AND '2001-12-21 23:14:24' >= Publishing_Date AND '2001-12-21 23:14:24' <= Expiration_Date AND ct1.Document_ID = ct2.Document_ID AND ct1.Language_ID = ct2.Language_ID AND ct1.Contractor_ID = ct2.Contractor_ID AND ( ct2.Customer_ID = '4'  OR ct2.Customer_ID = '999999'  OR ct2.Customer_ID = '1' )AND ct2.CanRead = '1'  AND ct1.Column_ID=ct3.Column_ID AND ct1.Language_ID=ct3.Language_ID AND ( ct3.Contractor_ID = '4'  OR ct3.Contractor_ID = '999999'  OR ct3.Contractor_ID = '1') AND ct3.CanRead='1' AND ct3.Active='1';
SELECT DISTINCT COUNT(ct1.Title) FROM ct1,ct2, ct3 WHERE ct1.Document_ID='xep80' AND ct1.Contractor_ID='1' AND ct1.Language_ID='ger' AND '2001-12-21 23:14:24' >= Publishing_Date AND '2001-12-21 23:14:24' <= Expiration_Date AND ct1.Document_ID = ct2.Document_ID AND ct1.Language_ID = ct2.Language_ID AND ct1.Contractor_ID = ct2.Contractor_ID AND ( ct2.Customer_ID = '4'  OR ct2.Customer_ID = '999999'  OR ct2.Customer_ID = '1' )AND ct2.CanRead = '1'  AND ct1.Column_ID=ct3.Column_ID AND ct1.Language_ID=ct3.Language_ID AND ( ct3.Contractor_ID = '4'  OR ct3.Contractor_ID = '999999'  OR ct3.Contractor_ID = '1') AND ct3.CanRead='1' AND ct3.Active='1';
drop table ct1;
drop table ct2;
drop table ct3;

#
# Problem with internal list handling when reducing WHERE
#

CREATE TABLE t1 (ID INTEGER NOT NULL PRIMARY KEY, Value1 VARCHAR(255));
CREATE TABLE t2 (ID INTEGER NOT NULL PRIMARY KEY, Value2 VARCHAR(255));
INSERT INTO t1 VALUES (1, 'A');
INSERT INTO t2 VALUES (1, 'B');

SELECT * FROM t1 NATURAL JOIN t2 WHERE 1 AND (Value1 = 'A' AND Value2 <> 'B');
SELECT * FROM t1 NATURAL JOIN t2 WHERE 1 AND Value1 = 'A' AND Value2 <> 'B';
SELECT * FROM t1 NATURAL JOIN t2 WHERE (Value1 = 'A' AND Value2 <> 'B') AND 1;
drop table t1;
drop table t2;

#
# dummy natural join (no common columns) Bug #4807
#

CREATE TABLE t1 (a int);
CREATE TABLE t2 (b int);
CREATE TABLE t3 (c int);
SELECT * FROM t1 NATURAL JOIN t2 NATURAL JOIN t3;
DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;

#
# Test combination of join methods
#

create table t1 (id int);
create table t2 (id int);
create table t3 (id int);
insert into t1 values(1),(2);
insert into t2 values(2),(3);
insert into t3 values (2),(4);

#--sorted_result
select * from t1 natural left join t2;
#--sorted_result
select * from t1 left join t2 on (t1.id=t2.id);
#--sorted_result
select * from t1 natural left join t2 natural left join t3;
#--sorted_result
select * from t1 left join t2 on (t1.id=t2.id) left join t3 on (t2.id=t3.id);

select * from t3 natural right join t2;
select * from t3 right join t2 on (t3.id=t2.id);
#--sorted_result
select * from t3 natural right join t2 natural right join t1;
#--sorted_result
select * from t3 right join t2 on (t3.id=t2.id) right join t1 on (t2.id=t1.id);

select * from t1,t2 natural left join t3 order by t1.id,t2.id,t3.id;
select * from t1,t2 left join t3 on (t2.id=t3.id) order by t1.id,t2.id,t3.id;
select t1.id,t2.id,t3.id from t2 natural left join t3,t1 order by t1.id,t2.id,t3.id;
select t1.id,t2.id,t3.id from t2 left join t3 on (t2.id=t3.id),t1 order by t1.id,t2.id,t3.id;

select * from t1,t2 natural right join t3 order by t1.id,t2.id,t3.id;
select * from t1,t2 right join t3 on (t2.id=t3.id) order by t1.id,t2.id,t3.id;
select t1.id,t2.id,t3.id from t2 natural right join t3,t1 order by t1.id,t2.id,t3.id;
select t1.id,t2.id,t3.id from t2 right join t3 on (t2.id=t3.id),t1 order by t1.id,t2.id,t3.id;
drop table t1;
drop table t2;
drop table t3;

#
# Bug #27531: Query performance degredation in 4.1.22 and greater
#
CREATE TABLE t1 (id int, b int default 0, c int default 1);

INSERT INTO t1 (id) VALUES (1),(2),(3),(4),(5),(6),(7),(8);
INSERT INTO t1 (id) SELECT id + 8 FROM t1;
INSERT INTO t1 (id) SELECT id + 16 FROM t1;

CREATE TABLE t2 (id int, d int, e int default 0);

INSERT INTO t2 (id, d) VALUES (1,1),(2,2),(3,3),(4,4);
INSERT INTO t2 (id, d) SELECT id+4, id+4 FROM t2;
INSERT INTO t2 (id, d) SELECT id+8, id+8 FROM t2;

# should use join cache
# -- EXPLAIN SELECT STRAIGHT_JOIN t2.e FROM t1,t2 WHERE t2.d=1 AND t1.b=t2.e ORDER BY t1.b, t1.c;
SELECT STRAIGHT_JOIN t2.e FROM t1,t2 WHERE t2.d=1 AND t1.b=t2.e ORDER BY t1.b, t1.c;

drop table t1;
drop table t2;

# End of 4.1 tests

#
#  Tests for WL#2486 Natural/using join according to SQL:2003.
#
#  NOTICE:
#  - The tests are designed so that all statements, except MySQL
#    extensions run on any SQL server. Please do no change.
#  - Tests marked with TODO will be submitted as bugs.
#

create table at1 (c int, b int);
create table at2 (a int, b int);
create table at3 (b int, c int);
create table at4 (y int, c int);
create table at5 (y int, z int);
create table at6 (a int, c int);

insert into at1 values (10,1);
insert into at1 values (3 ,1);
insert into at1 values (3 ,2);
insert into at2 values (2, 1);
insert into at3 values (1, 3);
insert into at3 values (1,10);
insert into at4 values (11,3);
insert into at4 values (2, 3);
insert into at5 values (11,4);
insert into at6 values (2, 3);

# Views with simple natural join.
create view v1a as select * from at1 natural join at2;
# as above, but column names are cross-renamed: a->c, c->b, b->a
create view v1b(a,b,c) as select * from at1 natural join at2;
# as above, but column names are aliased: a->c, c->b, b->a
create view v1c as select b as a, c as b, a as c from at1 natural join at2;
#  as above, but column names are cross-renamed, and aliased
#  a->c->b, c->b->a, b->a->c
create view v1d(b, a, c) as select a as c, c as b, b as a from at1 natural join at2;

# Views with JOIN ... ON
create view v2a as select at1.c, at1.b, at2.a from at1 join (at2 join at4 on b + 1 = y) on at1.c = at4.c;
create view v2b as select at1.c as b, at1.b as a, at2.a as c from at1 join (at2 join at4 on b + 1 = y) on at1.c = at4.c;

# Views with bigger natural join
create view v3a as select * from at1 natural join at2 natural join at3;
create view v3b as select * from at1 natural join (at2 natural join at3);

# View over views with mixed natural join and join ... on
create view v4 as select * from v2a natural join v3a;

# Nested natural/using joins.
select * from (at1 natural join at2) natural join (at3 natural join at4);
#--sorted_result
select * from (at1 natural join at2) natural left join (at3 natural join at4);
#--sorted_result
select * from (at3 natural join at4) natural right join (at1 natural join at2);
#--sorted_result
select * from (at1 natural left join at2) natural left join (at3 natural left join at4);
#--sorted_result
select * from (at4 natural right join at3) natural right join (at2 natural right join at1);
select * from at1 natural join at2 natural join at3 natural join at4;
select * from ((at1 natural join at2) natural join at3) natural join at4;
select * from at1 natural join (at2 natural join (at3 natural join at4));
# BUG#15355: this query fails in 'prepared statements' mode
# select * from ((at3 natural join (at1 natural join at2)) natural join at4) natural join at5;
# select * from ((at3 natural left join (at1 natural left join at2)) natural left join at4) natural left join at5;
select * from at5 natural right join (at4 natural right join ((at2 natural right join at1) natural right join at3));
select * from (at1 natural join at2), (at3 natural join at4);
# MySQL extension - nested comma ',' operator instead of cross join.
select * from at5 natural join ((at1 natural join at2), (at3 natural join at4));
select * from  ((at1 natural join at2),  (at3 natural join at4)) natural join at5;
select * from at5 natural join ((at1 natural join at2) cross join (at3 natural join at4));
select * from  ((at1 natural join at2) cross join (at3 natural join at4)) natural join at5;

select * from (at1 join at2 using (b)) join (at3 join at4 using (c)) using (c);
select * from (at1 join at2 using (b)) natural join (at3 join at4 using (c));


# Other clauses refer to NJ columns.
select a,b,c from (at1 natural join at2) natural join (at3 natural join at4) where b + 1 = y or b + 10 = y group by b,c,a having min(b) < max(y) order by a;
select * from (at1 natural join at2) natural left join (at3 natural join at4) where b + 1 = y or b + 10 = y group by b,c,a,y having min(b) < max(y) order by a, y;
select * from (at3 natural join at4) natural right join (at1 natural join at2) where b + 1 = y or b + 10 = y group by b,c,a,y having min(b) < max(y) order by a, y;

# Qualified column references to NJ columns.
select * from at1 natural join at2 where at1.c > at2.a;
select * from at1 natural join at2 where at1.b > at2.b;
select * from at1 natural left join (at4 natural join at5) where at5.z is not NULL;

# Nested 'join ... on' - name resolution of ON conditions
select * from at1 join (at2 join at4 on b + 1 = y) on at1.c = at4.c;
select * from (at2 join at4 on b + 1 = y) join at1 on at1.c = at4.c;
select * from at1 natural join (at2 join at4 on b + 1 = y);
select * from (at1 cross join at2) join (at3 cross join at4) on (a < y and at2.b < at3.c);

# MySQL extension - 'join ... on' over nested comma operator
select * from (at1, at2) join (at3, at4) on (a < y and at2.b < at3.c);
select * from (at1 natural join at2) join (at3 natural join at4) on a = y;
select * from ((at3 join (at1 join at2 on c > a) on at3.b < at2.a) join at4 on y > at1.c) join at5 on z = at1.b + 3;

# MySQL extension - refererence qualified coalesced columns
select * from at1 natural join at2 where at1.b > 0;
select * from at1 natural join (at4 natural join at5) where at4.y > 7;
select * from (at4 natural join at5) natural join at1 where at4.y > 7;
select * from at1 natural left join (at4 natural join at5) where at4.y > 7;
select * from (at4 natural join at5) natural right join at1 where at4.y > 7;
select * from (at1 natural join at2) join (at3 natural join at4) on at1.b = at3.b;

# MySQL extension - select qualified columns of NJ columns
select at1.*, at2.* from at1 natural join at2;
select at1.*, at2.*, at3.*, at4.* from (at1 natural join at2) natural join (at3 natural join at4);

# Queries over subselects in the FROM clause
#--sorted_result
select * from (select * from at1 natural join at2) as at12 natural join(select * from at3 natural join at4) as at34;
#--sorted_result
select * from (select * from at1 natural join at2) as at12 natural left join(select * from at3 natural join at4) as at34;
#--sorted_result
select * from (select * from at3 natural join at4) as at34 natural right join(select * from at1 natural join at2) as at12;

# Queries over views
select * from v1a;
select * from v1b;
select * from v1c;
select * from v1d;
select * from v2a;
select * from v2b;
select * from v3a;
select * from v3b;
select * from v4;
select * from v1a natural join v2a;
select v2a.* from v1a natural join v2a;
select * from v1b join v2a on v1b.b = v2a.c;
select * from v1c join v2a on v1c.b = v2a.c;
select * from v1d join v2a on v1d.a = v2a.c;
select * from v1a join (at3 natural join at4) on a = y;

# TODO: add tests with correlated subqueries for natural join/join on.
# related to BUG#15269


##--------------------------------------------------------------------
# Negative tests (tests for errors)
#--------------------------------------------------------------------
# works in Oracle - bug
#-- error 1052
select * from at1 natural join (at3 cross join at4);
# works in Oracle - bug
#-- error 1052
select * from (at3 cross join at4) natural join at1;
#-- error 1052
select * from at1 join (at2, at3) using (b);
#-- error 1052
select * from ((at1 natural join at2), (at3 natural join at4)) natural join at6;
#-- error 1052
select * from ((at1 natural join at2), (at3 natural join at4)) natural join at6;
#-- error 1052
select * from at6 natural join ((at1 natural join at2),  (at3 natural join at4));
#-- error 1052
select * from (at1 join at2 on at1.b=at2.b) natural join (at3 natural join at4);
#-- error 1052
select * from  (at3 natural join at4) natural join (at1 join at2 on at1.b=at2.b);
# this one is OK, the next equivalent one is incorrect (bug in Oracle)
#-- error 1052
select * from (at3 join (at4 natural join at5) on (b < z)) natural join (at1 natural join at2);
#-- error 1052
select * from (at1 natural join at2) natural join (at3 join (at4 natural join at5) on (b < z));

#-- error 1054
select at1.b from v1a;
#-- error 1054
select * from v1a join v1b on at1.b = at2.b;

#
# Bug #17523 natural join and information_schema
#
# Omit columns.PRIVILIGES as it may vary with embedded server.
# Omit columns.ORDINAL_POSITION and statistics.CARDINALITY as it may vary with hostname='localhost'.
select statistics.TABLE_NAME, statistics.COLUMN_NAME, statistics.TABLE_CATALOG, statistics.TABLE_SCHEMA, statistics.NON_UNIQUE, statistics.INDEX_SCHEMA, statistics.INDEX_NAME, statistics.SEQ_IN_INDEX, statistics.COLLATION, statistics.SUB_PART, statistics.PACKED, statistics.NULLABLE, statistics.INDEX_TYPE, statistics.COMMENT, columns.TABLE_CATALOG, columns.TABLE_SCHEMA, columns.COLUMN_DEFAULT, columns.IS_NULLABLE, columns.DATA_TYPE, columns.CHARACTER_MAXIMUM_LENGTH, columns.CHARACTER_OCTET_LENGTH, columns.NUMERIC_PRECISION, columns.NUMERIC_SCALE, columns.CHARACTER_SET_NAME, columns.COLLATION_NAME, columns.COLUMN_TYPE, columns.COLUMN_KEY, columns.EXTRA, columns.COLUMN_COMMENT from information_schema.statistics join information_schema.columns using(table_name,column_name) where table_name='user';

drop table at1;
drop table at2;
drop table at3;
drop table at4;
drop table at5;
drop table at6;

drop view v1a;
drop view v1b;
drop view v1c;
drop view v1d;
drop view v2a;
drop view v2b;
drop view v3a;
drop view v3b;
drop view v4;

#
# BUG#15229 - columns of nested joins that are not natural joins incorrectly
# materialized
#
create table tt1 (a1 int, a2 int);
create table tt2 (a1 int, b int);
create table tt3 (c1 int, c2 int);
create table tt4 (c2 int);

insert into tt1 values (1,1);
insert into tt2 values (1,1);
insert into tt3 values (1,1);
insert into tt4 values (1);

select * from tt1 join tt2 using (a1) join tt3 on b=c1 join tt4 using (c2);
select * from tt3 join (tt1 join tt2 using (a1)) on b=c1 join tt4 using (c2);
select a2 from tt1 join tt2 using (a1) join tt3 on b=c1 join tt4 using (c2);
select a2 from tt3 join (tt1 join tt2 using (a1)) on b=c1 join tt4 using (c2);
select a2 from ((tt1 join tt2 using (a1)) join tt3 on b=c1) join tt4 using (c2);
select a2 from ((tt1 natural join tt2) join tt3 on b=c1) natural join tt4;

drop table tt1;
drop table tt2;
drop table tt3;
drop table tt4;

#
# BUG#15355: Common natural join column not resolved in prepared statement nested query
#
create table tp1 (c int, b int);
create table tp2 (a int, b int);
create table tp3 (b int, c int);
create table tp4 (y int, c int);
create table tp5 (y int, z int);

insert into tp1 values (3,2);
insert into tp2 values (1,2);
insert into tp3 values (2,3);
insert into tp4 values (1,3);
insert into tp5 values (1,4);

# this fails
prepare stmt1 from "select * from ((tp3 natural join (tp1 natural join tp2)) natural join tp4) natural join tp5";
execute stmt1;

# this works
select * from ((tp3 natural join (tp1 natural join tp2)) natural join tp4) natural join tp5;
drop table tp1;
drop table tp2;
drop table tp3;
drop table tp4;
drop table tp5;

# End of tests for WL#2486 - natural/using join

#
# BUG#25106: A USING clause in combination with a VIEW results in column 
#            aliases ignored
#
CREATE TABLE t1 (id INTEGER, Name VARCHAR(50));
CREATE TABLE t2 (id INTEGER);
CREATE VIEW v1 (Test_ID, Description) AS SELECT id, Name FROM t1;

CREATE TABLE tv1 SELECT Description AS Name FROM v1 JOIN t2 USING (id);
DESCRIBE tv1;
CREATE TABLE tv2 SELECT Description AS Name FROM v1 JOIN t2 ON v1.Test_ID = t2.id;
DESCRIBE tv2;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE t2;
DROP TABLE tv1;
DROP TABLE tv2;


# BUG#27939: Early NULLs filtering doesn't work for eq_ref access
create table t1 (id int, b int);
insert into t1 values (NULL, 1),(NULL, 2),(NULL, 3),(NULL, 4);

create table t2 (id int not null, primary key(id));
insert into t2 values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

create table t3 (id int not null, primary key(id));
insert into t3 values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

flush status;
select * from t1, t2, t3 where t3.id=t1.id and t2.id=t1.b;
# -- explain select * from t1, t2, t3 where t3.id=t1.id and t2.id=t1.b;
#--echo We expect rnd_next=5, and read_key must be 0 because of short-cutting:
show status like 'Handler_read%'; 
drop table t1;
drop table t2;
drop table t3;

#
# BUG#14940: Make E(#rows) from "range" access be re-used by range optimizer
#
create table t1 (id int);
insert into t1 values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

create table t2 (id int, b int, filler char(100), key(id), key(b));
create table t3 (id int, b int, filler char(100), key(id), key(b));

insert into t2 select @a:= A.id + 10*(B.id + 10*C.id), @a, 'filler' from t1 A, t1 B, t1 C;
insert into t3 select * from t2 where id < 800;

# The order of tables must be t2,t3:
# -- explain select * from t2,t3 where t2.id < 200 and t2.b=t3.b;
select * from t2,t3 where t2.id < 200 and t2.b=t3.b;

drop table t1;
drop table t2;
drop table t3;

# BUG#14940 {Wrong query plan is chosen because of odd results of
# prev_record_reads() function }
create table t1 (id int); 
insert into t1 values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

create table t2 (id int, b int, primary key(id));
insert into t2 select @v:=A.id+10*B.id, @v  from t1 A, t1 B;

# -- explain select * from t1;
select * from t1;
show status like '%cost%';
select 'The cost of accessing t1 (dont care if it changes' '^';

select 'vv: Following query must use ALL(t1), eq_ref(id), eq_ref(B): vv' Z;

# -- explain select * from t1, t2 a, t2 b where a.id = t1.id and b.id=a.b;
select * from t1, t2 a, t2 b where a.id = t1.id and b.id=a.b;
show status like '%cost%';
select '^^: The above should be ~= 20 + cost(select * from t1). Value less than 20 is an error' Z;



drop table t1;
drop table t2;

#
# Bug #31094: Forcing index-based sort doesn't work anymore if joins are
# done
#

CREATE TABLE tp2 (a INT PRIMARY KEY, b INT);
CREATE TABLE tp1 (c INT PRIMARY KEY, d INT);

INSERT INTO tp2 VALUES(1,NULL),(2,NULL),(3,NULL),(4,NULL);
INSERT INTO tp2 SELECT a + 4, b FROM tp2;
INSERT INTO tp2 SELECT a + 8, b FROM tp2;
INSERT INTO tp2 SELECT a + 16, b FROM tp2;
INSERT INTO tp2 SELECT a + 32, b FROM tp2;
INSERT INTO tp2 SELECT a + 64, b FROM tp2;
INSERT INTO tp1 SELECT a, b FROM tp2;

#expect indexed ORDER BY
# -- EXPLAIN SELECT * FROM tp2 JOIN tp1 ON b=c ORDER BY a LIMIT 2;
# -- EXPLAIN SELECT * FROM tp2 JOIN tp1 ON a=c ORDER BY a LIMIT 2;
SELECT * FROM tp2 JOIN tp1 ON b=c ORDER BY a LIMIT 2;
SELECT * FROM tp2 JOIN tp1 ON a=c ORDER BY a LIMIT 2;

#expect filesort
# -- EXPLAIN SELECT * FROM tp2 JOIN tp1 ON b=c ORDER BY a;
# -- EXPLAIN SELECT * FROM tp2 JOIN tp1 ON a=c ORDER BY a;
SELECT * FROM tp2 JOIN tp1 ON b=c ORDER BY a;
SELECT * FROM tp2 JOIN tp1 ON a=c ORDER BY a;

DROP TABLE IF EXISTS tp2;
DROP TABLE IF EXISTS tp1;


#--echo #
#--echo # Bug #42116: Mysql crash on specific query
#--echo #
CREATE TABLE t1 (id INT);
CREATE TABLE t2 (id INT);
CREATE TABLE t3 (id INT, INDEX (id));
CREATE TABLE t4 (id INT);
CREATE TABLE t5 (id INT);
CREATE TABLE t6 (id INT);

INSERT INTO t1 VALUES (1), (1), (1);

INSERT INTO t2 VALUES(2), (2), (2), (2), (2), (2), (2), (2), (2), (2);

INSERT INTO t3 VALUES(3), (3), (3), (3), (3), (3), (3), (3), (3), (3);

# -- EXPLAIN SELECT * FROM t1 JOIN t2 ON t1.id = t2.id LEFT JOIN ((t3 LEFT JOIN t4 ON t3.id = t4.id) LEFT JOIN (t5 LEFT JOIN t6 ON t5.id = t6.id) ON t4.id = t5.id) ON t1.id = t3.id;

SELECT * FROM t1 JOIN t2 ON t1.id = t2.id LEFT JOIN( (t3 LEFT JOIN t4 ON t3.id = t4.id)  LEFT JOIN (t5 LEFT JOIN t6 ON t5.id = t6.id) ON t4.id = t5.id) ON t1.id = t3.id;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;
DROP TABLE t6;

#--echo #
#--echo # Bug#48483: crash in get_best_combination()
#--echo #

CREATE TABLE t1(id INT);
INSERT INTO t1 VALUES (1),(2);
CREATE VIEW v1 AS SELECT 1 FROM t1 LEFT JOIN t1 AS t2 on 1=1;
# -- EXPLAIN EXTENDED
SELECT 1 FROM v1 right join v1 AS v2 ON RAND();
DROP VIEW v1;
DROP TABLE t1;

#--echo #
#--echo # Bug#52177 crash with explain, row comparison, join, text field
#--echo #
CREATE TABLE t1 (id TINYINT, b TEXT, KEY (id));
INSERT INTO t1 VALUES (0,''),(0,'');
FLUSH TABLES;
# -- EXPLAIN SELECT 1 FROM t1 LEFT JOIN t1 id ON 1 WHERE ROW(t1.id, 1111.11) = ROW(1111.11, 1111.11) AND ROW(t1.b, 1111.11) <=> ROW('','');
DROP TABLE t1;

#--echo #
#--echo # Bug #50335: Assertion `!(order->used & map)' in eq_ref_table
#--echo #

CREATE TABLE t1 (id INT NOT NULL, b INT NOT NULL, PRIMARY KEY (id,b));
INSERT INTO t1 VALUES (0,0), (1,1);

SELECT * FROM t1 STRAIGHT_JOIN t1 t2 ON t1.id=t2.id AND t1.id=t2.b ORDER BY t2.id, t1.id;

DROP TABLE t1;

#--echo End of 5.0 tests.


#
# Bug#47150 Assertion in Field_long::val_int() on MERGE + TRIGGER + multi-table UPDATE
#
CREATE TABLE t1 (id int);

CREATE TABLE t2 (id int);
INSERT INTO t2  VALUES (1);
CREATE VIEW v1 AS SELECT * FROM t2;

PREPARE stmt FROM 'UPDATE t2 AS A NATURAL JOIN v1 B SET B.id = 1';
EXECUTE stmt;
EXECUTE stmt;

DEALLOCATE PREPARE stmt;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug #54468: crash after item's print() function when ordering/grouping
#--echo #             by subquery
#--echo #

CREATE TABLE t1(id INT, b INT);
INSERT INTO t1 VALUES (), ();

SELECT 1 FROM t1 GROUP BY GREATEST(t1.id,(SELECT 1 FROM(SELECT t1.b FROM t1,t1 t2 ORDER BY t1.id, t1.id LIMIT 1) AS d));

DROP TABLE t1;

#--echo #
#--echo # Bug #53544: Server hangs during JOIN query in stored procedure called
#--echo #             twice in a row
#--echo #

CREATE TABLE t1(id INT);

INSERT INTO t1 VALUES (1), (2);

PREPARE stmt FROM "SELECT t2.id AS f1 FROM t1 LEFT JOIN t1 t2 ON t1.id=t2.id RIGHT JOIN t1 t3 ON t1.id=t3.id GROUP BY f1;";

EXECUTE stmt;
EXECUTE stmt;

DEALLOCATE PREPARE stmt;
DROP TABLE t1;

#--echo End of 5.1 tests

#--echo #
#--echo # Bug #59696 Optimizer fails to move WHERE condition on JOIN column
#--echo #            when joining with a view
#--echo #

CREATE TABLE t1 ( id INTEGER NOT NULL);
INSERT INTO t1 VALUES (1),(2),(3);
CREATE TABLE t2 (id INTEGER NOT NULL, c1 INTEGER NOT NULL,PRIMARY KEY (id));
INSERT INTO t2 VALUES (1,4),(3,5),(2,6);

# -- let $query=SELECT t2.id, t2.id FROM t2, t1 WHERE t2.id = t1.id AND t2.id >= 2;

# -- eval EXPLAIN $query;
# -- eval $query;
SELECT t2.id, t2.id FROM t2, t1 WHERE t2.id = t1.id AND t2.id >= 2;

# Create a view on one of the tables. The same query plan should
# be used when joining with this view as with the underlying table.
CREATE VIEW v_t2 AS SELECT * FROM t2;

# -- let $query=SELECT v_t2.id, v_t2.c1 FROM v_t2, t1 WHERE v_t2.id = t1.id AND v_t2.id >= 2;
# -- eval EXPLAIN $query;
# -- eval $query;
SELECT v_t2.id, v_t2.c1 FROM v_t2, t1 WHERE v_t2.id = t1.id AND v_t2.id >= 2;

DROP VIEW v_t2;
DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug 13102033 - CRASH IN COPY_FUNCS IN SQL_SELECT.CC ON JOIN +
#--echo #                GROUP BY + ORDER BY
#--echo #

CREATE TABLE t1 (  id INTEGER NOT NULL,i1 INTEGER NOT NULL,i2 INTEGER NOT NULL,PRIMARY KEY (id));

INSERT INTO t1 VALUES (7,8,1), (8,2,2);

CREATE VIEW v1 AS SELECT * FROM t1;

#--let query=SELECT t1.id FROM v1, t1 WHERE v1.i2 = 211 AND v1.i2 > 7 OR t1.i1 < 3 GROUP BY t1.id ORDER BY v1.i2;

#--source include/turn_off_only_full_group_by.inc
#--eval EXPLAIN $query;
#--eval $query;
SELECT t1.id FROM v1, t1 WHERE v1.i2 = 211 AND v1.i2 > 7 OR t1.i1 < 3 GROUP BY t1.id ORDER BY v1.i2;
#--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

#--let query=SELECT t1.id FROM v1, t1 WHERE (v1.i2 = 211 AND v1.i2 > 7) OR (t1.i1 < 3 AND v1.i2 < 10);
#--eval EXPLAIN $query;
#--eval $query;
SELECT t1.id FROM v1, t1 WHERE (v1.i2 = 211 AND v1.i2 > 7) OR (t1.i1 < 3 AND v1.i2 < 10);

DROP VIEW v1;
DROP TABLE t1;


#--echo # Bug#20455184: Assertion failed: join_cond in optimizer.cc

CREATE TABLE t1(id INTEGER) engine=innodb;

#--let $query=SELECT 1 FROM (SELECT 1 FROM t1 WHERE id) AS q NATURAL LEFT JOIN t1 NATURAL LEFT JOIN t1 AS t2;
#--eval explain $query;
#--eval $query;
SELECT 1 FROM (SELECT 1 FROM t1 WHERE id) AS q NATURAL LEFT JOIN t1 NATURAL LEFT JOIN t1 AS t2;

#--let $query=SELECT 1 FROM t1 NATURAL RIGHT JOIN t1 AS t2 NATURAL RIGHT JOIN (SELECT 1 FROM t1 WHERE id) AS q;
#--eval explain $query;
#--eval $query;
SELECT 1 FROM t1 NATURAL RIGHT JOIN t1 AS t2 NATURAL RIGHT JOIN (SELECT 1 FROM t1 WHERE id) AS q;

DROP TABLE t1;

#--echo # Bug#21045724: Assertion '!table || !table->read_set ...

CREATE TABLE t1(id INTEGER,dummy VARCHAR(64),col_check TINYINT,PRIMARY KEY(id)) engine=innodb;

INSERT INTO t1 VALUES (13, '13', 13);

CREATE VIEW v1 AS SELECT * FROM t1 WHERE id BETWEEN 13 AND 14;

PREPARE st1 FROM "UPDATE v1 AS a NATURAL JOIN v1 AS b SET a.dummy = '', b.col_check = NULL ";

EXECUTE st1;
EXECUTE st1;

DEALLOCATE PREPARE st1;
DROP VIEW v1;
DROP TABLE t1;
