#!share_conn
use schema1 /*dble_dest_expect:CS*/;
set autocommit=1 /*dble_dest_expect:CS*/;
use mysql /*dble_dest_expect:CS*/;
select count(*) from user where user='maxuser' /*dble_dest_expect:M*/