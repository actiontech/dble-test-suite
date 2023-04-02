#!share_conn
DROP DATABASE If EXISTS FOO /*dble_dest_expect:M*/;
SET autocommit=1 /*dble_dest_expect:CS*/;
BEGIN /*dble_dest_expect:M*/;
CREATE DATABASE FOO /*dble_dest_expect:CM*/; -- implicit commit
SELECT (@@version) INTO @a /*dble_dest_expect:M*/;
SELECT @a /*dble_dest_expect:S*/; -- should read from slave
DROP DATABASE If EXISTS FOO /*dble_dest_expect:M*/;
COMMIT /*dble_dest_expect:CS*/;