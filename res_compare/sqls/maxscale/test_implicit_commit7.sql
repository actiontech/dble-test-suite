#!share_conn
DROP TABLE IF EXISTS T1 /*dble_dest_expect:M*/;
CREATE TABLE T1 (id integer) /*dble_dest_expect:M*/; -- implicit commit
SET autocommit=1 /*dble_dest_expect:CS*/;
BEGIN /*dble_dest_expect:M*/;
CREATE INDEX foo_t1 on T1 (id) /*dble_dest_expect:CM*/; -- implicit commit
SELECT (@@version) INTO @a /*dble_dest_expect:M*/;
SELECT @a /*dble_dest_expect:S*/; -- should read from slave
DROP TABLE IF EXISTS T1 /*dble_dest_expect:M*/;
COMMIT /*dble_dest_expect:CS*/;