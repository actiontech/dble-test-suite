# The include statement below is a temp one for tests that are yet to
#be ported to run with InnoDB,
#but needs to be kept for tests that would need MyISAM in future.
#--source include/force_myisam_default.inc

#
# test of left outer join
#

#--disable_warnings
drop table if exists t0;
drop table if exists t1;
drop table if exists t2;
drop table if exists t3;
drop table if exists t4;
drop table if exists t5;
#--enable_warnings

CREATE TABLE t1 (   id int(11) default NULL,   a bigint(20) unsigned default NULL,   c char(10) NOT NULL default '' ) ENGINE=InnoDB;
INSERT INTO t1 VALUES (1,1,'a'),(2,2,'b'),(2,3,'c'),(3,4,'E'),(3,5,'C'),(3,6,'D'),(NULL,NULL,'');
create table t2 (id int, a bigint unsigned not null, c char(10), d int, primary key (a));
insert into t2 values (1,1,"a",1),(3,4,"A",4),(3,5,"B",5),(3,6,"C",6),(4,7,"D",7);

select t1.*,t2.* from t1 JOIN t2 where t1.a=t2.a;
select t1.*,t2.* from t1 left join t2 on (t1.a=t2.a) order by t1.id,t1.a,t2.c;
select t1.*,t2.* from { oj t2 left outer join t1 on (t1.a=t2.a) };
select t1.*,t2.* from t1 as t0,{ oj t2 left outer join t1 on (t1.a=t2.a) } WHERE t0.a=2;
select t1.*,t2.* from t1 left join t2 using (a);
select t1.*,t2.* from t1 left join t2 using (a) where t1.a=t2.a;
select t1.*,t2.* from t1 left join t2 using (a,c);
# --sorted_result
select t1.*,t2.* from t1 left join t2 using (c);
select t1.*,t2.* from t1 natural left outer join t2;

select t1.*,t2.* from t1 left join t2 on (t1.a=t2.a) where t2.id=3;
select t1.*,t2.* from t1 left join t2 on (t1.a=t2.a) where t2.id is null;

# -- explain select t1.*,t2.* from t1,t2 where t1.a=t2.a and isnull(t2.a)=1;
# -- explain select t1.*,t2.* from t1 left join t2 on t1.a=t2.a where isnull(t2.a)=1;

# --sorted_result
select t1.*,t2.*,t3.a from t1 left join t2 on (t1.a=t2.a) left join t1 as t3 on (t2.a=t3.a);

# The next query should rearange the left joins to get this to work
# --error 1054
# -- explain select t1.*,t2.*,t3.a from t1 left join t2 on (t3.a=t2.a) left join t1 as t3 on (t1.a=t3.a);
# --error 1054
select t1.*,t2.*,t3.a from t1 left join t2 on (t3.a=t2.a) left join t1 as t3 on (t1.a=t3.a);

# The next query should give an error in MySQL
# --error 1054
select t1.*,t2.*,t3.a from t1 left join t2 on (t3.a=t2.a) left join t1 as t3 on (t2.a=t3.a);

# Test of inner join
select t1.*,t2.* from t1 inner join t2 using (a);
select t1.*,t2.* from t1 inner join t2 on (t1.a=t2.a);
select t1.*,t2.* from t1 natural join t2;

drop table t1;
drop table t2;

#
# Test of left join bug
#

CREATE TABLE ts1 (  sid INT unsigned NOT NULL,  uniq_id INT unsigned NOT NULL AUTO_INCREMENT,         start_num INT unsigned NOT NULL DEFAULT 1,         increment INT unsigned NOT NULL DEFAULT 1,  PRIMARY KEY (uniq_id),  INDEX usr_uniq_idx (sid, uniq_id),  INDEX uniq_sidx (uniq_id, sid) );
CREATE TABLE t2 (  id INT unsigned NOT NULL DEFAULT 0,  usr2_id INT unsigned NOT NULL DEFAULT 0,  max INT unsigned NOT NULL DEFAULT 0,  c_amount INT unsigned NOT NULL DEFAULT 0,  d_max INT unsigned NOT NULL DEFAULT 0,  d_num INT unsigned NOT NULL DEFAULT 0,  orig_time INT unsigned NOT NULL DEFAULT 0,  c_time INT unsigned NOT NULL DEFAULT 0,  active ENUM ("no","yes") NOT NULL,  PRIMARY KEY (id,usr2_id),  INDEX id_idx (id),  INDEX usr2_idx (usr2_id) );
INSERT INTO ts1 VALUES (3,NULL,0,50),(3,NULL,0,200),(3,NULL,0,25),(3,NULL,0,84676),(3,NULL,0,235),(3,NULL,0,10),(3,NULL,0,3098),(3,NULL,0,2947),(3,NULL,0,8987),(3,NULL,0,8347654),(3,NULL,0,20398),(3,NULL,0,8976),(3,NULL,0,500),(3,NULL,0,198);

#1st select shows that one record is returned with null entries for the right
#table, when selecting on an id that does not exist in the right table t2
SELECT ts1.sid,ts1.uniq_id,ts1.increment, t2.usr2_id,t2.c_amount,t2.max FROM ts1 LEFT JOIN t2 ON t2.id = ts1.uniq_id WHERE ts1.uniq_id = 4 ORDER BY t2.c_amount;

# The same with RIGHT JOIN
SELECT ts1.sid,ts1.uniq_id,ts1.increment, t2.usr2_id,t2.c_amount,t2.max FROM t2 RIGHT JOIN ts1 ON t2.id = ts1.uniq_id WHERE ts1.uniq_id = 4 ORDER BY t2.c_amount;

INSERT INTO t2 VALUES (2,3,3000,6000,0,0,746584,837484,'yes');
#--error ER_DUP_ENTRY
INSERT INTO t2 VALUES (2,3,3000,6000,0,0,746584,837484,'yes');
INSERT INTO t2 VALUES (7,3,1000,2000,0,0,746294,937484,'yes');

#3rd select should show that one record is returned with null entries for the
# right table, when selecting on an id that does not exist in the right table
# t2 but this select returns an empty set!!!!
SELECT ts1.sid,ts1.uniq_id,ts1.increment,t2.usr2_id,t2.c_amount,t2.max FROM ts1 LEFT JOIN t2 ON t2.id = ts1.uniq_id WHERE ts1.uniq_id = 4 ORDER BY t2.c_amount;
#--source include/turn_off_only_full_group_by.inc
SELECT ts1.sid,ts1.uniq_id,ts1.increment,t2.usr2_id,t2.c_amount,t2.max FROM ts1 LEFT JOIN t2 ON t2.id = ts1.uniq_id WHERE ts1.uniq_id = 4 GROUP BY t2.c_amount;
#--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
# Removing the ORDER BY works:
SELECT ts1.sid,ts1.uniq_id,ts1.increment,t2.usr2_id,t2.c_amount,t2.max FROM ts1 LEFT JOIN t2 ON t2.id = ts1.uniq_id WHERE ts1.uniq_id = 4;

drop table ts1;
drop table t2;

#
# Test of LEFT JOIN with const tables (failed for frankie@etsetb.upc.es)
#

CREATE TABLE t1 (   id int(11) DEFAULT '0' NOT NULL,   desc_larga_cat varchar(80) DEFAULT '' NOT NULL,   desc_larga_cas varchar(80) DEFAULT '' NOT NULL,   desc_corta_cat varchar(40) DEFAULT '' NOT NULL,   desc_corta_cas varchar(40) DEFAULT '' NOT NULL,   cred_total double(3,1) DEFAULT '0.0' NOT NULL,   pre_requisit int(11),   co_requisit int(11),   preco_requisit int(11),   PRIMARY KEY (id) );

INSERT INTO t1 VALUES (10360,'asdfggfg','Introduccion a los  Ordenadores I','asdfggfg','Introduccio Ordinadors I',6.0,NULL,NULL,NULL);
INSERT INTO t1 VALUES (10361,'Components i Circuits Electronics I','Componentes y Circuitos Electronicos I','Components i Circuits Electronics I','Comp. i Circ. Electr. I',6.0,NULL,NULL,NULL);
INSERT INTO t1 VALUES (10362,'Laboratori d`Ordinadors','Laboratorio de Ordenadores','Laboratori d`Ordinadors','Laboratori Ordinadors',4.5,NULL,NULL,NULL);
INSERT INTO t1 VALUES (10363,'Tecniques de Comunicacio Oral i Escrita','Tecnicas de Comunicacion Oral y Escrita','Tecniques de Comunicacio Oral i Escrita','Tec. Com. Oral i Escrita',4.5,NULL,NULL,NULL);
INSERT INTO t1 VALUES (11403,'Projecte Fi de Carrera','Proyecto Fin de Carrera','Projecte Fi de Carrera','PFC',9.0,NULL,NULL,NULL);
INSERT INTO t1 VALUES (11404,'+lgebra lineal','Algebra lineal','+lgebra lineal','+lgebra lineal',15.0,NULL,NULL,NULL);
INSERT INTO t1 VALUES (11405,'+lgebra lineal','Algebra lineal','+lgebra lineal','+lgebra lineal',18.0,NULL,NULL,NULL);
INSERT INTO t1 VALUES (11406,'Calcul Infinitesimal','Cßlculo Infinitesimal','Calcul Infinitesimal','Calcul Infinitesimal',15.0,NULL,NULL,NULL);

CREATE TABLE t2 ( id int(11) DEFAULT '0' NOT NULL,   Grup int(11) DEFAULT '0' NOT NULL,   Places smallint(6) DEFAULT '0' NOT NULL,   PlacesOcupades int(11) DEFAULT '0',   PRIMARY KEY (id,Grup) );


INSERT INTO t2 VALUES (10360,12,333,0);
INSERT INTO t2 VALUES (10361,30,2,0);
INSERT INTO t2 VALUES (10361,40,3,0);
INSERT INTO t2 VALUES (10360,45,10,0);
INSERT INTO t2 VALUES (10362,10,12,0);
INSERT INTO t2 VALUES (10360,55,2,0);
INSERT INTO t2 VALUES (10360,70,0,0);
INSERT INTO t2 VALUES (10360,565656,0,0);
INSERT INTO t2 VALUES (10360,32767,7,0);
INSERT INTO t2 VALUES (10360,33,8,0);
INSERT INTO t2 VALUES (10360,7887,85,0);
INSERT INTO t2 VALUES (11405,88,8,0);
INSERT INTO t2 VALUES (10360,0,55,0);
INSERT INTO t2 VALUES (10360,99,0,0);
INSERT INTO t2 VALUES (11411,30,10,0);
INSERT INTO t2 VALUES (11404,0,0,0);
INSERT INTO t2 VALUES (10362,11,111,0);
INSERT INTO t2 VALUES (10363,33,333,0);
INSERT INTO t2 VALUES (11412,55,0,0);
INSERT INTO t2 VALUES (50003,66,6,0);
INSERT INTO t2 VALUES (11403,5,0,0);
INSERT INTO t2 VALUES (11406,11,11,0);
INSERT INTO t2 VALUES (11410,11410,131,0);
INSERT INTO t2 VALUES (11416,11416,32767,0);
INSERT INTO t2 VALUES (11409,0,0,0);

CREATE TABLE t3 (   id int(11) NOT NULL auto_increment,   dni_pasaporte char(16) DEFAULT '' NOT NULL,   idPla int(11) DEFAULT '0' NOT NULL,   cod_asig int(11) DEFAULT '0' NOT NULL,   any smallint(6) DEFAULT '0' NOT NULL,   quatrimestre smallint(6) DEFAULT '0' NOT NULL,   estat char(1) DEFAULT 'M' NOT NULL,   PRIMARY KEY (id),   UNIQUE dni_pasaporte (dni_pasaporte,idPla),   UNIQUE dni_pasaporte_2 (dni_pasaporte,idPla,cod_asig,any,quatrimestre) );

INSERT INTO t3 VALUES (1,'11111111',1,10362,98,1,'M');

CREATE TABLE t4 (   id int(11) NOT NULL auto_increment,   papa int(11) DEFAULT '0' NOT NULL,   fill int(11) DEFAULT '0' NOT NULL,   idPla int(11) DEFAULT '0' NOT NULL,   PRIMARY KEY (id),   KEY papa (idPla,papa),   UNIQUE papa_2 (idPla,papa,fill) );

INSERT INTO t4 VALUES (1,-1,10360,1);
INSERT INTO t4 VALUES (2,-1,10361,1);
INSERT INTO t4 VALUES (3,-1,10362,1);

SELECT DISTINCT fill,desc_larga_cat,cred_total,Grup,Places,PlacesOcupades FROM t4 LEFT JOIN t3 ON t3.cod_asig=fill AND estat='S'   AND dni_pasaporte='11111111'   AND t3.idPla=1 , t2,t1 WHERE fill=t1.id   AND Places>PlacesOcupades   AND fill=t2.id   AND t4.idPla=1   AND papa=-1;

SELECT DISTINCT fill,t3.idPla FROM t4 LEFT JOIN t3 ON t3.cod_asig=t4.fill AND t3.estat='S' AND t3.dni_pasaporte='1234' AND t3.idPla=1 ;

INSERT INTO t3 VALUES (3,'1234',1,10360,98,1,'S');
SELECT DISTINCT fill,t3.idPla FROM t4 LEFT JOIN t3 ON t3.cod_asig=t4.fill AND t3.estat='S' AND t3.dni_pasaporte='1234' AND t3.idPla=1 ;

drop table t1;
drop table t2;
drop table t3;
drop table t4;

#
# Test of IS NULL on AUTO_INCREMENT with LEFT JOIN
#
CREATE TABLE t1 (   id smallint(5) unsigned NOT NULL auto_increment,   name char(60) DEFAULT '' NOT NULL,   PRIMARY KEY (id) );
INSERT INTO t1 VALUES (1,'Antonio Paz');
INSERT INTO t1 VALUES (2,'Lilliana Angelovska');
INSERT INTO t1 VALUES (3,'Thimble Smith');

CREATE TABLE t2 (   id smallint(5) unsigned NOT NULL auto_increment,   owner smallint(5) unsigned DEFAULT '0' NOT NULL,   name char(60),   PRIMARY KEY (id) );
INSERT INTO t2 VALUES (1,1,'El Gato');
INSERT INTO t2 VALUES (2,1,'Perrito');
INSERT INTO t2 VALUES (3,3,'Happy');

#--sorted_result
select t1.name, t2.name, t2.id from t1 left join t2 on (t1.id = t2.owner);
select t1.name, t2.name, t2.id from t1 left join t2 on (t1.id = t2.owner) where t2.id is null;
# -- explain select t1.name, t2.name, t2.id from t1 left join t2 on (t1.id = t2.owner) where t2.id is null;
# -- explain select t1.name, t2.name, t2.id from t1 left join t2 on (t1.id = t2.owner) where t2.name is null;
select count(*) from t1 left join t2 on (t1.id = t2.owner);

#--sorted_result
select t1.name, t2.name, t2.id from t2 right join t1 on (t1.id = t2.owner);
select t1.name, t2.name, t2.id from t2 right join t1 on (t1.id = t2.owner) where t2.id is null;
# -- explain select t1.name, t2.name, t2.id from t2 right join t1 on (t1.id = t2.owner) where t2.id is null;
# -- explain select t1.name, t2.name, t2.id from t2 right join t1 on (t1.id = t2.owner) where t2.name is null;
select count(*) from t2 right join t1 on (t1.id = t2.owner);

#--sorted_result
select t1.name, t2.name, t2.id,t3.id from t2 right join t1 on (t1.id = t2.owner) left join t1 as t3 on t3.id=t2.owner;
select t1.name, t2.name, t2.id,t3.id from t1 right join t2 on (t1.id = t2.owner) right join t1 as t3 on t3.id=t2.owner;
select t1.name, t2.name, t2.id, t2.owner, t3.id from t1 left join t2 on (t1.id = t2.owner) right join t1 as t3 on t3.id=t2.owner;

drop table t1;
drop table t2;

create table t1 (id int not null, str char(10), index(str));
insert into t1 values (1, null), (2, null), (3, "foo"), (4, "bar");
select * from t1 where str is not null order by id;
select * from t1 where str is null;
drop table t1;

#
# Test wrong LEFT JOIN query
#

CREATE TABLE t1 (   id bigint(21) NOT NULL auto_increment,   PRIMARY KEY (id) );
CREATE TABLE t2 (   id bigint(21) NOT NULL auto_increment,   PRIMARY KEY (id) );
CREATE TABLE t3 (   id bigint(21) NOT NULL auto_increment,   PRIMARY KEY (id) );
CREATE TABLE t4 (   id bigint(21) DEFAULT '0' NOT NULL,   seq_1_id bigint(21) DEFAULT '0' NOT NULL,   KEY seq_0_id (id),   KEY seq_1_id (seq_1_id) );
CREATE TABLE t5 (   id bigint(21) DEFAULT '0' NOT NULL,   seq_1_id bigint(21) DEFAULT '0' NOT NULL,   KEY seq_1_id (seq_1_id),   KEY seq_0_id (id) );

insert into t1 values (1);
insert into t2 values (1);
insert into t3 values (1);
insert into t4 values (1,1);
insert into t5 values (1,1);

#--error 1054
# -- explain select * from t3 left join t4 on t4.seq_1_id = t2.id left join t1 on t1.id = t4.id left join t5 on t5.id = t1.id left join t2 on t2.id = t5.seq_1_id where t3.id = 23;

drop table t1;
drop table t2;
drop table t3;
drop table t4;
drop table t5;

#
# Another LEFT JOIN problem
# (The problem was that the result changed when we added ORDER BY)
#

create table t1 (id int, m int, o int, key(id));
create table t2 (id int not null, m int, o int, primary key(id));
insert into t1 values (1, 2, 11), (1, 2, 7), (2, 2, 8), (1,2,9),(1,3,9);
insert into t2 values (1, 2, 3),(2, 2, 8), (4,3,9),(3,2,10);
select t1.*, t2.* from t1 left join t2 on t1.id = t2.id and t1.m = t2.m where t1.id = 1;
select t1.*, t2.* from t1 left join t2 on t1.id = t2.id and t1.m = t2.m where t1.id = 1 order by t1.o,t1.m;
drop table t1;
drop table t2;

# Test bug with NATURAL join:

CREATE TABLE td1 (id1 INT NOT NULL PRIMARY KEY, dat1 CHAR(1), id2 INT);
INSERT INTO td1 VALUES (1,'a',1);
INSERT INTO td1 VALUES (2,'b',1);
INSERT INTO td1 VALUES (3,'c',2);

CREATE TABLE td2 (id2 INT NOT NULL PRIMARY KEY, dat2 CHAR(1));
INSERT INTO td2 VALUES (1,'x');
INSERT INTO td2 VALUES (2,'y');
INSERT INTO td2 VALUES (3,'z');

SELECT td2.id2 FROM td2 LEFT OUTER JOIN td1 ON td1.id2 = td2.id2 WHERE id1 IS NULL;
SELECT td2.id2 FROM td2 NATURAL LEFT OUTER JOIN td1 WHERE id1 IS NULL;

drop table td1;
drop table td2;

create table ts5 ( id varchar(20), name varchar(20) );
insert into ts5 values ( 'red', 'apple' );
insert into ts5 values ( 'yellow', 'banana' );
insert into ts5 values ( 'green', 'lime' );
insert into ts5 values ( 'black', 'grape' );
insert into ts5 values ( 'blue', 'blueberry' );
create table t2 ( id int, color varchar(20) );
insert into t2 values (10, 'green');
insert into t2 values (5, 'black');
insert into t2 values (15, 'white');
insert into t2 values (7, 'green');
select * from ts5;
select * from t2;
select * from t2 natural join ts5;
select t2.id, ts5.name from t2 natural join ts5;
select t2.id, ts5.name from t2 inner join ts5 using (id);
drop table ts5;
drop table t2;

#
# Test of LEFT JOIN + GROUP FUNCTIONS within functions:
#

CREATE TABLE ts1 (   sid varchar(8) DEFAULT '' NOT NULL );
INSERT INTO ts1 VALUES ('kvw2000'),('kvw2001'),('kvw3000'),('kvw3001'),('kvw3002'),('kvw3500'),('kvw3501'),('kvw3502'),('kvw3800'),('kvw3801'),('kvw3802'),('kvw3900'),('kvw3901'),('kvw3902'),('kvw4000'),('kvw4001'),('kvw4002'),('kvw4200'),('kvw4500'),('kvw5000'),('kvw5001'),('kvw5500'),('kvw5510'),('kvw5600'),('kvw5601'),('kvw6000'),('klw1000'),('klw1020'),('klw1500'),('klw2000'),('klw2001'),('klw2002'),('kld2000'),('klw2500'),('kmw1000'),('kmw1500'),('kmw2000'),('kmw2001'),('kmw2100'),('kmw3000'),('kmw3200');
CREATE TABLE ts2 (   sid varchar(8) DEFAULT '' NOT NULL,   KEY sid (sid) );
INSERT INTO ts2 VALUES ('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw2000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3000'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw3500'),('kvw6000'),('kvw6000'),('kld2000');
#--source include/turn_off_only_full_group_by.inc

SELECT ts1.sid, IF(ISNULL(ts2.sid), 0, COUNT(*)) AS count FROM ts1 LEFT JOIN ts2 ON ts1.sid = ts2.sid GROUP BY ts1.sid;
SELECT SQL_BIG_RESULT ts1.sid, IF(ISNULL(ts2.sid), 0, COUNT(*)) AS count FROM ts1 LEFT JOIN ts2 ON ts1.sid = ts2.sid GROUP BY ts1.sid;

#--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
drop table ts1;
drop table ts2;

#
# Another left join problem
#
SET sql_mode = 'NO_ENGINE_SUBSTITUTION';
CREATE TABLE t1 (   id int(11),   pid int(11),   rep_del tinyint(4),   KEY id (id),   KEY pid (pid) );
INSERT INTO t1 VALUES (1,NULL,NULL);
INSERT INTO t1 VALUES (2,1,NULL);
select * from t1 LEFT JOIN t1 t2 ON (t1.id=t2.pid) AND t2.rep_del IS NULL;
create index rep_del ON t1(rep_del);
select * from t1 LEFT JOIN t1 t2 ON (t1.id=t2.pid) AND t2.rep_del IS NULL;
drop table t1;

CREATE TABLE t1 (   id int(11) DEFAULT '0' NOT NULL,   name tinytext DEFAULT '' NOT NULL,   UNIQUE id (id) );
INSERT INTO t1 VALUES (1,'yes'),(2,'no');
CREATE TABLE t2 (   id int(11) DEFAULT '0' NOT NULL,   idx int(11) DEFAULT '0' NOT NULL,   UNIQUE id (id,idx) );
INSERT INTO t2 VALUES (1,1);
# -- explain SELECT * from t1 left join t2 on t1.id=t2.id where t2.id IS NULL;
SELECT * from t1 left join t2 on t1.id=t2.id where t2.id IS NULL;
drop table t1;
drop table t2;
SET sql_mode = default;
#
# Test problem with using key_column= constant in ON and WHERE
#
create table t1 (id mediumint, reporter mediumint);
create table t2 (id mediumint, who mediumint, index(who));
insert into t2 values (1,1),(1,2);
insert into t1 values (1,1),(2,1);
SELECT * FROM t1 LEFT JOIN t2 ON (t1.id =  t2.id AND  t2.who = 2) WHERE  (t1.reporter = 2 OR t2.who = 2);
drop table t1;
drop table t2;

#
# Test problem with LEFT JOIN

create table tsing1 (id smallint unsigned auto_increment, primary key (id));
create table t2 (id smallint unsigned not null, barID smallint unsigned not null, primary key (id,barID));
insert into tsing1 (id) values (10),(20),(30);
insert into t2 values (10,1),(20,2),(30,3);
# -- explain select * from t2 left join tsing1 on tsing1.id = t2.id and tsing1.id = 30;
select * from t2 left join tsing1 on tsing1.id = t2.id and tsing1.id = 30;
#--sorted_result
select * from t2 left join tsing1 ignore index(primary) on tsing1.id = t2.id and tsing1.id = 30;
drop table tsing1;
drop table t2;

create table t1 (id int);
create table t2 (id int);
create table t3 (id int);
insert into t1 values(1),(2);
insert into t2 values(2),(3);
insert into t3 values(2),(4);
#--sorted_result
select * from t1 natural left join t2 natural left join t3;
select * from t1 natural left join t2 where (t2.id is not null)=0;
#--sorted_result
select * from t1 natural left join t2 where (t2.id is not null) is not null;
select * from t1 natural left join t2 where (id is not null)=0;
#--sorted_result
select * from t1 natural left join t2 where (id is not null) is not null;
drop table t1;
drop table t2;
drop table t3;

#
# Test of USING
#
create table td1 (id1 integer,id2 integer,id3 integer);
create table td2 (id2 integer,f4 integer);
create table td3 (id3 integer,f5 integer);
select * from td1          left outer join td2 using (id2)          left outer join td3 using (id3);
drop table td1;
drop table td2;
drop table td3;

create table td1 (id1 int, a2 int);
create table td2 (id2 int not null, b2 int);
create table td3 (id3 int, c2 int);

insert into td1 values (1,2), (2,2), (3,2);
insert into td2 values (1,3), (2,3);
insert into td3 values (2,4),        (3,4);

select * from td1 left join td2  on  id2 = id1 left join td3  on  id3 = id1  and  id2 is null;
# -- explain select * from td1 left join td2  on  id2 = id1 left join td3  on  id3 = id1  and  id2 is null;

drop table td1;
drop table td2;
drop table td3;

# Test for BUG#8711 '<=>' was considered to be a NULL-rejecting predicate.
create table t1 (   id int(11),   b char(10),   key (id) );
insert into t1 (id) values (1),(2),(3),(4);
create table t2 (id int);

select * from t1 left join t2 on t1.id=t2.id where not (t2.id <=> t1.id);
select * from t1 left join t2 on t1.id=t2.id having not (t2.id <=> t1.id);
drop table t1;
drop table t2;

# Test for BUG#5088
create table tsing1 (   id tinyint(3) unsigned not null auto_increment,   id1 tinyint(3) unsigned default '0',   unique key id (id),   key id_2 (id) );

insert into tsing1 values("1", "2");

create table t2 (   id tinyint(3) unsigned default '0',   match_1_h tinyint(3) unsigned default '0',   key id (id) );

insert into t2 values("1", "5");
insert into t2 values("2", "9");
insert into t2 values("3", "3");
insert into t2 values("4", "7");
insert into t2 values("5", "6");
insert into t2 values("6", "8");
insert into t2 values("7", "4");
insert into t2 values("8", "12");
insert into t2 values("9", "11");
insert into t2 values("10", "10");

# -- explain select s.*, '*', m.*, (s.match_1_h - m.id1) UUX from   (t2 s left join tsing1 m on m.id = 1)   order by m.id desc;
  
# -- explain select s.*, '*', m.*, (s.match_1_h - m.id1) UUX from   (t2 s left join tsing1 m on m.id = 1)   order by UUX desc;

select s.*, '*', m.*, (s.match_1_h - m.id1) UUX from   (t2 s left join tsing1 m on m.id = 1)   order by UUX desc;

# -- explain select s.*, '*', m.*, (s.match_1_h - m.id1) UUX from   t2 s straight_join tsing1 m where m.id = 1   order by UUX desc;

select s.*, '*', m.*, (s.match_1_h - m.id1) UUX from   t2 s straight_join tsing1 m where m.id = 1   order by UUX desc;

drop table tsing1;
drop table t2;

# Tests for bugs #6307 and 6460

create table t1 (id int, b int, unique index idx (id, b));
create table t2 (id int, b int, c int, unique index idx (id, b));

insert into t1 values (1, 10), (1,11), (2,10), (2,11);
insert into t2 values (1,10,3);

select t1.id, t1.b, t2.c from t1 left join t2                                 on t1.id=t2.id and t1.b=t2.b and t2.c=3    where t1.id=1 and t2.c is null;

drop table t1;
drop table t2;

CREATE TABLE t1 (   id bigint(20) default NULL,   inst_id tinyint(4) default NULL,   flag_name varchar(64) default NULL,   flag_value text,   UNIQUE KEY ts_id (id,inst_id,flag_name) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE t2 (   id bigint(20) default NULL,   inst_id tinyint(4) default NULL,   flag_name varchar(64) default NULL,   flag_value text,   UNIQUE KEY ts_id (id,inst_id,flag_name) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO t1 VALUES   (111056548820001, 0, 'flag1', NULL),   (111056548820001, 0, 'flag2', NULL),   (2, 0, 'other_flag', NULL);

INSERT INTO t2 VALUES   (111056548820001, 3, 'flag1', 'sss');

SELECT t1.flag_name,t2.flag_value   FROM t1 LEFT JOIN t2           ON (t1.id = t2.id AND t1.flag_name = t2.flag_name AND               t2.inst_id = 3)   WHERE t1.inst_id = 0 AND t1.id=111056548820001 AND         t2.flag_value IS  NULL;

DROP TABLE t1;
drop table t2;

CREATE TABLE t1 (   id int(11) unsigned NOT NULL auto_increment,   id2 int(10) unsigned default NULL,   PRIMARY KEY  (id) );

INSERT INTO t1 VALUES("1", "0");
INSERT INTO t1 VALUES("2", "10");

CREATE TABLE td2 (   id2 char(3) NOT NULL default '',   language_id char(3) NOT NULL default '',   text_data text,   PRIMARY KEY  (id2,language_id) );

INSERT INTO td2 VALUES("0", "EN", "0-EN");
INSERT INTO td2 VALUES("0", "SV", "0-SV");
INSERT INTO td2 VALUES("10", "EN", "10-EN");
INSERT INTO td2 VALUES("10", "SV", "10-SV");
SELECT t1.id, t1.id2, td2.text_data   FROM t1 LEFT JOIN td2                ON t1.id2 = td2.id2                   AND td2.language_id = 'SV'   WHERE (t1.id LIKE '%' OR td2.text_data LIKE '%');

DROP TABLE t1;
drop table td2;

# Test for bug #5896  

CREATE TABLE tp1 (c int PRIMARY KEY);
CREATE TABLE tp2 (a int PRIMARY KEY);
CREATE TABLE tp3 (b int);
CREATE TABLE tp4 (y int);
INSERT INTO tp1 VALUES (1);
INSERT INTO tp2 VALUES (1);
INSERT INTO tp3 VALUES (1), (2);
INSERT INTO tp4 VALUES (1), (2);

SELECT * FROM tp2 LEFT JOIN tp3 ON a=0;
# -- explain SELECT * FROM tp2 LEFT JOIN tp3 ON a=0;
SELECT * FROM tp2 LEFT JOIN (tp3,tp4) ON a=0;
# -- explain SELECT * FROM tp2 LEFT JOIN (tp3,tp4) ON a=0;
SELECT * FROM tp1, tp2 LEFT JOIN (tp3,tp4) ON a=0 WHERE c=a;
# -- explain SELECT * FROM tp1, tp2 LEFT JOIN (tp3,tp4) ON a=0 WHERE c=a;

INSERT INTO tp1 VALUES (0);
INSERT INTO tp2 VALUES (0);
SELECT * FROM tp1, tp2 LEFT JOIN (tp3,tp4) ON a=5 WHERE c=a AND c=1;
# -- explain SELECT * FROM tp1, tp2 LEFT JOIN (tp3,tp4) ON a=5 WHERE c=a AND c=1;

# Test for BUG#4480
drop table tp2;
drop table tp3;
create table tp2 (a int, b int);
insert into tp2 values (1,1),(2,2),(3,3);
create table tp3 (a int, b int);
insert into tp3 values (1,1), (2,2);

select * from tp3 right join tp2 on tp3.a=tp2.a;
select straight_join * from tp3 right join tp2 on tp3.a=tp2.a;

DROP TABLE tp1;
DROP TABLE tp2;
DROP TABLE tp3;
DROP TABLE tp4;

#
# Test for bug #9017: left join mistakingly converted to inner join
#

CREATE TABLE tp2 (a int PRIMARY KEY, b int);
CREATE TABLE at2 (a int PRIMARY KEY, b int);

INSERT INTO tp2 VALUES (1,1), (2,1), (3,1), (4,2);
INSERT INTO at2 VALUES (1,2), (2,2);

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a=at2.a;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a=at2.a WHERE tp2.b=1;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a=at2.a   WHERE tp2.b=1 XOR (NOT ISNULL(at2.a) AND at2.b=1);
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a=at2.a WHERE not(0+(tp2.a=30 and at2.b=1));

DROP TABLE tp2;
DROP TABLE at2;

# Bug #8681: Bad warning message when group_concat() exceeds max length
set group_concat_max_len=5;
create table tp2 (a int, b varchar(20));
create table at2 (a int, c varchar(20));
insert into tp2 values (1,"aaaaaaaaaa"),(2,"bbbbbbbbbb");
insert into at2 values (1,"cccccccccc"),(2,"dddddddddd");
select group_concat(tp2.b,at2.c) from tp2 left join at2 using(a) group by tp2.a;
select group_concat(tp2.b,at2.c) from tp2 inner join at2 using(a) group by tp2.a;
select group_concat(tp2.b,at2.c) from tp2 left join at2 using(a) group by a;
select group_concat(tp2.b,at2.c) from tp2 inner join at2 using(a) group by a;
drop table tp2;
drop table at2;
set group_concat_max_len=default;

# End of 4.1 tests

#
# BUG#10162 - ON is merged with WHERE, left join is convered to a regular join
#
create table tp4 (gid smallint(5) unsigned not null, x int(11) not null, y int(11) not null, art int(11) not null, primary key  (gid,x,y));
insert tp4 values (1, -5, -8, 2), (1, 2, 2, 1), (1, 1, 1, 1);
create table t2 (gid smallint(5) unsigned not null, x int(11) not null, y int(11) not null, id int(11) not null, primary key  (gid,id,x,y), key id (id));
insert t2 values (1, -5, -8, 1), (1, 1, 1, 1), (1, 2, 2, 1);
create table t3 ( set_id smallint(5) unsigned not null, id tinyint(4) unsigned not null, name char(12) not null, primary key  (id,set_id));
insert t3 values (0, 1, 'a'), (1, 1, 'b'), (0, 2, 'c'), (1, 2, 'd'), (1, 3, 'e'), (1, 4, 'f'), (1, 5, 'g'), (1, 6, 'h');
# -- explain select name from tp4 left join t2 on tp4.x = t2.x and tp4.y = t2.y left join t3 on tp4.art = t3.id where t2.id =1 and t2.x = -5 and t2.y =-8 and tp4.gid =1 and t2.gid =1 and t3.set_id =1;
drop table tp4;
drop table t2;
drop table t3;

#
# Test for bug #9938: invalid conversion from outer join to inner join 
# for queries containing indirect reference in WHERE clause
#

CREATE TABLE t1 (id INT, GRP INT);
INSERT INTO t1 VALUES (0, 10);
INSERT INTO t1 VALUES (2, 30);

CREATE TABLE t2 (id INT, NAME CHAR(5));
INSERT INTO t2 VALUES (0, 'KERI');
INSERT INTO t2 VALUES (9, 'BARRY');

CREATE VIEW v1 AS SELECT COALESCE(t2.id,t1.id) AS id, NAME, GRP   FROM t2 LEFT OUTER JOIN t1 ON t2.id=t1.id;

SELECT * FROM v1;
SELECT * FROM v1 WHERE id < 10;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE t2;

#
# Test for bug #11285: false Item_equal on expression in outer join
# 

CREATE TABLE td1 (id1 int);
CREATE TABLE td2 (id2 int);
INSERT INTO td1 VALUES (30), (40), (50);
INSERT INTO td2 VALUES (300), (400), (500);
SELECT * FROM td1 LEFT JOIN td2 ON (id1=id2 AND id2=30) WHERE id1=40;
DROP TABLE td1;
DROP TABLE td2;
#
# Test for bugs
# #12101: erroneously applied outer join elimination in case of WHERE NOT BETWEEN
# #12102: erroneously missing outer join elimination in case of WHERE IN/IF
#

CREATE TABLE tp2 (a int PRIMARY KEY, b int);
CREATE TABLE at2 (a int PRIMARY KEY, b int);

INSERT INTO tp2 VALUES (1,2), (2,1), (3,2), (4,3), (5,6), (6,5), (7,8), (8,7), (9,10);
INSERT INTO at2 VALUES (3,0), (4,1), (6,4), (7,5);

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE at2.b <= tp2.a AND tp2.a <= tp2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a BETWEEN at2.b AND tp2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(tp2.a NOT BETWEEN at2.b AND tp2.b);

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE at2.b > tp2.a OR tp2.a > tp2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a NOT BETWEEN at2.b AND tp2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(tp2.a BETWEEN at2.b AND tp2.b);

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a = at2.a OR at2.b > tp2.a OR tp2.a > tp2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(tp2.a != at2.a AND tp2.a BETWEEN at2.b AND tp2.b);

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a = at2.a AND (at2.b > tp2.a OR tp2.a > tp2.b);
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(tp2.a != at2.a OR tp2.a BETWEEN at2.b AND tp2.b);

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a = at2.a OR tp2.a = at2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a IN(at2.a, at2.b);
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(tp2.a NOT IN(at2.a, at2.b));

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a != tp2.b AND tp2.a != at2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a NOT IN(tp2.b, at2.b);
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(tp2.a IN(tp2.b, at2.b));

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE at2.a != at2.b OR (tp2.a != at2.a AND tp2.a != at2.b);
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(at2.a = at2.b AND tp2.a IN(at2.a, at2.b));

SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE at2.a != at2.b AND tp2.a != tp2.b AND tp2.a != at2.b;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE NOT(at2.a = at2.b OR tp2.a IN(tp2.b, at2.b));

# -- explain SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a = at2.a OR tp2.a = at2.b;
# -- explain SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a IN(at2.a, at2.b);
# -- explain SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a = at2.a WHERE tp2.a > IF(tp2.a = at2.b-2, at2.b, at2.b-1);

DROP TABLE tp2;
DROP TABLE at2;

#
# Test for bug #17164: ORed FALSE blocked conversion of outer join into join
#

# Test case moved to join_outer_innodb

#
# Bug 19396: LEFT OUTER JOIN over views in curly braces 
# 
#--disable_warnings
DROP VIEW IF EXISTS v1;
DROP VIEW IF EXISTS v2;
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
#--enable_warnings

CREATE TABLE tp2 (a int);
CREATE table tp3 (b int);
INSERT INTO tp2 VALUES (1), (2), (3), (4), (1), (1), (3);
INSERT INTO tp3 VALUES (2), (3);

CREATE VIEW v1 AS SELECT a FROM tp2 JOIN tp3 ON tp2.a=tp3.b;
CREATE VIEW v2 AS SELECT b FROM tp3 JOIN tp2 ON tp3.b=tp2.a;

# We see the functional dependency implied by ON:
SELECT v1.a, v2. b   FROM v1 LEFT OUTER JOIN v2 ON (v1.a=v2.b) AND (v1.a >= 3)     GROUP BY v1.a;
SELECT v1.a, v2. b   FROM { OJ v1 LEFT OUTER JOIN v2 ON (v1.a=v2.b) AND (v1.a >= 3) }     GROUP BY v1.a;

DROP VIEW v1;
DROP VIEW  v2;
DROP TABLE tp2;
DROP TABLE tp3;

#
# Bug 19816: LEFT OUTER JOIN with constant ORed predicates in WHERE clause
# 

CREATE TABLE tp2 (a int);
CREATE TABLE tp3 (b int);
INSERT INTO tp2 VALUES (1), (2), (3), (4);
INSERT INTO tp3 VALUES (2), (3);

#--sorted_result
SELECT * FROM tp2 LEFT JOIN tp3 ON tp2.a = tp3.b WHERE (1=1);

#--sorted_result
SELECT * FROM tp2 LEFT JOIN tp3 ON tp2.a = tp3.b WHERE (1 OR 1);
#--sorted_result
SELECT * FROM tp2 LEFT JOIN tp3 ON tp2.a = tp3.b WHERE (0 OR 1);
#--sorted_result
SELECT * FROM tp2 LEFT JOIN tp3 ON tp2.a = tp3.b WHERE (1=1 OR 2=2);
#--sorted_result
SELECT * FROM tp2 LEFT JOIN tp3 ON tp2.a = tp3.b WHERE (1=1 OR 1=0);

DROP TABLE tp2;
DROP TABLE tp3;

#
# Bug 26017: LEFT OUTER JOIN over two constant tables and 
#            a case-insensitive comparison predicate field=const 
# 

CREATE TABLE ts1 (   sid varchar(16) collate latin1_swedish_ci PRIMARY KEY,   f2 varchar(16) collate latin1_swedish_ci );
CREATE TABLE ts2 (   sid varchar(16) collate latin1_swedish_ci PRIMARY KEY,   f3 varchar(16) collate latin1_swedish_ci );

INSERT INTO ts1 VALUES ('bla','blah');
INSERT INTO ts2 VALUES ('bla','sheep');

SELECT * FROM ts1 JOIN ts2 USING(sid) WHERE sid='Bla';
SELECT * FROM ts1 LEFT JOIN ts2 USING(sid) WHERE sid='bla';
SELECT * FROM ts1 LEFT JOIN ts2 USING(sid) WHERE sid='Bla';

DROP TABLE ts1;
DROP TABLE ts2;

#
# Bug 28188: 'not exists' optimization for outer joins 
#
 
CREATE TABLE t1 (id int PRIMARY KEY, a varchar(8));
CREATE TABLE t2 (id int NOT NULL, b int NOT NULL, INDEX idx(id));
INSERT INTO t1 VALUES   (1,'aaaaaaa'), (5,'eeeeeee'), (4,'ddddddd'), (2,'bbbbbbb'), (3,'ccccccc');
INSERT INTO t2 VALUES   (3,10), (2,20), (5,30), (3,20), (5,10), (3,40), (3,30), (2,10), (2,40);

# -- explain SELECT t1.id, a FROM t1 LEFT JOIN t2 ON t1.id=t2.id WHERE t2.b IS NULL;

flush status;
SELECT t1.id, a FROM t1 LEFT JOIN t2 ON t1.id=t2.id WHERE t2.b IS NULL;
show status like 'Handler_read%';

DROP TABLE t1;
DROP TABLE t2;

#
# Bug 28571: outer join with false on condition over constant tables 
#

CREATE TABLE tp1 (c int  PRIMARY KEY, e int NOT NULL);
INSERT INTO tp1 VALUES (1,0), (2,1);
CREATE TABLE tp6 (d int PRIMARY KEY);
INSERT INTO tp6 VALUES (1), (2), (3);

# -- explain SELECT * FROM tp1 LEFT JOIN tp6 ON e<>0 WHERE c=1 AND d IS NULL;
SELECT * FROM tp1 LEFT JOIN tp6 ON e<>0 WHERE c=1 AND d IS NULL;
SELECT * FROM tp1 LEFT JOIN tp6 ON e<>0 WHERE c=1 AND d<=>NULL;

DROP TABLE tp1;
DROP TABLE tp6;

#--echo #
#--echo # Bug#47650: using group by with rollup without indexes returns incorrect 
#--echo # results with where
#--echo #
CREATE TABLE tp2 ( a INT );
INSERT INTO tp2 VALUES (1);

CREATE TABLE at2 ( a INT, b INT );
INSERT INTO at2 VALUES (1, 1),(1, 2),(1, 3),(2, 4),(2, 5);

# -- explain SELECT tp2.a, COUNT( at2.b ), SUM( at2.b ), MAX( at2.b ) FROM tp2 LEFT JOIN at2 USING( a ) GROUP BY tp2.a WITH ROLLUP;

SELECT tp2.a, COUNT( at2.b ), SUM( at2.b ), MAX( at2.b ) FROM tp2 LEFT JOIN at2 USING( a ) GROUP BY tp2.a WITH ROLLUP;

# -- explain SELECT tp2.a, COUNT( at2.b ), SUM( at2.b ), MAX( at2.b ) FROM tp2 JOIN at2 USING( a ) GROUP BY tp2.a WITH ROLLUP;

SELECT tp2.a, COUNT( at2.b ), SUM( at2.b ), MAX( at2.b ) FROM tp2 JOIN at2 USING( a ) GROUP BY tp2.a WITH ROLLUP;

DROP TABLE tp2;
DROP TABLE at2;

#--echo #
#--echo # Bug#51598 Inconsistent behaviour with a COALESCE statement inside an IN comparison
#--echo #
CREATE TABLE t1(id INT, f2 INT, f3 INT);
INSERT INTO t1 VALUES (1, NULL, 3);
CREATE TABLE t2(id INT, f2 INT);
INSERT INTO t2 VALUES (2, 1);

# -- explain EXTENDED SELECT * FROM t1 LEFT JOIN t2 ON t1.f2 = t2.f2 WHERE (COALESCE(t1.id, t2.id), f3) IN ((1, 3), (2, 2));

SELECT * FROM t1 LEFT JOIN t2 ON t1.f2 = t2.f2 WHERE (COALESCE(t1.id, t2.id), f3) IN ((1, 3), (2, 2));

DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug#52357: Assertion failed: join->best_read in greedy_search 
#--echo # optimizer_search_depth=0
#--echo #
CREATE TABLE tp2( a INT );

INSERT INTO tp2 VALUES (1),(2);
SET optimizer_search_depth = 0;

#--echo # Should not core dump on query preparation
# -- explain SELECT 1 FROM tp2 tt3 LEFT  OUTER JOIN tp2 tt4 ON 1             LEFT  OUTER JOIN tp2 tt5 ON 1             LEFT  OUTER JOIN tp2 tt6 ON 1             LEFT  OUTER JOIN tp2 tt7 ON 1             LEFT  OUTER JOIN tp2 tt8 ON 1             RIGHT OUTER JOIN tp2 tt2 ON 1             RIGHT OUTER JOIN tp2 tt1 ON 1             STRAIGHT_JOIN    tp2 tt9 ON 1;

SET optimizer_search_depth = DEFAULT;
DROP TABLE tp2;

#--echo #
#--echo # Bug#46091 STRAIGHT_JOIN + RIGHT JOIN returns different result
#--echo #
CREATE TABLE t1 (id INT NOT NULL);
INSERT INTO t1 VALUES (9),(0);

CREATE TABLE t2 (id INT NOT NULL);
INSERT INTO t2 VALUES (5),(3),(0),(3),(1),(0),(1),(7),(1),(0),(0),(8),(4),(9),(0),(2),(0),(8),(5),(1);

SELECT STRAIGHT_JOIN COUNT(*) FROM t1 ta1 RIGHT JOIN t2 ta2 JOIN t2 ta3 ON ta2.id ON ta3.id;

# -- explain SELECT STRAIGHT_JOIN COUNT(*) FROM t1 ta1 RIGHT JOIN t2 ta2 JOIN t2 ta3 ON ta2.id ON ta3.id;

DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug#48971 Segfault in add_found_match_trig_cond () at sql_select.cc:5990
#--echo #
CREATE TABLE t1(id INT, PRIMARY KEY (id));
INSERT INTO t1 VALUES (1),(2);

# -- explain EXTENDED SELECT STRAIGHT_JOIN jt1.id FROM t1 AS jt1  LEFT JOIN t1 AS jt2   RIGHT JOIN t1 AS jt3     JOIN t1 AS jt4 ON 1    LEFT JOIN t1 AS jt5 ON 1   ON 1   RIGHT JOIN t1 AS jt6 ON jt6.id  ON 1;

# -- explain EXTENDED SELECT STRAIGHT_JOIN jt1.id FROM t1 AS jt1  RIGHT JOIN t1 AS jt2   RIGHT JOIN t1 AS jt3     JOIN t1 AS jt4 ON 1    LEFT JOIN t1 AS jt5 ON 1   ON 1   RIGHT JOIN t1 AS jt6 ON jt6.id  ON 1;

DROP TABLE t1;

#--echo #
#--echo # Bug#57688 Assertion `!table || (!table->write_set || bitmap_is_set(table->write_set, field
#--echo #

CREATE TABLE t1 (id INT NOT NULL, PRIMARY KEY (id));
CREATE TABLE t2 (id INT NOT NULL, f2 INT NOT NULL, PRIMARY KEY (id, f2));

INSERT INTO t1 VALUES (4);
INSERT INTO t2 VALUES (3, 3);
INSERT INTO t2 VALUES (7, 7);

# -- explain SELECT * FROM t1 LEFT JOIN t2 ON t2.id = t1.id WHERE t1.id = 4 GROUP BY t2.id, t2.f2;

SELECT * FROM t1 LEFT JOIN t2 ON t2.id = t1.id WHERE t1.id = 4 GROUP BY t2.id, t2.f2;

# -- explain SELECT * FROM t1 LEFT JOIN t2 ON t2.id = t1.id WHERE t1.id = 4 AND t2.id IS NOT NULL AND t2.f2 IS NOT NULL GROUP BY t2.id, t2.f2;

SELECT * FROM t1 LEFT JOIN t2 ON t2.id = t1.id WHERE t1.id = 4 AND t2.id IS NOT NULL AND t2.f2 IS NOT NULL GROUP BY t2.id, t2.f2;

DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug#57034 incorrect OUTER JOIN result when joined on unique key
#--echo #

CREATE TABLE t1 (id INT PRIMARY KEY,                  col_int INT,                  col_int_unique INT UNIQUE KEY); INSERT INTO t1 VALUES (1,NULL,2), (2,0,0);

CREATE TABLE t2 (id INT PRIMARY KEY,                  col_int INT,                  col_int_unique INT UNIQUE KEY); INSERT INTO t2 VALUES (1,0,1), (2,0,2);

# -- explain SELECT * FROM t1 LEFT JOIN t2   ON t1.col_int_unique = t2.col_int_unique AND t1.col_int = t2.col_int   WHERE t1.id=1;

SELECT * FROM t1 LEFT JOIN t2   ON t1.col_int_unique = t2.col_int_unique AND t1.col_int = t2.col_int   WHERE t1.id=1;

DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug#48046 Server incorrectly processing JOINs on NULL values
#--echo #

# bug#48046 is a duplicate of bug#57034

CREATE TABLE `t1` (   `id` int(11) NOT NULL AUTO_INCREMENT,   `time_key` time DEFAULT NULL,   `varchar_key` varchar(1) DEFAULT NULL,   `varchar_nokey` varchar(1) DEFAULT NULL,   PRIMARY KEY (`id`),   KEY `time_key` (`time_key`),   KEY `varchar_key` (`varchar_key`) ) ENGINE=innodb AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

INSERT INTO `t1` VALUES (10,'18:27:58',NULL,NULL);

SELECT table1.time_key AS field1, table2.id FROM t1 table1  LEFT JOIN t1 table2  ON table2.varchar_nokey = table1.varchar_key  HAVING field1;

DROP TABLE t1;

#--echo #
#--echo # Bug#49600 Server incorrectly processing RIGHT JOIN with 
#--echo #           constant WHERE clause and no index
#--echo #

# bug#49600 is a duplicate of bug#57034

CREATE TABLE `ts1` (   `col_datetime_key` datetime DEFAULT NULL,   `sid` varchar(1) DEFAULT NULL,   `col_varchar_nokey` varchar(1) DEFAULT NULL,   KEY `col_datetime_key` (`col_datetime_key`),   KEY `sid` (`sid`) ) ENGINE=innodb DEFAULT CHARSET=latin1;

INSERT INTO `ts1` VALUES ('1900-01-01 00:00:00',NULL,NULL);

SELECT table1.col_datetime_key  FROM ts1 table1 RIGHT JOIN ts1 table2  ON table2 .col_varchar_nokey = table1.sid  WHERE 7;

# Disable keys, and we get incorrect result for the same query
ALTER TABLE ts1 DISABLE KEYS;

SELECT table1.col_datetime_key  FROM ts1 table1 RIGHT JOIN ts1 table2  ON table2 .col_varchar_nokey = table1.sid  WHERE 7;

DROP TABLE ts1;


#--echo #
#--echo # Bug#58490: Incorrect result in multi level OUTER JOIN
#--echo # in combination with IS NULL
#--echo #

CREATE TABLE t1 (id INT NOT NULL);
INSERT INTO t1 VALUES (0),    (2),(3),(4);
CREATE TABLE t2 (id INT NOT NULL);
INSERT INTO t2 VALUES (0),(1),    (3),(4);
CREATE TABLE t3 (id INT NOT NULL);
INSERT INTO t3 VALUES (0),(1),(2),    (4);
CREATE TABLE t4 (id INT NOT NULL);
INSERT INTO t4 VALUES (0),(1),(2),(3)   ;

#--sorted_result
SELECT * FROM  t1 LEFT JOIN  ( t2 LEFT JOIN    ( t3 LEFT JOIN      t4      ON t4.id = t3.id    )    ON t3.id = t2.id  )  ON t2.id = t1.id  ;

#--sorted_result
SELECT * FROM  t1 LEFT JOIN  ( t2 LEFT JOIN    ( t3 LEFT JOIN      t4      ON t4.id = t3.id    )    ON t3.id = t2.id  )  ON t2.id = t1.id  WHERE t4.id IS NULL;


# Most simplified testcase to reproduce the bug.
# (Has to be at least a two level nested outer join)
#--sorted_result
SELECT * FROM  t1 LEFT JOIN  ( ( t2 LEFT JOIN      t3      ON t3.id = t2.id    )  )  ON t2.id = t1.id  WHERE t3.id IS NULL;


# Extended testing:
# We then add some equi-join inside the query above:
# (There Used to be some problems here with first
#  proposed patch for this bug)
#--sorted_result
SELECT * FROM  t1 LEFT JOIN  ( ( t2 LEFT JOIN      t3      ON t3.id = t2.id    )    JOIN t4    ON t4.id=t2.id  )  ON t2.id = t1.id  WHERE t3.id IS NULL;

#--sorted_result
SELECT * FROM  t1 LEFT JOIN  ( ( t2 LEFT JOIN      t3      ON t3.id = t2.id    )    JOIN (t4 AS t4a JOIN t4 AS t4b ON t4a.id=t4b.id)    ON t4a.id=t2.id  )  ON t2.id = t1.id  WHERE t3.id IS NULL;

#--sorted_result
SELECT * FROM  t1 LEFT JOIN  ( ( t2 LEFT JOIN      t3      ON t3.id = t2.id    )    JOIN (t4 AS t4a, t4 AS t4b)    ON t4a.id=t2.id  )  ON t2.id = t1.id  WHERE t3.id IS NULL;


DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;

## Bug#49322 & bug#58490 are duplicates. However, we include testcases
## for both.
#--echo #
#--echo # Bug#49322(Duplicate): Server is adding extra NULL row
#--echo # on processing a WHERE clause
#--echo #

CREATE TABLE t1 (id INT NOT NULL, col_int_key INT);
INSERT INTO t1 VALUES (1,NULL),(4,2),(5,2),(3,4),(2,8);

CREATE TABLE t2 (id INT NOT NULL, col_int_key INT);
INSERT INTO t2 VALUES (1,2),(2,7),(3,5),(4,7),(5,5),(6,NULL),(7,NULL),(8,9);
CREATE TABLE t3 (id INT NOT NULL, col_int_key INT);
INSERT INTO t3 VALUES (1,9),(2,2),(3,5),(4,2),(5,7),(6,0),(7,5);

# Baseline query wo/ 'WHERE ... IS NULL' - was correct
#--sorted_result
SELECT TABLE1.id FROM t3 TABLE1 RIGHT JOIN t1 TABLE2 ON TABLE1.col_int_key=TABLE2.col_int_key RIGHT JOIN t2 TABLE4 ON TABLE2.col_int_key=TABLE4.col_int_key;

# Adding 'WHERE ... IS NULL' -> incorrect result
#--sorted_result
SELECT TABLE1.id FROM t3 TABLE1 RIGHT JOIN t1 TABLE2 ON TABLE1.col_int_key=TABLE2.col_int_key RIGHT JOIN t2 TABLE4 ON TABLE2.col_int_key=TABLE4.col_int_key WHERE TABLE1.id IS NULL;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;

#--echo #
#--echo # Bug #11765810	58813: SERVER THREAD HANGS WHEN JOIN + WHERE + GROUP BY
#--echo # IS EXECUTED TWICE FROM P
#--echo #
CREATE TABLE tp2 ( a INT ) ENGINE=InnoDB;
INSERT INTO tp2 VALUES (1);
PREPARE prep_stmt FROM '  SELECT 1 AS f FROM tp2  LEFT JOIN tp2 t2   RIGHT JOIN tp2 t3     JOIN tp2 t4    ON 1   ON 1  ON 1  GROUP BY f';
EXECUTE prep_stmt;
EXECUTE prep_stmt;

DROP TABLE tp2;


#--echo End of 5.1 tests

#--echo #
#--echo # Bug#54235 Extra rows with join_cache_level=4,6,8 and two LEFT JOIN
#--echo #

CREATE TABLE t1 (id int);
CREATE TABLE t2 (id int);
CREATE TABLE t3 (id int);
CREATE TABLE t4 (id int);

INSERT INTO t1 VALUES (null),(null);

# -- let $query = SELECT t1.id FROM t1 LEFT JOIN (t2 LEFT JOIN t3 ON t2.id) ON 0 WHERE t1.id OR t3.id;

# -- eval # -- explain $query;

# -- eval $query;

# -- let $query = SELECT t1.id FROM t1 LEFT JOIN (t2 LEFT JOIN (t3 LEFT JOIN t4 ON 1) ON t2.id) ON 0 WHERE t1.id OR t4.id;

# -- eval # -- explain $query;

# -- eval $query;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;

#--echo #
#--echo # Bug#56254 Assertion tab->ref.use_count fails in
#--echo # join_read_key_unlock_row() on 4-way JOIN
#--echo #

CREATE TABLE t1 (   id INT NOT NULL,   col_int_key INT,   a INT,   PRIMARY KEY (id),   KEY col_int_key (col_int_key) );

INSERT INTO t1 VALUES (6, -448724992, NULL);

CREATE TABLE tp2 (   a INT,   sid VARCHAR(10) );

INSERT INTO tp2 VALUES (6,'afasdkiyum');

CREATE TABLE ts1 (   sid VARCHAR(10),   a INT );

CREATE TABLE t4 (   id INT NOT NULL,   PRIMARY KEY (id) );

INSERT INTO t4 VALUES (1);
INSERT INTO t4 VALUES (2);

SELECT t1.a FROM t1   LEFT JOIN tp2     LEFT JOIN ts1       JOIN t4        ON ts1.a  = t4.id     ON tp2.sid = ts1.sid   ON tp2.a = t1.id WHERE   t1.col_int_key IS NULL OR t4.id < ts1.a;

DROP TABLE t1;
DROP TABLE tp2;
DROP TABLE ts1;
DROP TABLE t4;

#--echo
#--echo # BUG#12567331 - INFINITE LOOP WHEN RESOLVING AN ALIASED COLUMN
#--echo # USED IN GROUP BY
#--echo 
CREATE TABLE t1 (id int(11));

PREPARE prep_stmt_9846 FROM ' SELECT alias1.id AS field1 FROM t1 AS alias1 LEFT JOIN (   t1 AS alias2   RIGHT  JOIN   (     t1 AS alias3     JOIN t1 AS alias4     ON 1   )   ON 1 ) ON 1 GROUP BY field1';
execute prep_stmt_9846;
execute prep_stmt_9846;
deallocate prepare prep_stmt_9846;
drop table t1;

#--echo #
#--echo # Bug#13040136 - ASSERT IN PLAN_CHANGE_WATCHDOG::~PLAN_CHANGE_WATCHDOG()
#--echo #
CREATE TABLE t1 (   col_varchar_10 VARCHAR(10),   col_int_key INTEGER,   col_varchar_10_key VARCHAR(10),   id INTEGER NOT NULL,   PRIMARY KEY (id),   KEY (col_int_key),   KEY (col_varchar_10_key) );
INSERT INTO t1 VALUES ('q',NULL,'o',1);

CREATE TABLE tsing1 (   id INTEGER NOT NULL AUTO_INCREMENT,   col_varchar_10_key VARCHAR(10),   col_int_key INTEGER,   col_varchar_10 VARCHAR(10),   PRIMARY KEY (id),   KEY (col_varchar_10_key),   KEY col_int_key (col_int_key) );
INSERT INTO tsing1 VALUES (1,'r',NULL,'would'),(2,'tell',-655032320,'t'), (3,'d',9,'a'),(4,'gvafasdkiy',6,'ugvafasdki'), (5,'that\'s',NULL,'she'),(6,'bwftwugvaf',7,'cbwftwugva'), (7,'f',-700055552,'mkacbwftwu'),(8,'a',9,'be'), (9,'d',NULL,'u'),(10,'ckiixcsxmk',NULL,'o');

SELECT DISTINCT tsing1.col_int_key FROM t1 LEFT JOIN tsing1 ON t1.col_varchar_10 = tsing1.col_varchar_10_key WHERE tsing1.id ORDER BY tsing1.col_int_key;

DROP TABLE t1;
DROP TABLE tsing1;

#--echo #
#--echo # Bug#13068506 - QUERY WITH GROUP BY ON NON-AGGR COLUMN RETURNS WRONG RESULT
#--echo #
CREATE TABLE td1 (id1 int);
INSERT INTO td1 VALUES (100), (101);

CREATE TABLE td2 (id2 int, i3 int);
INSERT INTO td2 VALUES (20,1),(10,2);

CREATE TABLE td3 (id3 int(11));
INSERT INTO td3 VALUES (1),(2);

#-- # -- let $query= SELECT (   SELECT MAX( td2.id2 )   FROM td3 RIGHT JOIN td2 ON ( td2.i3 = 2 )   WHERE td2.i3 <> td1.id1 ) AS field1 FROM td1;
SELECT (   SELECT MAX( td2.id2 )   FROM td3 RIGHT JOIN td2 ON ( td2.i3 = 2 )   WHERE td2.i3 <> td1.id1 ) AS field1 FROM td1;

#--echo
#--# -- eval $query;
#--echo
#--# -- eval $query GROUP BY field1;
SELECT (   SELECT MAX( td2.id2 )   FROM td3 RIGHT JOIN td2 ON ( td2.i3 = 2 )   WHERE td2.i3 <> td1.id1 ) AS field1 FROM td1 GROUP BY field1;

#--echo
drop table td1;
drop table td2;
drop table td3;

#--echo # Bug#11766384 - 59487: WRONG RESULT WITH STRAIGHT_JOIN AND RIGHT JOIN

CREATE TABLE t1 (   id int(11) NOT NULL,   col_varchar_10_latin1_key varchar(10) DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO t1 VALUES (1,'1');
CREATE TABLE t2 (   id int(11) NOT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO t2 VALUES (1);
CREATE TABLE t3 (   id int(11) NOT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO t3 VALUES (1);
CREATE TABLE t4 (   id int(11) NOT NULL,   a int(11) DEFAULT NULL,   b int(11) DEFAULT NULL,   col_varchar_10_latin1_key varchar(10) DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO t4 VALUES (1,1,1,'1');
CREATE TABLE tp2 (   a int(11) DEFAULT NULL,   col_varchar_10_utf8_key varchar(10) CHARACTER SET utf8 DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1;
INSERT INTO tp2 VALUES (1,'1');
CREATE TABLE tp3 (   b int(11) DEFAULT NULL,   col_varchar_10_latin1_key varchar(10) DEFAULT NULL,   id int(11) NOT NULL ) ENGINE=InnoDB DEFAULT CHARSET=latin1; INSERT INTO tp3 VALUES (1,'1',1);

# # -- explain of query above (t2 is before tp2 in plan)

# -- # -- let $rest_of_query=t6a.id, t2.id FROM   tp3 AS t6a   LEFT JOIN   (     t2     RIGHT JOIN     (       (         t1         LEFT JOIN         (           t4           JOIN           t3           ON t4.a         )         ON t4.b = t1.id       )       LEFT JOIN       (         tp2         JOIN         tp3 AS t6b         ON tp2.col_varchar_10_utf8_key = t6b.col_varchar_10_latin1_key       )       ON t1.id = tp2.a     )     ON t4.col_varchar_10_latin1_key = t1.col_varchar_10_latin1_key        AND tp2.col_varchar_10_utf8_key = 0   )   ON t6a.id IS TRUE WHERE t6b.b IS TRUE ;
SELECT STRAIGHT_JOIN t6a.id, t2.id FROM   tp3 AS t6a   LEFT JOIN   (     t2     RIGHT JOIN     (       (         t1         LEFT JOIN         (           t4           JOIN           t3           ON t4.a         )         ON t4.b = t1.id       )       LEFT JOIN       (         tp2         JOIN         tp3 AS t6b         ON tp2.col_varchar_10_utf8_key = t6b.col_varchar_10_latin1_key       )       ON t1.id = tp2.a     )     ON t4.col_varchar_10_latin1_key = t1.col_varchar_10_latin1_key        AND tp2.col_varchar_10_utf8_key = 0   )   ON t6a.id IS TRUE WHERE t6b.b IS TRUE ;

# -- # -- eval SELECT STRAIGHT_JOIN $rest_of_query;
# -- # -- eval # -- explain SELECT STRAIGHT_JOIN $rest_of_query;

# right result (same query, just remove STRAIGHT_JOIN):

# -- # -- eval SELECT $rest_of_query;
# -- # -- eval # -- explain SELECT $rest_of_query;
SELECT t6a.id, t2.id FROM   tp3 AS t6a   LEFT JOIN   (     t2     RIGHT JOIN     (       (         t1         LEFT JOIN         (           t4           JOIN           t3           ON t4.a         )         ON t4.b = t1.id       )       LEFT JOIN       (         tp2         JOIN         tp3 AS t6b         ON tp2.col_varchar_10_utf8_key = t6b.col_varchar_10_latin1_key       )       ON t1.id = tp2.a     )     ON t4.col_varchar_10_latin1_key = t1.col_varchar_10_latin1_key        AND tp2.col_varchar_10_utf8_key = 0   )   ON t6a.id IS TRUE WHERE t6b.b IS TRUE ;

drop table t1;
drop table t2;
drop table t3;
drop table t4;
drop table tp2;
drop table tp3;

#--echo #
#--echo # Verify that the "not exists" optimization works.
#--echo #
CREATE TABLE tp2(a INT);
CREATE TABLE at2(a INT NOT NULL);
INSERT INTO tp2 VALUES(1),(2);
INSERT INTO at2 VALUES(1),(2);
# -- # -- let $query=SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a=at2.a WHERE at2.a IS NULL;
# -- # -- eval # -- explain $query;
FLUSH STATUS;
# -- # -- eval $query;
SELECT * FROM tp2 LEFT JOIN at2 ON tp2.a=at2.a WHERE at2.a IS NULL;
# Without the "not exists" optimization, there would be more read_rnd_next
SHOW STATUS LIKE 'HANDLER_READ%';
DROP TABLE tp2;
DROP TABLE at2;

#--echo #
#--echo # Bug#13464334 SAME QUERY PRODUCES DIFFERENT RESULTS WHEN USED WITH AND
#--echo # WITHOUT UNION ALL
#--echo #

CREATE TABLE td1 (id1 INT PRIMARY KEY, a CHAR(1));
CREATE TABLE td2 (id2 INT PRIMARY KEY, b CHAR(1));
INSERT INTO td1 VALUES (1,'a'),(2,'b'),(3,'c');
INSERT INTO td2 VALUES (1,'h'),(2,'i'),(3,'j'),(4,'k');
CREATE VIEW v1 AS SELECT * FROM td1;
CREATE VIEW v2 AS SELECT * FROM td2;
(SELECT p1 FROM v2 LEFT JOIN v1 ON b = a WHERE p2 = 1 GROUP BY p1 ORDER BY p1) UNION (SELECT NULL LIMIT 0);
DROP VIEW v1;
DROP VIEW v2;
DROP TABLE td1;
DROP TABLE td2;

#--echo #
#--echo # Bug#13980954 Missing data on left join + null value + where..in
#--echo #

CREATE TABLE t1 (id INT, vc varchar(1)) ENGINE=Innodb;

# -- $query= SELECT straight_join t1.vc, t1.id FROM t1 JOIN t1 AS t2 ON t1.vc=t2.vc LEFT JOIN t1 AS t3 ON t1.vc=t3.vc;

# -- eval # -- explain format=json $query;
# -- eval $query;

SELECT straight_join t1.vc, t1.id FROM t1 JOIN t1 AS t2 ON t1.vc=t2.vc LEFT JOIN t1 AS t3 ON t1.vc=t3.vc;
DROP TABLE t1;

#--echo #
#--echo # Bug #18345786 CRASH AROUND ST_JOIN_TABLE::AND_WITH_CONDITION
#--echo #

CREATE TABLE t1(id INT) ENGINE=INNODB;
SET @id:=(SELECT ROW(1, 2)=                 ROW((SELECT 1 FROM t1 LEFT JOIN t1 t2 ON 1), 1));
DROP TABLE t1;

#--echo #
#--echo # Coverage for "unique row not found"
#--echo #

create table t1(id int, unique key(id)) engine=InnoDB;
insert into t1 values(1);
# -- let $query= select * from t1 left join t1 as t2               on t2.id=12          where t1.id=1;
# -- eval # -- explain $query;
# -- eval $query;
select * from t1 left join t1 as t2               on t2.id=12          where t1.id=1;
drop table t1;

#--echo #
#--echo # Bug#18717059 MISSING ROWS ON NESTED JOIN WITH SUBQUERY  
#--echo #              WITH MYISAM OR MEMORY    
#--echo #
CREATE TABLE t1 (   id INT,   col_int_key INT,   col_varchar_key VARCHAR(1),   PRIMARY KEY (id),   KEY col_varchar_key (col_varchar_key, col_int_key) ) ENGINE=InnoDB;

INSERT INTO t1 VALUES (23,4,'d');
INSERT INTO t1 VALUES (24,8,'g');
INSERT INTO t1 VALUES (25,NULL,'x');
INSERT INTO t1 VALUES (26,NULL,'f');
INSERT INTO t1 VALUES (27,0,'p');
INSERT INTO t1 VALUES (28,NULL,'j');
INSERT INTO t1 VALUES (29,8,'c');

CREATE TABLE t2 (   id INT,   col_int_key INT,   col_varchar_key VARCHAR(1),   PRIMARY KEY (id) ) ENGINE=InnoDB;

# -- let $query=   SELECT 9   FROM t1 AS table1     RIGHT JOIN t1 AS table2     ON table2.col_int_key = table1.col_int_key       AND table1.col_varchar_key = (         SELECT subquery2_t2.col_varchar_key         FROM t2           STRAIGHT_JOIN ( t2 AS subquery2_t2             JOIN t1 AS subquery2_t3           ) ON ( subquery2_t3.col_int_key = subquery2_t2.id )       );

# -- eval $query;      
# -- eval CREATE TABLE where_subselect_table AS   $query;
CREATE TABLE where_subselect_table AS SELECT 9   FROM t1 AS table1     RIGHT JOIN t1 AS table2     ON table2.col_int_key = table1.col_int_key       AND table1.col_varchar_key = (         SELECT subquery2_t2.col_varchar_key         FROM t2           STRAIGHT_JOIN ( t2 AS subquery2_t2             JOIN t1 AS subquery2_t3           ) ON ( subquery2_t3.col_int_key = subquery2_t2.id )       );

set optimizer_switch='condition_fanout_filter=on';
# -- eval SELECT * FROM where_subselect_table WHERE (9) IN ( $query )  /* TRANSFORM_OUTCOME_UNORDERED_MATCH */;
SELECT * FROM where_subselect_table WHERE (9) IN ( SELECT 9   FROM t1 AS table1     RIGHT JOIN t1 AS table2     ON table2.col_int_key = table1.col_int_key       AND table1.col_varchar_key = (         SELECT subquery2_t2.col_varchar_key         FROM t2           STRAIGHT_JOIN ( t2 AS subquery2_t2             JOIN t1 AS subquery2_t3           ) ON ( subquery2_t3.col_int_key = subquery2_t2.id )       ); )  /* TRANSFORM_OUTCOME_UNORDERED_MATCH */;

set optimizer_switch='condition_fanout_filter=off';    
# -- eval SELECT * FROM where_subselect_table WHERE (9) IN ( $query )  /* TRANSFORM_OUTCOME_UNORDERED_MATCH */;
SELECT * FROM where_subselect_table WHERE (9) IN ( SELECT 9   FROM t1 AS table1     RIGHT JOIN t1 AS table2     ON table2.col_int_key = table1.col_int_key       AND table1.col_varchar_key = (         SELECT subquery2_t2.col_varchar_key         FROM t2           STRAIGHT_JOIN ( t2 AS subquery2_t2             JOIN t1 AS subquery2_t3           ) ON ( subquery2_t3.col_int_key = subquery2_t2.id )       ); )  /* TRANSFORM_OUTCOME_UNORDERED_MATCH */;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE where_subselect_table;

#--echo # Bug#14358878 Wrong results on table left join view

CREATE TABLE t1 (id INTEGER);
CREATE TABLE t2 (id INTEGER);

CREATE VIEW vmerge AS SELECT 1 AS id, id AS b_id FROM t2;
CREATE VIEW vmat AS SELECT 1 AS id, id AS b_id FROM t2;

INSERT INTO t1(id) VALUES (1);

SELECT * FROM t1 LEFT JOIN vmerge AS v ON t1.id = v.id;

SELECT * FROM t1 LEFT JOIN vmat AS v ON t1.id = v.id;

SELECT * FROM t1 LEFT JOIN (SELECT 1 AS one, id FROM t2) AS v ON t1.id = v.id;

SELECT * FROM t1 LEFT JOIN (SELECT DISTINCT 1 AS one, id FROM t2) AS v ON t1.id = v.id;

SELECT * FROM t1 LEFT JOIN vmerge AS v ON t1.id = v.id UNION DISTINCT SELECT * FROM t1 LEFT JOIN vmerge AS v ON t1.id = v.id;

SELECT * FROM t1 LEFT JOIN vmerge AS v ON t1.id = v.id UNION ALL SELECT * FROM t1 LEFT JOIN vmerge AS v ON t1.id = v.id;

DROP VIEW vmerge;
DROP VIEW vmat;
DROP TABLE t1;
DROP TABLE t2;

#--echo # Bug#15936817 Table left join view, unmatched rows problem where
#--echo #              view contains an IF

CREATE TABLE t1 (   id INTEGER not null,   PRIMARY KEY (id) );

CREATE TABLE t2 (   id INTEGER not null,   PRIMARY KEY (id) );

INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1), (2), (3), (4);

CREATE VIEW small_view AS SELECT *, IF (id % 2 = 1, 1, 0) AS is_odd FROM t1;

CREATE VIEW t2_view AS SELECT t2.*, small_view.id AS small_id, small_view.is_odd FROM t2 LEFT JOIN small_view ON small_view.id = t2.id;

SELECT * FROM t2_view;

SELECT t2.*, t1.id AS small_id, t1.is_odd FROM t2 LEFT JOIN      (SELECT id, IF (id % 2 = 1, 1, 0) AS is_odd FROM t1) AS t1      ON t2.id = t1.id;

#--echo # Check the IS NULL and thruth predicates

SELECT t2.*, dt.* FROM t2 LEFT JOIN (SELECT id as dt_id,                            id IS NULL AS nul,                            id IS NOT NULL AS nnul,                            id IS TRUE AS t,                            id IS NOT TRUE AS nt,                            id IS FALSE AS f,                            id IS NOT FALSE AS nf,                            id IS UNKNOWN AS u,                            id IS NOT UNKNOWN AS nu                     FROM t1) AS dt      ON t2.id=dt.dt_id;

#--echo # Check comparison predicates

SELECT t2.*, dt.* FROM t2 LEFT JOIN (SELECT id as dt_id,                            id = 1 AS eq,                            id <> 1 AS ne,                            id > 1 AS gt,                            id >= 1 AS ge,                            id < 1 AS lt,                            id <= 1 AS le,                            id <=> 1 AS equal                     FROM t1) AS dt      ON t2.id=dt.dt_id;

#--echo # Check CASE, NULLIF and COALESCE

SELECT t2.*, dt.* FROM t2 LEFT JOIN (SELECT id as dt_id,                            CASE id WHEN 0 THEN 0 ELSE 1 END AS simple,                            CASE WHEN id=0 THEN NULL ELSE 1 END AS cond,                            NULLIF(1, NULL) AS nullif,                            IFNULL(1, NULL) AS ifnull,                            COALESCE(id) AS coal,                            INTERVAL(NULL, 1, 2, 3) as intv,                            IF (id % 2 = 1, NULL, 1) AS iff                     FROM t1) AS dt      ON t2.id=dt.dt_id;

DROP VIEW small_view;
DROP VIEW t2_view;
DROP TABLE t1;
DROP TABLE t2;

#--echo # Bug#22561937 Wrong result on outer join with multiple join conditions
#--echo #              and derived table

CREATE TABLE t1 (   col_int INT,   id INT NOT NULL,   PRIMARY KEY (id) );

INSERT INTO t1 VALUES  (2,1), (2,2), (6,3), (4,4), (7,5),  (188,6), (0,7), (6,8), (0,9), (9,10);

CREATE TABLE t2 (   id INT NOT NULL,   col_int INT,   PRIMARY KEY (id) );

INSERT INTO t2 VALUES  (1,0), (2,0), (3,2), (4,NULL), (5,2),  (6,3), (7,3), (8,100), (9,3), (10,6);

# -- let $query= SELECT table2.id, table1.col_int FROM t2 AS table1      LEFT JOIN t1 AS table2      ON table2.id < table1.col_int AND         table2.id = table1.col_int;

# -- eval # -- explain $query;
# -- eval $query;
SELECT table2.id, table1.col_int FROM t2 AS table1      LEFT JOIN t1 AS table2      ON table2.id < table1.col_int AND         table2.id = table1.col_int;

# -- let $query= SELECT table2.id, table1.col_int FROM t2 AS table1      LEFT JOIN (SELECT * FROM t1) AS table2      ON table2.id < table1.col_int AND         table2.id = table1.col_int;

# -- eval # -- explain $query;
# -- eval $query;
SELECT table2.id, table1.col_int FROM t2 AS table1      LEFT JOIN (SELECT * FROM t1) AS table2      ON table2.id < table1.col_int AND         table2.id = table1.col_int;

DROP TABLE t1;
DROP TABLE t2;

#--echo # Bug#22671557: Wrong results on JOIN when composite index is present

CREATE TABLE t1 (   col_int INT DEFAULT NULL,   col_int_key INT DEFAULT NULL,   id INT NOT NULL,   PRIMARY KEY (id),   KEY test_idx (col_int_key,col_int) );

INSERT INTO t1 VALUES (0, -7, 1), (9, NULL, 15), (182, NULL, 25);

CREATE TABLE t2 (   col_int INT DEFAULT NULL,   id INT NOT NULL,   PRIMARY KEY (id) );

INSERT INTO t2 VALUES (NULL, 4), (-208, 5), (5, 6), (NULL, 75);

CREATE TABLE t3 (   col_datetime_key DATETIME DEFAULT NULL,   id INT NOT NULL,   PRIMARY KEY (id) );

INSERT INTO t3 VALUES ('1970-01-01 00:00:00', 5);

CREATE TABLE t4 (   col_int INT DEFAULT NULL,   id INT NOT NULL,   col_int_key INT DEFAULT NULL,   PRIMARY KEY (id),   KEY col_int_key (col_int_key) );

INSERT INTO t4 VALUES (0, 15, 6), (9, 16, 6);

SELECT alias2.col_datetime_key FROM     t1 AS alias1       LEFT JOIN t3 AS alias2         LEFT JOIN t2 AS alias3           LEFT JOIN t4 AS alias4           ON alias3.id = alias4.col_int_key         ON alias2.id = alias3.col_int       ON alias1.col_int = alias4.col_int ;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;

#--echo # Bug#22833364: Left join returns incorrect results on the outer side

CREATE TABLE td1 (   id1 varchar(1024) NOT NULL,   a2 int NOT NULL,   KEY user_id(a2) );

INSERT INTO td1 (id1, a2) VALUES ('row1', 4), ('row2', 4);

CREATE TABLE td2 (   id2 int NOT NULL,   b2 varchar(1024) NOT NULL,   b3 int NOT NULL,   PRIMARY KEY (id2) );

INSERT INTO td2 (id2, b2, b3) VALUES  (1, 'text1', 0), (2, 'text2', 0), (3, 'text3', 1), (4, 'text4', 1);

# -- let $query= SELECT td1.id1, td2.id2, td2.b2 FROM td1 LEFT OUTER JOIN td2      ON td1.a2 = td2.id2 AND td2.b3 = 0;

# -- eval # -- explain $query;
# -- eval $query;
SELECT td1.id1, td2.id2, td2.b2 FROM td1 LEFT OUTER JOIN td2      ON td1.a2 = td2.id2 AND td2.b3 = 0;

DROP TABLE td1;
DROP TABLE td2;

#--echo # Bug#23079533: Left join on PK + extra condition doesn't return match

CREATE TABLE ts1 (   sid VARCHAR(32) NOT NULL,   id2 bigint unsigned DEFAULT NULL,   PRIMARY KEY (sid) );

INSERT INTO ts1 (sid, id2) VALUES ('m1', NULL), ('m2', 2), ('m3', NULL), ('m4', NULL);

CREATE TABLE td2 (   id2 bigint unsigned NOT NULL,   sid VARCHAR(32) DEFAULT NULL,   PRIMARY KEY (id2) );

INSERT INTO td2 (id2, sid) VALUES (1, 'm2'), (2, 'm2');

SELECT td2.*,'|' as sep, ts1.* FROM td2 LEFT JOIN ts1      ON ts1.sid = td2.sid AND         ts1.id2 = td2.id2; 
DROP TABLE ts1;
DROP TABLE td2;

# --echo # Bug#23086825: Incorrect query results using left join against derived

CREATE TABLE ts3 (   sid3 varchar(5) NOT NULL );

INSERT INTO ts3(sid3) VALUES ('1'), ('2'), ('3');

CREATE TABLE ts1 (   sid varchar(20) NOT NULL,   sid3 varchar(5) NOT NULL );

INSERT INTO ts1 (sid, sid3) VALUES ('01602', 1), ('01602', 3);

CREATE TABLE ts2 (   sid varchar(20) NOT NULL,   ioattribute varchar(5) NOT NULL,   PRIMARY KEY (sid) );
INSERT INTO ts2 VALUES ('01602', 'BOB'), ('01603', 'SALLY');

SELECT s.sid3, lid.sid1, lid.sid2, lid.ioattribute FROM ts3 s LEFT JOIN      (SELECT lid.sid3,              i.sid as sid1,              lid.sid as sid2,              i.ioattribute       FROM ts1 lid JOIN ts2 i            USING (sid)      ) AS lid     USING (sid3);

DROP TABLE ts3;
DROP TABLE ts1;
DROP TABLE ts2;

#--echo #
#--echo # Bug #26432173: INCORRECT SUBQUERY OPTIMIZATION WITH
#--echo #                LEFT JOIN(SUBQUERY) AND ORDER BY
#--echo #

CREATE TABLE tp2 (a INT);
INSERT tp2 values (1),(2),(15),(24),(5);
CREATE TABLE t2 (id INT, b VARCHAR(10));

#No temp table is used. So correct result.
# -- let query1= SELECT tp2.a, subq.st_value FROM tp2 LEFT JOIN (SELECT t2.id, 'red' AS st_value  FROM t2) AS subq   ON subq.id = tp2.a;

#Problematic query where const column is in the inner table of outer join.
# -- let query2= SELECT tp2.a, subq.st_value FROM tp2 LEFT JOIN (SELECT t2.id, 'red' AS st_value  FROM t2) AS subq   ON subq.id = tp2.a ORDER BY tp2.a;

#fix doesn't apply here since const column is in the outer table of outer join.
# -- let query3= SELECT tp2.a, subq.st_value FROM (SELECT t2.id, 'red' AS st_value  FROM t2) AS subq LEFT JOIN tp2   ON subq.id = tp2.a ORDER BY tp2.a;

# -- eval # -- explain $query1;
# -- eval # -- explain $query2;
# -- eval # -- explain $query3;

# -- eval $query1;
# -- eval $query2;
# -- eval $query3;
SELECT tp2.a, subq.st_value FROM tp2 LEFT JOIN (SELECT t2.id, 'red' AS st_value  FROM t2) AS subq   ON subq.id = tp2.a;
SELECT tp2.a, subq.st_value FROM tp2 LEFT JOIN (SELECT t2.id, 'red' AS st_value  FROM t2) AS subq   ON subq.id = tp2.a ORDER BY tp2.a;
SELECT tp2.a, subq.st_value FROM (SELECT t2.id, 'red' AS st_value  FROM t2) AS subq LEFT JOIN tp2   ON subq.id = tp2.a ORDER BY tp2.a;

DROP TABLE tp2;
DROP TABLE t2;

#--echo # Bug #18898433: EXTREMELY SLOW PERFORMANCE WITH OUTER JOINS AND JOIN
#--echo #                BUFFER.
#--echo #

CREATE TABLE t1 (id INT NOT NULL);
INSERT INTO t1 VALUES (0),(2),(3),(4);
CREATE TABLE t2 (id INT NOT NULL);
INSERT INTO t2 VALUES (0),(1),(3),(4);
CREATE TABLE t3 (id INT NOT NULL);
INSERT INTO t3 VALUES (0),(1),(2),(4);
CREATE TABLE t4 (id INT NOT NULL);
INSERT INTO t4 VALUES (0),(1),(2),(3);
# -- let query1= SELECT * FROM t1 LEFT JOIN      (        (t2 LEFT JOIN t3 ON t3.id= t2.id)        LEFT JOIN t4 ON t3.id= t4.id      )ON t2.id= t1.id;

# -- let query2= SELECT * FROM t1 LEFT JOIN      (        (t2 INNER JOIN t3 ON t3.id= t2.id)        LEFT JOIN t4 ON t3.id= t4.id      )ON t2.id= t1.id;

# -- let query3= SELECT * FROM t1 LEFT JOIN t2 ON t2.id= t1.id         LEFT JOIN t3 ON t3.id= t2.id         LEFT JOIN t4 ON t3.id= t4.id;

# -- eval # -- explain $query1;
# -- eval # -- explain $query2;
# -- eval # -- explain $query3;

flush status;
# -- eval $query1;
SELECT * FROM t1 LEFT JOIN      (        (t2 LEFT JOIN t3 ON t3.id= t2.id)        LEFT JOIN t4 ON t3.id= t4.id      )ON t2.id= t1.id;
SHOW STATUS LIKE 'HANDLER_%';

flush status;
# -- eval $query2;
SELECT * FROM t1 LEFT JOIN      (        (t2 INNER JOIN t3 ON t3.id= t2.id)        LEFT JOIN t4 ON t3.id= t4.id      )ON t2.id= t1.id;
SHOW STATUS LIKE 'HANDLER_%';

flush status;
# -- eval $query3;
SELECT * FROM t1 LEFT JOIN t2 ON t2.id= t1.id         LEFT JOIN t3 ON t3.id= t2.id         LEFT JOIN t4 ON t3.id= t4.id;
SHOW STATUS LIKE 'HANDLER_%';

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;


#--echo #
#--echo # Bug #26627181: WRONG RESULT WITH LEFT JOIN + DERIVED TABLES
#--echo #

CREATE TABLE t1 (id INT);
CREATE TABLE t2 (id INT);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1);

# -- let query1= SELECT * FROM (SELECT id       FROM t1) AS a     LEFT JOIN     (SELECT id, 2 AS tall      FROM t2) AS b     ON a.id = b.id WHERE b.tall IS NOT NULL;

# -- eval # -- explain $query1;
# -- eval $query1;
SELECT * FROM (SELECT id       FROM t1) AS a     LEFT JOIN     (SELECT id, 2 AS tall      FROM t2) AS b     ON a.id = b.id WHERE b.tall IS NOT NULL;

DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug #23169204: Left join + merged derived table + group by = bad result
#--echo #

CREATE TABLE t1(doc text);
CREATE TABLE tp2(a INTEGER DEFAULT NULL);
INSERT INTO tp2 VALUES(1);

# Derived table is materialized due to LIMIT.
# t1 is empty so the derived table is empty, so NULL-complementing produces
# NULL for 'je' in the SELECT list.
SELECT je FROM tp2 LEFT JOIN (SELECT 1 AS je FROM t1 LIMIT 1) AS dt ON FALSE;

SELECT je FROM tp2 LEFT JOIN (SELECT 1 AS je FROM t1 LIMIT 1) AS dt ON FALSE GROUP BY je;

# Remove LIMIT (to have the derived table be merged), produces NULL too.

SELECT je FROM tp2 LEFT JOIN (SELECT 1 AS je FROM t1) AS dt ON FALSE;

SELECT je FROM tp2 LEFT JOIN (SELECT 1 AS je FROM t1) AS dt ON FALSE GROUP BY je;

DROP TABLE t1;
DROP TABLE tp2;