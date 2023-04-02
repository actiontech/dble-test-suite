#!share_conn
DROP TABLE IF EXISTS T1 /*dble_dest_expect:M*/;
SET autocommit=0 /*dble_dest_expect:CS*/;
BEGIN /*dble_dest_expect:M*/;
CREATE TEMPORARY TABLE T1 (id integer) /*dble_dest_expect:CM*/; -- NO implicit commit
SELECT (@@version) INTO @a /*dble_dest_expect:CM*/;
SELECT @a /*dble_dest_expect:CM*/; -- should read from master
DROP TABLE IF EXISTS T1 /*dble_dest_expect:CM*/;
COMMIT /*dble_dest_expect:CS*/;