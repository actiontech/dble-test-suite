# The include statement below is a temp one for tests that are yet to
#be ported to run with InnoDB,
#but needs to be kept for tests that would need MyISAM in future.
##--source include/force_myisam_default.inc


# Initialise
##--disable_warnings
drop table if exists t1;
drop table if exists t2;
drop table if exists t3;
##--enable_warnings

SET sql_mode = 'NO_ENGINE_SUBSTITUTION';

#
# Simple test without tables

##-- error 1111
SELECT 1 FROM (SELECT 1) as a  GROUP BY SUM(1);

#
# Test of group (Failed for Lars Hoss <lh@pbm.de>)
#

CREATE TABLE t1 (   id int(10) unsigned,   userID int(10) unsigned,   score smallint(5) unsigned,   lsg char(40),   date date );

INSERT INTO t1 VALUES (1,1,1,'','0000-00-00');
INSERT INTO t1 VALUES (2,2,2,'','0000-00-00');
INSERT INTO t1 VALUES (2,1,1,'','0000-00-00');
INSERT INTO t1 VALUES (3,3,3,'','0000-00-00');

CREATE TABLE ts5 (   userID int(10) unsigned NOT NULL auto_increment,   id char(15),   passwd char(8),   mail char(50),   isAukt enum('N','Y') DEFAULT 'N',   vName char(30),   nName char(40),   adr char(60),   plz char(5),   ort char(35),   land char(20),   PRIMARY KEY (userID) );

INSERT INTO ts5 VALUES (1,'name','pass','mail','Y','v','n','adr','1','1','1');
INSERT INTO ts5 VALUES (2,'name','pass','mail','Y','v','n','adr','1','1','1');
INSERT INTO ts5 VALUES (3,'name','pass','mail','Y','v','n','adr','1','1','1');
INSERT INTO ts5 VALUES (4,'name','pass','mail','Y','v','n','adr','1','1','1');
INSERT INTO ts5 VALUES (5,'name','pass','mail','Y','v','n','adr','1','1','1');

SELECT ts5.userid, MIN(t1.score) FROM t1, ts5 WHERE t1.userID=ts5.userID GROUP BY ts5.userid;
SELECT ts5.userid, MIN(t1.score) FROM t1, ts5 WHERE t1.userID=ts5.userID GROUP BY ts5.userid ORDER BY NULL;
SELECT ts5.userid, MIN(t1.score) FROM t1, ts5 WHERE t1.userID=ts5.userID AND t1.id=2  GROUP BY ts5.userid;
SELECT ts5.userid, MIN(t1.score+0.0) FROM t1, ts5 WHERE t1.userID=ts5.userID AND t1.id=2  GROUP BY ts5.userid;
SELECT ts5.userid, MIN(t1.score+0.0) FROM t1, ts5 WHERE t1.userID=ts5.userID AND t1.id=2  GROUP BY ts5.userid ORDER BY NULL;
#--explain SELECT ts5.userid, MIN(t1.score+0.0) FROM t1, ts5 WHERE t1.userID=ts5.userID AND t1.id=2  GROUP BY ts5.userid ORDER BY NULL;
SELECT ts5.userid, MIN(t1.score+0.0) FROM t1, ts5 WHERE t1.userID=ts5.userID AND t1.id=2  GROUP BY ts5.userid ORDER BY NULL;
drop table t1;
drop table ts5;

#
# Bug in GROUP BY, by Nikki Chumakov <nikki@saddam.cityline.ru>
#

CREATE TABLE t1 (   PID int(10) unsigned NOT NULL auto_increment,   payDate date DEFAULT '0000-00-00' NOT NULL,   recDate datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,   id int(10) unsigned DEFAULT '0' NOT NULL,   CRID int(10) unsigned DEFAULT '0' NOT NULL,   amount int(10) unsigned DEFAULT '0' NOT NULL,   operator int(10) unsigned,   method enum('unknown','cash','dealer','check','card','lazy','delayed','test') DEFAULT 'unknown' NOT NULL,   DIID int(10) unsigned,   reason char(1) binary DEFAULT '' NOT NULL,   code_id int(10) unsigned,   qty mediumint(8) unsigned DEFAULT '0' NOT NULL,   PRIMARY KEY (PID),   KEY id (id),   KEY reason (reason),   KEY method (method),   KEY payDate (payDate) );

INSERT INTO t1 VALUES (1,'1970-01-01','1997-10-17 00:00:00',2529,1,21000,11886,'check',0,'F',16200,6);

##--error 1056
SELECT COUNT(P.id),SUM(P.amount),P.method, MIN(PP.recdate+0) > 19980501000000   AS IsNew FROM t1 AS P JOIN t1 as PP WHERE P.id = PP.id GROUP BY method,IsNew;

drop table t1;

#
# Problem with GROUP BY + ORDER BY when no match
# Tested with locking
#

CREATE TABLE ts1 (   cid mediumint(9) NOT NULL auto_increment,   a varchar(32) DEFAULT '' NOT NULL,   surname varchar(32) DEFAULT '' NOT NULL,   PRIMARY KEY (cid) );
INSERT INTO ts1 VALUES (1,'That','Guy');
INSERT INTO ts1 VALUES (2,'Another','Gent');

CREATE TABLE t2 (   call_id mediumint(8) NOT NULL auto_increment,   id mediumint(8) DEFAULT '0' NOT NULL,   PRIMARY KEY (call_id),   KEY id (id) );

lock tables ts1 read,t2 write;

INSERT INTO t2 VALUES (10,2);
INSERT INTO t2 VALUES (18,2);
INSERT INTO t2 VALUES (62,2);
INSERT INTO t2 VALUES (91,2);
INSERT INTO t2 VALUES (92,2);

SELECT cid, CONCAT(a, ' ', surname), COUNT(call_id) FROM ts1 LEFT JOIN t2 ON cid=id WHERE a like '%foo%' GROUP BY cid;
SELECT cid, CONCAT(a, ' ', surname), COUNT(call_id) FROM ts1 LEFT JOIN t2 ON cid=id WHERE a like '%foo%' GROUP BY cid ORDER BY NULL;
SELECT HIGH_PRIORITY cid, CONCAT(a, ' ', surname), COUNT(call_id) FROM ts1 LEFT JOIN t2 ON cid=id WHERE a like '%foo%' GROUP BY cid ORDER BY surname, a;

drop table t2;
unlock tables;
drop table ts1;

#
# Test of group by bug in bugzilla
#

CREATE TABLE t1 (   bug_id mediumint(9) NOT NULL auto_increment,   groupset bigint(20) DEFAULT '0' NOT NULL,   id mediumint(9) DEFAULT '0' NOT NULL,   bug_file_loc text,   bug_severity enum('blocker','critical','major','normal','minor','trivial','enhancement') DEFAULT 'blocker' NOT NULL,   bug_status enum('','NEW','ASSIGNED','REOPENED','RESOLVED','VERIFIED','CLOSED') DEFAULT 'NEW' NOT NULL,   creation_ts datetime DEFAULT '0000-00-00 00:00:00' NOT NULL,   delta_ts timestamp,   short_desc mediumtext,   long_desc mediumtext,   op_sys enum('All','Windows 3.1','Windows 95','Windows 98','Windows NT','Windows 2000','Linux','other') DEFAULT 'All' NOT NULL,   priority enum('P1','P2','P3','P4','P5') DEFAULT 'P1' NOT NULL,   product varchar(64) DEFAULT '' NOT NULL,   rep_platform enum('All','PC','VTD-8','Other'),   reporter mediumint(9) DEFAULT '0' NOT NULL,   version varchar(16) DEFAULT '' NOT NULL,   component varchar(50) DEFAULT '' NOT NULL,   resolution enum('','FIXED','INVALID','WONTFIX','LATER','REMIND','DUPLICATE','WORKSFORME') DEFAULT '' NOT NULL,   target_milestone varchar(20) DEFAULT '' NOT NULL,   qa_contact mediumint(9) DEFAULT '0' NOT NULL,   status_whiteboard mediumtext NOT NULL,   votes mediumint(9) DEFAULT '0' NOT NULL,   PRIMARY KEY (bug_id),   KEY id (id),   KEY creation_ts (creation_ts),   KEY delta_ts (delta_ts),   KEY bug_severity (bug_severity),   KEY bug_status (bug_status),   KEY op_sys (op_sys),   KEY priority (priority),   KEY product (product),   KEY reporter (reporter),   KEY version (version),   KEY component (component),   KEY resolution (resolution),   KEY target_milestone (target_milestone),   KEY qa_contact (qa_contact),   KEY votes (votes) );

INSERT INTO t1 VALUES (1,0,0,'','normal','','2000-02-10 09:25:12',20000321114747,'','','Linux','P1','TestProduct','PC',3,'other','TestComponent','','M1',0,'',0);
INSERT INTO t1 VALUES (9,0,0,'','enhancement','','2000-03-10 11:49:36',20000321114747,'','','All','P5','AAAAA','PC',3,'2.00 CD - Pre','BBBBBBBBBBBBB - conversion','','',0,'',0);
INSERT INTO t1 VALUES (10,0,0,'','enhancement','','2000-03-10 18:10:16',20000321114747,'','','All','P4','AAAAA','PC',3,'2.00 CD - Pre','BBBBBBBBBBBBB - conversion','','',0,'',0);
INSERT INTO t1 VALUES (7,0,0,'','critical','','2000-03-09 10:50:21',20000321114747,'','','All','P1','AAAAA','PC',3,'2.00 CD - Pre','BBBBBBBBBBBBB - generic','','',0,'',0);
INSERT INTO t1 VALUES (6,0,0,'','normal','','2000-03-09 10:42:44',20000321114747,'','','All','P2','AAAAA','PC',3,'2.00 CD - Pre','kkkkkkkkkkk lllllllllll','','',0,'',0);
INSERT INTO t1 VALUES (8,0,0,'','major','','2000-03-09 11:32:14',20000321114747,'','','All','P3','AAAAA','PC',3,'2.00 CD - Pre','kkkkkkkkkkk lllllllllll','','',0,'',0);
INSERT INTO t1 VALUES (5,0,0,'','enhancement','','2000-03-09 10:38:59',20000321114747,'','','All','P5','CCC/CCCCCC','PC',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (4,0,0,'','normal','','2000-03-08 18:32:14',20000321114747,'','','other','P2','TestProduct','Other',3,'other','TestComponent2','','',0,'',0);
INSERT INTO t1 VALUES (3,0,0,'','normal','','2000-03-08 18:30:52',20000321114747,'','','other','P2','TestProduct','Other',3,'other','TestComponent','','',0,'',0);
INSERT INTO t1 VALUES (2,0,0,'','enhancement','','2000-03-08 18:24:51',20000321114747,'','','All','P2','TestProduct','Other',4,'other','TestComponent2','','',0,'',0);
INSERT INTO t1 VALUES (11,0,0,'','blocker','','2000-03-13 09:43:41',20000321114747,'','','All','P2','CCC/CCCCCC','PC',5,'7.00','DDDDDDDDD','','',0,'',0);
INSERT INTO t1 VALUES (12,0,0,'','normal','','2000-03-13 16:14:31',20000321114747,'','','All','P2','AAAAA','PC',3,'2.00 CD - Pre','kkkkkkkkkkk lllllllllll','','',0,'',0);
INSERT INTO t1 VALUES (13,0,0,'','normal','','2000-03-15 16:20:44',20000321114747,'','','other','P2','TestProduct','Other',3,'other','TestComponent','','',0,'',0);
INSERT INTO t1 VALUES (14,0,0,'','blocker','','2000-03-15 18:13:47',20000321114747,'','','All','P1','AAAAA','PC',3,'2.00 CD - Pre','BBBBBBBBBBBBB - generic','','',0,'',0);
INSERT INTO t1 VALUES (15,0,0,'','minor','','2000-03-16 18:03:28',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','DDDDDDDDD','','',0,'',0);
INSERT INTO t1 VALUES (16,0,0,'','normal','','2000-03-16 18:33:41',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (17,0,0,'','normal','','2000-03-16 18:34:18',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (18,0,0,'','normal','','2000-03-16 18:34:56',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (19,0,0,'','enhancement','','2000-03-16 18:35:34',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (20,0,0,'','enhancement','','2000-03-16 18:36:23',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (21,0,0,'','enhancement','','2000-03-16 18:37:23',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (22,0,0,'','enhancement','','2000-03-16 18:38:16',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','Administration','','',0,'',0);
INSERT INTO t1 VALUES (23,0,0,'','normal','','2000-03-16 18:58:12',20000321114747,'','','All','P2','CCC/CCCCCC','Other',5,'7.00','DDDDDDDDD','','',0,'',0);
INSERT INTO t1 VALUES (24,0,0,'','normal','','2000-03-17 11:08:10',20000321114747,'','','All','P2','AAAAAAAA-AAA','PC',3,'2.8','Web Interface','','',0,'',0);
INSERT INTO t1 VALUES (25,0,0,'','normal','','2000-03-17 11:10:45',20000321114747,'','','All','P2','AAAAAAAA-AAA','PC',3,'2.8','Web Interface','','',0,'',0);
INSERT INTO t1 VALUES (26,0,0,'','normal','','2000-03-17 11:15:47',20000321114747,'','','All','P2','AAAAAAAA-AAA','PC',3,'2.8','Web Interface','','',0,'',0);
INSERT INTO t1 VALUES (27,0,0,'','normal','','2000-03-17 17:45:41',20000321114747,'','','All','P2','CCC/CCCCCC','PC',5,'7.00','DDDDDDDDD','','',0,'',0);
INSERT INTO t1 VALUES (28,0,0,'','normal','','2000-03-20 09:51:45',20000321114747,'','','Windows NT','P2','TestProduct','PC',8,'other','TestComponent','','',0,'',0);
INSERT INTO t1 VALUES (29,0,0,'','normal','','2000-03-20 11:15:09',20000321114747,'','','All','P5','AAAAAAAA-AAA','PC',3,'2.8','Web Interface','','',0,'',0);
CREATE TABLE ts1 (   value tinytext,   a varchar(64),   initialowner tinytext NOT NULL,   initialqacontact tinytext NOT NULL,   description mediumtext NOT NULL );

INSERT INTO ts1 VALUES ('TestComponent','TestProduct','id0001','','');
INSERT INTO ts1 VALUES ('BBBBBBBBBBBBB - conversion','AAAAA','id0001','','');
INSERT INTO ts1 VALUES ('BBBBBBBBBBBBB - generic','AAAAA','id0001','','');
INSERT INTO ts1 VALUES ('TestComponent2','TestProduct','id0001','','');
INSERT INTO ts1 VALUES ('BBBBBBBBBBBBB - eeeeeeeee','AAAAA','id0001','','');
INSERT INTO ts1 VALUES ('kkkkkkkkkkk lllllllllll','AAAAA','id0001','','');
INSERT INTO ts1 VALUES ('Test Procedures','AAAAA','id0001','','');
INSERT INTO ts1 VALUES ('Documentation','AAAAA','id0003','','');
INSERT INTO ts1 VALUES ('DDDDDDDDD','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Eeeeeeee Lite','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Eeeeeeee Full','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Administration','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Distribution','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Setup','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Unspecified','CCC/CCCCCC','id0002','','');
INSERT INTO ts1 VALUES ('Web Interface','AAAAAAAA-AAA','id0001','','');
INSERT INTO ts1 VALUES ('Host communication','AAAAA','id0001','','');
##--source include/turn_off_only_full_group_by.inc

select value,description,bug_id from ts1 left join t1 on ts1.a=t1.product and ts1.value=t1.component where a="AAAAA";
select value,description,COUNT(bug_id) from ts1 left join t1 on ts1.a=t1.product and ts1.value=t1.component where a="AAAAA" group by value;
select value,description,COUNT(bug_id) from ts1 left join t1 on ts1.a=t1.product and ts1.value=t1.component where a="AAAAA" group by value having COUNT(bug_id) IN (0,2);

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
drop table t1;
drop table ts1;

#
# Problem with functions and group functions when no matching rows
#

create table t1 (id int);
insert into t1 values (1);
select 1+1, "a",count(*) from t1 where id in (2);
insert into t1 values (1);
select 1+1,"a",count(*) from t1 where id in (2);
drop table t1;

#
# Test GROUP BY DESC

CREATE TABLE t1 (   id int(10) unsigned,   userID int(10) unsigned,   score smallint(5) unsigned,   key (id),   key (score) );

INSERT INTO t1 VALUES (1,1,1),(2,2,2),(2,1,1),(3,3,3),(4,3,3),(5,3,3),(6,3,3),(7,3,3);
# -- explain select userid,count(*) from t1 group by userid desc;
# -- explain select userid,count(*) from t1 group by userid desc order by null;
select userid,count(*) from t1 group by userid desc;
select userid,count(*) from t1 group by userid desc having (count(*)+1) IN (4,3);
select userid,count(*) from t1 group by userid desc having 3  IN (1,COUNT(*));
# -- explain select id,count(*) from t1 where id between 1 and 2 group by id desc;
# -- explain select id,count(*) from t1 where id between 1 and 2 group by id;
# -- explain select id,count(*) from t1 where id between 1 and 2 group by id order by null;
select id,count(*) from t1 where id between 1 and 2 group by id;
select id,count(*) from t1 where id between 1 and 2 group by id desc;
select id,count(*) from t1 where id between 1 and 2 group by id order by null;
# -- explain extended select sql_big_result id,sum(userid) from t1 group by id desc;
# -- explain select sql_big_result id,sum(userid) from t1 group by id desc order by null;
select sql_big_result id,sum(userid) from t1 group by id desc;
select sql_big_result id,sum(userid) from t1 group by id desc order by null;
# -- explain select sql_big_result score,count(*) from t1 group by score desc;
# -- explain select sql_big_result score,count(*) from t1 group by score desc order by null;
select sql_big_result score,count(*) from t1 group by score desc;
select sql_big_result score,count(*) from t1 group by score desc order by null;
drop table t1;

# not purely group_by bug, but group_by is involved...

create table d1 (id date default null, b date default null);
insert d1 values ('1999-10-01','2000-01-10'), ('1997-01-01','1998-10-01');
select id,min(b) c,count(distinct rand()) from d1 group by id having c<id + interval 1 day;
drop table d1;

# Compare with hash keys

CREATE TABLE ts1 (a char(1));
INSERT INTO ts1 VALUES ('A'),('B'),('A'),('B'),('A'),('B'),(NULL),('a'),('b'),(NULL),('A'),('B'),(NULL);
--source include/turn_off_only_full_group_by.inc

SELECT a FROM ts1 GROUP BY a;
SELECT a,count(*) FROM ts1 GROUP BY a;
SELECT a FROM ts1 GROUP BY binary a;
SELECT a,count(*) FROM ts1 GROUP BY binary a;
SELECT binary a FROM ts1 GROUP BY 1;
SELECT binary a,count(*) FROM ts1 GROUP BY 1;
# Do the same tests with MyISAM temporary tables
SET BIG_TABLES=1;
SELECT a FROM ts1 GROUP BY a;
SELECT a,count(*) FROM ts1 GROUP BY a;
SELECT a FROM ts1 GROUP BY binary a;
SELECT a,count(*) FROM ts1 GROUP BY binary a;
SELECT binary a FROM ts1 GROUP BY 1;
SELECT binary a,count(*) FROM ts1 GROUP BY 1;
SET BIG_TABLES=0;

--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
drop table ts1;

#
# Test of key >= 256 bytes
#

CREATE TABLE ts5 (   `id` char(193) default NULL,   `b` char(63) default NULL );
INSERT INTO ts5 VALUES ('abc','def'),('hij','klm');
SELECT CONCAT(id, b) FROM ts5 GROUP BY 1;
SELECT CONCAT(id, b),count(*) FROM ts5 GROUP BY 1;
SELECT CONCAT(id, b),count(distinct id) FROM ts5 GROUP BY 1;
SELECT 1 FROM ts5 GROUP BY CONCAT(id, b);
INSERT INTO ts5 values ('hij','klm');
SELECT CONCAT(id, b),count(*) FROM ts5 GROUP BY 1;
DROP TABLE ts5;

#
# Test problem with ORDER BY on a SUM() column
#

create table t1 (id int unsigned, Two int unsigned, Three int unsigned, Four int unsigned);
insert into t1 values (1,2,1,4),(1,2,2,4),(1,2,3,4),(1,2,4,4),(1,1,1,4),(1,1,2,4),(1,1,3,4),(1,1,4,4),(1,3,1,4),(1,3,2,4),(1,3,3,4),(1,3,4,4);
select id, Two, sum(Four) from t1 group by id,Two;
drop table t1;

create table ts1 (id integer primary key not null auto_increment, a char(1));
insert into ts1 values (NULL, 'M'), (NULL, 'F'),(NULL, 'F'),(NULL, 'F'),(NULL, 'M');
create table t2 (id integer not null, date date);
insert into t2 values (1, '2002-06-09'),(2, '2002-06-09'),(1, '2002-06-09'),(3, '2002-06-09'),(4, '2002-06-09'),(4, '2002-06-09');
select u.a as a, count(distinct  u.id) as dist_count, (count(distinct u.id)/5*100) as percentage from ts1 u, t2 l where l.id = u.id group by u.a;
select u.a as  a, count(distinct  u.id) as dist_count, (count(distinct u.id)/5*100) as percentage from ts1 u, t2 l where l.id = u.id group by u.a  order by percentage;
drop table ts1;
drop table t2;

#
# The GROUP BY returned rows in wrong order in 3.23.51
#

CREATE TABLE t0 (a int, ID2 int, id int NOT NULL AUTO_INCREMENT,PRIMARY KEY(id ));
insert into t0 values (1,244,NULL),(2,243,NULL),(134,223,NULL),(185,186,NULL);
##--sorted_result
select S.id as xID, S.a as xID1 from t0 as S left join t0 as yS  on S.a between yS.a and yS.ID2;
select S.id as xID, S.a as xID1, repeat('*',count(distinct yS.ID)) as Level from t0 as S left join t0 as yS  on S.a between yS.a and yS.ID2 group by xID order by xID1;
drop table t0;

#
# Problem with MAX and LEFT JOIN
#

CREATE TABLE t1 (   id  int(11) unsigned NOT NULL default '0',   c1id int(11) unsigned default NULL,   c2id int(11) unsigned default NULL,   value int(11) unsigned NOT NULL default '0',   UNIQUE KEY pid2 (id ,c1id,c2id),   UNIQUE KEY pid (id ,value) ) ENGINE=InnoDB;

INSERT INTO t1 VALUES (1, 1, NULL, 1),(1, 2, NULL, 2),(1, NULL, 3, 3),(1, 4, NULL, 4),(1, 5, NULL, 5);

CREATE TABLE t2 (   id int(11) unsigned NOT NULL default '0',   active enum('Yes','No') NOT NULL default 'Yes',   PRIMARY KEY  (id) ) ENGINE=InnoDB;

INSERT INTO t2 VALUES (1, 'Yes'),(2, 'No'),(4, 'Yes'),(5, 'No');

CREATE TABLE t3 (   id int(11) unsigned NOT NULL default '0',   active enum('Yes','No') NOT NULL default 'Yes',   PRIMARY KEY  (id) );
INSERT INTO t3 VALUES (3, 'Yes');

select * from t1 AS m LEFT JOIN t2 AS c1 ON m.c1id = c1.id AND c1.active = 'Yes' LEFT JOIN t3 AS c2 ON m.c2id = c2.id AND c2.active = 'Yes' WHERE m.id =1  AND (c1.id IS NOT NULL OR c2.id IS NOT NULL);
select max(value) from t1 AS m LEFT JOIN t2 AS c1 ON m.c1id = c1.id AND c1.active = 'Yes' LEFT JOIN t3 AS c2 ON m.c2id = c2.id AND c2.active = 'Yes' WHERE m.id =1  AND (c1.id IS NOT NULL OR c2.id IS NOT NULL);
drop table t1;
drop table t2;
drop table t3;
#
# Test bug in GROUP BY on BLOB that is NULL or empty
#

create table ts1 (a blob null);
insert into ts1 values (NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(NULL),(""),(""),(""),("b");
select a,count(*) from ts1 group by a;
set big_tables=1;
select a,count(*) from ts1 group by a;
drop table ts1;

#
# Test of GROUP BY ... ORDER BY NULL optimization
#

create table t1 (id int not null, b int not null);
insert into t1 values (1,1),(1,2),(3,1),(3,2),(2,2),(2,1);
create table t2 (id int not null, b int not null, key(id));
insert into t2 values (1,3),(3,1),(2,2),(1,1);
select t1.id,t2.b from t1,t2 where t1.id=t2.id group by t1.id,t2.b;
select t1.id,t2.b from t1,t2 where t1.id=t2.id group by t1.id,t2.b ORDER BY NULL;
# -- explain select t1.id,t2.b from t1,t2 where t1.id=t2.id group by t1.id,t2.b;
select t1.id,t2.b from t1,t2 where t1.id=t2.id group by t1.id,t2.b;
# -- explain select t1.id,t2.b from t1,t2 where t1.id=t2.id group by t1.id,t2.b ORDER BY NULL;
select t1.id,t2.b from t1,t2 where t1.id=t2.id group by t1.id,t2.b ORDER BY NULL;
drop table t1;
drop table t2;

#
# group function arguments in some functions
#

create table t1 (id int, b int);
insert into t1 values (1, 4),(10, 40),(1, 4),(10, 43),(1, 4),(10, 41),(1, 4),(10, 43),(1, 4);
select id, MAX(b), INTERVAL (MAX(b), 1,3,10,30,39,40,50,60,100,1000) from t1 group by id;
select id, MAX(b), CASE MAX(b) when 4 then 4 when 43 then 43 else 0 end from t1 group by id;
select id, MAX(b), FIELD(MAX(b), '43', '4', '5') from t1 group by id;
select id, MAX(b), CONCAT_WS(MAX(b), '43', '4', '5') from t1 group by id;
select id, MAX(b), ELT(MAX(b), 'id', 'b', 'c', 'd', 'e', 'f') from t1 group by id;
select id, MAX(b), MAKE_SET(MAX(b), 'id', 'b', 'c', 'd', 'e', 'f', 'g', 'h') from t1 group by id;
drop table t1;

#
# Problem with group by and alias
#

create table t1 (id int not null, qty int not null);
insert into t1 values (1,2),(1,3),(2,4),(2,5);
select id, sum(qty) as sqty, count(qty) as cqty from t1 group by id having sum(qty)>2 and cqty>1;
select id, sum(qty) as sqty from t1 group by id having sqty>2 and count(qty)>1;
select id, sum(qty) as sqty, count(qty) as cqty from t1 group by id having sqty>2 and cqty>1;
select id, sum(qty) as sqty, count(qty) as cqty from t1 group by id having sum(qty)>2 and count(qty)>1;
select count(*), case interval(qty,2,3,4,5,6,7,8) when -1 then NULL when 0 then "zero" when 1 then "one" when 2 then "two" end as category from t1 group by category;
select count(*), interval(qty,2,3,4,5,6,7,8) as category from t1 group by category;
drop table t1;
#
# Tests for bug #1355: 'Using filesort' is missing in # -- explain when ORDER BY
# NULL is used.
#
CREATE TABLE t1 (   id int(10) unsigned,   score smallint(5) unsigned,   key (score) );
INSERT INTO t1 VALUES (1,1),(2,2),(1,1),(3,3),(3,3),(3,3),(3,3),(3,3);
# Here we select unordered GROUP BY into a temporary talbe, 
# and then sort it with filesort (GROUP BY in MySQL 
# implies sorted order of results)
SELECT id,count(*) FROM t1 GROUP BY id DESC;
# -- explain SELECT id,count(*) FROM t1 GROUP BY id DESC;
DROP TABLE t1;
CREATE TABLE t1 (   id int(11) default NULL,   j int(11) default NULL );
INSERT INTO t1 VALUES (1,2),(2,3),(4,5),(3,5),(1,5),(23,5);
##--source include/turn_off_only_full_group_by.inc
SELECT id, COUNT(DISTINCT(id)) FROM t1 GROUP BY j ORDER BY NULL;
# -- explain SELECT id, COUNT(DISTINCT(id)) FROM t1 GROUP BY j ORDER BY NULL;
##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
SELECT id, COUNT(DISTINCT(id)) FROM t1 GROUP BY j ORDER BY NULL;
DROP TABLE t1;

#Test for BUG#6976: Aggregate functions have incorrect NULL-ness
create table t1 (id int);
insert into t1 values(null);
select min(id) is null from t1;
select min(id) is null or null from t1;
select 1 and min(id) is null from t1;
drop table t1;

# Test for BUG#5400: GROUP_CONCAT returns everything twice.
create table t1 ( id int, col2 int );
insert into t1 values (1,1),(1,2),(1,3),(2,1),(2,2);
select group_concat( distinct id ) as alias from t1   group by col2 having alias like '%';

drop table t1;

#
# Test BUG#8216 when referring in HAVING to n alias which is rand() function
#

create table t1 (id integer, b integer, c integer);
insert into t1 (id,b) values (1,2),(1,3),(2,5);

select id, 0.1*0+1 r2, sum(1) r1 from t1 where id = 1 group  by id having r1>1 and r2=1;
# rand(100)*10 will be < 2 only for the first row (of 6)
select id, round(rand(100)*10) r2, sum(1) r1 from t1 where id = 1 group  by id having r1>1 and r2<=2;
select id,sum(b) from t1 where id=1 group by c;
select id*sum(b) from t1 where id=1 group by c;
select sum(id)*sum(b) from t1 where id=1 group by c;
select id,sum(b) from t1 where id=1 group by c having id=1;
select id as d,sum(b) from t1 where id=1 group by c having d=1;
select sum(id)*sum(b) as d from t1 where id=1 group by c having d > 0;

drop table t1;

# Test for BUG#9213 GROUP BY query on utf-8 key returns wrong results
create table t1(id int);
insert into t1 values (0),(1),(2),(3),(4),(5),(6),(8),(9);
create table t2 (   id int,   b varchar(200) NOT NULL,   c varchar(50) NOT NULL,   d varchar(100) NOT NULL,   primary key (id,b(132),c,d),   key id (id,b) ) charset=utf8;

insert into t2 select    x3.id,  concat('val-', x3.id + 3*x4.id), concat('val-', @a:=x3.id + 3*x4.id + 12*C.id),  concat('val-', @a + 120*D.id) from t1 x3, t1 x4, t1 C, t1 D where x3.id < 3 and x4.id < 4 and D.id < 4;

delete from t2  where id = 2 and b = 'val-2' order by id,b,c,d limit 30;

# -- explain select c from t2 where id = 2 and b = 'val-2' group by c;
select c from t2 where id = 2 and b = 'val-2' group by c;
drop table t1;
drop table t2;

# Test for BUG#9298 "Wrong handling of int4 unsigned columns in GROUP functions"
# (the actual problem was with protocol code, not GROUP BY)
create table t1 (id int4 unsigned not null);
insert into t1 values(3000000000);
select * from t1;
select min(id) from t1;
drop table t1;

#
# Test for bug #11088: GROUP BY a BLOB column with COUNT(DISTINCT column1) 
#

CREATE TABLE t1 (id int PRIMARY KEY, user_id int, hostname longtext);
INSERT INTO t1 VALUES   (1, 7, 'cache-dtc-af05.proxy.aol.com'),   (2, 3, 'what.ever.com'),   (3, 7, 'cache-dtc-af05.proxy.aol.com'),   (4, 7, 'cache-dtc-af05.proxy.aol.com');

SELECT hostname, COUNT(DISTINCT user_id) as no FROM t1   WHERE hostname LIKE '%aol%'     GROUP BY hostname;

DROP TABLE t1;

#
# Test for bug #8614: GROUP BY 'const' with DISTINCT  
#

CREATE TABLE t1 (id  int, b int);
INSERT INTO t1 VALUES (1,2), (1,3);
##--source include/turn_off_only_full_group_by.inc

SELECT id, b FROM t1 GROUP BY 'const';
SELECT DISTINCT id, b FROM t1 GROUP BY 'const';

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
DROP TABLE t1;

#
# Test for bug #11385: GROUP BY for datetime converted to decimals  
#

CREATE TABLE t1 (id INT, dt DATETIME);
INSERT INTO t1 VALUES ( 1, '2005-05-01 12:30:00' );
INSERT INTO t1 VALUES ( 1, '2005-05-01 12:30:00' );
INSERT INTO t1 VALUES ( 1, '2005-05-01 12:30:00' );
INSERT INTO t1 VALUES ( 1, '2005-05-01 12:30:00' );
##--source include/turn_off_only_full_group_by.inc

SELECT dt DIV 1 AS f, id FROM t1 GROUP BY f;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc
DROP TABLE t1;

#
# Test for bug #11295: GROUP BY a BLOB column with COUNT(DISTINCT column1) 
#                      when the BLOB column takes NULL values
# 

CREATE TABLE ts5 (id varchar(20) NOT NULL);
INSERT INTO ts5 VALUES ('trans1'), ('trans2');
CREATE TABLE ts6 (id varchar(20) NOT NULL, err_comment blob NOT NULL);
INSERT INTO ts6 VALUES ('trans1', 'a problem');
SELECT COUNT(DISTINCT(ts5.id)), LEFT(err_comment, 256) AS comment   FROM ts5 LEFT JOIN ts6 ON ts5.id=ts6.id GROUP BY comment;

DROP TABLE ts5;
DROP TABLE ts6;

#
# Bug #12266 GROUP BY expression on DATE column produces result with
#            reduced length
#
create table d1 (id date);
insert into d1 values('1997-02-06');
insert into d1 values('1997-02-06');
select date(left(id+0,8)) from d1 group by 1;
drop table d1;

#
# Test for bug #11414: crash on Windows for a simple GROUP BY query 
#  
                    
CREATE TABLE t1 (id int);
INSERT INTO t1 VALUES (1);
SELECT id+1 AS id FROM t1 GROUP BY id;
DROP TABLE t1;

#
# BUG#12695: Item_func_isnull::update_used_tables
# did not update const_item_cache
#
create table ts5(id varchar(5) key);
insert into ts5 values (1),(2);
select sql_buffer_result max(id) is null from ts5;
select sql_buffer_result max(id)+1 from ts5;
drop table ts5;

#
# BUG#14019-4.1-opt
#
CREATE TABLE t1(id INT);
INSERT INTO t1 VALUES (1),(2);

##--source include/turn_off_only_full_group_by.inc
SELECT id FROM t1 GROUP BY 'id';
SELECT id FROM t1 GROUP BY "id";
##--source include/restore_sql_mode_idfter_turn_off_only_full_group_by.inc

SELECT id FROM t1 GROUP BY `id`;

set sql_mode=ANSI_QUOTES;
SELECT id FROM t1 GROUP BY "id";
SELECT id FROM t1 GROUP BY 'id';
SELECT id FROM t1 GROUP BY `id`;
set sql_mode=DEFAULT;

SELECT id FROM t1 HAVING 'id' > 1;
SELECT id FROM t1 HAVING "id" > 1;
SELECT id FROM t1 HAVING `id` > 1;

SELECT id FROM t1 ORDER BY 'id' DESC;
SELECT id FROM t1 ORDER BY "id" DESC;
SELECT id FROM t1 ORDER BY `id` DESC;
DROP TABLE t1;

#
# Bug #29717 INSERT INTO SELECT inserts values even if SELECT statement itself
# returns empty
# 
CREATE TABLE ts5 (     f1 int(10) unsigned NOT NULL auto_increment primary key,     id varchar(100) NOT NULL default '' );
CREATE TABLE ts6 (     f1 varchar(10) NOT NULL default '',     id char(3) NOT NULL default '',     PRIMARY KEY  (`f1`),     KEY `k1` (`id`,`f1`) );

INSERT INTO ts5 values(NULL, '');
INSERT INTO `ts6` VALUES ('486878','WDT'),('486910','WDT');
SELECT SQL_BUFFER_RESULT avg(ts6.f1) FROM ts5, ts6 where ts6.id = 'SIR' GROUP BY ts5.f1;
SELECT avg(ts6.f1) FROM ts5, ts6 where ts6.id = 'SIR' GROUP BY ts5.f1;
DROP TABLE ts5;
DROP TABLE ts6;


# End of 4.1 tests

#
# Bug#11211: Ambiguous column reference in GROUP BY.
#

create table ts2 (c1 char(3), c2 char(3));
create table ts3 (c3 char(3), c4 char(3));
insert into ts2 values ('aaa', 'bb1'), ('aaa', 'bb2');
insert into ts3 values ('aaa', 'bb1'), ('aaa', 'bb2');

##--source include/turn_off_only_full_group_by.inc

# query with ambiguous column reference 'c2'
select ts2.c1 as c2 from ts2, ts3 where ts2.c2 = ts3.c4 group by c2;
show warnings;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

# this query has no ambiguity
select ts2.c1 as c2 from ts2, ts3 where ts2.c2 = ts3.c4 group by ts2.c1;

show warnings;
drop table ts2;
drop table ts3;

#
# Bug #20466: a view is mixing data when there's a trigger on the table
#
CREATE TABLE t1 (id tinyint(3), b varchar(255), PRIMARY KEY  (id));

INSERT INTO t1 VALUES (1,'##---'), (6,'Allemagne'), (17,'Autriche'),     (25,'Belgique'), (54,'Danemark'), (62,'Espagne'), (68,'France');

CREATE TABLE t2 (id tinyint(3), b tinyint(3), PRIMARY KEY  (id), KEY b (b));

INSERT INTO t2 VALUES (1,1), (2,1), (6,6), (18,17), (15,25), (16,25),  (17,25), (10,54), (5,62),(3,68);

CREATE VIEW v1 AS select t1.id, concat(t1.b,'') AS b, t1.b as real_b from t1;

#-- explain SELECT straight_join sql_no_cache v1.id, v1.b, v1.real_b from t2, v1 where t2.b=v1.id GROUP BY t2.b;
SELECT straight_join sql_no_cache v1.id, v1.b, v1.real_b from t2, v1 where t2.b=v1.id GROUP BY t2.b;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE t2;

#
# Bug#22781: SQL_BIG_RESULT fails to influence sort plan
#
CREATE TABLE t1 (id INT PRIMARY KEY, b INT, key (b));

INSERT INTO t1 VALUES (1,      1);
INSERT INTO t1 SELECT  id + 1 , MOD(id + 1 , 20) FROM t1;
INSERT INTO t1 SELECT  id + 2 , MOD(id + 2 , 20) FROM t1;
INSERT INTO t1 SELECT  id + 4 , MOD(id + 4 , 20) FROM t1;
INSERT INTO t1 SELECT  id + 8 , MOD(id + 8 , 20) FROM t1;
INSERT INTO t1 SELECT  id + 16, MOD(id + 16, 20) FROM t1;
INSERT INTO t1 SELECT  id + 32, MOD(id + 32, 20) FROM t1;
INSERT INTO t1 SELECT  id + 64, MOD(id + 64, 20) FROM t1;

SELECT MIN(b), MAX(b) from t1;

# -- explain SELECT b, sum(1) FROM t1 GROUP BY b;
# -- explain SELECT SQL_BIG_RESULT b, sum(1) FROM t1 GROUP BY b;
SELECT b, sum(1) FROM t1 GROUP BY b;
SELECT SQL_BIG_RESULT b, sum(1) FROM t1 GROUP BY b;
DROP TABLE t1;

#
# Bug #23417: Too strict checks against GROUP BY in the ONLY_FULL_GROUP_BY mode
#
CREATE TABLE t1 (id INT, b INT);
INSERT INTO t1 VALUES (1,1),(2,1),(3,2),(4,2),(5,3),(6,3);

SET SQL_MODE = 'ONLY_FULL_GROUP_BY';
SELECT MAX(id)-MIN(id) FROM t1 GROUP BY b;
SELECT CEILING(MIN(id)) FROM t1 GROUP BY b;
SELECT CASE WHEN AVG(id)>=0 THEN 'Positive' ELSE 'Negative' END FROM t1  GROUP BY b;
SELECT id + 1 FROM t1 GROUP BY id;
##--error ER_WRONG_FIELD_WITH_GROUP 
SELECT id + b FROM t1 GROUP BY b;
SELECT (SELECT t1_outer.id FROM t1 AS t1_inner GROUP BY b LIMIT 1)   FROM t1 AS t1_outer;
SELECT 1 FROM t1 as t1_outer GROUP BY id   HAVING (SELECT t1_outer.id FROM t1 AS t1_inner GROUP BY b LIMIT 1);
##--error ER_WRONG_FIELD_WITH_GROUP 
SELECT (SELECT t1_outer.id FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
##--error ER_BAD_FIELD_ERROR 
SELECT 1 FROM t1 as t1_outer GROUP BY id  HAVING (SELECT t1_outer.b FROM t1 AS t1_inner LIMIT 1);
SELECT (SELECT SUM(t1_inner.id) FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
SELECT (SELECT SUM(t1_inner.id) FROM t1 AS t1_inner GROUP BY t1_inner.b LIMIT 1)   FROM t1 AS t1_outer;
# This statement is valid, as aggregation happens in outer query.
# -- let $query= SELECT (SELECT SUM(t1_outer.id) FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
# -- eval $query;
SELECT (SELECT SUM(t1_outer.id) FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
SET SQL_MODE = '';
# -- eval $query;
SELECT (SELECT SUM(t1_outer.id) FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
SET SQL_MODE = 'ONLY_FULL_GROUP_BY';
# -- let $query= SELECT (SELECT SUM(t1_outer.id+0*t1_inner.id) FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
# Here we add id column of t1_inner in the MAX() so aggregation happens
# in inner Q, which cannot know what value of t1_outer.id to pick, this
# is invalid. And the result changes (multiples of 6).
##--error ER_WRONG_FIELD_WITH_GROUP 
# -- eval $query;
SELECT (SELECT SUM(t1_outer.id+0*t1_inner.id) FROM t1 AS t1_inner LIMIT 1)   FROM t1 AS t1_outer GROUP BY t1_outer.b;
SET SQL_MODE = '';
# -- eval $query;
SET SQL_MODE = 'ONLY_FULL_GROUP_BY';

SELECT 1 FROM t1 as t1_outer   WHERE (SELECT t1_outer.b FROM t1 AS t1_inner GROUP BY t1_inner.b LIMIT 1);

SELECT b FROM t1 GROUP BY b HAVING CEILING(b) > 0;

SELECT 1 FROM t1 GROUP BY b HAVING b = 2 OR b = 3 OR SUM(id) > 12;
SELECT 1 FROM t1 GROUP BY b HAVING ROW (b,b) = ROW (1,1);

##--error ER_BAD_FIELD_ERROR
SELECT 1 FROM t1 GROUP BY b HAVING id = 2;
##--error ER_INVALID_GROUP_FUNC_USE
SELECT 1 FROM t1 GROUP BY SUM(b);
# I de# -- leted pk from table, as it was making query below become valid.
##--error ER_WRONG_FIELD_WITH_GROUP 
SELECT b FROM t1 AS t1_outer GROUP BY id HAVING t1_outer.id IN   (SELECT SUM(t1_inner.b)+t1_outer.b FROM t1 AS t1_inner GROUP BY t1_inner.id    HAVING SUM(t1_inner.b)+t1_outer.b > 5);
DROP TABLE t1;
SET SQL_MODE = '';
#
# Bug#27874: Non-grouped columns are allowed by * in ONLY_FULL_GROUP_BY mode.
#
SET SQL_MODE = 'ONLY_FULL_GROUP_BY';
create table t1(id int, f2 int);
##--error 1055
select * from t1 group by id;
##--error 1055
select * from t1 group by f2;
select * from t1 group by id, f2;
##--error 1055
select t1.id,t.* from t1, t1 t group by 1;
drop table t1;
SET SQL_MODE = DEFAULT;

#
# Bug #32202: ORDER BY not working with GROUP BY
#

CREATE TABLE t0(   id INT AUTO_INCREMENT PRIMARY KEY,   a INT NOT NULL,   c2 INT NOT NULL,   UNIQUE KEY (c2,a));

INSERT INTO t0(a,c2) VALUES (5,1), (4,1), (3,5), (2,3), (1,3);

# Show that the test cases from the bug report pass
SELECT * FROM t0 ORDER BY a;
SELECT * FROM t0 GROUP BY id ORDER BY a;

# Show that DESC is handled correctly
SELECT * FROM t0 GROUP BY id ORDER BY id DESC;

# Show that results are correctly ordered when ORDER BY fields
# are a subset of GROUP BY ones
SELECT * FROM t0 GROUP BY c2 ,a, id ORDER BY c2, a;
SELECT * FROM t0 GROUP BY c2, a, id ORDER BY c2 DESC, a;
SELECT * FROM t0 GROUP BY c2, a, id ORDER BY c2 DESC, a DESC;

##--source include/turn_off_only_full_group_by.inc

# Show that results are correctly ordered when GROUP BY fields
# are a subset of ORDER BY ones
SELECT * FROM t0 GROUP BY c2  ORDER BY c2, a;
SELECT * FROM t0 GROUP BY c2  ORDER BY c2 DESC, a;
SELECT * FROM t0 GROUP BY c2  ORDER BY c2 DESC, a DESC;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

DROP TABLE t0;


# --echo #
# --echo # Bug#27219: Aggregate functions in ORDER BY.  
# --echo #
SET @save_sql_mode=@@sql_mode;
SET @@sql_mode='ONLY_FULL_GROUP_BY';

CREATE TABLE t0 (a INT, b INT, c INT DEFAULT 0);
INSERT INTO t0 (a, b) VALUES (3,3), (2,2), (3,3), (2,2), (3,3), (4,4);
# -- CREATE TABLE t2 SELECT * FROM t0;
CREATE TABLE t8(a INT, b INT, c INT DEFAULT 0);
INSERT INTO t8 (a, b) VALUES (3,3), (2,2), (3,3), (2,2), (3,3), (4,4);

SELECT COUNT(*) FROM t0 ORDER BY COUNT(*);
SELECT COUNT(*) FROM t0 ORDER BY COUNT(*) + 1;
# This is a bad ORDER BY, but as the result is guaranteed to have only
# one row, there is no actual issue - ordering doesn't matter.
SELECT COUNT(*) FROM t0 ORDER BY COUNT(*) + a;
SELECT COUNT(*) FROM t0 ORDER BY COUNT(*), 1;
SELECT COUNT(*) FROM t0 ORDER BY COUNT(*), a;
SELECT COUNT(*) FROM t0 ORDER BY SUM(a);
SELECT COUNT(*) FROM t0 ORDER BY SUM(a + 1);
SELECT COUNT(*) FROM t0 ORDER BY SUM(a) + 1;
SELECT COUNT(*) FROM t0 ORDER BY SUM(a), b;

SELECT SUM(a) FROM t0 ORDER BY COUNT(b);

SELECT t0.a FROM t0 ORDER BY (SELECT SUM(t8.a) FROM t8);

##--error ER_OPERAND_COLUMNS
SELECT t0.a FROM t0 ORDER BY (SELECT SUM(t8.a), t8.a FROM t8);
SELECT t0.a FROM t0 ORDER BY (SELECT SUM(t8.a) FROM t8 ORDER BY t8.a);
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT t0.a FROM t0 ORDER BY (SELECT t8.a FROM t8 ORDER BY SUM(t8.b) LIMIT 1);

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT t0.a FROM t0   WHERE t0.a = (SELECT t8.a FROM t8 ORDER BY SUM(t8.b) LIMIT 1);
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT t0.a FROM t0 GROUP BY t0.a   HAVING t0.a = (SELECT t8.a FROM t8 ORDER BY SUM(t8.a) LIMIT 1);
SELECT t0.a FROM t0 GROUP BY t0.a   HAVING t0.a IN (SELECT t8.a FROM t8 ORDER BY SUM(t0.b));
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT t0.a FROM t0 GROUP BY t0.a   HAVING t0.a IN (SELECT t8.a FROM t8 ORDER BY t8.a, SUM(t8.b));
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT t0.a FROM t0 GROUP BY t0.a   HAVING t0.a > ANY (SELECT t8.a FROM t8 ORDER BY t8.a, SUM(t8.b));

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT t0.a FROM t0   WHERE t0.a = (SELECT t8.a FROM t8 ORDER BY SUM(t0.b));

SELECT 1 FROM t0 GROUP BY t0.a   HAVING (SELECT AVG(SUM(t0.b) + 1) FROM t8 ORDER BY SUM(t8.a) LIMIT 1);
SELECT 1 FROM t0 GROUP BY t0.a   HAVING (SELECT AVG(SUM(t0.b) + t8.b) FROM t8 ORDER BY SUM(t8.a) LIMIT 1);
##--error ER_WRONG_FIELD_WITH_GROUP
SELECT 1 FROM t0 GROUP BY t0.a   HAVING (SELECT AVG(t0.b + t8.b) FROM t8 ORDER BY SUM(t8.a) LIMIT 1);

SELECT 1 FROM t0 GROUP BY t0.a   HAVING (SELECT AVG(SUM(t0.b) + 1) FROM t8 ORDER BY t8.a LIMIT 1);
SELECT 1 FROM t0 GROUP BY t0.a   HAVING (SELECT AVG(SUM(t0.b) + t8.b) FROM t8 ORDER BY t8.a LIMIT 1);
##--error ER_WRONG_FIELD_WITH_GROUP
SELECT 1 FROM t0 GROUP BY t0.a   HAVING (SELECT AVG(t0.b + t8.b) FROM t8 ORDER BY t8.a LIMIT 1);

# Both SUMs are aggregated in the subquery, no mixture:
SELECT t0.a FROM t0   WHERE t0.a = (SELECT t8.a FROM t8 GROUP BY t8.a                   ORDER BY SUM(t8.b), SUM(t0.b) LIMIT 1);

# SUM(t0.b) is aggregated in the subquery, no mixture:
SELECT t0.a, SUM(t0.b) FROM t0   WHERE t0.a = (SELECT SUM(t8.b) FROM t8 GROUP BY t8.a                   ORDER BY SUM(t8.b), SUM(t0.b) LIMIT 1)   GROUP BY t0.a;

# 2nd SUM(t0.b) is aggregated in the subquery, no mixture:
SELECT t0.a, SUM(t0.b) FROM t0   WHERE t0.a = (SELECT SUM(t8.b) FROM t8                   ORDER BY SUM(t8.b) + SUM(t0.b) LIMIT 1)   GROUP BY t0.a;

# SUM(t8.b + t0.a) is aggregated in the subquery, no mixture:
SELECT t0.a, SUM(t0.b) FROM t0   WHERE t0.a = (SELECT SUM(t8.b) FROM t8                   ORDER BY SUM(t8.b + t0.a) LIMIT 1)   GROUP BY t0.a;

SELECT t0.a FROM t0 GROUP BY t0.a     HAVING (1, 1) = (SELECT SUM(t0.a), t0.a FROM t8 LIMIT 1);

select avg (   (select     (select sum(outr.a + innr.a) from t0 as innr limit 1) as tt    from t0 as outr order by outr.a limit 1)) from t0 as most_outer;

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
select avg (   (select (     (select sum(outr.a + innr.a) from t0 as innr limit 1)) as tt    from t0 as outr order by count(outr.a) limit 1)) as tt from t0 as most_outer;

select (select sum(outr.a + t0.a) from t0 limit 1) as tt from t0 as outr order by outr.a;

SET sql_mode=@save_sql_mode;
DROP TABLE t0;
DROP TABLE t8;

# --echo # 
# --echo # BUG#38072: Wrong result: HAVING not observed in a query with aggregate
# --echo # 
CREATE TABLE t1 (   id int(11) NOT NULL AUTO_INCREMENT,   int_nokey int(11) NOT NULL,   int_key int(11) NOT NULL,   varchar_key varchar(1) NOT NULL,   varchar_nokey varchar(1) NOT NULL,   PRIMARY KEY (id),   KEY int_key (int_key),   KEY varchar_key (varchar_key) );
INSERT INTO t1 VALUES (1,5,5, 'h','h'), (2,1,1, '{','{'), (3,1,1, 'z','z'), (4,8,8, 'x','x'), (5,7,7, 'o','o'), (6,3,3, 'p','p'), (7,9,9, 'c','c'), (8,0,0, 'k','k'), (9,6,6, 't','t'), (10,0,0,'c','c');

# -- explain SELECT COUNT(varchar_key) AS x FROM t1 WHERE id = 8 having 'foo'='bar';
SELECT COUNT(varchar_key) AS x FROM t1 WHERE id = 8 having 'foo'='bar';
drop table t1;
  
# --echo End of 5.0 tests
# Bug #21174: Index degrades sort performance and 
#             optimizer does not honor IGNORE INDEX.
#             a.k.a WL3527.
#
CREATE TABLE t8 (a INT, b INT,                  PRIMARY KEY (a),                  KEY i2(a,b));
INSERT INTO t8 VALUES (1,1),(2,2),(3,3),(4,4),(5,5),(6,6),(7,7),(8,8);
INSERT INTO t8 SELECT a + 8,b FROM t8;
INSERT INTO t8 SELECT a + 16,b FROM t8;
INSERT INTO t8 SELECT a + 32,b FROM t8;
INSERT INTO t8 SELECT a + 64,b FROM t8;
INSERT INTO t8 SELECT a + 128,b FROM t8 limit 16;
ANALYZE TABLE t8;
# -- explain SELECT a FROM t8 WHERE a < 2;
SELECT a FROM t8 WHERE a < 2;
# -- explain SELECT a FROM t8 WHERE a < 2 ORDER BY a;
SELECT a FROM t8 WHERE a < 2 ORDER BY a;
# -- explain SELECT a FROM t8 WHERE a < 2 GROUP BY a;
SELECT a FROM t8 WHERE a < 2 GROUP BY a;
# -- explain SELECT a FROM t8 IGNORE INDEX (PRIMARY,i2);
SELECT a FROM t8 IGNORE INDEX (PRIMARY,i2);
# -- explain SELECT a FROM t8 IGNORE INDEX FOR JOIN (PRIMARY,i2);
SELECT a FROM t8 IGNORE INDEX FOR JOIN (PRIMARY,i2);
# -- let $query=SELECT a FROM t8 IGNORE INDEX FOR GROUP BY (PRIMARY,i2) GROUP BY a
# -- eval # -- explain $query
SELECT a FROM t8 IGNORE INDEX FOR GROUP BY (PRIMARY,i2) GROUP BY a;
FLUSH STATUS;
##--disable_result_log
# -- eval $query
SELECT a FROM t8 IGNORE INDEX FOR GROUP BY (PRIMARY,i2) GROUP BY a;
##--enable_result_log
SHOW SESSION STATUS LIKE 'Sort_scan%';
# -- let $query=SELECT a FROM t8 IGNORE INDEX FOR ORDER BY (PRIMARY,i2) ORDER BY a
SELECT a FROM t8 IGNORE INDEX FOR GROUP BY (PRIMARY,i2) GROUP BY a;
# -- eval # -- explain $query
FLUSH STATUS;
##--disable_result_log
# -- eval $query
##--enable_result_log
SHOW SESSION STATUS LIKE 'Sort_scan%';
SELECT a FROM t8 IGNORE INDEX FOR ORDER BY (PRIMARY,i2) ORDER BY a;
# -- explain SELECT a FROM t8 IGNORE INDEX FOR ORDER BY (PRIMARY)   IGNORE INDEX FOR GROUP BY (i2) GROUP BY a;
SELECT a FROM t8 IGNORE INDEX FOR ORDER BY (PRIMARY)   IGNORE INDEX FOR GROUP BY (i2) GROUP BY a;
# -- explain SELECT a FROM t8 IGNORE INDEX (PRIMARY) IGNORE INDEX FOR ORDER BY (i2);
SELECT a FROM t8 IGNORE INDEX (PRIMARY) IGNORE INDEX FOR ORDER BY (i2);
# -- explain SELECT a FROM t8 FORCE INDEX (i2);
SELECT a FROM t8 FORCE INDEX (i2);
# -- explain SELECT a FROM t8 USE INDEX ();
SELECT a FROM t8 USE INDEX ();
# -- explain SELECT a FROM t8 USE INDEX () USE INDEX (i2);
SELECT a FROM t8 USE INDEX () USE INDEX (i2);
##--error ER_WRONG_USAGE
# -- explain SELECT a FROM t8   FORCE INDEX (PRIMARY)   IGNORE INDEX FOR GROUP BY (i2)   IGNORE INDEX FOR ORDER BY (i2)   USE INDEX (i2);
SELECT a FROM t8   FORCE INDEX (PRIMARY)   IGNORE INDEX FOR GROUP BY (i2)   IGNORE INDEX FOR ORDER BY (i2)   USE INDEX (i2);
# -- explain SELECT a FROM t8 USE INDEX (i2) USE INDEX ();
SELECT a FROM t8 USE INDEX (i2) USE INDEX ();
##--error ER_PARSE_ERROR
# -- explain SELECT a FROM t8 FORCE INDEX ();
SELECT a FROM t8 FORCE INDEX ();
##--error ER_PARSE_ERROR
# -- explain SELECT a FROM t8 IGNORE INDEX ();
SELECT a FROM t8 IGNORE INDEX ();
# disable the columns irrelevant to this test here. On some systems 
# without support for large files the rowid is shorter and its size affects 
# the cost calculations. This causes the optimizer to choose loose index
# scan over normal index access.
##--replace_column 5 # 8 # 10 # 12 #
# -- explain SELECT a FROM t8 USE INDEX FOR JOIN (i2)   USE INDEX FOR GROUP BY (i2) GROUP BY a;
SELECT a FROM t8 USE INDEX FOR JOIN (i2)   USE INDEX FOR GROUP BY (i2) GROUP BY a;
# -- explain SELECT a FROM t8 FORCE INDEX FOR JOIN (i2)   FORCE INDEX FOR GROUP BY (i2) GROUP BY a;
SELECT a FROM t8 FORCE INDEX FOR JOIN (i2)   FORCE INDEX FOR GROUP BY (i2) GROUP BY a;
# -- explain SELECT a FROM t8 USE INDEX () IGNORE INDEX (i2);
SELECT a FROM t8 USE INDEX () IGNORE INDEX (i2);
# -- explain SELECT a FROM t8 IGNORE INDEX (i2) USE INDEX ();
SELECT a FROM t8 IGNORE INDEX (i2) USE INDEX ();

# -- explain SELECT a FROM t8   USE INDEX FOR GROUP BY (i2)   USE INDEX FOR ORDER BY (i2)   USE INDEX FOR JOIN (i2);
SELECT a FROM t8   USE INDEX FOR GROUP BY (i2)   USE INDEX FOR ORDER BY (i2)   USE INDEX FOR JOIN (i2);
# -- explain SELECT a FROM t8   USE INDEX FOR JOIN (i2)   USE INDEX FOR JOIN (i2)   USE INDEX FOR JOIN (i2,i2);
SELECT a FROM t8   USE INDEX FOR JOIN (i2)   USE INDEX FOR JOIN (i2)   USE INDEX FOR JOIN (i2,i2);

# -- explain SELECT 1 FROM t8 WHERE a IN   (SELECT a FROM t8 USE INDEX (i2) IGNORE INDEX (i2));
SELECT 1 FROM t8 WHERE a IN   (SELECT a FROM t8 USE INDEX (i2) IGNORE INDEX (i2));

CREATE TABLE t9 (a INT, b INT, KEY(a));
INSERT INTO t9 VALUES (1, 1), (2, 2), (3,3), (4,4);
# -- explain SELECT a, SUM(b) FROM t9 GROUP BY a LIMIT 2; 
SELECT a, SUM(b) FROM t9 GROUP BY a LIMIT 2; 
# -- explain SELECT a, SUM(b) FROM t9 IGNORE INDEX (a) GROUP BY a LIMIT 2;
SELECT a, SUM(b) FROM t9 IGNORE INDEX (a) GROUP BY a LIMIT 2;

# -- explain SELECT 1 FROM t9 WHERE a IN   (SELECT a FROM t8 USE INDEX (i2) IGNORE INDEX (i2));
SELECT 1 FROM t9 WHERE a IN   (SELECT a FROM t8 USE INDEX (i2) IGNORE INDEX (i2));

SHOW VARIABLES LIKE 'old';  
##--error ER_INCORRECT_GLOBAL_LOCAL_VAR
SET @@old = off;  

DROP TABLE t8; 
DROP TABLE t9;

#
# Bug#30596: GROUP BY optimization gives wrong result order
#
CREATE TABLE t8(   a INT,   b INT NOT NULL,   c INT NOT NULL,   d INT,   UNIQUE KEY (c,b) );

INSERT INTO t8 VALUES (1,1,1,50), (1,2,3,40), (2,1,3,4);

CREATE TABLE t9(   a INT,   b INT,   UNIQUE KEY(a,b) );

INSERT INTO t9 VALUES (NULL, NULL), (NULL, NULL), (NULL, 1), (1, NULL), (1, 1), (1,2);

# -- explain SELECT c,b,d FROM t8 GROUP BY c,b,d;
SELECT c,b,d FROM t8 GROUP BY c,b,d;
# -- explain SELECT c,b,d FROM t8 GROUP BY c,b,d ORDER BY NULL;
SELECT c,b,d FROM t8 GROUP BY c,b,d ORDER BY NULL;
# -- explain SELECT c,b,d FROM t8 ORDER BY c,b,d;
SELECT c,b,d FROM t8 ORDER BY c,b,d;

# -- explain SELECT c,b,d FROM t8 GROUP BY c,b;
SELECT c,b,d FROM t8 GROUP BY c,b;
# -- explain SELECT c,b   FROM t8 GROUP BY c,b;
SELECT c,b   FROM t8 GROUP BY c,b;

# -- explain SELECT a,b from t9 ORDER BY a,b;
SELECT a,b from t9 ORDER BY a,b;
# -- explain SELECT a,b from t9 GROUP BY a,b;
SELECT a,b from t9 GROUP BY a,b;
# -- explain SELECT a from t9 GROUP BY a;
SELECT a from t9 GROUP BY a;
# -- explain SELECT b from t9 GROUP BY b;
SELECT b from t9 GROUP BY b;

DROP TABLE t8;
DROP TABLE t9;

#
# Bug #31797: error while parsing subqueries ##-- WHERE is parsed as HAVING
#
CREATE TABLE t8 ( a INT, b INT );

SELECT b c, (SELECT a FROM t8 WHERE b = c) FROM t8;

SELECT b c, (SELECT a FROM t8 WHERE b = c) FROM t8 HAVING b = 10;

##--error ER_ILLEGAL_REFERENCE
SELECT MAX(b) c, (SELECT a FROM t8 WHERE b = c) FROM t8 HAVING b = 10;

SET @old_sql_mode = @@sql_mode;
SET @@sql_mode='ONLY_FULL_GROUP_BY';

SELECT b c, (SELECT a FROM t8 WHERE b = c) FROM t8;

SELECT b c, (SELECT a FROM t8 WHERE b = c) FROM t8 HAVING b = 10;

##--error ER_ILLEGAL_REFERENCE
SELECT MAX(b) c, (SELECT a FROM t8 WHERE b = c) FROM t8 HAVING b = 10;

INSERT INTO t8 VALUES (1, 1); SELECT b c, (SELECT a FROM t8 WHERE b = c) FROM t8;

INSERT INTO t8 VALUES (2, 1);
##--error ER_SUBQUERY_NO_1_ROW
SELECT b c, (SELECT a FROM t8 WHERE b = c) FROM t8;

DROP TABLE t8;
SET @@sql_mode = @old_sql_mode;


#
# Bug#42567 Invalid GROUP BY error
#

# Setup of the subtest
SET @old_sql_mode = @@sql_mode;
SET @@sql_mode='ONLY_FULL_GROUP_BY';

CREATE TABLE t1(id INT);
INSERT INTO t1 VALUES (1), (10);

# The actual test
SELECT COUNT(id) FROM t1;
SELECT COUNT(id) FROM t1 WHERE id > 1;

# Cleanup of subtest
DROP TABLE t1;
SET @@sql_mode = @old_sql_mode;

# --echo #
# --echo # Bug #45640: optimizer bug produces wrong results
# --echo #

CREATE TABLE t8 (a INT, b INT);
INSERT INTO t8 VALUES (4, 40), (1, 10), (2, 20), (2, 20), (3, 30);

# --echo # should return 4 ordered records:
SELECT (SELECT t8.a) aa, COUNT(DISTINCT b) FROM t8 GROUP BY aa;

SELECT (SELECT (SELECT t8.a)) aa, COUNT(DISTINCT b) FROM t8 GROUP BY aa;

##--source include/turn_off_only_full_group_by.inc

SELECT (SELECT t8.a) aa, COUNT(DISTINCT b) FROM t8 GROUP BY aa+0;

# --echo # should return the same result in a reverse order:
SELECT (SELECT t8.a) aa, COUNT(DISTINCT b) FROM t8 GROUP BY -aa;

# --echo # execution plan should not use temporary table:
# -- explain EXTENDED
SELECT (SELECT t8.a) aa, COUNT(DISTINCT b) FROM t8 GROUP BY aa+0;

# -- explain EXTENDED
SELECT (SELECT t8.a) aa, COUNT(DISTINCT b) FROM t8 GROUP BY -aa;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

# --echo # should return only one record
SELECT (SELECT tt.a FROM t8 tt LIMIT 1) aa, COUNT(DISTINCT b) FROM t8   GROUP BY aa;

# -- CREATE TABLE t9 SELECT DISTINCT a FROM t8;
CREATE TABLE t9 (a INT, b INT);
INSERT INTO t9 VALUES (4, 40), (1, 10), (2, 20), (3, 30);

# --echo # originally reported queries (1st two columns of next two query
# --echo # results should be same):

SELECT (SELECT t9.a FROM t9 WHERE t9.a = t8.a) aa, b, COUNT(DISTINCT b)   FROM t8 GROUP BY aa, b;
SELECT (SELECT t9.a FROM t9 WHERE t9.a = t8.a) aa, b, COUNT( b)   FROM t8 GROUP BY aa, b;

# --echo # ORDER BY for sure:

SELECT (SELECT t9.a FROM t9 WHERE t9.a = t8.a) aa, b, COUNT(DISTINCT b)   FROM t8 GROUP BY aa, b ORDER BY -aa, -b;
SELECT (SELECT t9.a FROM t9 WHERE t9.a = t8.a) aa, b, COUNT(         b)   FROM t8 GROUP BY aa, b ORDER BY -aa, -b;

DROP TABLE t8;
DROP TABLE t9;


# --echo #
# --echo # Bug#52051: Aggregate functions incorrectly returns NULL from outer
# --echo # join query
# --echo #
CREATE TABLE t8 (a INT PRIMARY KEY);
CREATE TABLE t9 (a INT PRIMARY KEY);
INSERT INTO t9 VALUES (1), (2);
# -- explain SELECT MIN(t9.a) FROM t9 LEFT JOIN t8 ON t9.a = t8.a;
SELECT MIN(t9.a) FROM t9 LEFT JOIN t8 ON t9.a = t8.a;
# -- explain SELECT MAX(t9.a) FROM t9 LEFT JOIN t8 ON t9.a = t8.a;
SELECT MAX(t9.a) FROM t9 LEFT JOIN t8 ON t9.a = t8.a;
DROP TABLE t8;
DROP TABLE t9;


# --echo #
# --echo # Bug#55188: GROUP BY, GROUP_CONCAT and TEXT - inconsistent results
# --echo #

CREATE TABLE ts2 (a text, c1 varchar(10));
INSERT INTO ts2 VALUES (repeat('1', 1300),'one'), (repeat('1', 1300),'two');

#query_vertical # -- explain 
SELECT SUBSTRING(a,1,10), LENGTH(a), GROUP_CONCAT(c1) FROM ts2 GROUP BY a;
SELECT SUBSTRING(a,1,10), LENGTH(a), GROUP_CONCAT(c1) FROM ts2 GROUP BY a;
#query_vertical # -- explain SELECT SUBSTRING(a,1,10), LENGTH(a) FROM ts2 GROUP BY a;
SELECT SUBSTRING(a,1,10), LENGTH(a) FROM ts2 GROUP BY a;
DROP TABLE ts2;

# --echo #
# --echo # Bug#57688 Assertion `!table || (!table->write_set || bitmap_is_set(table->write_set, field
# --echo #

CREATE TABLE t1(id INT NOT NULL); INSERT INTO t1 VALUES (16777214),(0);

SELECT COUNT(*) FROM t1 LEFT JOIN t1 t2 ON 1 WHERE t2.id > 1 GROUP BY t2.id;

DROP TABLE t1;


# --echo #
# --echo # Bug#12798270: ASSERTION `!TAB->SORTED' FAILED IN JOIN_READ_KEY2
# --echo #

CREATE TABLE t1 (id int);
INSERT INTO t1 VALUES (1);

CREATE TABLE t2 (id int PRIMARY KEY);
INSERT INTO t2 VALUES (10);

CREATE VIEW v1 AS SELECT t2.id FROM t2;

SELECT v1.id FROM t1 LEFT JOIN v1 ON t1.id = v1.id GROUP BY v1.id;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE t2;

# --echo # End of Bug#12798270
# --echo #
# --echo # Bug#59839: Aggregation followed by subquery yields wrong result
# --echo #

CREATE TABLE t8 (   a INT,   b INT,   c INT,   KEY (a, b) );
INSERT INTO t8 VALUES   ( 1, 1,  1 ),   ( 1, 2,  2 ),   ( 1, 3,  3 ),   ( 1, 4,  6 ),   ( 1, 5,  5 ),   ( 1, 9, 13 ),    ( 2, 1,  6 ),   ( 2, 2,  7 ),   ( 2, 3,  8 );

# -- explain SELECT a, AVG(t8.b), (SELECT t81.c FROM t8 t81 WHERE t81.a = t8.a AND t81.b = AVG(t8.b)) AS t81c, (SELECT t82.c FROM t8 t82 WHERE t82.a = t8.a AND t82.b = AVG(t8.b)) AS t82c FROM t8 GROUP BY a;

SELECT a, AVG(t8.b), (SELECT t81.c FROM t8 t81 WHERE t81.a = t8.a AND t81.b = AVG(t8.b)) AS t81c, (SELECT t82.c FROM t8 t82 WHERE t82.a = t8.a AND t82.b = AVG(t8.b)) AS t82c FROM t8 GROUP BY a;

DROP TABLE t8;

# --echo #
# --echo # Bug#11765254 (58200): Assertion failed: param.sort_length when grouping
# --echo # by functions
# --echo #

SET BIG_TABLES=1;
CREATE TABLE t8(a INT);
INSERT INTO t8 VALUES (0),(0);
##--error ER_WRONG_KEY_COLUMN
SELECT 1 FROM t8 GROUP BY IF(`a`,'','');
SELECT 1 FROM t8 GROUP BY TRIM(LEADING RAND() FROM '');
SELECT 1 FROM t8 GROUP BY SUBSTRING('',SLEEP(0),'');
SELECT 1 FROM t8 GROUP BY SUBSTRING(SYSDATE() FROM 'K' FOR 'jxW<');
DROP TABLE t8;
SET BIG_TABLES=0;

# --echo # End of 5.1 tests

# --echo #
# --echo # Bug#49771: Incorrect MIN (date) when minimum value is 0000-00-00
# --echo #

SET @save_sql_mode=@@sql_mode;
SET @@sql_mode='ONLY_FULL_GROUP_BY';

CREATE TABLE t1 (id int, f2 DATE);

INSERT INTO t1 VALUES (1,'2004-04-19'), (1,'0000-00-00'), (1,'2004-04-18'), (2,'2004-05-19'), (2,'0001-01-01'), (3,'2004-04-10');

SELECT MIN(f2),MAX(f2) FROM t1;
SELECT id,MIN(f2),MAX(f2) FROM t1 GROUP BY 1;

DROP TABLE t1;

CREATE TABLE t1 ( id int, f2 time);
INSERT INTO t1 VALUES (1,'01:27:35'), (1,'06:11:01'), (2,'19:53:05'), (2,'21:44:25'), (3,'10:55:12'), (3,'05:45:11'), (4,'00:25:00');

SELECT MIN(f2),MAX(f2) FROM t1;
SELECT id,MIN(f2),MAX(f2) FROM t1 GROUP BY 1;

DROP TABLE t1;

SET sql_mode=@save_sql_mode;

# --echo #End of test#49771

# --echo #
# --echo # Bug #58782
# --echo # Missing rows with SELECT .. WHERE .. IN subquery 
# --echo # with full GROUP BY and no aggr
# --echo #

CREATE TABLE t1 (   id INT NOT NULL,   col_int_nokey INT,   PRIMARY KEY (id) );

INSERT INTO t1 VALUES (10,7);
INSERT INTO t1 VALUES (11,1);
INSERT INTO t1 VALUES (12,5);
INSERT INTO t1 VALUES (13,3);

## original query:
SELECT id AS field1, col_int_nokey AS field2 FROM t1 WHERE col_int_nokey > 0 GROUP BY field1, field2;

## store query results in a new table:

#-- CREATE TABLE t0   SELECT id AS field1, col_int_nokey AS field2   FROM t1   WHERE col_int_nokey > 0   GROUP BY field1, field2 ;
CREATE TABLE t0(a INT NOT NULL, field2 INT,   PRIMARY KEY (a) );
insert into t0 values(10,7),(11,1),(12,5),(13,3);

## query the new table and compare to original using WHERE ... IN():

SELECT * FROM t0 WHERE (a, field2) IN (   SELECT id AS a, col_int_nokey AS field2   FROM t1   WHERE col_int_nokey > 0   GROUP BY a, field2 );

DROP TABLE t1;
DROP TABLE t0;

# --echo # End of Bug #58782

# --echo #
# --echo # Bug #11766429 
# --echo # RE-EXECUTE OF PREPARED STATEMENT CRASHES IN ITEM_REF::FIX_FIELDS WITH
# --echo #

CREATE TABLE t8(a INT, KEY(a));
INSERT INTO t8 VALUES (0);
CREATE TABLE t7(b INT, KEY(b));
INSERT INTO t7 VALUES (0),(0);

PREPARE stmt FROM ' SELECT 1 FROM t7 LEFT JOIN t8 ON NULL GROUP BY t7.b, t8.a HAVING a <> 2';
EXECUTE stmt;
EXECUTE stmt;

DEALLOCATE PREPARE stmt;
DROP TABLE t8;
DROP TABLE t7;

# --echo # End of Bug #11766429

# --echo #
# --echo # Bug#12699645 SELECT SUM() + STRAIGHT_JOIN QUERY MISSES ROWS
# --echo #

CREATE TABLE t1 ( id INT, col_int_key INT, col_varchar_key VARCHAR(1), col_varchar_nokey VARCHAR(1) );
INSERT INTO t1 VALUES (10,7,'v','v'),(11,0,'s','s'),(12,9,'l','l'),(13,3,'y','y'),(14,4,'c','c'), (15,2,'i','i'),(16,5,'h','h'),(17,3,'q','q'),(18,1,'a','a'),(19,3,'v','v'), (20,6,'u','u'),(21,7,'s','s'),(22,5,'y','y'),(23,1,'z','z'),(24,204,'h','h'), (25,224,'p','p'),(26,9,'e','e'),(27,5,'i','i'),(28,0,'y','y'),(29,3,'w','w');

CREATE TABLE t2 ( id INT, col_int_key INT, col_varchar_key VARCHAR(1), col_varchar_nokey VARCHAR(1), PRIMARY KEY (id) );
INSERT INTO t2 VALUES (1,4,'b','b'),(2,8,'y','y'),(3,0,'p','p'),(4,0,'f','f'),(5,0,'p','p'), (6,7,'d','d'),(7,7,'f','f'),(8,5,'j','j'),(9,3,'e','e'),(10,188,'u','u'), (11,4,'v','v'),(12,9,'u','u'),(13,6,'i','i'),(14,1,'x','x'),(15,5,'l','l'), (16,6,'q','q'),(17,2,'n','n'),(18,4,'r','r'),(19,231,'c','c'),(20,4,'h','h'), (21,3,'k','k'),(22,3,'t','t'),(23,7,'t','t'),(24,6,'k','k'),(25,7,'g','g'), (26,9,'z','z'),(27,4,'n','n'),(28,4,'j','j'),(29,2,'l','l'),(30,1,'d','d'), (31,2,'t','t'),(32,194,'y','y'),(33,2,'i','i'),(34,3,'j','j'),(35,8,'r','r'), (36,4,'b','b'),(37,9,'o','o'),(38,4,'k','k'),(39,5,'a','a'),(40,5,'f','f'), (41,9,'t','t'),(42,3,'c','c'),(43,8,'c','c'),(44,0,'r','r'),(45,98,'k','k'), (46,3,'l','l'),(47,1,'o','o'),(48,0,'t','t'),(49,189,'v','v'),(50,8,'x','x'), (51,3,'j','j'),(52,3,'x','x'),(53,9,'k','k'),(54,6,'o','o'),(55,8,'z','z'), (56,3,'n','n'),(57,9,'c','c'),(58,5,'d','d'),(59,9,'s','s'),(60,2,'j','j'), (61,2,'w','w'),(62,5,'f','f'),(63,8,'p','p'),(64,6,'o','o'),(65,9,'f','f'), (66,0,'x','x'),(67,3,'q','q'),(68,6,'g','g'),(69,5,'x','x'),(70,8,'p','p'), (71,2,'q','q'),(72,120,'q','q'),(73,25,'v','v'),(74,1,'g','g'),(75,3,'l','l'), (76,1,'w','w'),(77,3,'h','h'),(78,153,'c','c'),(79,5,'o','o'),(80,9,'o','o'), (81,1,'v','v'),(82,8,'y','y'),(83,7,'d','d'),(84,6,'p','p'),(85,2,'z','z'), (86,4,'t','t'),(87,7,'b','b'),(88,3,'y','y'),(89,8,'k','k'),(90,4,'c','c'), (91,6,'z','z'),(92,1,'t','t'),(93,7,'o','o'),(94,1,'u','u'),(95,0,'t','t'), (96,2,'k','k'),(97,7,'u','u'),(98,2,'b','b'),(99,1,'m','m'),(100,5,'o','o');

# -- let $query=SELECT SUM(alias2.col_varchar_nokey) , alias2.id AS field2 FROM t1 AS alias1 STRAIGHT_JOIN t2 AS alias2 ON alias2.id = alias1.col_int_key WHERE alias1.id GROUP BY field2 ORDER BY alias1.col_int_key,alias2.id ;
# -- eval # -- explain $query;
# -- eval $query;
SELECT SUM(alias2.col_varchar_nokey) , alias2.id AS field2 FROM t1 AS alias1 STRAIGHT_JOIN t2 AS alias2 ON alias2.id = alias1.col_int_key WHERE alias1.id GROUP BY field2 ORDER BY alias1.col_int_key,alias2.id ;

DROP TABLE t1;
DROP TABLE t2;

# --echo #
# --echo # Bug#12798270: ASSERTION `!TAB->SORTED' FAILED IN JOIN_READ_KEY2
# --echo #

CREATE TABLE t1 (id int);
INSERT INTO t1 VALUES (1);

CREATE TABLE t8 (a int PRIMARY KEY);
INSERT INTO t8 VALUES (10);

CREATE VIEW v1 AS SELECT t8.a FROM t8;

SELECT v1.a FROM t1 LEFT JOIN v1 ON t1.id = v1.a GROUP BY v1.a;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE t8;

# --echo # End of Bug#12798270

# --echo #
# --echo # Bug#12837714: ADDITIONAL NULL IN 5.6 ON GROUPED SELECT
# --echo #

CREATE TABLE ts1 (a varchar(1), INDEX vc_idx (a)) ;
INSERT INTO ts1 VALUES (NULL), ('o'), (NULL), ('p'), ('c');

FLUSH TABLE ts1;

SELECT a FROM ts1 GROUP BY a;

DROP TABLE ts1; 

# --echo # End of Bug#12837714

# --echo #
# --echo # Bug#12578908: SELECT SQL_BUFFER_RESULT OUTPUTS TOO MANY 
# --echo #               ROWS WHEN GROUP IS OPTIMIZED AWAY
# --echo #

CREATE TABLE t1 (id int, col2 int) ;
INSERT INTO t1 VALUES (10,1),(11,7);

CREATE TABLE t2 (id int, col2 int) ;
INSERT INTO t2 VALUES (10,8);

# -- let $q_body=t2.col2 FROM t2 JOIN t1 ON t1.id GROUP BY t2.col2;

# --echo
# -- eval # -- explain SELECT SQL_BUFFER_RESULT $q_body
# -- eval SELECT SQL_BUFFER_RESULT $q_body
SELECT SQL_BUFFER_RESULT t2.col2 FROM t2 JOIN t1 ON t1.id GROUP BY t2.col2;

# --echo
# -- eval # -- explain SELECT $q_body
# -- eval SELECT $q_body
select t2.col2 FROM t2 JOIN t1 ON t1.id GROUP BY t2.col2;

# --echo
DROP TABLE t1;
DROP TABLE t2;

# --echo #
# --echo # Bug#11761078: 53534: INCORRECT 'SELECT SQL_BIG_RESULT...' 
# --echo #               WITH GROUP BY ON DUPLICATED FIELDS
# --echo #

CREATE TABLE t1(  id int,  INDEX idx (id) );

INSERT INTO t1 VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),    (11),(12),(13),(14),(15),(16),(17),(18),(19),(20);

# -- let $query=SELECT SQL_BIG_RESULT id AS field1, id AS field2            FROM t1 GROUP BY field1, field2;

# Needs to be range to exercise bug
# -- eval # -- explain $query;
FLUSH STATUS;
# -- eval $query
SELECT SQL_BIG_RESULT id AS field1, id AS field2            FROM t1 GROUP BY field1, field2;
SHOW SESSION STATUS LIKE 'Sort_scan%';

CREATE VIEW v1 AS SELECT * FROM t1;

SELECT SQL_BIG_RESULT id AS field1, id AS field2 FROM v1 GROUP BY field1, field2; 

SELECT SQL_BIG_RESULT tbl1.id AS field1, tbl2.id AS field2 FROM t1 as tbl1, t1 as tbl2 GROUP BY field1, field2 LIMIT 3;

DROP VIEW v1;
DROP TABLE t1;

# --echo #
# --echo # Bug#13422961: WRONG RESULTS FROM SELECT WITH AGGREGATES AND
# --echo #               IMPLICIT GROUPING + MYISAM OR MEM
# --echo #

CREATE TABLE it (   id INT NOT NULL,   col_int_nokey INT NOT NULL,   PRIMARY KEY (id) ) ENGINE=InnoDB;

CREATE TABLE ot (   id int(11) NOT NULL,   col_int_nokey int(11) NOT NULL,   PRIMARY KEY (id) ) ENGINE=InnoDB; INSERT INTO ot VALUES (10,8);

##--source include/turn_off_only_full_group_by.inc

# --echo
SELECT col_int_nokey, MAX( id ) FROM ot WHERE (8, 1) IN ( SELECT id, COUNT( col_int_nokey ) FROM it );

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

# --echo
DROP TABLE it;
DROP TABLE ot;

# --echo #
# --echo # Bug#13430588: WRONG RESULT FROM IMPLICITLY GROUPED QUERY WITH
# --echo #               CONST TABLE AND NO MATCHING ROWS
# --echo #
CREATE TABLE t1 (id INT) ENGINE=InnoDB;
INSERT INTO t1 VALUES (1);

CREATE TABLE t8 (a INT) ENGINE=InnoDB;
INSERT INTO t8 VALUES (1),(2);

##--source include/turn_off_only_full_group_by.inc

# --echo
SELECT id, a, COUNT(id) FROM t1 JOIN t8 WHERE a=3;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

# --echo
DROP TABLE t1;
DROP TABLE t8;

# --echo #
# --echo # BUG#13541761: WRONG RESULTS ON CORRELATED SUBQUERY + 
# --echo #               AGGREGATE FUNCTION + MYISAM OR MEMORY
# --echo #

CREATE TABLE ts5 (   id varchar(1) ) ENGINE=InnoDB;

INSERT INTO ts5 VALUES ('a'), ('b');

CREATE TABLE ts6 (   id varchar(1),   b int(11) ) ENGINE=InnoDB;

INSERT INTO ts6 VALUES ('a',1);

# -- let $query= SELECT (SELECT MAX(b) FROM ts6 WHERE ts6.id != ts5.id) as MAX FROM ts5;

# --echo
# -- eval # -- explain $query;
# -- eval $query;
SELECT (SELECT MAX(b) FROM ts6 WHERE ts6.id != ts5.id) as MAX FROM ts5;

DROP TABLE ts5;
DROP TABLE ts6;

# --echo # Bug 11923239 - ERROR WITH CORRELATED SUBQUERY IN VIEW WITH
# --echo # ONLY_FULL_GROUP_BY SQL MODE


SET @old_sql_mode = @@sql_mode;
SET sql_mode='';

CREATE TABLE t1 (   id INT,   col_int_key INT,   col_int_nokey INT,   col_varchar_key VARCHAR(10),   col_varchar_nokey VARCHAR(10),   KEY col_int_key (col_int_key),   KEY col_varchar_key (col_varchar_key) );
INSERT INTO t1 VALUES (), ();

# -- let $query_with_alias_in_group_by= SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1, field2;

# -- let $query_with_no_alias_in_group_by= SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   );

# --echo # In GROUP BY, aliases are printed as aliases.

# -- eval # -- explain EXTENDED $query_with_alias_in_group_by;
SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1, field2;


# --echo # In GROUP BY, expressions are printed as expressions.

# -- eval # -- explain EXTENDED $query_with_no_alias_in_group_by;
SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   );


# --echo # Aliased expression in GROUP BY in a view.

# -- eval CREATE VIEW v1 AS $query_with_alias_in_group_by;
CREATE VIEW v1 AS SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1, field2;

# --echo # In GROUP BY, aliases are printed as aliases.

SHOW CREATE VIEW v1;

SET @@sql_mode='ONLY_FULL_GROUP_BY';

# -- eval $query_with_alias_in_group_by;
SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1, field2;

# --echo # The SELECT above has been accepted, and v1 was created
# --echo # using the same SELECT as above, so SELECTing from v1
# --echo # should be accepted.
SELECT * FROM v1;

# --echo # Here is why in GROUP BY we print aliases of subqueries as
# --echo # aliases: below, "GROUP BY (subquery)" confuses
# --echo # ONLY_FULL_GROUP_BY, it causes an error though the subquery of
# --echo # GROUP BY and of SELECT list are the same. Fixing this would
# --echo # require implementing Item_subselect::eq(). It's not worth
# --echo # the effort because:
# --echo # a) GROUP BY (subquery) is non-SQL-standard so is likely of
# --echo # very little interest to users of ONLY_FULL_GROUP_BY
# --echo # b) as the user uses ONLY_FULL_GROUP_BY, he wants to have the
# --echo # same subquery in GROUP BY and SELECT list, so can give the
# --echo # subquery an alias in the SELECT list and use this alias in
# --echo # GROUP BY, thus avoiding the problem.

##--error ER_WRONG_FIELD_WITH_GROUP
# -- eval $query_with_no_alias_in_group_by;
SELECT alias1.col_int_nokey AS field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   ) AS field2 FROM t1 AS alias1 GROUP BY field1,   (SELECT alias2.col_int_key    FROM t1 AS alias2    WHERE alias1.col_varchar_key <= alias1.col_varchar_nokey   );

DROP VIEW v1;
SET @@sql_mode = @old_sql_mode;

# --echo # Verify that if an alias is used in GROUP BY/ORDER BY it
# --echo # is printed as an alias, not as the expression.

CREATE TABLE t8(a INT);
INSERT INTO t8 VALUES(3),(4);

# -- explain EXTENDED SELECT id AS foo, col_int_key AS bar, (SELECT a FROM t8 WHERE a=t1.id) AS baz FROM t1 GROUP BY foo, col_int_key, baz ORDER BY id, bar, (SELECT a FROM t8 WHERE a=t1.id);
SELECT id AS foo, col_int_key AS bar, (SELECT a FROM t8 WHERE a=t1.id) AS baz FROM t1 GROUP BY foo, col_int_key, baz ORDER BY id, bar, (SELECT a FROM t8 WHERE a=t1.id);

# Printing the alias in GROUP/ORDER BY would introduce an ambiguity.
# -- explain EXTENDED SELECT id AS foo, col_int_key AS foo, (SELECT a FROM t8 WHERE a=t1.id) AS foo FROM t1 GROUP BY id, col_int_key, (SELECT a FROM t8 WHERE a=t1.id) ORDER BY id, col_int_key, (SELECT a FROM t8 WHERE a=t1.id);
SELECT id AS foo, col_int_key AS foo, (SELECT a FROM t8 WHERE a=t1.id) AS foo FROM t1 GROUP BY id, col_int_key, (SELECT a FROM t8 WHERE a=t1.id) ORDER BY id, col_int_key, (SELECT a FROM t8 WHERE a=t1.id);

DROP TABLE t1;
DROP TABLE t8;

# --echo #
# --echo # Bug#13591138 - ASSERTION NAME && !IS_AUTOGENERATED_NAME IN
# --echo # ITEM::PRINT_FOR_ORDER ON # -- explain EXT
# --echo #

# There was a bug with Item_direct_view_ref

CREATE TABLE t1 (    id int(11) NOT NULL AUTO_INCREMENT,   col_datetime_key datetime NOT NULL,   col_varchar_key varchar(1) NOT NULL,   PRIMARY KEY (id),   KEY col_datetime_key (col_datetime_key),   KEY col_varchar_key (col_varchar_key) );

CREATE TABLE t2 (    id int(11) NOT NULL AUTO_INCREMENT,   PRIMARY KEY (id) );

CREATE TABLE t3 (    id int(11) NOT NULL AUTO_INCREMENT,   col_varchar_key varchar(1) NOT NULL,   PRIMARY KEY (id),   KEY col_varchar_key (col_varchar_key) );

CREATE VIEW view1 AS SELECT * FROM t1;

# -- explain EXTENDED SELECT     alias1.col_datetime_key AS field1 FROM (         view1 AS alias1,         t3 AS alias2     ) WHERE (     (SELECT MIN(sq1_alias1.id)      FROM t2 AS sq1_alias1     ) ) OR (alias1.col_varchar_key = alias2.col_varchar_key   AND alias1.col_varchar_key = 'j' ) AND alias1.id IS NULL GROUP BY     field1;
SELECT     alias1.col_datetime_key AS field1 FROM (         view1 AS alias1,         t3 AS alias2     ) WHERE (     (SELECT MIN(sq1_alias1.id)      FROM t2 AS sq1_alias1     ) ) OR (alias1.col_varchar_key = alias2.col_varchar_key   AND alias1.col_varchar_key = 'j' ) AND alias1.id IS NULL GROUP BY     field1;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP VIEW view1;

# Another one with Item_direct_view_ref:

CREATE TABLE t1 (   id int(11) DEFAULT NULL,   col_varchar_key varchar(1) DEFAULT NULL,   col_varchar_nokey varchar(1) DEFAULT NULL,   KEY id (id),   KEY col_varchar_key (col_varchar_key,id) );

CREATE TABLE t2 (   id int(11) DEFAULT NULL,   col_varchar_key varchar(1) DEFAULT NULL,   col_varchar_nokey varchar(1) DEFAULT NULL,   KEY id (id),   KEY col_varchar_key (col_varchar_key,id) );

CREATE VIEW view1 AS   SELECT CONCAT( table1.col_varchar_nokey , table2.col_varchar_key ) AS field1   FROM     t2 AS table1 JOIN t1 AS table2     ON table2.col_varchar_nokey = table1.col_varchar_key        AND        table2.col_varchar_key >= table1.col_varchar_nokey ORDER BY field1 ;

# -- explain EXTENDED SELECT * FROM view1;
SELECT * FROM view1;

DROP TABLE t1;
DROP TABLE t2;
DROP VIEW view1;

# And a bug with Item_singlerow_subselect:

CREATE TABLE ts5 (id varchar(1) DEFAULT NULL);
INSERT INTO ts5 VALUES ('v'),('c');

# -- explain EXTENDED SELECT (SELECT 150) AS field5 FROM (SELECT * FROM ts5) AS alias1 GROUP BY field5;
SELECT (SELECT 150) AS field5 FROM (SELECT * FROM ts5) AS alias1 GROUP BY field5;

DROP TABLE ts5;

# --echo #
# --echo # BUG#12626418 "only_full_group_by wrongly allows column in order by"
# --echo #

SET @old_sql_mode = @@sql_mode;
SET @@sql_mode='ONLY_FULL_GROUP_BY';

create table t8(a int, b int);
##--error ER_WRONG_FIELD_WITH_GROUP
select a from t8 group by b;
select 1 from t8 group by b;
##--error ER_WRONG_FIELD_WITH_GROUP
select 1 from t8 group by b order by a;
##--error ER_WRONG_FIELD_WITH_GROUP
select a from t8 group by b order by b;
       
drop table t8;

# A query from BUG#12844977

CREATE TABLE t1 (id int, i1 int,  v1 varchar(1), primary key (id));
INSERT INTO t1 VALUES (0,2,'b'),(1,4,'a'),(2,0,'a'),(3,7,'b'),(4,7,'c');

##--error ER_WRONG_FIELD_WITH_GROUP
SELECT a1.v1,a2.v1 FROM t1 AS a1 JOIN t1 AS a2 ON a2.id = a1.i1 group by a1.v1,a2.v1 ORDER BY a1.i1,a2.id,a2.v1 ASC;

SELECT a1.v1,a2.v1 FROM t1 AS a1 JOIN t1 AS a2 ON a2.id = a1.i1 group by a1.v1,a2.v1 ORDER BY             a2.v1 ASC;

DROP TABLE t1;

# A query from BUG#12699645

CREATE TABLE t1 (id int(11) NOT NULL AUTO_INCREMENT, col_int_key int(11) NOT NULL, col_varchar_key varchar(1) NOT NULL, col_varchar_nokey varchar(1) NOT NULL, PRIMARY KEY (id), KEY col_int_key (col_int_key), KEY col_varchar_key (col_varchar_key,col_int_key));
CREATE TABLE t2 (id int(11) NOT NULL AUTO_INCREMENT, col_int_key int(11) NOT NULL, col_varchar_key varchar(1) NOT NULL, col_varchar_nokey varchar(1) NOT NULL, PRIMARY KEY (id), KEY col_int_key (col_int_key), KEY col_varchar_key (col_varchar_key,col_int_key));

SELECT SUM(alias2.col_varchar_nokey) , alias2.id AS field2 FROM t1 AS alias1 STRAIGHT_JOIN t2 AS alias2 ON alias2.id = alias1.col_int_key WHERE alias1.id group by field2 ORDER BY alias1.col_int_key,alias2.id ;

DROP TABLE t1;
DROP TABLE t2;

# A query from BUG#12626418

CREATE TABLE t1 (pk int(11) NOT NULL AUTO_INCREMENT, id int(11) NOT NULL, col_datetime_key datetime NOT NULL, col_varchar_key varchar(1) NOT NULL, col_varchar_nokey varchar(1) NOT NULL, PRIMARY KEY (pk), KEY id (id), KEY col_datetime_key (col_datetime_key), KEY col_varchar_key (col_varchar_key,id));
CREATE TABLE t2 (pk int(11) NOT NULL AUTO_INCREMENT, id int(11) NOT NULL, col_datetime_key datetime NOT NULL, col_varchar_key varchar(1) NOT NULL, col_varchar_nokey varchar(1) NOT NULL, PRIMARY KEY (pk), KEY id (id), KEY col_datetime_key (col_datetime_key), KEY col_varchar_key (col_varchar_key,id));

##--error ER_WRONG_FIELD_WITH_GROUP
SELECT alias2.col_varchar_key AS field1 , COUNT(DISTINCT alias1.col_varchar_nokey), alias2.pk AS field4 FROM t1 AS alias1 RIGHT JOIN t2 AS alias2 ON alias2.pk = alias1.id GROUP BY field1 , field4 ORDER BY alias1.col_datetime_key ;

DROP TABLE t1;
DROP TABLE t2;

# Particular situations met while fixing the bug

create table t8 (a int, b int);
# A field for COUNT(*) will be inserted in all_fields, between
# 'fields' (which has the Item_func_gt) and elements of ORDER BY ('b').
##--error ER_WRONG_FIELD_WITH_GROUP
select count(*) > 3 from t8 group by a order by b;

create table t9 (a int, b int);
# The subquery in ORDER BY has an outer query's column, which means
# that the outer query's ORDER BY depends on a non-aggregated column,
# which itself is not in GROUP BY.
##--error ER_WRONG_FIELD_WITH_GROUP
select a from t9 group by a order by (select a from t8 order by t9.b);
SET @@sql_mode = @old_sql_mode;
DROP TABLE t8;
DROP TABLE t9;

# From BUG#17282

create table t1 (branch varchar(40), id int);

##--source include/turn_off_only_full_group_by.inc

select count(*) from t1 group by branch having branch<>'mumbai' order by id desc,branch desc limit 100;

select branch, count(*)/max(id) from t1 group by branch having (branch<>'mumbai' OR count(*)<2) order by id desc,branch desc limit 100;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

SET @@sql_mode='ONLY_FULL_GROUP_BY';

##--error ER_WRONG_FIELD_WITH_GROUP
select count(*) from t1 group by branch having branch<>'mumbai' order by id desc,branch desc limit 100;

##--error ER_WRONG_FIELD_WITH_GROUP
select branch, count(*)/max(id) from t1 group by branch having (branch<>'mumbai' OR count(*)<2) order by id desc,branch desc limit 100;

DROP TABLE t1;

# From BUG#8510

create table t8 (a int, b int);
insert into t8 values (1, 2), (1, 3), (null, null);

select sum(a), count(*) from t8 group by a;
select round(sum(a)), count(*) from t8 group by a;
select ifnull(a, 'xyz') from t8 group by a;

DROP TABLE t8;

SET @@sql_mode = @old_sql_mode;

# --echo #
# --echo # BUG#12640437: USING SQL_BUFFER_RESULT RESULTS IN A
# --echo #               DIFFERENT QUERY OUTPUT
# --echo #

CREATE TABLE t8 (   a int,   b varchar(1),   KEY (b,a) );

INSERT INTO t8 VALUES (1,NULL),(0,'a'),(1,NULL),(0,'a');
INSERT INTO t8 VALUES (1,'a'),(0,'a'),(1,'a'),(0,'a');
ANALYZE TABLE t8;

# -- let $query=   SELECT SQL_BUFFER_RESULT MIN(a), b FROM t8 WHERE t8.b = 'a' GROUP BY b;

# --echo
# -- eval # -- explain $query
# --echo
# -- eval $query
SELECT SQL_BUFFER_RESULT MIN(a), b FROM t8 WHERE t8.b = 'a' GROUP BY b;

# -- let $query= SELECT MIN(a), b FROM t8 WHERE t8.b = 'a' GROUP BY b;
# --echo
# -- eval # -- explain $query
# --echo
# -- eval $query
SELECT MIN(a), b FROM t8 WHERE t8.b = 'a' GROUP BY b;

# --echo
DROP TABLE t8;

# --echo #
# --echo # Bug #12888306 MISSING ROWS FOR SELECT >ALL (SUBQUERY WITHOUT ROWS)
# --echo #

CREATE TABLE t8(a INT);
INSERT INTO t8 VALUES (0);
SELECT 1 FROM t8 WHERE 1 > ALL(SELECT 1 FROM t8 WHERE a);
DROP TABLE t8;

# --echo # 
# --echo # Bug#18035906: TEST_IF_SKIP_SORT_ORDER INCORRECTLY CHOSES NON-COVERING
# --echo #               INDEX FOR ORDERING
# --echo # 

CREATE TABLE t1 (   i INT PRIMARY KEY AUTO_INCREMENT,   id INT,   kp2 INT,   INDEX idx_noncov(id),   INDEX idx_cov(id,kp2) ) ENGINE=InnoDB;

INSERT INTO t1 VALUES (NULL, 1, 1);

INSERT INTO t1 SELECT NULL, id, kp2+1 from t1;
INSERT INTO t1 SELECT NULL, id, kp2+2 from t1;
INSERT INTO t1 SELECT NULL, id, kp2+4 from t1;
INSERT INTO t1 SELECT NULL, id, kp2 from t1;

##--disable_query_log
##--disable_result_log
# -- ANALYZE TABLE t1;
##--enable_result_log
##--enable_query_log

# -- explain SELECT id, SUM(kp2) FROM t1 GROUP BY id;

DROP TABLE t1;

# --echo # Bug#72512/18694751: Non-aggregated query with set function in
# --echo # ORDER BY should be rejected

CREATE TABLE t8(a INTEGER);
INSERT INTO t8 VALUES (1), (2);

# --echo # Non-aggregated queries
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 ORDER BY COUNT(*);

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 WHERE a > 0 ORDER BY COUNT(*);

# --echo # Implicitly grouped query
SELECT SUM(a) FROM t8 ORDER BY COUNT(*);

SELECT COUNT(*) FROM t8 ORDER BY COUNT(*);

SELECT COUNT(*) AS c FROM t8 ORDER BY COUNT(*);

SELECT COUNT(*) AS c FROM t8 ORDER BY c;

# --echo # Explicitly grouped query
##--sorted_result
SELECT a, COUNT(*) FROM t8 GROUP BY a ORDER BY COUNT(*);

##--sorted_result
SELECT a, COUNT(*) AS c FROM t8 GROUP BY a ORDER BY COUNT(*);

##--sorted_result
SELECT a, COUNT(*) AS c FROM t8 GROUP BY a ORDER BY c;

##--sorted_result
SELECT a AS c FROM t8 GROUP BY a ORDER BY COUNT(*);

# --echo # Query with HAVING,
SELECT 1 FROM t8 HAVING COUNT(*) > 1 ORDER BY COUNT(*);

# --echo # Subquery, ORDER BY contains outer reference
SELECT (SELECT 1 AS foo ORDER BY a) AS x FROM t8;

SELECT (SELECT 1 AS foo ORDER BY t8.a) AS x FROM t8;

# --echo # Subquery, ORDER BY contains set function with outer reference
SELECT (SELECT 1 AS foo ORDER BY COUNT(a)) AS x FROM t8;

SELECT (SELECT 1 AS foo ORDER BY COUNT(t8.a)) AS x FROM t8;

# --echo # Subquery, ORDER BY contains set function with local reference
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT (SELECT 1 AS foo ORDER BY COUNT(*)) AS x FROM t8;

# --echo # Subquery in ORDER BY with outer reference
##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 ORDER BY (SELECT COUNT(t8.a) FROM t8 AS t2);

SELECT SUM(a) FROM t8 ORDER BY (SELECT COUNT(t8.a) FROM t8 AS t2);

# --echo # Query with ORDER BY inside UNION

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*)) UNION SELECT a FROM t8;

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*)) UNION ALL SELECT a FROM t8;

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1) UNION SELECT a FROM t8;

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1) UNION ALL SELECT a FROM t8;

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 UNION (SELECT a FROM t8 ORDER BY COUNT(*));

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 UNION ALL (SELECT a FROM t8 ORDER BY COUNT(*));

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 UNION (SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1 OFFSET 1);

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
SELECT a FROM t8 UNION ALL (SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1 OFFSET 1);

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*)) UNION (SELECT a FROM t8 ORDER BY COUNT(*));

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*)) UNION ALL (SELECT a FROM t8 ORDER BY COUNT(*));

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1) UNION (SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1 OFFSET 1);

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1) UNION ALL (SELECT a FROM t8 ORDER BY COUNT(*) LIMIT 1 OFFSET 1);

##--error ER_AGGREGATE_ORDER_NON_AGG_QUERY
(SELECT COUNT(*) FROM t8 ORDER BY a) ORDER BY COUNT(*);

DROP TABLE t8;

# --echo # 
# --echo # Bug#18487060: ASSERTION FAILED: !TABLE || (!TABLE->READ_SET || 
# --echo #               BITMAP_IS_SET(TABLE->READ_SET,
# --echo # 

CREATE TABLE r(c BLOB) ENGINE=INNODB;

INSERT INTO r VALUES('');

SELECT 1 FROM r GROUP BY MAKE_SET(1,c) WITH ROLLUP;

DROP TABLE r;

# --echo #
# --echo # Bug #18921626 	DEBUG CRASH IN PLAN_CHANGE_WATCHDOG::~PLAN_CHANGE_WATCHDOG AT SQL_OPTIMIZER.CC
# --echo #

SET @old_sql_mode = @@sql_mode;
set sql_mode='';

SET GLOBAL innodb_large_prefix=OFF;
CREATE TABLE ts5 ( col_varchar_1024_latin1 varchar(1024)  CHARACTER SET latin1, pk integer auto_increment, col_varchar_1024_utf8_key varchar(1024)  CHARACTER SET utf8, id varchar(1024)  CHARACTER SET latin1, col_varchar_10_utf8_key varchar(10)  CHARACTER SET utf8, col_varchar_10_latin1_key varchar(10)  CHARACTER SET latin1, col_int int, col_varchar_10_latin1 varchar(10)  CHARACTER SET latin1, col_varchar_10_utf8 varchar(10)  CHARACTER SET utf8, col_varchar_1024_utf8 varchar(1024)  CHARACTER SET utf8, col_int_key int, primary key (pk), key (col_varchar_1024_utf8_key ), key (id ), key (col_varchar_10_utf8_key ), key (col_varchar_10_latin1_key ), key (col_int_key )) ENGINE=innodb;

CREATE OR REPLACE VIEW view_ts5 AS SELECT * FROM ts5;

CREATE TABLE ts6 ( id varchar(1024)  CHARACTER SET latin1, col_varchar_10_latin1 varchar(10)  CHARACTER SET latin1, col_varchar_10_utf8_key varchar(10)  CHARACTER SET utf8, col_int_key int, col_varchar_1024_latin1 varchar(1024)  CHARACTER SET latin1, col_varchar_1024_utf8_key varchar(1024)  CHARACTER SET utf8, col_varchar_10_utf8 varchar(10)  CHARACTER SET utf8, col_int int, pk integer auto_increment, col_varchar_10_latin1_key varchar(10)  CHARACTER SET latin1, col_varchar_1024_utf8 varchar(1024)  CHARACTER SET utf8, key (id ), key (col_varchar_10_utf8_key ), key (col_int_key ), key (col_varchar_1024_utf8_key ), primary key (pk), key (col_varchar_10_latin1_key )) ENGINE=InnoDB;

INSERT INTO ts6 VALUES  ('at', repeat('a',1000), 'the', -1622540288, 'as', repeat('a',1000), 'want', 1810890752, NULL, 'v', 'just');

SELECT DISTINCT table1 . pk AS field1 FROM  view_ts5 AS table1  LEFT  JOIN ts6 AS table2 ON  table1 . col_varchar_10_latin1_key =  table2 . id WHERE ( ( table2 . pk > table1 . col_int_key AND table1 . pk NOT BETWEEN 3 AND ( 3 + 3 ) ) AND table2 . pk <> 6 ) GROUP BY table1 . pk;

DROP TABLE ts5;
DROP TABLE ts6;
DROP VIEW view_ts5;

SET @@sql_mode = @old_sql_mode;

SET sql_mode = default;
SET GLOBAL innodb_large_prefix=default;

# --echo #
# --echo # Bug#20262196 ASSERTION FAILED: !IMPLICIT_GROUPING || TMP_TABLE_PARAM.SUM_FUNC_COUNT
# --echo #

CREATE TABLE t8(a INT, b INT) ENGINE=INNODB;
INSERT INTO t8 VALUES (1,2), (3,4);

SELECT   EXISTS   (     SELECT 1     FROM (SELECT a FROM t8) t_inner     GROUP BY t_inner.a     ORDER BY MIN(t_outer.b)   ) FROM t8 t_outer;

DROP TABLE t8;

# --echo #
# --echo # Bug#20210742 GROUP BY ON MERGE VIEW WITH ORDER BY DOES NOT WORK WITH ONLY_FULL_GROUP_BY
# --echo #

CREATE TABLE ts1(a CHAR(1), n CHAR(1), d CHAR(1));

CREATE OR REPLACE ALGORITHM = MERGE VIEW v1 AS  SELECT * FROM ts1 WHERE a = 'AUS' ORDER BY n;

SELECT d, COUNT(*) FROM v1 GROUP BY d;

DROP TABLE ts1;
DROP VIEW v1;

# --echo #
# --echo # Bug#20819199 ASSERTION FAILED IN TEST_IF_SKIP_SORT_ORDER
# --echo #

CREATE TABLE t0 ( a INT );
INSERT INTO t0 VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10);

CREATE TABLE t8 (   pk INT NOT NULL AUTO_INCREMENT,   a INT,   b INT,   PRIMARY KEY (pk),   KEY idx1 (a),   KEY idx2 (b, a),   KEY idx3 (a, b) ) ENGINE = InnoDB;

INSERT INTO t8 (a, b) SELECT t01.a, t02.a FROM t0 t01, t0 t02;

ANALYZE TABLE t8;

# -- let $query= SELECT DISTINCT a, MAX(b) FROM t1 WHERE a >= 0 GROUP BY a,a;

# -- eval # -- explain $query;
# -- eval $query;
SELECT DISTINCT a, MAX(b) FROM t8 WHERE a >= 0 GROUP BY a,a;

DROP TABLE t0;
DROP TABLE t8;

# --echo # Bug#21753180: handle_fatal_signal (sig=11) in my_strtod_int

CREATE TABLE t0(  a INTEGER,  b BLOB(1),  c BLOB(1),  PRIMARY KEY(a,b(1)),  UNIQUE KEY (a,c(1)) );

INSERT INTO t0 VALUES(1,2,1),(2,4,1);

# -- let $query= SELECT a, (SELECT SUM(a + c) FROM (SELECT b as c FROM t0) AS v1) FROM t0;

# -- eval # -- explain $query;

# -- eval $query;
SELECT a, (SELECT SUM(a + c) FROM (SELECT b as c FROM t0) AS v1) FROM t0;

DROP TABLE t0;

# --echo #
# --echo # Bug#21761044 CONDITIONAL JUMP AT TEST_IF_ORDER_BY_KEY IN SQL_OPTIMIZER.CC
# --echo #
# --echo # Used to give ASAN error on the SELECT: addressing beyond allocated memory
# --echo #

CREATE TABLE t1 (id int,  i int, c varchar(1),                  PRIMARY KEY (id, i), KEY c_key(c)) ENGINE=InnoDB;

SELECT c, i, id FROM t1 WHERE (t1.id = 1)  GROUP BY c, i, id;

DROP TABLE t1;

# --echo #
# --echo # Bug#22132822 CRASH IN GROUP_CHECK::IS_FD_ON_SOURCE
# --echo #

CREATE TABLE t8 (   a INT GENERATED ALWAYS AS (1) VIRTUAL,   b INT GENERATED ALWAYS AS (a) VIRTUAL,   c INT GENERATED ALWAYS AS (1) VIRTUAL );

##--error ER_WRONG_FIELD_WITH_GROUP
SELECT a.b FROM t8 AS a RIGHT JOIN t8 AS b ON 1 INNER JOIN t8 AS c ON 1 WHERE b.b = c.b GROUP BY c.c;

DROP TABLE t8;

# --echo #
# --echo # Bug #22186926 CONVERT_CONSTANT_ITEM(THD*, ITEM_FIELD*, ITEM**): ASSERTION `!RESULT' FAILED.
# --echo #

CREATE TABLE t1 (   id INTEGER NOT NULL,   f2 DATETIME NOT NULL,   f3 VARCHAR(1) NOT NULL,   KEY (f3) );

INSERT INTO t1(id, f2, f3) VALUES (5, '2001-07-25 08:40:24.058646', 'j'), (2, '1900-01-01 00:00:00', 's'), (4, '2001-01-20 12:47:23.022022', 'x');


CREATE TABLE ts5 (id VARCHAR(1) NOT NULL);

FLUSH TABLES;

#--explain SELECT MIN(t1.f3 ) FROM t1 WHERE t1.f3 IN (SELECT ts5.id FROM ts5 WHERE NOT t1.f2 IS NOT NULL) AND t1.id IS NULL OR   NOT t1 . f3 < 'q';
SELECT MIN(t1.f3 ) FROM t1 WHERE t1.f3 IN (SELECT ts5.id FROM ts5 WHERE NOT t1.f2 IS NOT NULL) AND t1.id IS NULL OR   NOT t1 . f3 < 'q';


DROP TABLE t1;
DROP TABLE ts5;

# --echo #
# --echo # Bug#22275357 ORDER BY DOES NOT WORK CORRECTLY WITH GROUPED AVG()
# --echo #              VALUES EXTRACTED FROM JSON
# --echo #

# The bug was only seen when grouping on a BLOB-based column type
# (such as TEXT and JSON), and using an aggregate function based on
# Item_sum_num_field class (AVG, VAR_*, STDEV_*), and the grouping
# operation used a temporary table.

CREATE TABLE t1(txt TEXT, id INT);
INSERT INTO t1 VALUES ('a', 2), ('b', 8), ('b', 0), ('c', 2);
SELECT txt, AVG(id) a FROM t1 GROUP BY txt ORDER BY a, txt;
SELECT txt, VAR_POP(id) v FROM t1 GROUP BY txt ORDER BY v, txt;
SELECT txt, STDDEV_POP(id) s FROM t1 GROUP BY txt ORDER BY s, txt;
# SQL_BUFFER_RESULT forces the use of a temporary table in the
# grouping operation, in case that strategy is not chosen in the
# queries above.
SELECT SQL_BUFFER_RESULT txt, AVG(id) a FROM t1 GROUP BY txt ORDER BY a, txt;
SELECT SQL_BUFFER_RESULT txt, VAR_POP(id) v FROM t1 GROUP BY txt ORDER BY v, txt;
SELECT SQL_BUFFER_RESULT txt, STDDEV_POP(id) s FROM t1 GROUP BY txt ORDER BY s, txt;
DROP TABLE t1;
