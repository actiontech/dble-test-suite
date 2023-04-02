#!share_conn
drop table if exists t1 /*dble_dest_expect:M*/;
create temporary table t1 (id integer) /*dble_dest_expect:M*/;
insert into t1 values(1) /*dble_dest_expect:CM*/;
select id from t1 /*dble_dest_expect:CM*/;