#less important
create table if not exists sharding_4_t1(id int,name varchar(8)) partition by hash(id);
drop table sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by hash(id) partitions 3;
drop table sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by hash(id) (partition p0,partition p1,partition p2,partition p3);
drop table sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by linear hash(id) partitions 3 (partition p0,partition p1,partition p2);
drop table sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by key(id) partitions 4 (partition p0,partition p1,partition p2,partition p3);
drop table sharding_4_t1;
create table sharding_4_t1(id int,c_id int,name varchar(8)) partition by key  algorithm=1(id,c_id) partitions 4 (partition p0,partition p1,partition p2,partition p3);
drop table sharding_4_t1;
create table sharding_4_t1(id int,c_id int,name varchar(8)) partition by linear key algorithm=2 (id,c_id) partitions 4 (partition p0,partition p1,partition p2,partition p3);
drop table sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by range (id) partitions 2 subpartition by hash(id) subpartitions 2(partition p0 values less than (1990)(subpartition sp0,subpartition sp1),partition p1 values less than(3880)(subpartition sp2,subpartition sp3));
drop table sharding_4_t1;
create table sharding_4_t1(id int,purchased date) partition by range (to_days(purchased)) partitions 2 subpartition by hash(to_days(purchased)) subpartitions 2(partition p0 values less than (1990)(subpartition sp0,subpartition sp1),partition p1 values less than(3880)(subpartition sp2,subpartition sp3));
drop table sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by list (id) partitions 2 subpartition by hash(id) subpartitions 2(partition p0 values less than (1990)(subpartition sp0,subpartition sp1),partition p1 values less than(3880)(subpartition sp2,subpartition sp3));
drop table sharding_4_t1;
create table sharding_4_t1(id int,purchased date) partition by list (id) partitions 2 subpartition by hash(id) subpartitions 2 (partition p0 values in (1,2,3,4,5)(subpartition sp0,subpartition sp1),partition p1 values in (6,7,8,9,10)(subpartition sp2,subpartition sp3));
drop table sharding_4_t1;
#
#clear tables
#
drop table if exists sharding_4_t1