#
# test of left outer join for tests that depends on innodb
#

#--source include/have_innodb.inc

#
# Test for bug #17164: ORed FALSE blocked conversion of outer join into join
# 

CREATE TABLE t1 (id int(11) NOT NULL PRIMARY KEY, name varchar(20), INDEX (name)) ENGINE=InnoDB;
CREATE TABLE t2 (id int(11) NOT NULL PRIMARY KEY, fkey int(11), FOREIGN KEY (fkey) REFERENCES t2(id)) ENGINE=InnoDB;
INSERT INTO t1 VALUES (1,'A1'),(2,'A2'),(3,'B');
INSERT INTO t2 VALUES (1,1),(2,2),(3,2),(4,3),(5,3);

#-- disable_result_log
ANALYZE TABLE t1;
ANALYZE TABLE t2;
#-- enable_result_log

SELECT COUNT(*) FROM t2 LEFT JOIN t1 ON t2.fkey = t1.id   WHERE t1.name LIKE 'A%';

SELECT COUNT(*) FROM t2 LEFT JOIN t1 ON t2.fkey = t1.id   WHERE t1.name LIKE 'A%' OR FALSE;

DROP TABLE t1;
DROP TABLE t2;

#--echo #
#--echo # BUG#58456: Assertion 0 in QUICK_INDEX_MERGE_SELECT::need_sorted_output
#--echo #            in opt_range.h
#--echo #
CREATE TABLE t1 (   col_int INT,   col_int_key INT,   id INT NOT NULL,   PRIMARY KEY (id),   KEY col_int_key (col_int_key) ) ENGINE=InnoDB;

INSERT INTO t1 VALUES (NULL,1,1), (6,2,2), (5,3,3), (NULL,4,4);
INSERT INTO t1 VALUES (1,NULL,6), (8,5,7), (NULL,8,8), (8,NULL,5);

#-- disable_result_log
ANALYZE TABLE t1;
#-- enable_result_log

CREATE TABLE t2 (   id INT PRIMARY KEY ) ENGINE=InnoDB;

SELECT t1.id FROM t2 LEFT JOIN t1 ON t2.id = t1.col_int WHERE t1.col_int_key BETWEEN 5 AND 6       AND t1.id IS NULL OR t1.id IN (5) ORDER BY id;

#--echo
#--eval EXPLAIN $query
#--echo
#--eval $query
#--echo

DROP TABLE t1;
DROP TABLE t2;

#--echo # End BUG#58456

#--echo #
#--echo # Bug #20939184:INNODB: UNLOCK ROW COULD NOT FIND A 2 MODE LOCK ON THE
#--echo #               RECORD
#--echo #
CREATE  TABLE t1 (id INT, c2 INT, c3 INT, PRIMARY KEY (id,c2) );
CREATE  TABLE t2 (id INT, c2 INT, c3 INT, PRIMARY KEY (id), KEY (c2));
INSERT INTO t1 VALUES (1,2,3),(2,3,4),(3,4,5);
INSERT INTO t2 SELECT * FROM t1;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
#unlocks rows in table t2 where id = 1
SELECT * FROM t1 LEFT JOIN t2 ON t1.c2=t2.c2 AND t2.id=1 FOR UPDATE;
UPDATE t1 LEFT JOIN t2 ON t1.id = t2.c2 AND t2.id = 3 SET t1.c3 = RAND()*10;
COMMIT;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
DROP TABLE t1;
DROP TABLE t2;
