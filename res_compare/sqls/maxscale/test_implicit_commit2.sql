#!share_conn_1
DROP TABLE IF EXISTS T1 /*dble_dest_expect:M*/;
DROP EVENT IF EXISTS myevent /*dble_dest_expect:M*/;
SET autocommit=1 /*dble_dest_expect:CS*/;
BEGIN /*dble_dest_expect:M*/;
CREATE TABLE T1 (id integer) /*dble_dest_expect:CM*/;
#!share_conn_1 #!multiline
CREATE EVENT myevent
ON SCHEDULE AT CURRENT_TIMESTAMP + INTERVAL 1 HOUR
DO
UPDATE t1 SET id = id + 1 /*dble_dest_expect:M*/;
#end multiline
#!share_conn_1
SELECT (@@version) INTO @a /*dble_dest_expect:M*/;
SELECT @a /*dble_dest_expect:S*/; -- should read from slave
DROP TABLE IF EXISTS T1 /*dble_dest_expect:M*/;
DROP EVENT IF EXISTS myevent /*dble_dest_expect:M*/;
COMMIT /*dble_dest_expect:CS*/;