#!share_conn
drop table if exists t1 /*dble_dest_expect:M*/;
create table t1 (id integer) /*dble_dest_expect:M*/;
set autocommit=0     /*dble_dest_expect:CS*/  ;      
insert into t1 values(1) /*dble_dest_expect:M*/  ;   
select count(*) from t1 /*dble_dest_expect:CM*/  ;     
drop table t1 /*dble_dest_expect:CM*/ ;