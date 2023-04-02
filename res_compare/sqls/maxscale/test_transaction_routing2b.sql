#!share_conn
SET autocommit = Off /*dble_dest_expect:CS*/; 
START TRANSACTION /*dble_dest_expect:M*/; 
CREATE TABLE IF NOT EXISTS myCity (a int, b char(20)) /*dble_dest_expect:CM*/; 
INSERT INTO myCity VALUES (1, 'Milan') /*dble_dest_expect:M*/; 
INSERT INTO myCity VALUES (2, 'London') /*dble_dest_expect:CM*/; 
COMMIT /*dble_dest_expect:CM*/; 
START TRANSACTION /*dble_dest_expect:M*/; 
DELETE FROM myCity /*dble_dest_expect:CM*/;
SELECT COUNT(*) FROM myCity /*dble_dest_expect:CM*/; -- read transaction's modifications from master
COMMIT /*dble_dest_expect:CM*/;