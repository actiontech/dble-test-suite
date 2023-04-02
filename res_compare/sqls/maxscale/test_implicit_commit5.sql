#!share_conn
DROP PROCEDURE IF EXISTS simpleproc /*dble_dest_expect:M*/;
SET autocommit=1 /*dble_dest_expect:CS*/;
BEGIN /*dble_dest_expect:M*/;
#!share_conn_1 #!multiline
CREATE PROCEDURE simpleproc (OUT param1 INT) 
BEGIN
    SELECT COUNT(*) INTO param1 FROM t;
END /*dble_dest_expect:M*/;
#!share_conn_1
SELECT (@@version) INTO @a /*dble_dest_expect:M*/;
SELECT @a /*dble_dest_expect:S*/; -- should read from slave
DROP PROCEDURE IF EXISTS simpleproc /*dble_dest_expect:M*/;
COMMIT /*dble_dest_expect:CS*/;