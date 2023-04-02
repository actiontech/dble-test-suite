#!share_conn
drop table if exists t1 /*dble_dest_expect:M*/;
create table t1 (id integer) /*dble_dest_expect:M*/;
insert into t1 values(1) /*dble_dest_expect:M*/; -- in master
commit /*dble_dest_expect:CS*/;
select count(*) from t1 /*dble_dest_expect:S*/; -- in slave