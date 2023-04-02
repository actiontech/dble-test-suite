#-- simple read with variable from master
#!share_conn
BEGIN /* dble_dest_expect:M */;
SELECT (@@version) INTO @a /* dble_dest_expect:CM */;
SELECT @a /* dble_dest_expect:CM */;
COMMIT /* dble_dest_expect:CM */;