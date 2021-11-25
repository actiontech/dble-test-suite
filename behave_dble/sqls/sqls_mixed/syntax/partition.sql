#!default_db:schema1
#less important
create table if not exists sharding_4_t1(id int,name varchar(8)) partition by hash(id);
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by hash(id) partitions 3;
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by hash(id) (partition p0,partition p1,partition p2,partition p3);
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by linear hash(id) partitions 3 (partition p0,partition p1,partition p2);
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by key(id) partitions 4 (partition p0,partition p1,partition p2,partition p3);
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,c_id int,name varchar(8)) partition by key  algorithm=1(id,c_id) partitions 4 (partition p0,partition p1,partition p2,partition p3);
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,c_id int,name varchar(8)) partition by linear key algorithm=2 (id,c_id) partitions 4 (partition p0,partition p1,partition p2,partition p3);
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by range (id) partitions 2 subpartition by hash(id) subpartitions 2(partition p0 values less than (1990)(subpartition sp0,subpartition sp1),partition p1 values less than(3880)(subpartition sp2,subpartition sp3));
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,purchased date) partition by range (to_days(purchased)) partitions 2 subpartition by hash(to_days(purchased)) subpartitions 2(partition p0 values less than (1990)(subpartition sp0,subpartition sp1),partition p1 values less than(3880)(subpartition sp2,subpartition sp3));
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,name varchar(8)) partition by list (id) partitions 2 subpartition by hash(id) subpartitions 2(partition p0 values less than (1990)(subpartition sp0,subpartition sp1),partition p1 values less than(3880)(subpartition sp2,subpartition sp3));
drop table if exists sharding_4_t1;
create table sharding_4_t1(id int,purchased date) partition by list (id) partitions 2 subpartition by hash(id) subpartitions 2 (partition p0 values in (1,2,3,4,5)(subpartition sp0,subpartition sp1),partition p1 values in (6,7,8,9,10)(subpartition sp2,subpartition sp3));
drop table if exists sharding_4_t1;
#DBLE0REQ-1313
create table sharding_4_t1 (id int, name varchar(30), signed date) partition by HASH( month(signed) ) partitionS 12;
alter table sharding_4_t1 coalesce partition 4;
drop table if exists sharding_4_t1;
CREATE TABLE `sharding_4_t1` (`id` int,`name` varchar(50),`purchased` date) ENGINE=InnoDB default CHARSET=utf8 partition by range( year(purchased) ) (partition p0 values less than (1990),partition p1 values less than (1995),partition p2 values less than (2000),partition p3 values less than (2005),partition p4 values less than (2010),partition p5 values less than (2015));
SELECT * FROM sharding_4_t1 partition (p2);
alter table sharding_4_t1 add partition (partition p6 values less than (2020));
alter table sharding_4_t1 reorganize partition p5 into(partition s0 values less than(2012),partition s1 values less than(2015));
alter table sharding_4_t1 reorganize partition s0,s1 into (partition p5 values less than (2015));
alter table sharding_4_t1 truncate partition p0;
alter table sharding_4_t1 drop partition p1;
alter table sharding_4_t1 discard partition p5 tablespace;
drop table if exists sharding_4_t1;
CREATE TABLE `sharding_4_t1` (`id` int,`name` varchar(50),`purchased` date) ENGINE=InnoDB default CHARSET=utf8 partition by range( year(purchased) ) (partition p0 values less than (1990),partition p1 values less than (1995),partition p2 values less than (2000),partition p3 values less than (2005),partition p4 values less than (2010),partition p5 values less than (2015));
alter table sharding_4_t1 analyze partition p3;
alter table sharding_4_t1 check partition p2;
alter table sharding_4_t1 repair partition p2;
alter table sharding_4_t1 optimize partition p4;
alter table sharding_4_t1 rebuild partition p4;
alter table sharding_4_t1 remove partitioning;
drop table if exists sharding_4_t1;
#
#clear tables
#
drop table if exists sharding_4_t1