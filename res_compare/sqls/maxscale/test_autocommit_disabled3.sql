#!share_conn
drop table if exists t1 /* dble_dest_expect:M */;
create table t1 (id integer) /* dble_dest_expect:M */;
set autocommit=0 /* dble_dest_expect:CS */;              
begin /* dble_dest_expect:M */;                         
insert into t1 values(1) /* dble_dest_expect:CM */;       
commit /* dble_dest_expect:CM */;
select count(*) from t1 /* dble_dest_expect:M */;        
drop table t1 /* dble_dest_expect:CM */;