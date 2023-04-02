#!share_conn
DROP FUNCTION IF EXISTS hello /*dble_dest_expect:M*/;
SET autocommit=1 /*dble_dest_expect:CS*/;
BEGIN /*dble_dest_expect:M*/;
#!share_conn_1 #!multiline
CREATE FUNCTION hello (s CHAR(20))
RETURNS CHAR(50) DETERMINISTIC
RETURN CONCAT('Hello, ',s,'!') /*dble_dest_expect:M*/; -- implicit COMMIT
#!share_conn_1
SELECT (@@versioin) INTO @a /*dble_dest_expect:M*/;
SELECT @a /*dble_dest_expect:S*/; -- should read from slave
DROP FUNCTION IF EXISTS hello /*dble_dest_expect:M*/;
COMMIT /*dble_dest_expect:CS*/;