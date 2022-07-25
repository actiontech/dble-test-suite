#
# Test file for WL#1724 (Min/Max Optimization for Queries with Group By Clause).
# The queries in this file test query execution via QUICK_GROUP_MIN_MAX_SELECT
# that depends on InnoDB
#

#--source include/have_innodb.inc

#--disable_warnings
drop view if exists v1;
drop table if exists ts1;
drop table if exists ts7;
#--enable_warnings

#
# Bug #12672: primary key implcitly included in every innodb index
#

#--disable_warnings
create table ts7 (   pk_col int auto_increment primary key, a1 char(64), a2 char(64), b char(16), c char(16) not null, d char(16), dummy char(64) default ' ' ) engine=innodb;
#--enable_warnings

insert into ts7 (a1, a2, b, c, d) values ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4'), ('d','a','a','a411','xy1'),('d','a','a','b411','xy2'),('d','a','a','c411','xy3'),('d','a','a','d411','xy4'), ('d','a','b','e412','xy1'),('d','a','b','f412','xy2'),('d','a','b','g412','xy3'),('d','a','b','h412','xy4'), ('d','b','a','i421','xy1'),('d','b','a','j421','xy2'),('d','b','a','k421','xy3'),('d','b','a','l421','xy4'), ('d','b','b','m422','xy1'),('d','b','b','n422','xy2'),('d','b','b','o422','xy3'),('d','b','b','p422','xy4'), ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4'), ('d','a','a','a411','xy1'),('d','a','a','b411','xy2'),('d','a','a','c411','xy3'),('d','a','a','d411','xy4'), ('d','a','b','e412','xy1'),('d','a','b','f412','xy2'),('d','a','b','g412','xy3'),('d','a','b','h412','xy4'), ('d','b','a','i421','xy1'),('d','b','a','j421','xy2'),('d','b','a','k421','xy3'),('d','b','a','l421','xy4'), ('d','b','b','m422','xy1'),('d','b','b','n422','xy2'),('d','b','b','o422','xy3'),('d','b','b','p422','xy4');

create index idx12672_0 on ts7 (a1);
create index idx12672_1 on ts7 (a1,a2,b,c);
create index idx12672_2 on ts7 (a1,a2,b);
#-- #--ANALYZE table ts7;

select distinct a1 from ts7 where pk_col not in (1,2,3,4);

drop table ts7;


#
# Bug #6142: a problem with the empty innodb table
#

#--disable_warnings
create table ts1 (   a varchar(30), b varchar(30), primary key(a), key(b) ) engine=innodb;
#--enable_warnings
select distinct a from ts1;
drop table ts1;

#
# Bug #9798: group by with rollup
#

#--disable_warnings
create table t0(a int, key(a)) engine=innodb;
#--enable_warnings
insert into t0 values(1);
select a, count(a) from t0 group by a with rollup;
drop table t0;


#
# Bug #13293 Wrongly used index results in endless loop.
#
create table t1 (id int, f2 char(1), primary key(id,f2)) engine=innodb stats_persistent=0;
insert into t1 values ( 1,"e"),(2,"a"),( 3,"c"),(4,"d");
alter table t1 drop primary key, add primary key (f2, id);
#--explain select distinct id a, id b from t1;
select distinct id a, id b from t1;
#--explain select distinct id, f2 from t1;
select distinct id, f2 from t1;
drop table t1;


#
# Bug #36632: Select distinct from a simple view on an InnoDB table
#             returns incorrect results
#
create table t1(id int primary key) engine=innodb;
create view v1 as select id from t1 where id < 20;

insert into t1 values (1), (2), (3), (4);
select distinct id from v1;

insert into t1 values (5), (6), (7);
select distinct id from v1;

drop view v1;
drop table t1;

#--echo End of 5.1 tests

#--echo #
#--echo # Bug#12540545 61101: ASSERTION FAILURE IN THREAD 1256741184 IN
#--echo # FILE /BUILDDIR/BUILD/BUILD/MYSQ
#--echo #

CREATE TABLE ts1 (a CHAR(1), b CHAR(1), PRIMARY KEY (a,b)) ENGINE=InnoDB;
INSERT INTO ts1 VALUES ('a', 'b'), ('c', 'd');
#--EXPLAIN SELECT COUNT(DISTINCT a) FROM ts1 WHERE b = 'b';
SELECT COUNT(DISTINCT a) FROM ts1 WHERE b = 'b';
DROP TABLE ts1;

CREATE TABLE ts1 (a CHAR(1) NOT NULL, b CHAR(1) NOT NULL, UNIQUE KEY (a,b)) ENGINE=InnoDB;
INSERT INTO ts1 VALUES ('a', 'b'), ('c', 'd');
#--EXPLAIN SELECT COUNT(DISTINCT a) FROM ts1 WHERE b = 'b';
SELECT COUNT(DISTINCT a) FROM ts1 WHERE b = 'b';
DROP TABLE ts1;

#--echo End of 5.5 tests

#--echo #
#--echo # Bug#17909656 - WRONG RESULTS FOR A SIMPLE QUERY WITH GROUP BY
#--echo #

CREATE TABLE t3 (   id INTEGER NOT NULL );

INSERT INTO t3 VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20),(21),(22),(23),(24),(25),(26),(27),(28),(29),(30);

CREATE TABLE t1 (   c1 CHAR(1) NOT NULL,   id INTEGER NOT NULL,   i2 INTEGER NOT NULL,   UNIQUE KEY k1 (c1,i2) ) ENGINE=InnoDB;

INSERT INTO t1 SELECT 'A',id,id FROM t3;
INSERT INTO t1 SELECT 'B',id,id FROM t3;
INSERT INTO t1 SELECT 'C',id,id FROM t3;
INSERT INTO t1 SELECT 'D',id,id FROM t3;
INSERT INTO t1 SELECT 'E',id,id FROM t3;
INSERT INTO t1 SELECT 'F',id,id FROM t3;
                 
CREATE TABLE t2 (   c1 CHAR(1) NOT NULL,   id INTEGER NOT NULL,   i2 INTEGER NOT NULL,   UNIQUE KEY k2 (c1,id,i2) ) ENGINE=InnoDB;

INSERT INTO t2 SELECT 'A',id,id FROM t3;
INSERT INTO t2 SELECT 'B',id,id FROM t3;
INSERT INTO t2 SELECT 'C',id,id FROM t3;
INSERT INTO t2 SELECT 'D',id,id FROM t3;
INSERT INTO t2 SELECT 'E',id,id FROM t3;
INSERT INTO t2 SELECT 'F',id,id FROM t3;

#-- disable_result_log
#--#--ANALYZE TABLE t1;
#--#--ANALYZE TABLE t2;
#-- enable_result_log

#--let $DEFAULT_TRACE_MEM_SIZE=1048576; # 1MB
#--eval set optimizer_trace_max_mem_size=$DEFAULT_TRACE_MEM_SIZE;
set optimizer_trace_max_mem_size=1048576;
set @@session.optimizer_trace='enabled=on';
set end_markers_in_json=on;
#--let $show_method= SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, max(i2) FROM t1 WHERE (c1 = 'C' AND i2 = 17) OR ( c1 = 'F') GROUP BY c1;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, max(i2) FROM t1 WHERE (c1 = 'C' AND i2 = 17) OR ( c1 = 'F') GROUP BY c1;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, max(i2) FROM t1 WHERE (c1 = 'C' OR ( c1 = 'F' AND i2 = 17)) GROUP BY c1;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, max(i2) FROM t1 WHERE (c1 = 'C' OR ( c1 = 'F' AND i2 = 17)) GROUP BY c1;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, max(i2) FROM t1 WHERE (c1 = 'C' OR c1 = 'F' ) AND ( i2 = 17 ) GROUP BY c1;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, max(i2) FROM t1 WHERE (c1 = 'C' OR c1 = 'F' ) AND ( i2 = 17 ) GROUP BY c1;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, max(i2) FROM t1 WHERE ((c1 = 'C' AND (i2 = 40 OR i2 = 30)) OR ( c1 = 'F' AND (i2 = 40 ))) GROUP BY c1;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, max(i2) FROM t1 WHERE ((c1 = 'C' AND (i2 = 40 OR i2 = 30)) OR ( c1 = 'F' AND (i2 = 40 ))) GROUP BY c1;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, id, max(i2) FROM t2 WHERE (c1 = 'C' OR ( c1 = 'F' AND id < 35)) AND ( i2 = 17 ) GROUP BY c1,id;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, id, max(i2) FROM t2 WHERE (c1 = 'C' OR ( c1 = 'F' AND id < 35)) AND ( i2 = 17 ) GROUP BY c1,id;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, id, max(i2) FROM t2 WHERE (((c1 = 'C' AND id < 40) OR ( c1 = 'F' AND id < 35)) AND ( i2 = 17 )) GROUP BY c1,id;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, id, max(i2) FROM t2 WHERE (((c1 = 'C' AND id < 40) OR ( c1 = 'F' AND id < 35)) AND ( i2 = 17 )) GROUP BY c1,id;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--let query= SELECT c1, id, max(i2) FROM t2 WHERE ((c1 = 'C' AND id < 40) OR ( c1 = 'F' AND id < 35) OR ( i2 = 17 )) GROUP BY c1,id;
#--replace_column 10 ROWS
#--eval EXPLAIN $query;
#--eval $query;
#--eval $show_method;
SELECT c1, id, max(i2) FROM t2 WHERE ((c1 = 'C' AND id < 40) OR ( c1 = 'F' AND id < 35) OR ( i2 = 17 )) GROUP BY c1,id;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SET optimizer_trace_max_mem_size=DEFAULT;
SET optimizer_trace=DEFAULT;
SET end_markers_in_json=DEFAULT;

DROP TABLE t3;
DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # Bug #21749123: SELECT DISTINCT, WRONG RESULTS COMBINED WITH
#--echo #                USE_INDEX_EXTENSIONS=OFF
#--echo #

CREATE TABLE ts7 (   pk_col INT AUTO_INCREMENT PRIMARY KEY,   a1 CHAR(64),   KEY a1_idx (a1) ) ENGINE=INNODB;
INSERT INTO ts7 (a1) VALUES ('a'),('a'),('a'),('a'), ('a');

CREATE TABLE ts8 (   pk_col1 INT NOT NULL,   pk_col2 INT NOT NULL,   a1 CHAR(64),   a2 CHAR(64),   PRIMARY KEY(pk_col1, pk_col2),   KEY a1_idx (a1),   KEY a1_a2_idx (a1, a2) ) ENGINE=INNODB;
INSERT INTO ts8 (pk_col1, pk_col2, a1, a2) VALUES (1,1,'a','b'),(1,2,'a','b'), (1,3,'a','c'),(1,4,'a','c'),                                                  (2,1,'a','d');
#--ANALYZE TABLE ts7;
#--ANALYZE TABLE ts8;

#Doesn't use loose index scan irrespective of index extensions.
#--let query1= SELECT DISTINCT a1 FROM ts7 WHERE (pk_col = 2 OR pk_col = 22) AND a1 = 'a';

#Doesn't use loose index scan when index extensions is off.
#--let query2= SELECT COUNT(DISTINCT a1) FROM ts7 GROUP BY a1,pk_col;

#Doesn't use loose index scan when index extensions is off.
#--let query3= SELECT COUNT(DISTINCT a1) FROM ts8 GROUP BY a1,pk_col1;

#Uses loose index scan irrespective of index extensions.
#--let query4= SELECT COUNT(DISTINCT a1) FROM ts8 GROUP BY a1,a2;

#--eval EXPLAIN $query1;
#--eval $query1;
#--eval EXPLAIN $query2;
#--eval $query2;
#--eval EXPLAIN $query3;
#--eval $query3;
#--eval EXPLAIN $query4;
#--eval $query4;
SELECT DISTINCT a1 FROM ts7 WHERE (pk_col = 2 OR pk_col = 22) AND a1 = 'a';
SELECT COUNT(DISTINCT a1) FROM ts7 GROUP BY a1,pk_col;
SELECT COUNT(DISTINCT a1) FROM ts8 GROUP BY a1,pk_col1;
SELECT COUNT(DISTINCT a1) FROM ts8 GROUP BY a1,a2;

SET @optimizer_switch_save=@@optimizer_switch;
SET @@optimizer_switch= "use_index_extensions=off";

#--eval EXPLAIN $query1;
#--eval $query1;
#--eval EXPLAIN $query2;
#--eval $query2;
#--eval EXPLAIN $query3;
#--eval $query3;
#--eval EXPLAIN $query4;
#--eval $query4;
SELECT DISTINCT a1 FROM ts7 WHERE (pk_col = 2 OR pk_col = 22) AND a1 = 'a';
SELECT COUNT(DISTINCT a1) FROM ts7 GROUP BY a1,pk_col;
SELECT COUNT(DISTINCT a1) FROM ts8 GROUP BY a1,pk_col1;
SELECT COUNT(DISTINCT a1) FROM ts8 GROUP BY a1,a2;

SET @@optimizer_switch= @optimizer_switch_save;
DROP TABLE ts7;
DROP TABLE ts8;

#--echo #
#--echo # Bug #24671968: WHEN THE OPTIMISER IS USING INDEX FOR GROUP-BY IT OFTEN
#--echo #                OFTEN GIVES WRONG RESULTS
#--echo #

CREATE TABLE t1 ( id int NOT NULL, c1 int NOT NULL, c2 int, PRIMARY KEY(id), INDEX c1_c2_idx(c1, c2));

INSERT INTO t1 (id, c1, c2) VALUES (1,1,1), (2,2,2), (10,10,1), (11,10,8),(12,10,1), (13,10,2);
#--ANALYZE TABLE t1;

# Query similar to the one mentioned in the bug page. Incorrectly chooses
# loose index scan.
#--let query1= SELECT DISTINCT c1 FROM t1 WHERE EXISTS (SELECT * FROM DUAL WHERE (c2 = 2));

# IN subquery. Incorrectly chooses loose index scan.
#--let query2= SELECT DISTINCT c1 FROM t1 WHERE 1 IN (2, (SELECT 1 FROM DUAL  WHERE (c2 = 2)), 3);

# Similar to above queries but without subquery.
#--let query3= SELECT DISTINCT c1 FROM t1 WHERE c2 = 2;

# Same as query1 with IGNORE INDEX. So this will not choose loose index scan.
#--let query4= SELECT DISTINCT c1 FROM t1 IGNORE INDEX (c1_c2_idx) WHERE EXISTS (SELECT * FROM DUAL  WHERE (c2 = 2));

# Same as query2 with IGNORE INDEX. So this will not choose loose index scan.
#--let query5= SELECT DISTINCT c1 FROM t1 IGNORE INDEX (c1_c2_idx) WHERE 1 IN (2, (SELECT 1  FROM DUAL  WHERE (c2 = 2)), 3);

#--eval EXPLAIN $query1;
#--eval EXPLAIN $query2;
#--eval EXPLAIN $query3;
#--eval EXPLAIN $query4;
#--eval EXPLAIN $query5;
SELECT DISTINCT c1 FROM t1 WHERE EXISTS (SELECT * FROM DUAL WHERE (c2 = 2));
SELECT DISTINCT c1 FROM t1 WHERE 1 IN (2, (SELECT 1 FROM DUAL  WHERE (c2 = 2)), 3);
SELECT DISTINCT c1 FROM t1 WHERE c2 = 2;
SELECT DISTINCT c1 FROM t1 IGNORE INDEX (c1_c2_idx) WHERE EXISTS (SELECT * FROM DUAL  WHERE (c2 = 2));
SELECT DISTINCT c1 FROM t1 IGNORE INDEX (c1_c2_idx) WHERE 1 IN (2, (SELECT 1  FROM DUAL  WHERE (c2 = 2)), 3);

# Looking for the tag in optimizer trace: "dependent_subquery_in_where".
SET optimizer_trace="enabled=on";

#--eval $query1;
SELECT DISTINCT c1 FROM t1 WHERE EXISTS (SELECT * FROM DUAL WHERE (c2 = 2));
SELECT TRACE INTO @trace FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;
SELECT @trace RLIKE "keypart_reference_from_where_clause";

SET optimizer_trace="enabled=off";

#--eval $query2;
#--eval $query3;
#--eval $query4;
#--eval $query5;
SELECT DISTINCT c1 FROM t1 WHERE 1 IN (2, (SELECT 1 FROM DUAL  WHERE (c2 = 2)), 3);
SELECT DISTINCT c1 FROM t1 WHERE c2 = 2;
SELECT DISTINCT c1 FROM t1 IGNORE INDEX (c1_c2_idx) WHERE EXISTS (SELECT * FROM DUAL  WHERE (c2 = 2));
SELECT DISTINCT c1 FROM t1 IGNORE INDEX (c1_c2_idx) WHERE 1 IN (2, (SELECT 1  FROM DUAL  WHERE (c2 = 2)), 3);

DROP TABLE t1;

#--echo #
#--echo # Bug #26532061: SELECT DISTINCT WITH SECONDARY KEY FOR
#--echo #                'USING INDEX FOR GROUP-BY' BAD RESULTS
#--echo #

CREATE TABLE t1(   id INT NOT NULL,   c1 CHAR(2),   c2 INT,   PRIMARY KEY(id),   UNIQUE KEY ukey(c1, c2) );

INSERT INTO t1(id, c1, c2) VALUES (1,1,1),(2,2,2),(3,3,3),(4,5,4);
SET @a:=5;
#--disable_warnings
INSERT IGNORE INTo t1(id, c1, c2)   SELECT (@a:=@a+1),@a,@a FROM t1, t1 t2,t1 t3, t1 t4;
#--enable_warnings
#--ANALYZE TABLE t1;

SELECT * FROM t1 WHERE id = 1 OR id = 231;

#query shouldn't use loose index scan
#--let query1= SELECT DISTINCT c1 FROM t1 FORCE INDEX(ukey) WHERE id IN (1,231) and c1 IS NOT NULL;

#--let query2= SELECT DISTINCT c1 FROM t1 IGNORE INDEX(ukey) WHERE id IN (1,231) and c1 IS NOT NULL;

#--eval EXPLAIN $query1;
#--eval EXPLAIN $query2;

#--eval $query1;
#--eval $query2;
SELECT DISTINCT c1 FROM t1 FORCE INDEX(ukey) WHERE id IN (1,231) and c1 IS NOT NULL;
SELECT DISTINCT c1 FROM t1 IGNORE INDEX(ukey) WHERE id IN (1,231) and c1 IS NOT NULL;

DROP TABLE t1;

#--echo #
#--echo # Bug #25989915: LOOSE INDEX SCANS RETURNING WRONG RESULT
#--echo #

CREATE TABLE t1 (   pk INT NOT NULL AUTO_INCREMENT,   c1 varchar(100) DEFAULT NULL,   id INT NOT NULL,   PRIMARY KEY (pk),   UNIQUE KEY ukey (id,c1) );

INSERT INTO t1(pk, id) VALUES (100, 0), (101, 0), (102, 0), (103, 0);
#--ANALYZE TABLE t1;

#--let query1= SELECT COUNT(DISTINCT(id)) FROM t1 WHERE pk IN (102, 101);
#--let query2= SELECT COUNT(DISTINCT(id)) FROM t1 WHERE pk IN (102, 100);

#--eval EXPLAIN $query1;
#--eval EXPLAIN $query2;

#--eval $query1;
#--eval $query2;
SELECT COUNT(DISTINCT(id)) FROM t1 WHERE pk IN (102, 101);
SELECT COUNT(DISTINCT(id)) FROM t1 WHERE pk IN (102, 100);

DROP TABLE t1;
