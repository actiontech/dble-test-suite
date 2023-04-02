#!share_conn
set autocommit=0 /* dble_dest_expect:CS */;
select @@version /* dble_dest_expect:M */;