-- Read from slave after implicit COMMIT
#!share_conn
drop table if exists T2 /*dble_dest_expect:M*/;
START TRANSACTION /*dble_dest_expect:M*/; 
CREATE TABLE IF NOT EXISTS T2 (id integer) /*dble_dest_expect:CM*/; 
INSERT INTO T2 VALUES (@@server_id) /*dble_dest_expect:M*/;
SET AUTOCOMMIT=1 /*dble_dest_expect:CS*/;
SELECT id from T2 /*dble_dest_expect:S*//*allow_diff*/; -- read transaction's modifications from slave