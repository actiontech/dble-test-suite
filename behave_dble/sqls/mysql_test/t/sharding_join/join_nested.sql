# The include statement below is a temp one for tests that are yet to
#be ported to run with InnoDB,
#but needs to be kept for tests that would need MyISAM in future.
##--source include/force_myisam_default.inc


##--disable_warnings
DROP TABLE IF EXISTS t0;
DROP TABLE IF EXISTS t1;
DROP TABLE IF EXISTS t2;
DROP TABLE IF EXISTS t3;
DROP TABLE IF EXISTS t4;
DROP TABLE IF EXISTS t5;
DROP TABLE IF EXISTS t6;
DROP TABLE IF EXISTS t7;
DROP TABLE IF EXISTS t8;
DROP TABLE IF EXISTS t9;
##--enable_warnings

CREATE TABLE t0 (id int, b int, c int);
CREATE TABLE t1 (id int, b int, c int);
CREATE TABLE t2 (id int, b int, c int);
CREATE TABLE t3 (id int, b int, c int);
CREATE TABLE t4 (id int, b int, c int);
CREATE TABLE t5 (id int, b int, c int);
CREATE TABLE t6 (id int, b int, c int);
CREATE TABLE t7 (id int, b int, c int);
CREATE TABLE t8 (id int, b int, c int);
CREATE TABLE t9 (id int, b int, c int);

INSERT INTO t0 VALUES (1,1,0), (1,2,0), (2,2,0);
INSERT INTO t1 VALUES (1,3,0), (2,2,0), (3,2,0);
INSERT INTO t2 VALUES (3,3,0), (4,2,0), (5,3,0);
INSERT INTO t3 VALUES (1,2,0), (2,2,0);
INSERT INTO t4 VALUES (3,2,0), (4,2,0);
INSERT INTO t5 VALUES (3,1,0), (2,2,0), (3,3,0);
INSERT INTO t6 VALUES (3,2,0), (6,2,0), (6,1,0);
INSERT INTO t7 VALUES (1,1,0), (2,2,0);
INSERT INTO t8 VALUES (0,2,0), (1,2,0);
INSERT INTO t9 VALUES (1,1,0), (1,2,0), (3,3,0);

CREATE TABLE t34 (a3 int, b3 int, c3 int, a4 int, b4 int, c4 int);
# -- INSERT INTO t34 SELECT t3.*, t4.* FROM t3 CROSS JOIN t4;
INSERT INTO t34 values (1 ,2 ,0 ,3 ,2 ,0),(2 ,2 ,0 ,3 ,2 ,0 ),(1 ,2 ,0 ,4 ,2 ,0 ),(2 ,2 ,0 ,4 ,2 ,0);

CREATE TABLE t345 (a3 int, b3 int, c3 int, a4 int, b4 int, c4 int,a5 int, b5 int, c5 int);
# -- INSERT INTO t345 SELECT t3.*, t4.*, t5.* FROM t3 CROSS JOIN t4 CROSS JOIN t5;
insert into t345 values ( 1 , 2 , 0 , 3 , 2 , 0 , 3 , 1 , 0 ), ( 2 , 2 , 0 , 3 , 2 , 0 , 3 , 1 , 0 ), ( 1 , 2 , 0 , 4 , 2 , 0 , 3 , 1 , 0 ), ( 2 , 2 , 0 , 4 , 2 , 0 , 3 , 1 , 0 ), ( 1 , 2 , 0 , 3 , 2 , 0 , 2 , 2 , 0 ), ( 2 , 2 , 0 , 3 , 2 , 0 , 2 , 2 , 0 ), ( 1 , 2 , 0 , 4 , 2 , 0 , 2 , 2 , 0 ), ( 2 , 2 , 0 , 4 , 2 , 0 , 2 , 2 , 0 ), ( 1 , 2 , 0 , 3 , 2 , 0 , 3 , 3 , 0 ), ( 2 , 2 , 0 , 3 , 2 , 0 , 3 , 3 , 0 ), ( 1 , 2 , 0 , 4 , 2 , 0 , 3 , 3 , 0 ), ( 2 , 2 , 0 , 4 , 2 , 0 , 3 , 3 , 0 );

CREATE TABLE t67 (a6 int, b6 int, c6 int, a7 int, b7 int, c7 int);
# -- INSERT INTO t67 SELECT t6.*, t7.* FROM t6 CROSS JOIN t7;
insert into t67 values (3 ,2 ,0 ,1 ,1 ,0), (3 ,2 ,0 ,2 ,2 ,0), (6 ,2 ,0 ,1 ,1 ,0), (6 ,2 ,0 ,2 ,2 ,0), (6 ,1 ,0 ,1 ,1 ,0), (6 ,1 ,0 ,2 ,2 ,0);

SELECT t2.id,t2.b   FROM t2;

SELECT t3.id,t3.b   FROM t3;
SELECT t4.id,t4.b   FROM t4;

SELECT t3.id,t3.b,t4.id,t4.b FROM t3,t4;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b FROM t2 LEFT JOIN (t3, t4) ON t2.b=t4.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4   FROM t2        LEFT JOIN t34        ON t2.b=t34.b4;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t3.id=1 AND t2.b=t4.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4   FROM t2        LEFT JOIN t34        ON t34.a3=1 AND t2.b=t34.b4;

# -- EXPLAIN EXTENDED  SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t2.b=t4.b     WHERE t3.id=1 OR t3.c IS NULL;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t2.b=t4.b     WHERE t3.id=1 OR t3.c IS NULL;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4   FROM t2        LEFT JOIN t34        ON t2.b=t34.b4     WHERE t34.a3=1 OR t34.c3 IS NULL;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t2.b=t4.b     WHERE t3.id>1 OR t3.c IS NULL;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4   FROM t2        LEFT JOIN t34        ON t2.b=t34.b4     WHERE t34.a3>1 OR t34.c3 IS NULL;

SELECT t5.id,t5.b   FROM t5;

SELECT t3.id,t3.b,t4.id,t4.b,t5.id,t5.b   FROM t3,t4,t5;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,t5.id,t5.b   FROM t2        LEFT JOIN                     (t3, t4, t5)        ON t2.b=t4.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t345.a3,t345.b3,t345.a4,t345.b4,t345.a5,t345.b5   FROM t2   LEFT JOIN t345   ON t2.b=t345.b4;

# -- EXPLAIN EXTENDED  SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,t5.id,t5.b   FROM t2   LEFT JOIN  (t3, t4, t5)        ON t2.b=t4.b     WHERE t3.id>1 OR t3.c IS NULL;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,t5.id,t5.b   FROM t2   LEFT JOIN   (t3, t4, t5)        ON t2.b=t4.b     WHERE t3.id>1 OR t3.c IS NULL;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t345.a3,t345.b3,t345.a4,t345.b4,t345.a5,t345.b5   FROM t2        LEFT JOIN t345        ON t2.b=t345.b4     WHERE t345.a3>1 OR t345.c3 IS NULL;

# -- EXPLAIN EXTENDED  SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,t5.id,t5.b   FROM t2        LEFT JOIN                     (t3, t4, t5)        ON t2.b=t4.b     WHERE (t3.id>1 OR t3.c IS NULL) AND           (t5.id<3 OR t5.c IS NULL);

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,t5.id,t5.b   FROM t2        LEFT JOIN                     (t3, t4, t5)        ON t2.b=t4.b     WHERE (t3.id>1 OR t3.c IS NULL) AND           (t5.id<3 OR t5.c IS NULL);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t345.a3,t345.b3,t345.a4,t345.b4,t345.a5,t345.b5   FROM t2        LEFT JOIN t345        ON t2.b=t345.b4     WHERE (t345.a3>1 OR t345.c3 IS NULL) AND           (t345.a5<3 OR t345.c5 IS NULL);

SELECT t6.id,t6.b   FROM t6;

SELECT t7.id,t7.b   FROM t7;

SELECT t6.id,t6.b,t7.id,t7.b   FROM t6,t7;

SELECT t8.id,t8.b   FROM t8;

# -- EXPLAIN EXTENDED  SELECT t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM (t6, t7)        LEFT JOIN        t8        ON t7.b=t8.b AND t6.b < 10;

#--sorted_result
SELECT t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM (t6, t7)        LEFT JOIN        t8        ON t7.b=t8.b AND t6.b < 10;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t67        LEFT JOIN        t8        ON t67.b7=t8.b AND t67.b6 < 10;

SELECT t5.id,t5.b   FROM t5;

#--sorted_result
SELECT t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t5        LEFT JOIN        (          (t6, t7)          LEFT JOIN          t8          ON t7.b=t8.b AND t6.b < 10        )        ON t6.b >= 2 AND t5.b=t7.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t5        LEFT JOIN        (          t67          LEFT JOIN          t8          ON t67.b7=t8.b AND t67.b6 < 10        )        ON t67.b6 >= 2 AND t5.b=t67.b7;

#--sorted_result
SELECT t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t5        LEFT JOIN        (          (t6, t7)          LEFT JOIN          t8          ON t7.b=t8.b AND t6.b < 10        )        ON t6.b >= 2 AND t5.b=t7.b AND           (t8.id < 1 OR t8.c IS NULL);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t5        LEFT JOIN        (          t67          LEFT JOIN          t8          ON t67.b7=t8.b AND t67.b6 < 10        )        ON t67.b6 >= 2 AND t5.b=t67.b7 AND           (t8.id < 1 OR t8.c IS NULL);

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t3.id=1 AND t2.b=t4.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4   FROM t2        LEFT JOIN t34        ON t34.a3=1 AND t2.b=t34.b4;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t3.id=1 AND t2.b=t4.b,        t5        LEFT JOIN        (          (t6, t7)          LEFT JOIN          t8          ON t7.b=t8.b AND t6.b < 10        )        ON t6.b >= 2 AND t5.b=t7.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t2        LEFT JOIN t34        ON t34.a3=1 AND t2.b=t34.b4        CROSS JOIN t5        LEFT JOIN        (          t67          LEFT JOIN          t8          ON t67.b7=t8.b AND t67.b6 < 10        )        ON t67.b6 >= 2 AND t5.b=t67.b7;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t3.id=1 AND t2.b=t4.b,        t5        LEFT JOIN        (          (t6, t7)          LEFT JOIN          t8          ON t7.b=t8.b AND t6.b < 10        )        ON t6.b >= 2 AND t5.b=t7.b     WHERE t2.id > 3 AND           (t6.id < 6 OR t6.c IS NULL);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t2        LEFT JOIN t34        ON t34.a3=1 AND t2.b=t34.b4        CROSS JOIN t5        LEFT JOIN        (          t67          LEFT JOIN          t8          ON t67.b7=t8.b AND t67.b6 < 10        )        ON t67.b6 >= 2 AND t5.b=t67.b7     WHERE t2.id > 3 AND           (t67.a6 < 6 OR t67.c6 IS NULL);

SELECT t1.id,t1.b   FROM t1;

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t1        LEFT JOIN                       (          t2          LEFT JOIN t34          ON t34.a3=1 AND t2.b=t34.b4          CROSS JOIN t5          LEFT JOIN          (            t67            LEFT JOIN            t8            ON t67.b7=t8.b AND t67.b6 < 10          )          ON t67.b6 >= 2 AND t5.b=t67.b7        )        ON (t34.b3=2 OR t34.c3 IS NULL) AND (t67.b6=2 OR t67.c6 IS NULL) AND           (t1.b=t5.b OR t34.c3 IS NULL OR t67.c6 IS NULL or t8.c IS NULL) AND           (t1.id <> 2);

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2)     WHERE (t2.id >= 4 OR t2.c IS NULL);
   
#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t1        LEFT JOIN                       (          t2          LEFT JOIN t34          ON t34.a3=1 AND t2.b=t34.b4          CROSS JOIN t5          LEFT JOIN          (            t67            LEFT JOIN            t8            ON t67.b7=t8.b AND t67.b6 < 10          )          ON t67.b6 >= 2 AND t5.b=t67.b7        )        ON (t34.b3=2 OR t34.c3 IS NULL) AND (t67.b6=2 OR t67.c6 IS NULL) AND           (t1.b=t5.b OR t34.c3 IS NULL OR t67.c6 IS NULL or t8.c IS NULL) AND           (t1.id <> 2)     WHERE (t2.id >= 4 OR t2.c IS NULL);
   
SELECT t0.id,t0.b   FROM t0;

# -- EXPLAIN EXTENDED  SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2)     WHERE t0.id=1 AND           t0.b=t1.b AND                    (t2.id >= 4 OR t2.c IS NULL);

#--sorted_result
SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2)     WHERE t0.id=1 AND           t0.b=t1.b AND                    (t2.id >= 4 OR t2.c IS NULL);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b   FROM t0        CROSS JOIN t1        LEFT JOIN                       (          t2          LEFT JOIN t34          ON t34.a3=1 AND t2.b=t34.b4          CROSS JOIN t5          LEFT JOIN          (            t67            LEFT JOIN            t8            ON t67.b7=t8.b AND t67.b6 < 10          )          ON t67.b6 >= 2 AND t5.b=t67.b7        )        ON (t34.b3=2 OR t34.c3 IS NULL) AND (t67.b6=2 OR t67.c6 IS NULL) AND           (t1.b=t5.b OR t34.c3 IS NULL OR t67.c6 IS NULL or t8.c IS NULL) AND           (t1.id <> 2)     WHERE t0.id=1 AND           t0.b=t1.b AND                    (t2.id >= 4 OR t2.c IS NULL);

# -- EXPLAIN EXTENDED  SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

SELECT t9.id,t9.b   FROM t9;

#--sorted_result
SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b,t9.id,t9.b   FROM t0        CROSS JOIN t1        LEFT JOIN                       (          t2          LEFT JOIN t34          ON t34.a3=1 AND t2.b=t34.b4          CROSS JOIN t5          LEFT JOIN          (            t67            LEFT JOIN            t8            ON t67.b7=t8.b AND t67.b6 < 10          )          ON t67.b6 >= 2 AND t5.b=t67.b7        )        ON (t34.b3=2 OR t34.c3 IS NULL) AND (t67.b6=2 OR t67.c6 IS NULL) AND           (t1.b=t5.b OR t34.c3 IS NULL OR t67.c6 IS NULL or t8.c IS NULL) AND           (t1.id <> 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t34.a3 < 5 OR t34.c3 IS NULL) AND            (t34.b3=t34.b4 OR t34.c3 IS NULL OR t34.c4 IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t67.a6 >=4 OR t67.c6 IS NULL) AND            (t67.a7 <= 2 OR t67.c7 IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

SELECT t1.id,t1.b   FROM t1;

SELECT t2.id,t2.b   FROM t2;

SELECT t3.id,t3.b   FROM t3;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b   FROM t2        LEFT JOIN                     t3        ON t2.b=t3.b;

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b   FROM t1, t2        LEFT JOIN                     t3        ON t2.b=t3.b     WHERE t1.id <= 2;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b   FROM t1        CROSS JOIN t2        LEFT JOIN                     t3        ON t2.b=t3.b     WHERE t1.id <= 2;

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b   FROM t1, t3        RIGHT JOIN                     t2        ON t2.b=t3.b     WHERE t1.id <= 2;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b   FROM t1 CROSS JOIN        (          t3          RIGHT JOIN                       t2          ON t2.b=t3.b        )     WHERE t1.id <= 2;

SELECT t3.id,t3.b,t4.id,t4.b   FROM t3,t4;

#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3, t4)        ON t3.id=1 AND t2.b=t4.b;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t2        LEFT JOIN                     (t3 CROSS JOIN t4)        ON t3.id=1 AND t2.b=t4.b;

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1 CROSS JOIN        (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b        )     WHERE t1.id <= 2;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1 CROSS JOIN        (          t2          LEFT JOIN                       (t3 CROSS JOIN t4)          ON t3.id=1 AND t2.b=t4.b        )     WHERE t1.id <= 2;

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1, (t3, t4)        RIGHT JOIN                     t2        ON t3.id=1 AND t2.b=t4.b     WHERE t1.id <= 2;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1 CROSS JOIN        (          (t3 CROSS JOIN t4)          RIGHT JOIN                       t2          ON t3.id=1 AND t2.b=t4.b        )     WHERE t1.id <= 2;

#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1, (t3, t4)        RIGHT JOIN                     t2        ON t3.id=1 AND t2.b=t4.b     WHERE t1.id <= 2;

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1 CROSS JOIN        (          (t3 CROSS JOIN t4)          RIGHT JOIN                       t2          ON t3.id=1 AND t2.b=t4.b        )     WHERE t1.id <= 2;

# -- EXPLAIN EXTENDED  SELECT t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM t1, (t3, t4)        RIGHT JOIN        t2        ON t3.id=1 AND t2.b=t4.b     WHERE t1.id <= 2;  CREATE INDEX idx_b ON t2(b);

# -- EXPLAIN EXTENDED  SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM (t3,t4)        LEFT JOIN                     (t1,t2)        ON t3.id=1 AND t3.b=t2.b AND t2.b=t4.b;

SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM (t3,t4)        LEFT JOIN                     (t1,t2)        ON t3.id=1 AND t3.b=t2.b AND t2.b=t4.b;

#--echo "Standard compliant copy of above query"
SELECT t2.id,t2.b,t3.id,t3.b,t4.id,t4.b   FROM (t3 CROSS JOIN t4)        LEFT JOIN                     (t1 CROSS JOIN t2)        ON t3.id=1 AND t3.b=t2.b AND t2.b=t4.b;

# -- EXPLAIN EXTENDED  SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

CREATE INDEX idx_b ON t4(b);
CREATE INDEX idx_b ON t5(b);

# -- EXPLAIN EXTENDED  SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

CREATE INDEX idx_b ON t8(b);

# -- EXPLAIN EXTENDED  SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

CREATE INDEX idx_b ON t1(b);
CREATE INDEX idx_a ON t0(id);

# -- EXPLAIN EXTENDED  SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

#--sorted_result
SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t3.id,t3.b,t4.id,t4.b,        t5.id,t5.b,t6.id,t6.b,t7.id,t7.b,t8.id,t8.b,t9.id,t9.b   FROM t0,t1        LEFT JOIN                       (          t2          LEFT JOIN                       (t3, t4)          ON t3.id=1 AND t2.b=t4.b,          t5          LEFT JOIN          (            (t6, t7)            LEFT JOIN            t8            ON t7.b=t8.b AND t6.b < 10          )          ON t6.b >= 2 AND t5.b=t7.b        )        ON (t3.b=2 OR t3.c IS NULL) AND (t6.b=2 OR t6.c IS NULL) AND           (t1.b=t5.b OR t3.c IS NULL OR t6.c IS NULL or t8.c IS NULL) AND           (t1.id != 2),        t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t3.id < 5 OR t3.c IS NULL) AND            (t3.b=t4.b OR t3.c IS NULL OR t4.c IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t6.id >=4 OR t6.c IS NULL) AND            (t7.id <= 2 OR t7.c IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

#--echo "Standard compliant copy of above query"
#--sorted_result
SELECT t0.id,t0.b,t1.id,t1.b,t2.id,t2.b,t34.a3,t34.b3,t34.a4,t34.b4,        t5.id,t5.b,t67.a6,t67.b6,t67.a7,t67.b7,t8.id,t8.b,t9.id,t9.b   FROM t0        CROSS JOIN t1        LEFT JOIN                       (          t2          LEFT JOIN                       t34          ON t34.a3=1 AND t2.b=t34.b4          CROSS JOIN t5          LEFT JOIN          (            t67            LEFT JOIN            t8            ON t67.b7=t8.b AND t67.b6 < 10          )          ON t67.b6 >= 2 AND t5.b=t67.b7        )        ON (t34.b3=2 OR t34.c3 IS NULL) AND (t67.b6=2 OR t67.c6 IS NULL) AND           (t1.b=t5.b OR t34.c3 IS NULL OR t67.c6 IS NULL or t8.c IS NULL) AND           (t1.id <> 2)        CROSS JOIN t9      WHERE t0.id=1 AND            t0.b=t1.b AND                     (t2.id >= 4 OR t2.c IS NULL) AND            (t34.a3 < 5 OR t34.c3 IS NULL) AND            (t34.b3=t34.b4 OR t34.c3 IS NULL OR t34.c4 IS NULL) AND            (t5.id >=2 OR t5.c IS NULL) AND            (t67.a6 >=4 OR t67.c6 IS NULL) AND            (t67.a7 <= 2 OR t67.c7 IS NULL) AND            (t8.id < 1 OR t8.c IS NULL) AND            (t8.b=t9.b OR t8.c IS NULL) AND            (t9.id=1);

SELECT t2.id,t2.b   FROM t2;

SELECT t3.id,t3.b   FROM t3;

SELECT t2.id,t2.b,t3.id,t3.b   FROM t2 LEFT JOIN t3 ON t2.b=t3.b     WHERE t2.id = 4 OR (t2.id > 4 AND t3.id IS NULL);

SELECT t2.id,t2.b,t3.id,t3.b   FROM t2 LEFT JOIN (t3) ON t2.b=t3.b     WHERE t2.id = 4 OR (t2.id > 4 AND t3.id IS NULL);

ALTER TABLE t3   CHANGE COLUMN id a1 int,   CHANGE COLUMN c c1 int;

SELECT t2.id,t2.b,t3.a1,t3.b   FROM t2 LEFT JOIN t3 ON t2.b=t3.b     WHERE t2.id = 4 OR (t2.id > 4 AND t3.a1 IS NULL);

SELECT t2.id,t2.b,t3.a1,t3.b   FROM t2 NATURAL LEFT JOIN t3     WHERE t2.id = 4 OR (t2.id > 4 AND t3.a1 IS NULL);

DROP TABLE t0;
DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;
DROP TABLE t6;
DROP TABLE t7;
DROP TABLE t8;
DROP TABLE t9;
DROP TABLE t34;
DROP TABLE t345;
DROP TABLE t67;

CREATE TABLE t1 (id int);
CREATE TABLE t2 (id int);
CREATE TABLE t3 (id int);

INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (2);
INSERT INTO t3 VALUES (2);
INSERT INTO t1 VALUES (2);

#check proper syntax for nested outer joins

#--sorted_result
SELECT * FROM t1 LEFT JOIN (t2 LEFT JOIN t3 ON t2.id=t3.id) ON t1.id=t3.id;

#must be equivalent to:

#--sorted_result
SELECT * FROM t1 LEFT JOIN t2 LEFT JOIN t3 ON t2.id=t3.id ON t1.id=t3.id;

#check that everything is al right when all tables contain not more than 1 row
#(bug #4922)

DELETE FROM t1 WHERE id=2;
SELECT * FROM t1 LEFT JOIN t2 LEFT JOIN t3 ON t2.id=t3.id ON t1.id=t3.id;
DELETE FROM t2;
SELECT * FROM t1 LEFT JOIN t2 LEFT JOIN t3 ON t2.id=t3.id ON t1.id=t3.id;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;

#on expression for a nested outer join does not depend on the outer table
#bug #4976

CREATE TABLE tp2(a int, key (a));
CREATE TABLE tp3(b int, key (b));
CREATE TABLE tp1(c int, key (c));

INSERT INTO tp2 VALUES (NULL), (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19);

INSERT INTO tp3 VALUES (NULL), (0), (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12), (13), (14), (15), (16), (17), (18), (19);

INSERT INTO tp1 VALUES (0), (1), (2), (3), (4), (5);
 
# -- EXPLAIN SELECT a, b, c FROM tp2 LEFT JOIN (tp3, tp1) ON c < 3 and b = c;
SELECT a, b, c FROM tp2 LEFT JOIN (tp3, tp1) ON c < 3 and b = c;
# -- EXPLAIN SELECT a, b, c FROM tp2 LEFT JOIN (tp3, tp1) ON b < 3 and b = c;
SELECT a, b, c FROM tp2 LEFT JOIN (tp3, tp1) ON b < 3 and b = c;

DELETE FROM tp1;
# -- EXPLAIN SELECT a, b, c FROM tp2 LEFT JOIN (tp3, tp1) ON b < 3 and b = c;
SELECT a, b, c FROM tp2 LEFT JOIN (tp3, tp1) ON b < 3 and b = c;

DROP TABLE tp2;
DROP TABLE tp3;
DROP TABLE tp1;

#
# Test for bug #11284: empty table in a nested left join
# 

CREATE TABLE t1 (id int);
CREATE TABLE t2 (id int);
CREATE TABLE t3 (id int);

INSERT INTO t1 VALUES (4), (5);

SELECT * FROM t1 LEFT JOIN t2 ON t1.id=t2.id;
# -- EXPLAIN SELECT * FROM t1 LEFT JOIN t2 ON t1.id=t2.id;

SELECT * FROM t1 LEFT JOIN (t2 LEFT JOIN t3 ON t2.id=t3.id) ON t1.id=t2.id;
# -- EXPLAIN SELECT * FROM t1 LEFT JOIN (t2 LEFT JOIN t3 ON t2.id=t3.id) ON t1.id=t2.id;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;

#
# Bug #12154: creation of temp table for a query with nested outer join
# 

#
# Bug #12154: creation of temp table for a query with nested outer join
#

CREATE TABLE t1 (id int(12) NOT NULL, price varchar(128) NOT NULL);
INSERT INTO t1 VALUES (23, 2340), (26, 9900);

CREATE TABLE t2 (id int(12), name varchar(50), shop char(2));
INSERT INTO t2 VALUES (23, 'as300', 'fr'), (26, 'as600', 'fr');

create table t3 (id int(12) NOT NULL, goodsid int(12) NOT NULL);
INSERT INTO t3 VALUES (3,23), (6,26);

CREATE TABLE t4 (id int(12));
INSERT INTO t4 VALUES (1), (2), (3), (4), (5), (6);

#--sorted_result
SELECT * FROM (SELECT DISTINCT gl.id, gp.price   FROM t4 gl        LEFT JOIN        (t3 g INNER JOIN t2 p ON g.goodsid = p.id              INNER JOIN t1 gp ON p.id = gp.id)        ON gl.id = g.id and p.shop = 'fr') t;

CREATE VIEW v1 AS SELECT g.id groupid, p.id goods,         p.name name, p.shop shop,        gp.price price   FROM t3 g INNER JOIN t2 p ON g.goodsid = p.id             INNER JOIN t1 gp on p.id = gp.id;

CREATE VIEW v2 AS SELECT DISTINCT g.id, fr.price   FROM t4 g        LEFT JOIN        v1 fr on g.id = fr.groupid and fr.shop = 'fr';
#--sorted_result
SELECT * FROM v2;
#--sorted_result
SELECT * FROM (SELECT DISTINCT g.id, fr.price   FROM t4 g        LEFT JOIN        v1 fr on g.id = fr.groupid and fr.shop = 'fr') t;

DROP VIEW v1;
DROP VIEW v2;
DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;

#
# Bug #13545: problem with NATURAL/USING joins.
#

CREATE TABLE tp2(a int);
CREATE TABLE tp3(b int);
CREATE TABLE tp1(c int, d int);
CREATE TABLE tp6(d int);
CREATE TABLE tp7(e int, f int);
CREATE TABLE tp8(f int);
CREATE VIEW v1 AS   SELECT e FROM tp7 JOIN tp8 ON tp7.e=tp8.f;
CREATE VIEW v2 AS   SELECT e FROM tp7 NATURAL JOIN tp8;

SELECT tp2.a FROM tp2 JOIN tp3 ON a=b JOIN tp1 ON a=c JOIN tp6 USING(d);
#--error 1054
SELECT tp2.x FROM tp2 JOIN tp3 ON a=b JOIN tp1 ON a=c JOIN tp6 USING(d);
SELECT tp2.a FROM tp2 JOIN tp3 ON a=b JOIN tp1 ON a=c NATURAL JOIN tp6;
#--error 1054
SELECT tp2.x FROM tp2 JOIN tp3 ON a=b JOIN tp1 ON a=c NATURAL JOIN tp6;
SELECT v1.e FROM v1 JOIN tp3 ON e=b JOIN tp1 ON e=c JOIN tp6 USING(d);
#--error 1054
SELECT v1.x FROM v1 JOIN tp3 ON e=b JOIN tp1 ON e=c JOIN tp6 USING(d);
SELECT v2.e FROM v2 JOIN tp3 ON e=b JOIN tp1 ON e=c JOIN tp6 USING(d);
#--error 1054
SELECT v2.x FROM v2 JOIN tp3 ON e=b JOIN tp1 ON e=c JOIN tp6 USING(d);

DROP VIEW v1;
DROP VIEW v2;
DROP TABLE tp2;
DROP TABLE tp3;
DROP TABLE tp1;
DROP TABLE tp6;
DROP TABLE tp7;
DROP TABLE tp8;

#
# BUG#13126 -test case from bug report
#
create table td1 (id1 int(11) not null); 
insert into td1 values (1),(2);

create table td2 (id2 int(11) not null);
insert into td2 values (1),(2),(3),(4);

create table td3 (id3 char(16) not null);
insert into td3 values ('100');

create table td4 (id2 int(11) not null, id3 char(16));

create table td5 (id1 int(11) not null, key (id1));
insert into td5 values (1),(2),(1);

create view v1 as   select td4.id3 from td4 join td2 on td4.id2 = td2.id2;

select td1.id1 from td1 inner join (td3 left join v1 on td3.id3 = v1.id3);

drop view v1;
drop table td1;
drop table td2;
drop table td3;
drop table td4;
drop table td5;

create table t0 (id int);
insert into t0 values (0),(1),(2),(3);
create table t1(id int);
#-- insert into t1 select A.id + 10*(B.id) from t0 A, t0 B;
insert into t1 values (0),(1),(2),(3),(10),(11),(12),(13),(20),(21),(22),(23),(30),(31),(32),(33);

create table t2 (id int, b int);
insert into t2 values (1,1), (2,2), (3,3);

create table t3(id int, b int, filler char(200), key(id));
insert into t3 select id,id,'filler' from t1;
insert into t3 select id,id,'filler' from t1;

create table t4 like t3;
insert into t4 select * from t3;
insert into t4 select * from t3;

create table t5 like t4;
insert into t5 select * from t4;
insert into t5 select * from t4;

create table t6 like t5;
insert into t6 select * from t5;
insert into t6 select * from t5;

create table t7 like t6;
insert into t7 select * from t6;
insert into t7 select * from t6;

#--replace_column 10 X
# -- explain select * from t4 join   t2 left join (t3 join t5 on t5.id=t3.b) on t3.id=t2.b where t4.id<=>t3.b;
select * from t4 join   t2 left join (t3 join t5 on t5.id=t3.b) on t3.id=t2.b where t4.id<=>t3.b;
#--replace_column 10 X
# -- explain select * from (t4 join t6 on t6.id=t4.b) right join t3 on t4.id=t3.b   join t2 left join (t5 join t7 on t7.id=t5.b) on t5.id=t2.b where t3.id<=>t2.b;
select * from (t4 join t6 on t6.id=t4.b) right join t3 on t4.id=t3.b   join t2 left join (t5 join t7 on t7.id=t5.b) on t5.id=t2.b where t3.id<=>t2.b;

#--replace_column 10 X
# -- explain select * from t2 left join   (t3 left join (t4 join t6 on t6.id=t4.b) on t4.id=t3.b    join t5 on t5.id=t3.b) on t3.id=t2.b;
select * from t2 left join   (t3 left join (t4 join t6 on t6.id=t4.b) on t4.id=t3.b    join t5 on t5.id=t3.b) on t3.id=t2.b;

drop table t0;
drop table t1;
drop table t2;
drop table t3;
drop table t4;
drop table t5;
drop table t6;
drop table t7;

# BUG#16393
create table t1 (id int);
insert into t1 values (0),(1),(2),(3),(4),(5),(6),(7),(8),(9);
create table t2 (id int, filler char(100), key(id));
# -- insert into t2 select A.id + 10*B.id, '' from t1 A, t1 B;
insert into t2 values ( 0,' '), ( 1,' '), ( 2,' '), ( 3,' '), ( 4,' '), ( 5,' '), ( 6,' '), ( 7,' '), ( 8,' '), ( 9,' '), (10,' '), (11,' '), (12,' '), (13,' '), (14,' '), (15,' '), (16,' '), (17,' '), (18,' '), (19,' '), (20,' '), (21,' '), (22,' '), (23,' '), (24,' '), (25,' '), (26,' '), (27,' '), (28,' '), (29,' '), (30,' '), (31,' '), (32,' '), (33,' '), (34,' '), (35,' '), (36,' '), (37,' '), (38,' '), (39,' '), (40,' '), (41,' '), (42,' '), (43,' '), (44,' '), (45,' '), (46,' '), (47,' '), (48,' '), (49,' '), (50,' '), (51,' '), (52,' '), (53,' '), (54,' '), (55,' '), (56,' '), (57,' '), (58,' '), (59,' '), (60,' '), (61,' '), (62,' '), (63,' '), (64,' '), (65,' '), (66,' '), (67,' '), (68,' '), (69,' '), (70,' '), (71,' '), (72,' '), (73,' '), (74,' '), (75,' '), (76,' '), (77,' '), (78,' '), (79,' '), (80,' '), (81,' '), (82,' '), (83,' '), (84,' '), (85,' '), (86,' '), (87,' '), (88,' '), (89,' '), (90,' '), (91,' '), (92,' '), (93,' '), (94,' '), (95,' '), (96,' '), (97,' '), (98,' '), (99,' ');
create table t3 like t2;
insert into t3 select * from t2;

# -- explain select * from t1 left join   (t2 left join t3 on (t2.id = t3.id))   on (t1.id = t2.id);
select * from t1 left join   (t2 left join t3 on (t2.id = t3.id))   on (t1.id = t2.id);
drop table t1;
drop table t2;
drop table t3;

#
# Bug #16260: single row table in the inner nest of an outer join  
#

CREATE TABLE t1 (id int NOT NULL PRIMARY KEY, type varchar(10));
CREATE TABLE td1 (id1 int NOT NULL PRIMARY KEY, type varchar(10));
CREATE TABLE td2 (id2 int NOT NULL PRIMARY KEY, id int NOT NULL, id1 int NOT NULL);

INSERT INTO t1 VALUES (1, 'A'), (3, 'C');
INSERT INTO td1 VALUES (1, 'A'), (3, 'C');
INSERT INTO td2 VALUES (1, 1, 1), (3, 3, 3);

SELECT * FROM t1 p LEFT JOIN (td2 JOIN t1) ON (t1.id=td2.id AND t1.type='B' AND p.id=td2.id) LEFT JOIN td1 ON (td2.id1=td1.id1)   WHERE p.id=1;

CREATE VIEW v1 AS   SELECT td2.* FROM td2 JOIN t1 ON t1.id=td2.id AND t1.type='B';

SELECT * FROM t1 p LEFT JOIN v1 ON p.id=v1.id LEFT JOIN td1 ON v1.id1=td1.id1   WHERE p.id=1;

DROP VIEW v1;
DROP TABLE t1;
DROP TABLE td1;
DROP TABLE td2;


#
# Test for bug #18279: crash when on conditions are moved out of a nested join
#                      to the on conditions for the nest

CREATE TABLE t1 (id int PRIMARY KEY, id2 int);
CREATE TABLE t2 (id int PRIMARY KEY, id2 int);
CREATE TABLE t3 (id int PRIMARY KEY, id2 int);
CREATE TABLE t4 (id int PRIMARY KEY, id2 int);
CREATE TABLE t5 (id int PRIMARY KEY, id2 int);

SELECT t1.id AS id, t5.id AS ngroupbynsa   FROM t1 INNER JOIN t2 ON t2.id2 = t1.id        LEFT OUTER JOIN        (t3 INNER JOIN t4 ON t4.id = t3.id2 INNER JOIN t5 ON t4.id2 = t5.id)        ON t3.id2 IS NOT NULL     WHERE t1.id=2;

PREPARE stmt FROM "SELECT t1.id AS id, t5.id AS ngroupbynsa   FROM t1 INNER JOIN t2 ON t2.id2 = t1.id        LEFT OUTER JOIN        (t3 INNER JOIN t4 ON t4.id = t3.id2 INNER JOIN t5 ON t4.id2 = t5.id)        ON t3.id2 IS NOT NULL     WHERE t1.id=2";

EXECUTE stmt; 
EXECUTE stmt; 
EXECUTE stmt; 
EXECUTE stmt;

INSERT INTO t1 VALUES (1,1), (2,1), (3,2);
INSERT INTO t2 VALUES (2,1), (3,2), (4,3);
INSERT INTO t3 VALUES (1,1), (3,2), (2,NULL);
INSERT INTO t4 VALUES (1,1), (2,1), (3,3);
INSERT INTO t5 VALUES (1,1), (2,2), (3,3), (4,3);

EXECUTE stmt; 
EXECUTE stmt; 
EXECUTE stmt; 
EXECUTE stmt;

SELECT t1.id AS id, t5.id AS ngroupbynsa   FROM t1 INNER JOIN t2 ON t2.id2 = t1.id        LEFT OUTER JOIN        (t3 INNER JOIN t4 ON t4.id = t3.id2 INNER JOIN t5 ON t4.id2 = t5.id)        ON t3.id2 IS NOT NULL     WHERE t1.id=2; 

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;

#
# Test for bug #24345: crash with nested left outer join when outer table is substituted
#                      for a row that happens to have a null value for the join attribute.
#

CREATE TABLE t1 (   id int NOT NULL PRIMARY KEY,   ct int DEFAULT NULL,   pc int DEFAULT NULL,   INDEX idx_ct (ct),   INDEX idx_pc (pc) );
INSERT INTO t1 VALUES   (1,NULL,NULL),(2,NULL,NULL),(3,NULL,NULL),(4,NULL,NULL),(5,NULL,NULL);

CREATE TABLE t2 (   id int NOT NULL PRIMARY KEY,   sr int NOT NULL,   nm varchar(255) NOT NULL,   INDEX idx_sr (sr) );
INSERT INTO t2 VALUES   (2441905,4308,'LesAbymes'),(2441906,4308,'Anse-Bertrand');
CREATE TABLE t3 (   id int NOT NULL PRIMARY KEY,   ct int NOT NULL,   ln int NOT NULL,   INDEX idx_ct (ct),   INDEX idx_ln (ln) );

CREATE TABLE t4 (   id int NOT NULL PRIMARY KEY,   nm varchar(255) NOT NULL );

INSERT INTO t4 VALUES (4308,'Guadeloupe'),(4309,'Martinique');

SELECT t1.*   FROM t1 LEFT JOIN        (t2 LEFT JOIN t3 ON t3.ct=t2.id AND t3.ln='5') ON t1.ct=t2.id     WHERE t1.id='5';

SELECT t1.*, t4.nm   FROM t1 LEFT JOIN       (t2 LEFT JOIN t3 ON t3.ct=t2.id AND t3.ln='5') ON t1.ct=t2.id           LEFT JOIN t4 ON t2.sr=t4.id     WHERE t1.id='5';

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;

#
# BUG#25575: ERROR 1052 (Column in from clause is ambiguous) with sub-join
#
CREATE TABLE t1 (id INT, b INT);
CREATE TABLE t2 (id INT);
CREATE TABLE t3 (id INT, c INT);
CREATE TABLE t4 (id INT, c INT);
CREATE TABLE t5 (id INT, c INT);

SELECT b FROM t1 JOIN (t2 LEFT JOIN t3 USING (id) LEFT JOIN t4 USING (id) LEFT JOIN t5 USING (id)) USING (id);

#--error ER_NON_UNIQ_ERROR
SELECT c FROM t1 JOIN (t2 LEFT JOIN t3 USING (id) LEFT JOIN t4 USING (id) LEFT JOIN t5 USING (id)) USING (id);

SELECT b FROM t1 JOIN (t2 JOIN t3 USING (id) JOIN t4 USING (id) JOIN t5 USING (id)) USING (id);

#--error ER_NON_UNIQ_ERROR
SELECT c FROM t1 JOIN (t2 JOIN t3 USING (id) JOIN t4 USING (id) JOIN t5 USING (id)) USING (id);

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;
CREATE TABLE t1 (id INT, b INT);
CREATE TABLE t2 (id INT, b INT);
CREATE TABLE t3 (id INT, b INT);

INSERT INTO t1 VALUES (1,1);
INSERT INTO t2 VALUES (1,1);
INSERT INTO t3 VALUES (1,1);

#--error ER_NON_UNIQ_ERROR
SELECT * FROM t1 JOIN (t2 JOIN t3 USING (b)) USING (id);

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;

#
# BUG#29604: inner nest of left join interleaves with outer tables
#

CREATE TABLE t1 (   carrier char(2) default NULL,   id int NOT NULL auto_increment PRIMARY KEY );
INSERT INTO t1 VALUES   ('CO',235371754),('CO',235376554),('CO',235376884),('CO',235377874),   ('CO',231060394),('CO',231059224),('CO',231059314),('CO',231060484),   ('CO',231060274),('CO',231060124),('CO',231060244),('CO',231058594),   ('CO',231058924),('CO',231058504),('CO',231059344),('CO',231060424),   ('CO',231059554),('CO',231060304),('CO',231059644),('CO',231059464),   ('CO',231059764),('CO',231058294),('CO',231058624),('CO',231058864),   ('CO',231059374),('CO',231059584),('CO',231059734),('CO',231059014),   ('CO',231059854),('CO',231059494),('CO',231059794),('CO',231058534),   ('CO',231058324),('CO',231058684),('CO',231059524),('CO',231059974);

CREATE TABLE t2 (   scan_date date default NULL,   id int default NULL,   INDEX scan_date(scan_date),   INDEX id(id) );
INSERT INTO t2 VALUES   ('2008-12-29',231062944),('2008-12-29',231065764),('2008-12-29',231066124),   ('2008-12-29',231060094),('2008-12-29',231061054),('2008-12-29',231065644),   ('2008-12-29',231064384),('2008-12-29',231064444),('2008-12-29',231073774),   ('2008-12-29',231058594),('2008-12-29',231059374),('2008-12-29',231066004),   ('2008-12-29',231068494),('2008-12-29',231070174),('2008-12-29',231071884),   ('2008-12-29',231063274),('2008-12-29',231063754),('2008-12-29',231064144),   ('2008-12-29',231069424),('2008-12-29',231073714),('2008-12-29',231058414),   ('2008-12-29',231060994),('2008-12-29',231069154),('2008-12-29',231068614),   ('2008-12-29',231071464),('2008-12-29',231074014),('2008-12-29',231059614),   ('2008-12-29',231059074),('2008-12-29',231059464),('2008-12-29',231069094),   ('2008-12-29',231067294),('2008-12-29',231070144),('2008-12-29',231073804),   ('2008-12-29',231072634),('2008-12-29',231058294),('2008-12-29',231065344),   ('2008-12-29',231066094),('2008-12-29',231069034),('2008-12-29',231058594),   ('2008-12-29',231059854),('2008-12-29',231059884),('2008-12-29',231059914),   ('2008-12-29',231063664),('2008-12-29',231063814),('2008-12-29',231063904);

CREATE TABLE t3 (   id int default NULL,   INDEX id(id) );
INSERT INTO t3 VALUES   (231058294),(231058324),(231058354),(231058384),(231058414),(231058444),   (231058474),(231058504),(231058534),(231058564),(231058594),(231058624),   (231058684),(231058744),(231058804),(231058864),(231058924),(231058954),   (231059014),(231059074),(231059104),(231059134),(231059164),(231059194),   (231059224),(231059254),(231059284),(231059314),(231059344),(231059374),   (231059404),(231059434),(231059464),(231059494),(231059524),(231059554),   (231059584),(231059614),(231059644),(231059674),(231059704),(231059734),   (231059764),(231059794),(231059824),(231059854),(231059884),(231059914),   (231059944),(231059974),(231060004),(231060034),(231060064),(231060094),   (231060124),(231060154),(231060184),(231060214),(231060244),(231060274),   (231060304),(231060334),(231060364),(231060394),(231060424),(231060454),   (231060484),(231060514),(231060544),(231060574),(231060604),(231060634),   (231060664),(231060694),(231060724),(231060754),(231060784),(231060814),   (231060844),(231060874),(231060904),(231060934),(231060964),(231060994),   (231061024),(231061054),(231061084),(231061144),(231061174),(231061204),   (231061234),(231061294),(231061354),(231061384),(231061414),(231061474),   (231061564),(231061594),(231061624),(231061684),(231061714),(231061774),   (231061804),(231061894),(231061984),(231062074),(231062134),(231062224),   (231062254),(231062314),(231062374),(231062434),(231062494),(231062554),   (231062584),(231062614),(231062644),(231062704),(231062734),(231062794),   (231062854),(231062884),(231062944),(231063004),(231063034),(231063064),   (231063124),(231063154),(231063184),(231063214),(231063274),(231063334),   (231063394),(231063424),(231063454),(231063514),(231063574),(231063664);
 
CREATE TABLE t4 (   carrier char(2) NOT NULL default '' PRIMARY KEY,   id int(11) default NULL,   INDEX id(id) );
INSERT INTO t4 VALUES   ('99',6),('SK',456),('UA',486),('AI',1081),('OS',1111),('VS',1510);

CREATE TABLE t5 (   id int default NULL,   INDEX id(id) );
INSERT INTO t5 VALUES   (6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),   (6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),   (6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),   (6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),   (6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),   (6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(6),(456),(456),(456),   (456),(456),(456),(456),(456),(456),(456),(456),(456),(456),(456),(456),   (456),(486),(1081),(1111),(1111),(1111),(1111),(1510);

SELECT COUNT(*)   FROM((t2 JOIN t1 ON t2.id = t1.id)         JOIN t3 ON t3.id = t1.id);

# -- EXPLAIN SELECT COUNT(*)   FROM ((t2 JOIN t1 ON t2.id = t1.id)          JOIN t3 ON t3.id = t1.id)        LEFT JOIN        (t5 JOIN t4 ON t5.id = t4.id)        ON t4.carrier = t1.carrier;
SELECT COUNT(*)   FROM ((t2 JOIN t1 ON t2.id = t1.id)         JOIN t3 ON t3.id = t1.id)        LEFT JOIN        (t5 JOIN t4 ON t5.id = t4.id)        ON t4.carrier = t1.carrier;

DROP TABLE t1;
DROP TABLE t2;
DROP TABLE t3;
DROP TABLE t4;
DROP TABLE t5;

#--echo End of 5.0 tests

