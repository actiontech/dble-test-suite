# The include statement below is a temp one for tests that are yet to
#be ported to run with InnoDB,
#but needs to be kept for tests that would need MyISAM in future.
#--source include/force_myisam_default.inc

#
# Test file for WL#1724 (Min/Max Optimization for Queries with Group By Clause).
# The queries in this file test query execution via QUICK_GROUP_MIN_MAX_SELECT.
#

#
# TODO:
# Add queries with:
# - C != const
# - C IS NOT NULL
# - HAVING clause

#--disable_warnings
drop table if exists ts7;
#--enable_warnings

create table ts7 (   a1 char(64), a2 char(64), b char(16), c char(16) not null, d char(16), dummy char(248) default ' ' );

insert into ts7 (a1, a2, b, c, d) values ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4'), ('d','a','a','a411','xy1'),('d','a','a','b411','xy2'),('d','a','a','c411','xy3'),('d','a','a','d411','xy4'), ('d','a','b','e412','xy1'),('d','a','b','f412','xy2'),('d','a','b','g412','xy3'),('d','a','b','h412','xy4'), ('d','b','a','i421','xy1'),('d','b','a','j421','xy2'),('d','b','a','k421','xy3'),('d','b','a','l421','xy4'), ('d','b','b','m422','xy1'),('d','b','b','n422','xy2'),('d','b','b','o422','xy3'),('d','b','b','p422','xy4'), ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4'), ('d','a','a','a411','xy1'),('d','a','a','b411','xy2'),('d','a','a','c411','xy3'),('d','a','a','d411','xy4'), ('d','a','b','e412','xy1'),('d','a','b','f412','xy2'),('d','a','b','g412','xy3'),('d','a','b','h412','xy4'), ('d','b','a','i421','xy1'),('d','b','a','j421','xy2'),('d','b','a','k421','xy3'),('d','b','a','l421','xy4'), ('d','b','b','m422','xy1'),('d','b','b','n422','xy2'),('d','b','b','o422','xy3'),('d','b','b','p422','xy4');

create index idx_ts7_0 on ts7 (a1);
create index idx_ts7_1 on ts7 (a1,a2,b,c);
create index idx_ts7_2 on ts7 (a1,a2,b);
#--analyze table ts7;

# ts8 is the same as ts7, but with some NULLs in the MIN/MAX column, and
# one more nullable attribute

#--disable_warnings
drop table if exists ts8;
#--enable_warnings

create table ts8 (   a1 char(64), a2 char(64) not null, b char(16), c char(16), d char(16), dummy char(248) default ' ' );
insert into ts8 select * from ts7;
# add few rows with NULL's in the MIN/MAX column
insert into ts8 (a1, a2, b, c, d) values ('a','a',NULL,'a777','xyz'),('a','a',NULL,'a888','xyz'),('a','a',NULL,'a999','xyz'), ('a','a','a',NULL,'xyz'), ('a','a','b',NULL,'xyz'), ('a','b','a',NULL,'xyz'), ('c','a',NULL,'c777','xyz'),('c','a',NULL,'c888','xyz'),('c','a',NULL,'c999','xyz'), ('d','b','b',NULL,'xyz'), ('e','a','a',NULL,'xyz'),('e','a','a',NULL,'xyz'),('e','a','a',NULL,'xyz'),('e','a','a',NULL,'xyz'), ('e','a','b',NULL,'xyz'),('e','a','b',NULL,'xyz'),('e','a','b',NULL,'xyz'),('e','a','b',NULL,'xyz'), ('a','a',NULL,'a777','xyz'),('a','a',NULL,'a888','xyz'),('a','a',NULL,'a999','xyz'), ('a','a','a',NULL,'xyz'), ('a','a','b',NULL,'xyz'), ('a','b','a',NULL,'xyz'), ('c','a',NULL,'c777','xyz'),('c','a',NULL,'c888','xyz'),('c','a',NULL,'c999','xyz'), ('d','b','b',NULL,'xyz'), ('e','a','a',NULL,'xyz'),('e','a','a',NULL,'xyz'),('e','a','a',NULL,'xyz'),('e','a','a',NULL,'xyz'), ('e','a','b',NULL,'xyz'),('e','a','b',NULL,'xyz'),('e','a','b',NULL,'xyz'),('e','a','b',NULL,'xyz');

create index idx_ts8_0 on ts8 (a1);
create index idx_ts8_1 on ts8 (a1,a2,b,c);
create index idx_ts8_2 on ts8 (a1,a2,b);
#--analyze table ts8;

# Table ts9 is the same as ts7, but with smaller column lenghts.
# This allows to test different branches of the cost computation procedure
# when the number of keys per block are less than the number of keys in the
# sub-groups formed by predicates over non-group attributes. 

#--disable_warnings
drop table if exists ts9;
#--enable_warnings

create table ts9 (   a1 char(1), a2 char(1), b char(1), c char(4) not null, d char(3), dummy char(1) default ' ' );

insert into ts9 (a1, a2, b, c, d) values ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4'); insert into ts9 (a1, a2, b, c, d) values ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4');
insert into ts9 (a1, a2, b, c, d) values ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4');
insert into ts9 (a1, a2, b, c, d) values ('a','a','a','a111','xy1'),('a','a','a','b111','xy2'),('a','a','a','c111','xy3'),('a','a','a','d111','xy4'), ('a','a','b','e112','xy1'),('a','a','b','f112','xy2'),('a','a','b','g112','xy3'),('a','a','b','h112','xy4'), ('a','b','a','i121','xy1'),('a','b','a','j121','xy2'),('a','b','a','k121','xy3'),('a','b','a','l121','xy4'), ('a','b','b','m122','xy1'),('a','b','b','n122','xy2'),('a','b','b','o122','xy3'),('a','b','b','p122','xy4'), ('b','a','a','a211','xy1'),('b','a','a','b211','xy2'),('b','a','a','c211','xy3'),('b','a','a','d211','xy4'), ('b','a','b','e212','xy1'),('b','a','b','f212','xy2'),('b','a','b','g212','xy3'),('b','a','b','h212','xy4'), ('b','b','a','i221','xy1'),('b','b','a','j221','xy2'),('b','b','a','k221','xy3'),('b','b','a','l221','xy4'), ('b','b','b','m222','xy1'),('b','b','b','n222','xy2'),('b','b','b','o222','xy3'),('b','b','b','p222','xy4'), ('c','a','a','a311','xy1'),('c','a','a','b311','xy2'),('c','a','a','c311','xy3'),('c','a','a','d311','xy4'), ('c','a','b','e312','xy1'),('c','a','b','f312','xy2'),('c','a','b','g312','xy3'),('c','a','b','h312','xy4'), ('c','b','a','i321','xy1'),('c','b','a','j321','xy2'),('c','b','a','k321','xy3'),('c','b','a','l321','xy4'), ('c','b','b','m322','xy1'),('c','b','b','n322','xy2'),('c','b','b','o322','xy3'),('c','b','b','p322','xy4');

create index idx_ts9_0 on ts9 (a1);
create index idx_ts9_1 on ts9 (a1,a2,b,c);
create index idx_ts9_2 on ts9 (a1,a2,b);
#--analyze table ts9;


#
# Queries without a WHERE clause. These queries do not use ranges.
#

# plans
#--explain select a1, min(a2) from ts7 group by a1;
#--explain select a1, max(a2) from ts7 group by a1;
#--explain select a1, min(a2), max(a2) from ts7 group by a1;
#--explain select a1, a2, b, min(c), max(c) from ts7 group by a1,a2,b;
#--explain select a1,a2,b,max(c),min(c) from ts7 group by a1,a2,b;
#--replace_column 8 # 10 #
#--explain select a1,a2,b,max(c),min(c) from ts8 group by a1,a2,b;
# Select fields in different order
#--explain select min(a2), a1, max(a2), min(a2), a1 from ts7 group by a1;
#--explain select a1, b, min(c), a1, max(c), b, a2, max(c), max(c) from ts7 group by a1, a2, b;
#--explain select min(a2) from ts7 group by a1;
#--explain select a2, min(c), max(c) from ts7 group by a1,a2,b;

# queries
select a1, min(a2) from ts7 group by a1;
select a1, max(a2) from ts7 group by a1;
select a1, min(a2), max(a2) from ts7 group by a1;
select a1, a2, b, min(c), max(c) from ts7 group by a1,a2,b;
select a1,a2,b,max(c),min(c) from ts7 group by a1,a2,b;
select a1,a2,b,max(c),min(c) from ts8 group by a1,a2,b;
# Select fields in different order
select min(a2), a1, max(a2), min(a2), a1 from ts7 group by a1;
select a1, b, min(c), a1, max(c), b, a2, max(c), max(c) from ts7 group by a1, a2, b;
select min(a2) from ts7 group by a1;
select a2, min(c), max(c) from ts7 group by a1,a2,b;

#
# Queries with a where clause
#

# A) Preds only over the group 'A' attributes
# plans
#--explain select a1,a2,b,min(c),max(c) from ts7 where a1 < 'd' group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where a1 >= 'b' group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
#--explain select a1, max(c)            from ts7 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where a1 >= 'c' or a2 < 'b' group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
#--explain select a1,min(c),max(c)      from ts7 where a1 >= 'b' group by a1,a2,b;
#--explain select a1,  max(c)           from ts7 where a1 in ('a','b','d') group by a1,a2,b;

#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where a1 < 'd' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where a1 < 'd' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where a1 >= 'b' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1, max(c)            from ts8 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where a1 >= 'c' or a2 < 'b' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,min(c),max(c)      from ts8 where a1 >= 'b' group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,  max(c)           from ts8 where a1 in ('a','b','d') group by a1,a2,b;

# queries
select a1,a2,b,min(c),max(c) from ts7 where a1 < 'd' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where a1 >= 'b' group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
select a1, max(c)            from ts7 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where a1 >= 'c' or a2 < 'b' group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
select a1,min(c),max(c)      from ts7 where a1 >= 'b' group by a1,a2,b;
select a1,  max(c)           from ts7 where a1 in ('a','b','d') group by a1,a2,b;

select a1,a2,b,       max(c) from ts8 where a1 < 'd' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where a1 < 'd' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where a1 >= 'b' group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
select a1, max(c)            from ts8 where a1 >= 'c' or a1 < 'b' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where a1 >= 'c' or a2 < 'b' group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where a1 = 'z' or a1 = 'b' or a1 = 'd' group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') group by a1,a2,b;
select a1,min(c),max(c)      from ts8 where a1 >= 'b' group by a1,a2,b;
select a1,  max(c)           from ts8 where a1 in ('a','b','d') group by a1,a2,b;

# B) Equalities only over the non-group 'B' attributes
# plans

#--explain select a1,a2,b,max(c),min(c) from ts7 where (a2 = 'a') and (b = 'b') group by a1;
#--explain select a1,max(c),min(c)      from ts7 where (a2 = 'a') and (b = 'b') group by a1;
#--explain select a1,a2,b,       max(c) from ts7 where (b = 'b') group by a1,a2;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (b = 'b') group by a1,a2;
#--explain select a1,a2, max(c)         from ts7 where (b = 'b') group by a1,a2;

#--explain select a1,a2,b,max(c),min(c) from ts8 where (a2 = 'a') and (b = 'b') group by a1;
#--explain select a1,max(c),min(c)      from ts8 where (a2 = 'a') and (b = 'b') group by a1;
#--explain select a1,a2,b,       max(c) from ts8 where (b = 'b') group by a1,a2;
#--explain select a1,a2,b,min(c),max(c) from ts8 where (b = 'b') group by a1,a2;
#--explain select a1,a2, max(c)         from ts8 where (b = 'b') group by a1,a2;

# these queries test case 2) in TRP_GROUP_MIN_MAX::update_cost()
#--explain select a1,a2,b,max(c),min(c) from ts9 where (a2 = 'a') and (b = 'b') group by a1;
#--explain select a1,max(c),min(c)      from ts9 where (a2 = 'a') and (b = 'b') group by a1;

# queries
select a1,a2,b,max(c),min(c) from ts7 where (a2 = 'a') and (b = 'b') group by a1;
select a1,max(c),min(c)      from ts7 where (a2 = 'a') and (b = 'b') group by a1;
select a1,a2,b,       max(c) from ts7 where (b = 'b') group by a1,a2;
select a1,a2,b,min(c),max(c) from ts7 where (b = 'b') group by a1,a2;
select a1,a2, max(c)         from ts7 where (b = 'b') group by a1,a2;

select a1,a2,b,max(c),min(c) from ts8 where (a2 = 'a') and (b = 'b') group by a1;
select a1,max(c),min(c)      from ts8 where (a2 = 'a') and (b = 'b') group by a1;
select a1,a2,b,       max(c) from ts8 where (b = 'b') group by a1,a2;
select a1,a2,b,min(c),max(c) from ts8 where (b = 'b') group by a1,a2;
select a1,a2, max(c)         from ts8 where (b = 'b') group by a1,a2;

# these queries test case 2) in TRP_GROUP_MIN_MAX::update_cost()
select a1,a2,b,max(c),min(c) from ts9 where (a2 = 'a') and (b = 'b') group by a1;
select a1,max(c),min(c)      from ts9 where (a2 = 'a') and (b = 'b') group by a1;


# IS NULL (makes sense for ts8 only)
# plans

# SQL standard does not impose recognition of 'b IS NULL' as
# a functional dependency of {b} on {}.
# These queries are home-grown.

#--source include/turn_off_only_full_group_by.inc

#--explain select a1,a2,b,min(c) from ts8 where (a2 = 'a') and b is NULL group by a1;
#--explain select a1,a2,b,max(c) from ts8 where (a2 = 'a') and b is NULL group by a1;
#--explain select a1,a2,b,min(c) from ts8 where b is NULL group by a1,a2;
#--explain select a1,a2,b,max(c) from ts8 where b is NULL group by a1,a2;
#--explain select a1,a2,b,min(c),max(c) from ts8 where b is NULL group by a1,a2;
#--explain select a1,a2,b,min(c),max(c) from ts8 where b is NULL group by a1,a2;
# queries
select a1,a2,b,min(c) from ts8 where (a2 = 'a') and b is NULL group by a1;
select a1,a2,b,max(c) from ts8 where (a2 = 'a') and b is NULL group by a1;
select a1,a2,b,min(c) from ts8 where b is NULL group by a1,a2;
select a1,a2,b,max(c) from ts8 where b is NULL group by a1,a2;
select a1,a2,b,min(c),max(c) from ts8 where b is NULL group by a1,a2;
select a1,a2,b,min(c),max(c) from ts8 where b is NULL group by a1,a2;

#--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

# C) Range predicates for the MIN/MAX attribute
# plans
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts7 where (c > 'b1') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c > 'b1') group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where (c > 'f123') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c > 'f123') group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where (c < 'a0') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c < 'a0') group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where (c < 'k321') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c < 'k321') group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
#--explain select a1,a2,b,       max(c) from ts7 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c > 'b111') and (c <= 'g112') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c < 'c5') or (c = 'g412') or (c = 'k421') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where ((c > 'b111') and (c <= 'g112')) or ((c > 'd000') and (c <= 'i110')) group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (c between 'b111' and 'g112') or (c between 'd000' and 'i110') group by a1,a2,b;

#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (c > 'b1') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c > 'b1') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (c > 'f123') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c > 'f123') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (c < 'a0') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c < 'a0') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (c < 'k321') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c < 'k321') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,       max(c) from ts8 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c > 'b111') and (c <= 'g112') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c < 'c5') or (c = 'g412') or (c = 'k421') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where ((c > 'b111') and (c <= 'g112')) or ((c > 'd000') and (c <= 'i110')) group by a1,a2,b;

# queries
select a1,a2,b,       max(c) from ts7 where (c > 'b1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c > 'b1') group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where (c > 'f123') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c > 'f123') group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where (c < 'a0') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c < 'a0') group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where (c < 'k321') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c < 'k321') group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
select a1,a2,b,       max(c) from ts7 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c > 'b111') and (c <= 'g112') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c < 'c5') or (c = 'g412') or (c = 'k421') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where ((c > 'b111') and (c <= 'g112')) or ((c > 'd000') and (c <= 'i110')) group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (c between 'b111' and 'g112') or (c between 'd000' and 'i110') group by a1,a2,b;

select a1,a2,b,       max(c) from ts8 where (c > 'b1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c > 'b1') group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where (c > 'f123') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c > 'f123') group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where (c < 'a0') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c < 'a0') group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where (c < 'k321') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c < 'k321') group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c < 'a0') or (c > 'b1') group by a1,a2,b;
select a1,a2,b,       max(c) from ts8 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c > 'b1') or (c <= 'g1') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c > 'b111') and (c <= 'g112') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (c < 'c5') or (c = 'g412') or (c = 'k421') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where ((c > 'b111') and (c <= 'g112')) or ((c > 'd000') and (c <= 'i110')) group by a1,a2,b;

# #--analyze the sub-select
#--explain select a1,a2,b,min(c),max(c) from ts7 where exists ( select * from ts8 where ts8.c = ts7.c ) group by a1,a2,b;

# the sub-select is unrelated to MIN/MAX
#--explain select a1,a2,b,min(c),max(c) from ts7 where exists ( select * from ts8 where ts8.c > 'b1' ) group by a1,a2,b;


# A,B,C) Predicates referencing mixed classes of attributes
# plans
#--explain select a1,a2,b,min(c),max(c) from ts7 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (a1 >= 'c' or a2 < 'b') and (c > 'b111') group by a1,a2,b;
#--explain select a1,a2,b,min(c),max(c) from ts7 where (a2 >= 'b') and (b = 'a') and (c > 'b111') group by a1,a2,b;
#--explain select a1,a2,b,min(c) from ts7 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c < 'h112') or (c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122')) group by a1,a2,b;
#--explain select a1,a2,b,min(c) from ts7 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122') or (c < 'h112') or (c = 'c111')) group by a1,a2,b;
#--explain select a1,a2,b,min(c) from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;
#--explain select a1,a2,b,min(c) from ts7 where (ord(a1) > 97) and (ord(a2) + ord(a1) > 194) and (b = 'c') group by a1,a2,b;

#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (a1 >= 'c' or a2 < 'b') and (c > 'b111') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c),max(c) from ts8 where (a2 >= 'b') and (b = 'a') and (c > 'b111') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c) from ts8 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c < 'h112') or (c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122')) group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c) from ts8 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122') or (c < 'h112') or (c = 'c111')) group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,min(c) from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;

# queries
select a1,a2,b,min(c),max(c) from ts7 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (a1 >= 'c' or a2 < 'b') and (c > 'b111') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts7 where (a2 >= 'b') and (b = 'a') and (c > 'b111') group by a1,a2,b;
select a1,a2,b,min(c) from ts7 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c < 'h112') or (c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122')) group by a1,a2,b;
select a1,a2,b,min(c) from ts7 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122') or (c < 'h112') or (c = 'c111')) group by a1,a2,b;
select a1,a2,b,min(c) from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;
select a1,a2,b,min(c) from ts7 where (ord(a1) > 97) and (ord(a2) + ord(a1) > 194) and (b = 'c') group by a1,a2,b;

select a1,a2,b,min(c),max(c) from ts8 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (a1 >= 'c' or a2 < 'b') and (c > 'b111') group by a1,a2,b;
select a1,a2,b,min(c),max(c) from ts8 where (a2 >= 'b') and (b = 'a') and (c > 'b111') group by a1,a2,b;
select a1,a2,b,min(c) from ts8 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c < 'h112') or (c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122')) group by a1,a2,b;
select a1,a2,b,min(c) from ts8 where ((a1 > 'a') or (a1 < '9'))  and ((a2 >= 'b') and (a2 < 'z')) and (b = 'a') and ((c = 'j121') or (c > 'k121' and c < 'm122') or (c > 'o122') or (c < 'h112') or (c = 'c111')) group by a1,a2,b;
select a1,a2,b,min(c) from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;


#
# GROUP BY queries without MIN/MAX
#

# plans
#--explain select a1,a2,b from ts7 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
#--explain select a1,a2,b from ts7 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;

#--explain select a1,a2,b,c from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
#--explain select a1,a2,b from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;

#--replace_column 10 #
#--explain select a1,a2,b from ts8 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b from ts8 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b,c from ts8 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
#--replace_column 10 #
#--explain select a1,a2,b from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;

# queries
select a1,a2,b from ts7 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
select a1,a2,b from ts7 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
select a1,a2,b,c from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
select a1,a2,b from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;

select a1,a2,b from ts8 where (a1 >= 'c' or a2 < 'b') and (b > 'a') group by a1,a2,b;
select a1,a2,b from ts8 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
select a1,a2,b,c from ts8 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
select a1,a2,b from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;

#
# DISTINCT queries
#

# plans
#--explain select distinct a1,a2,b from ts7;
#--explain select distinct a1,a2,b from ts7 where (a2 >= 'b') and (b = 'a');
#--explain extended select distinct a1,a2,b,c from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121');
#--explain select distinct a1,a2,b from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c');
#--explain select distinct b from ts7 where (a2 >= 'b') and (b = 'a');

#--replace_column 10 #
#--explain select distinct a1,a2,b from ts8;
#--replace_column 10 #
#--explain select distinct a1,a2,b from ts8 where (a2 >= 'b') and (b = 'a');
#--explain extended select distinct a1,a2,b,c from ts8 where (a2 >= 'b') and (b = 'a') and (c = 'i121');
#--replace_column 10 #
#--explain select distinct a1,a2,b from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c');
#--explain select distinct b from ts8 where (a2 >= 'b') and (b = 'a');

# queries
select distinct a1,a2,b from ts7;
select distinct a1,a2,b from ts7 where (a2 >= 'b') and (b = 'a');
select distinct a1,a2,b,c from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121');
select distinct a1,a2,b from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c');
select distinct b from ts7 where (a2 >= 'b') and (b = 'a');

select distinct a1,a2,b from ts8;
select distinct a1,a2,b from ts8 where (a2 >= 'b') and (b = 'a');
select distinct a1,a2,b,c from ts8 where (a2 >= 'b') and (b = 'a') and (c = 'i121');
select distinct a1,a2,b from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c');
select distinct b from ts8 where (a2 >= 'b') and (b = 'a');

# BUG #6303
select distinct t_00.a1 from ts7 t_00 where exists ( select * from ts8 where a1 = t_00.a1 );

# BUG #8532 - SELECT DISTINCT a, a causes server to crash
select distinct a1,a1 from ts7;
select distinct a2,a1,a2,a1 from ts7;
select distinct ts7.a1,ts8.a1 from ts7,ts8;


#
# DISTINCT queries with GROUP-BY
#

# plans

##--source include/turn_off_only_full_group_by.inc

#--explain select distinct a1,a2,b from ts7;
#--explain select distinct a1,a2,b from ts7 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
#--explain select distinct a1,a2,b,c from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
#--explain select distinct a1,a2,b from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;
#--explain select distinct b from ts7 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;

#--replace_column 10 #
#--explain select distinct a1,a2,b from ts8;
#--replace_column 10 #
#--explain select distinct a1,a2,b from ts8 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
#--replace_column 10 #
#--explain select distinct a1,a2,b,c from ts8 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
#--replace_column 10 #
#--explain select distinct a1,a2,b from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;
#--replace_column 10 #
#--explain select distinct b from ts8 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;

# queries
select distinct a1,a2,b from ts7;
select distinct a1,a2,b from ts7 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
select distinct a1,a2,b,c from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
select distinct a1,a2,b from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;
select distinct b from ts7 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;

select distinct a1,a2,b from ts8;
select distinct a1,a2,b from ts8 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;
select distinct a1,a2,b,c from ts8 where (a2 >= 'b') and (b = 'a') and (c = 'i121') group by a1,a2,b;
select distinct a1,a2,b from ts8 where (a1 > 'a') and (a2 > 'a') and (b = 'c') group by a1,a2,b;
select distinct b from ts8 where (a2 >= 'b') and (b = 'a') group by a1,a2,b;

##--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

#
# COUNT (DISTINCT cols) queries
#

#--explain select count(distinct a1,a2,b) from ts7 where (a2 >= 'b') and (b = 'a');
#--explain select count(distinct a1,a2,b,c) from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121');
#--explain extended select count(distinct a1,a2,b) from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c');
#--explain select count(distinct b) from ts7 where (a2 >= 'b') and (b = 'a');
#--explain extended select 98 + count(distinct a1,a2,b) from ts7 where (a1 > 'a') and (a2 > 'a');

select count(distinct a1,a2,b) from ts7 where (a2 >= 'b') and (b = 'a');
select count(distinct a1,a2,b,c) from ts7 where (a2 >= 'b') and (b = 'a') and (c = 'i121');
select count(distinct a1,a2,b) from ts7 where (a1 > 'a') and (a2 > 'a') and (b = 'c');
select count(distinct b) from ts7 where (a2 >= 'b') and (b = 'a');
select 98 + count(distinct a1,a2,b) from ts7 where (a1 > 'a') and (a2 > 'a');

#
# Queries with expressions in the select clause
#

#--explain select a1,a2,b, concat(min(c), max(c)) from ts7 where a1 < 'd' group by a1,a2,b;
#--explain select concat(a1,min(c)),b from ts7 where a1 < 'd' group by a1,a2,b;
#--explain select concat(a1,min(c)),b,max(c) from ts7 where a1 < 'd' group by a1,a2,b;
#--explain select concat(a1,a2),b,min(c),max(c) from ts7 where a1 < 'd' group by a1,a2,b;
#--explain select concat(ord(min(b)),ord(max(b))),min(b),max(b) from ts7 group by a1,a2;

select a1,a2,b, concat(min(c), max(c)) from ts7 where a1 < 'd' group by a1,a2,b;
select concat(a1,min(c)),b from ts7 where a1 < 'd' group by a1,a2,b;
select concat(a1,min(c)),b,max(c) from ts7 where a1 < 'd' group by a1,a2,b;
select concat(a1,a2),b,min(c),max(c) from ts7 where a1 < 'd' group by a1,a2,b;
select concat(ord(min(b)),ord(max(b))),min(b),max(b) from ts7 group by a1,a2;


#
# Negative examples: queries that should NOT be treated as optimizable by
# QUICK_GROUP_MIN_MAX_SELECT
#

# select a non-indexed attribute

#--source include/turn_off_only_full_group_by.inc

#--explain select a1,a2,b,d,min(c),max(c) from ts7 group by a1,a2,b;

#--explain select a1,a2,b,d from ts7 group by a1,a2,b;

# predicate that references an attribute that is after the MIN/MAX argument
# in the index
#--explain extended select a1,a2,min(b),max(b) from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') and (c > 'a111') group by a1,a2;

# predicate that references a non-indexed attribute
#--explain extended select a1,a2,b,min(c),max(c) from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') and (d > 'xy2') group by a1,a2,b;

#--explain extended select a1,a2,b,c from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') and (d > 'xy2') group by a1,a2,b,c;

# non-equality predicate for a non-group select attribute
#--explain select a1,a2,b,max(c),min(c) from ts8 where (a2 = 'a') and (b = 'b') or (b < 'b') group by a1;
#--explain extended select a1,a2,b from ts7 where (a1 = 'b' or a1 = 'd' or a1 = 'a' or a1 = 'c') and (a2 > 'a') and (c > 'a111') group by a1,a2,b;

# non-group field with an equality predicate that references a keypart after the
# MIN/MAX argument
#--explain select a1,a2,min(b),c from ts8 where (a2 = 'a') and (c = 'a111') group by a1; select a1,a2,min(b),c from ts8 where (a2 = 'a') and (c = 'a111') group by a1;

# disjunction for a non-group select attribute
#--explain select a1,a2,b,max(c),min(c) from ts8 where (a2 = 'a') and (b = 'b') or (b = 'a') group by a1;

#--source include/restore_sql_mode_after_turn_off_only_full_group_by.inc

# non-range predicate for the MIN/MAX attribute
#--explain select a1,a2,b,min(c),max(c) from ts8 where (c > 'a000') and (c <= 'd999') and (c like '_8__') group by a1,a2,b;

# not all attributes are indexed by one index
#--explain select a1, a2, b, c, min(d), max(d) from ts7 group by a1,a2,b,c;

# other aggregate functions than MIN/MAX
#--explain select a1,a2,count(a2) from ts7 group by a1,a2,b;
#--explain extended select a1,a2,count(a2) from ts7 where (a1 > 'a') group by a1,a2,b;
#--explain extended select sum(ord(a1)) from ts7 where (a1 > 'a') group by a1,a2,b;


#
# Bug #16710: select distinct doesn't return all it should
#

#--explain select distinct(a1) from ts7 where ord(a2) = 98;
select distinct(a1) from ts7 where ord(a2) = 98;

#
# BUG#11044: DISTINCT or GROUP BY queries with equality predicates instead of MIN/MAX.
#

#--explain select a1 from ts7 where a2 = 'b' group by a1;
select a1 from ts7 where a2 = 'b' group by a1;

#--explain select distinct a1 from ts7 where a2 = 'b';
select distinct a1 from ts7 where a2 = 'b';

#
# Bug #12672: primary key implcitly included in every innodb index
#
# Test case moved to group_min_max_innodb


#
# Bug #6142: a problem with the empty innodb table
#
# Test case moved to group_min_max_innodb


#
# Bug #9798: group by with rollup
#
# Test case moved to group_min_max_innodb


#
# Bug #13293 Wrongly used index results in endless loop.
#
# Test case moved to group_min_max_innodb


drop table ts7;
drop table ts8;
drop table ts9;

#
# Bug #14920 Ordering aggregated result sets with composite primary keys
# corrupts resultset
#
create table t1 (id int not null,c2 int not null, primary key(id,c2));
insert into t1 (id,c2) values (10,1),(10,2),(10,3),(20,4),(20,5),(20,6),(30,7),(30,8),(30,9);
select distinct id, c2 from t1 order by c2;
select id,min(c2) as c2 from t1 group by id order by c2;
select id,c2 from t1 group by id,c2 order by c2;
drop table t1;

#
# Bug #16203: Analysis for possible min/max optimization erroneously
#             returns impossible range
#

CREATE TABLE ts1 (a varchar(5), b int(11), PRIMARY KEY (a,b));
INSERT INTO ts1 VALUES ('AA',1), ('AA',2), ('AA',3), ('BB',1), ('AA',4);
OPTIMIZE TABLE ts1;

SELECT a FROM ts1 WHERE a='AA' GROUP BY a;
SELECT a FROM ts1 WHERE a='BB' GROUP BY a;

#--EXPLAIN SELECT a FROM ts1 WHERE a='AA' GROUP BY a;
#--EXPLAIN SELECT a FROM ts1 WHERE a='BB' GROUP BY a;

SELECT DISTINCT a FROM ts1 WHERE a='BB';
SELECT DISTINCT a FROM ts1 WHERE a LIKE 'B%';
SELECT a FROM ts1 WHERE a LIKE 'B%' GROUP BY a;

DROP TABLE ts1;


#
# Bug #15102: select distinct returns empty result, select count 
#             distinct > 0 (correct)
#

CREATE TABLE t0 (    a int(11) NOT NULL DEFAULT '0',    b varchar(16) COLLATE latin1_general_ci NOT NULL DEFAULT '',    PRIMARY KEY  (a,b)  ) engine=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

delimiter |;

CREATE PROCEDURE a(x INT) BEGIN   DECLARE rnd INT;   DECLARE cnt INT;    WHILE x > 0 DO     SET rnd= x % 100;     SET cnt = (SELECT COUNT(*) FROM t0 WHERE a = rnd);     INSERT INTO t0(a,b) VALUES (rnd, CAST(cnt AS CHAR));     SET x= x - 1;   END WHILE; END|

DELIMITER ;|

CALL a(1000);

SELECT a FROM t0 WHERE a=0;
SELECT DISTINCT a FROM t0 WHERE a=0;
SELECT COUNT(DISTINCT a) FROM t0 WHERE a=0;

DROP TABLE t0;
DROP PROCEDURE a;

#
# Bug #18068: SELECT DISTINCT
#

CREATE TABLE ts1 (a varchar(64) NOT NULL default '', PRIMARY KEY(a));
INSERT INTO ts1 (a) VALUES   (''), ('CENTRAL'), ('EASTERN'), ('GREATER LONDON'),   ('NORTH CENTRAL'), ('NORTH EAST'), ('NORTH WEST'), ('SCOTLAND'),   ('SOUTH EAST'), ('SOUTH WEST'), ('WESTERN');

#--EXPLAIN SELECT DISTINCT a,a FROM ts1 ORDER BY a;  
SELECT DISTINCT a,a FROM ts1 ORDER BY a;  

DROP TABLE ts1;

#
# Bug #21007: NATURAL JOIN (any JOIN (2 x NATURAL JOIN)) crashes the server
#

CREATE TABLE t11 (id1 INT, id2 INT);
CREATE TABLE t12 (id2 INT, id3 INT, id5 INT);
CREATE TABLE t13 (id3 INT, id4 INT);
CREATE TABLE t14 (id4 INT);
CREATE TABLE t15 (id5 INT, id6 INT);
CREATE TABLE t16 (id6 INT);

INSERT INTO t11 VALUES(1,1);
INSERT INTO t12 VALUES(1,1,1);
INSERT INTO t13 VALUES(1,1);
INSERT INTO t14 VALUES(1);
INSERT INTO t15 VALUES(1,1);
INSERT INTO t16 VALUES(1);

# original bug query
SELECT * FROM t11   NATURAL JOIN (t12 JOIN (t13 NATURAL JOIN t14, t15 NATURAL JOIN t16)     ON (t13.id3 = t12.id3 AND t15.id5 = t12.id5));

# inner join swapped
SELECT * FROM t11   NATURAL JOIN (((t13 NATURAL JOIN t14) join (t15 NATURAL JOIN t16) on t13.id4 = t15.id5) JOIN t12     ON (t13.id3 = t12.id3 AND t15.id5 = t12.id5));

# one join less, no ON cond
SELECT * FROM t11 NATURAL JOIN ((t13 join (t15 NATURAL JOIN t16)) JOIN t12);

# wrong error message: 'id2' - ambiguous column
SELECT * FROM (t12 JOIN (t13 NATURAL JOIN t14, t15 NATURAL JOIN t16)     ON (t13.id3 = t12.id3 AND t15.id5 = t12.id5))   NATURAL JOIN t11;
SELECT * FROM (t12 JOIN ((t13 NATURAL JOIN t14) join (t15 NATURAL JOIN t16)))   NATURAL JOIN t11;

DROP TABLE t11;
DROP TABLE t12;
DROP TABLE t13;
DROP TABLE t14;
DROP TABLE t15;
DROP TABLE t16;

#
# Bug#22342: No results returned for query using max and group by
#
CREATE TABLE t8 (a int, b int, PRIMARY KEY (a,b), KEY b (b));
INSERT INTO t8 VALUES (1,1),(1,2),(1,0),(1,3);
INSERT INTO t8 VALUES (2,1),(2,2),(2,0),(2,3);
INSERT INTO t8 VALUES (3,1),(3,2),(3,0),(3,3);
#--analyze TABLE t8;

#--explain SELECT MAX(b), a FROM t8 WHERE b < 2 AND a = 1 GROUP BY a;
SELECT MAX(b), a FROM t8 WHERE b < 2 AND a = 1 GROUP BY a;
SELECT MIN(b), a FROM t8 WHERE b > 1 AND a = 1 GROUP BY a;
CREATE TABLE t9 (a int, b int, c int, PRIMARY KEY (a,b,c));
INSERT INTO t9 SELECT a,b,b FROM t8;
#--analyze TABLE t9;
#--explain SELECT MIN(c) FROM t9 WHERE b = 2 and a = 1 and c > 1 GROUP BY a;
SELECT MIN(c) FROM t9 WHERE b = 2 and a = 1 and c > 1 GROUP BY a;

DROP TABLE t8;
DROP TABLE t9;

#
# Bug#24156: Loose index scan not used with CREATE TABLE ...SELECT and similar statements
#

CREATE TABLE t0 (a INT, b INT, INDEX (a,b));
INSERT INTO t0 (a, b) VALUES (1,1), (1,2), (1,3), (1,4), (1,5),(2,2), (2,3), (2,1), (3,1), (4,1), (4,2), (4,3), (4,4), (4,5), (4,6),  (5,1), (5,2), (5,3), (5,4), (5,5);
#--EXPLAIN SELECT max(b), a FROM t0 GROUP BY a;
FLUSH STATUS;
SELECT max(b), a FROM t0 GROUP BY a;
SHOW STATUS LIKE 'handler_read__e%';
#--EXPLAIN SELECT max(b), a FROM t0 GROUP BY a;
SELECT max(b), a FROM t0 GROUP BY a;
FLUSH STATUS;
CREATE TABLE t8 SELECT max(b), a FROM t0 GROUP BY a;
SHOW STATUS LIKE 'handler_read__e%';
FLUSH STATUS;
SELECT * FROM (SELECT max(b), a FROM t0 GROUP BY a) b;
SHOW STATUS LIKE 'handler_read__e%';
FLUSH STATUS;
(SELECT max(b), a FROM t0 GROUP BY a) UNION  (SELECT max(b), a FROM t0 GROUP BY a);
SHOW STATUS LIKE 'handler_read__e%';
#--EXPLAIN (SELECT max(b), a FROM t0 GROUP BY a) UNION  (SELECT max(b), a FROM t0 GROUP BY a);

#--EXPLAIN SELECT (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2) x   FROM t0 AS t0_outer;
#--EXPLAIN SELECT 1 FROM t0 AS t0_outer WHERE EXISTS   (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2);
#--EXPLAIN SELECT 1 FROM t0 AS t0_outer WHERE   (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2) > 12;
#--EXPLAIN SELECT 1 FROM t0 AS t0_outer WHERE   a IN (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2);
#--EXPLAIN SELECT 1 FROM t0 AS t0_outer GROUP BY a HAVING   a > (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2);
#--EXPLAIN SELECT 1 FROM t0 AS t0_outer1 JOIN t0 AS t0_outer2    ON t0_outer1.a = (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2)    AND t0_outer1.b = t0_outer2.b;
#--EXPLAIN SELECT (SELECT (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2) x   FROM t0 AS t0_outer) x2 FROM t0 AS t0_outer2;
SELECT (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2) x   FROM t0 AS t0_outer;
SELECT 1 FROM t0 AS t0_outer WHERE EXISTS   (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2);
SELECT 1 FROM t0 AS t0_outer WHERE   (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2) > 12;
SELECT 1 FROM t0 AS t0_outer WHERE   a IN (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2);
SELECT 1 FROM t0 AS t0_outer GROUP BY a HAVING   a > (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2);
SELECT 1 FROM t0 AS t0_outer1 JOIN t0 AS t0_outer2    ON t0_outer1.a = (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2)    AND t0_outer1.b = t0_outer2.b;
SELECT (SELECT (SELECT max(b) FROM t0 GROUP BY a HAVING a < 2) x   FROM t0 AS t0_outer) x2 FROM t0 AS t0_outer2;

CREATE TABLE t9 LIKE t0;
FLUSH STATUS;
INSERT INTO t9 SELECT a,MAX(b) FROM t0 GROUP BY a;
SHOW STATUS LIKE 'handler_read__e%';
DE# -- # -- letE FROM t9;
FLUSH STATUS;
INSERT INTO t9 SELECT 1, (SELECT MAX(b) FROM t0 GROUP BY a HAVING a < 2)   FROM t0 LIMIT 1;
SHOW STATUS LIKE 'handler_read__e%';
FLUSH STATUS;
DE# -- # -- letE FROM t9 WHERE (SELECT MAX(b) FROM t0 GROUP BY a HAVING a < 2) > 10000;
SHOW STATUS LIKE 'handler_read__e%';
FLUSH STATUS;
#--error ER_SUBQUERY_NO_1_ROW
DE# -- # -- letE FROM t9 WHERE (SELECT (SELECT MAX(b) FROM t0 GROUP BY a HAVING a < 2) x                       FROM t0) > 10000; SHOW STATUS LIKE 'handler_read__e%';

DROP TABLE t0;
DROP TABLE t8;
DROP TABLE t9;

#
# Bug#25602: queries with DISTINCT and SQL_BIG_RESULT hint 
#            for which loose scan optimization is applied
#

CREATE TABLE t0 (a int, INDEX idx(a));
INSERT INTO t0 VALUES   (4), (2), (1), (2), (4), (2), (1), (4),   (4), (2), (1), (2), (2), (4), (1), (4),   (4), (2), (1), (2), (2), (4), (1), (4);

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT DISTINCT(a) FROM t0;
SELECT DISTINCT(a) FROM t0;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT SQL_BIG_RESULT DISTINCT(a) FROM t0;
SELECT SQL_BIG_RESULT DISTINCT(a) FROM t0;

DROP TABLE t0;

#
# Bug #32268: Indexed queries give bogus MIN and MAX results
#

CREATE TABLE t0 (a INT, b INT);
INSERT INTO t0 (a, b) VALUES (1,1), (1,2), (1,3);
#-- INSERT INTO t0 SELECT a + 1, b FROM t0;
insert into t0 values(2,1),(2,2),(2,3);
#-- INSERT INTO t0 SELECT a + 2, b FROM t0;
insert into t0 values(3,1),(3,2),(3,3),(4,1),(4,2),(4,3);
#-- INSERT INTO t0 SELECT a + 4, b FROM t0;
insert into t0 values(5,1),(5,2),(5,3),(6,1),(6,2),(6,3),(7,1),(7,2),(7,3),(8,1),(8,2),(8,3);

#--EXPLAIN
SELECT a, MIN(b), MAX(b) FROM t0 GROUP BY a ORDER BY a DESC;
SELECT a, MIN(b), MAX(b) FROM t0 GROUP BY a ORDER BY a DESC;

CREATE INDEX break_it ON t0 (a, b);

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN
SELECT a, MIN(b), MAX(b) FROM t0 GROUP BY a ORDER BY a;
SELECT a, MIN(b), MAX(b) FROM t0 GROUP BY a ORDER BY a;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN
SELECT a, MIN(b), MAX(b) FROM t0 GROUP BY a ORDER BY a DESC;
SELECT a, MIN(b), MAX(b) FROM t0 GROUP BY a ORDER BY a DESC;

#--EXPLAIN
SELECT a, MIN(b), MAX(b), AVG(b) FROM t0 GROUP BY a ORDER BY a DESC;
SELECT a, MIN(b), MAX(b), AVG(b) FROM t0 GROUP BY a ORDER BY a DESC;

DROP TABLE t0;

#
# Bug#38195: Incorrect handling of aggregate functions when loose index scan is
#            used causes server crash.
#
create table t0 (a int, b int, primary key (a,b), key `index` (a,b)) engine=InnoDB;
insert into  t0 (a,b) values (0,0),(0,1),(0,2),(0,3),(0,4),(0,5),(0,6),   (0,7),(0,8),(0,9),(0,10),(0,11),(0,12),(0,13), (1,0),(1,1),(1,2),(1,3),(1,4),(1,5),(1,6),   (1,7),(1,8),(1,9),(1,10),(1,11),(1,12),(1,13), (2,0),(2,1),(2,2),(2,3),(2,4),(2,5),(2,6),   (2,7),(2,8),(2,9),(2,10),(2,11),(2,12),(2,13), (3,0),(3,1),(3,2),(3,3),(3,4),(3,5),(3,6),   (3,7),(3,8),(3,9),(3,10),(3,11),(3,12),(3,13);

#-- insert into t0 (a,b) select a, max(b)+1 from t0 where a = 0 group by a;
select sql_buffer_result a, max(b)+1 from t0 where a = 0 group by a;
select * from t0;
#--explain extended select sql_buffer_result a, max(b)+1 from t0 where a = 0 group by a;

drop table t0;


#
# Bug #41610: key_infix_len can be overwritten causing some group by queries
# to return no rows
#

CREATE TABLE t0 (a int, b int, c int, d int,   KEY foo (c,d,a,b), KEY bar (c,a,b,d));

INSERT INTO t0 VALUES (1, 1, 1, 1), (1, 1, 1, 2), (1, 1, 1, 3), (1, 1, 1, 4);
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT a,b,c+1,d FROM t0;

#Should be non-empty
# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT DISTINCT c FROM t0 WHERE d=4;
SELECT DISTINCT c FROM t0 WHERE d=4;

DROP TABLE t0;

#--echo #
#--echo # Bug #45386: Wrong query result with MIN function in field list, 
#--echo #  WHERE and GROUP BY clause
#--echo #

CREATE TABLE t0 (a INT, b INT, INDEX (a,b));
INSERT INTO t0 VALUES (2,0), (2,0), (2,1), (2,1);
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;

#--echo # test MIN
#--echo #should use range with index for group by
# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT a, MIN(b) FROM t0 WHERE b <> 0 GROUP BY a;
#--echo #should return 1 row
SELECT a, MIN(b) FROM t0 WHERE b <> 0 GROUP BY a;

#--echo # test MAX
#--echo #should use range with index for group by
# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT a, MAX(b) FROM t0 WHERE b <> 1 GROUP BY a;
#--echo #should return 1 row
SELECT a, MAX(b) FROM t0 WHERE b <> 1 GROUP BY a;

#--echo # test 3 ranges and use the middle one
INSERT INTO t0 SELECT a, 2 FROM t0;

#--echo #should use range with index for group by
# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT a, MAX(b) FROM t0 WHERE b > 0 AND b < 2 GROUP BY a;
#--echo #should return 1 row
SELECT a, MAX(b) FROM t0 WHERE b > 0 AND b < 2 GROUP BY a;

DROP TABLE t0;

#--echo #
#--echo # Bug #48472: Loose index scan inappropriately chosen for some WHERE
#--echo #             conditions
#--echo # 

CREATE TABLE t0 (a INT, b INT, INDEX (a,b));
INSERT INTO t0 VALUES (2,0), (2,0), (2,1), (2,1);
INSERT INTO t0 SELECT * FROM t0;                                   

SELECT a, MAX(b) FROM t0 WHERE 0=b+0 GROUP BY a;

DROP TABLE t0;

#--echo End of 5.0 tests

#--echo #
#--echo # Bug #46607: Assertion failed: (cond_type == Item::FUNC_ITEM) results in
#--echo #              server crash
#--echo #

CREATE TABLE t0 (a INT, b INT, INDEX (a,b));
INSERT INTO t0 VALUES (2,0), (2,0), (2,1), (2,1);
INSERT INTO t0 SELECT * FROM t0;

SELECT a, MAX(b) FROM t0 WHERE b GROUP BY a;

DROP TABLE t0;

#
# BUG#49902 - SELECT returns incorrect results
#
CREATE TABLE t0(a INT NOT NULL, b INT NOT NULL, KEY (b));
INSERT INTO t0 VALUES(1,1),(2,1);
#--analyze TABLE t0;
SELECT 1 AS c, b FROM t0 WHERE b IN (1,2) GROUP BY c, b;
SELECT a FROM t0 WHERE b=1;
DROP TABLE t0;

#--echo # 
#--echo # Bug#47762: Incorrect result from MIN() when WHERE tests NOT NULL column
#--echo #            for NULL
#--echo #

#--echo ## Test for NULLs allowed
CREATE TABLE t0 ( a INT, KEY (a) );
INSERT INTO t0 VALUES (1), (2), (3);
#--source include/min_null_cond.inc
INSERT INTO t0 VALUES (NULL), (NULL);
#--source include/min_null_cond.inc
DROP TABLE t0;

#--echo ## Test for NOT NULLs
CREATE TABLE t0 ( a INT NOT NULL PRIMARY KEY);
INSERT INTO t0 VALUES (1), (2), (3);
#--echo #
#--echo # NULL-safe operator test disabled for non-NULL indexed columns.
#--echo #
#--echo # See bugs
#--echo #
#--echo # - Bug#52173: Reading NULL value from non-NULL index gives
#--echo #   wrong result in embedded server 
#--echo #
#--echo # - Bug#52174: Sometimes wrong plan when reading a MAX value from 
#--echo #   non-NULL index
#--echo #
#-- let  $skip_null_safe_test= 1
#--source include/min_null_cond.inc
DROP TABLE t0;

#--echo #
#--echo # Bug#53859: Valgrind: opt_sum_query(TABLE_LIST*, List<Item>&, Item*) at
#--echo # opt_sum.cc:305
#--echo #
CREATE TABLE t0 ( a INT, KEY (a) );
INSERT INTO t0 VALUES (1), (2), (3); 

SELECT MIN( a ) AS min_a FROM t0 WHERE a > 1 AND a IS NULL ORDER BY min_a;

DROP TABLE t0;


#--echo End of 5.1 tests


#--echo #
#--echo # WL#3220 (Loose index scan for COUNT DISTINCT)
#--echo #

CREATE TABLE t0 (a INT, b INT, c INT, KEY (a,b));
INSERT INTO t0 VALUES (1,1,1), (1,2,1), (1,3,1), (1,4,1);
INSERT INTO t0 SELECT a, b + 4, 1 FROM t0;
INSERT INTO t0 SELECT a + 1, b, 1 FROM t0;
INSERT INTO t0 SELECT a + 2, b + 8, 1 FROM t0;

CREATE TABLE t8 (a INT, b INT, c INT, d INT, e INT, f INT, KEY (a,b,c));
INSERT INTO t8 VALUES (1,1,1,1,1,1), (1,2,1,1,1,1), (1,3,1,1,1,1),(1,4,1,1,1,1);
INSERT INTO t8 SELECT a, b + 4, c,d,e,f FROM t8;
INSERT INTO t8 SELECT a + 1, b, c,d,e,f FROM t8;
INSERT INTO t8 SELECT a + 2, b + 8, c,d,e,f FROM t8;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a) FROM t0; SELECT COUNT(DISTINCT a) FROM t0;
SELECT COUNT(DISTINCT a) FROM t0; SELECT COUNT(DISTINCT a) FROM t0;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a,b) FROM t0; SELECT COUNT(DISTINCT a,b) FROM t0;
SELECT COUNT(DISTINCT a,b) FROM t0; SELECT COUNT(DISTINCT a,b) FROM t0;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT b,a) FROM t0; SELECT COUNT(DISTINCT b,a) FROM t0;
SELECT COUNT(DISTINCT b,a) FROM t0; SELECT COUNT(DISTINCT b,a) FROM t0;

#--EXPLAIN SELECT COUNT(DISTINCT b) FROM t0; SELECT COUNT(DISTINCT b) FROM t0;
SELECT COUNT(DISTINCT b) FROM t0; SELECT COUNT(DISTINCT b) FROM t0;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a) FROM t0 GROUP BY a; SELECT COUNT(DISTINCT a) FROM t0 GROUP BY a;
SELECT COUNT(DISTINCT a) FROM t0 GROUP BY a; SELECT COUNT(DISTINCT a) FROM t0 GROUP BY a;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT b) FROM t0 GROUP BY a; SELECT COUNT(DISTINCT b) FROM t0 GROUP BY a;
SELECT COUNT(DISTINCT b) FROM t0 GROUP BY a; SELECT COUNT(DISTINCT b) FROM t0 GROUP BY a;

#--EXPLAIN SELECT COUNT(DISTINCT a) FROM t0 GROUP BY b; SELECT COUNT(DISTINCT a) FROM t0 GROUP BY b;
SELECT COUNT(DISTINCT a) FROM t0 GROUP BY b; SELECT COUNT(DISTINCT a) FROM t0 GROUP BY b;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT DISTINCT COUNT(DISTINCT a) FROM t0; SELECT DISTINCT COUNT(DISTINCT a) FROM t0;
SELECT DISTINCT COUNT(DISTINCT a) FROM t0; SELECT DISTINCT COUNT(DISTINCT a) FROM t0;

#--EXPLAIN SELECT COUNT(DISTINCT a, b + 0) FROM t0; SELECT COUNT(DISTINCT a, b + 0) FROM t0;
SELECT COUNT(DISTINCT a, b + 0) FROM t0; SELECT COUNT(DISTINCT a, b + 0) FROM t0;

#--EXPLAIN SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT b) < 20; SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT b) < 20;
SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT b) < 20; SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT b) < 20;

#--EXPLAIN SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT c) < 10; SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT c) < 10;
SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT c) < 10; SELECT COUNT(DISTINCT a) FROM t0 HAVING COUNT(DISTINCT c) < 10;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT 1 FROM t0 HAVING COUNT(DISTINCT a) < 10; SELECT 1 FROM t0 HAVING COUNT(DISTINCT a) < 10;
SELECT 1 FROM t0 HAVING COUNT(DISTINCT a) < 10; SELECT 1 FROM t0 HAVING COUNT(DISTINCT a) < 10;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT 1 FROM t0 GROUP BY a HAVING COUNT(DISTINCT b) > 1; SELECT 1 FROM t0 GROUP BY a HAVING COUNT(DISTINCT b) > 1;
SELECT 1 FROM t0 GROUP BY a HAVING COUNT(DISTINCT b) > 1; SELECT 1 FROM t0 GROUP BY a HAVING COUNT(DISTINCT b) > 1;

#--EXPLAIN SELECT COUNT(DISTINCT t0_1.a) FROM t0 t0_1, t0 t0_2 GROUP BY t0_1.a; SELECT COUNT(DISTINCT t0_1.a) FROM t0 t0_1, t0 t0_2 GROUP BY t0_1.a;
SELECT COUNT(DISTINCT t0_1.a) FROM t0 t0_1, t0 t0_2 GROUP BY t0_1.a; SELECT COUNT(DISTINCT t0_1.a) FROM t0 t0_1, t0 t0_2 GROUP BY t0_1.a;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a), 12 FROM t0; SELECT COUNT(DISTINCT a), 12 FROM t0;
SELECT COUNT(DISTINCT a), 12 FROM t0; SELECT COUNT(DISTINCT a), 12 FROM t0;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a, b, c) FROM t8; SELECT COUNT(DISTINCT a, b, c) FROM t8;
SELECT COUNT(DISTINCT a, b, c) FROM t8; SELECT COUNT(DISTINCT a, b, c) FROM t8;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT a) FROM t8; SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT a) FROM t8;
SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT a) FROM t8; SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT a) FROM t8;

#--EXPLAIN SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT f) FROM t8; SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT f) FROM t8;
SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT f) FROM t8; SELECT COUNT(DISTINCT a), SUM(DISTINCT a), AVG(DISTINCT f) FROM t8;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, a) FROM t8; SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, a) FROM t8;
SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, a) FROM t8; SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, a) FROM t8;

#--EXPLAIN SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, f) FROM t8; SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, f) FROM t8;
SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, f) FROM t8; SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, f) FROM t8;

#--EXPLAIN SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, d) FROM t8; SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, d) FROM t8;
SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, d) FROM t8; SELECT COUNT(DISTINCT a, b), COUNT(DISTINCT b, d) FROM t8;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT a, c, COUNT(DISTINCT c, a, b) FROM t8 GROUP BY a, b, c; SELECT a, c, COUNT(DISTINCT c, a, b) FROM t8 GROUP BY a, b, c;
SELECT a, c, COUNT(DISTINCT c, a, b) FROM t8 GROUP BY a, b, c; SELECT a, c, COUNT(DISTINCT c, a, b) FROM t8 GROUP BY a, b, c;

#--EXPLAIN SELECT COUNT(DISTINCT c, a, b) FROM t8   WHERE a > 5 AND b BETWEEN 10 AND 20 GROUP BY a, b, c; SELECT COUNT(DISTINCT c, a, b) FROM t8   WHERE a > 5 AND b BETWEEN 10 AND 20 GROUP BY a, b, c;
SELECT COUNT(DISTINCT c, a, b) FROM t8   WHERE a > 5 AND b BETWEEN 10 AND 20 GROUP BY a, b, c; SELECT COUNT(DISTINCT c, a, b) FROM t8   WHERE a > 5 AND b BETWEEN 10 AND 20 GROUP BY a, b, c;

#--EXPLAIN SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 WHERE a = 5   GROUP BY b; SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 WHERE a = 5   GROUP BY b;
SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 WHERE a = 5   GROUP BY b; SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 WHERE a = 5   GROUP BY b;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT a, COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a; SELECT a, COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a;
SELECT a, COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a; SELECT a, COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a; SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a;
SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a; SELECT COUNT(DISTINCT b), SUM(DISTINCT b) FROM t8 GROUP BY a;

#--EXPLAIN SELECT COUNT(DISTINCT a, b) FROM t8 WHERE c = 13 AND d = 42; SELECT COUNT(DISTINCT a, b) FROM t8 WHERE c = 13 AND d = 42;
SELECT COUNT(DISTINCT a, b) FROM t8 WHERE c = 13 AND d = 42; SELECT COUNT(DISTINCT a, b) FROM t8 WHERE c = 13 AND d = 42;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT a, COUNT(DISTINCT a), SUM(DISTINCT a) FROM t8   WHERE b = 13 AND c = 42 GROUP BY a; SELECT a, COUNT(DISTINCT a), SUM(DISTINCT a) FROM t8   WHERE b = 13 AND c = 42 GROUP BY a;
SELECT a, COUNT(DISTINCT a), SUM(DISTINCT a) FROM t8   WHERE b = 13 AND c = 42 GROUP BY a; SELECT a, COUNT(DISTINCT a), SUM(DISTINCT a) FROM t8   WHERE b = 13 AND c = 42 GROUP BY a;

#--echo # This query could have been resolved using loose index scan since
#--echo # the second part of count(..) is defined by a constant predicate
#--EXPLAIN SELECT COUNT(DISTINCT a, b), SUM(DISTINCT a) FROM t8 WHERE b = 42; SELECT COUNT(DISTINCT a, b), SUM(DISTINCT a) FROM t8 WHERE b = 42;
SELECT COUNT(DISTINCT a, b), SUM(DISTINCT a) FROM t8 WHERE b = 42; SELECT COUNT(DISTINCT a, b), SUM(DISTINCT a) FROM t8 WHERE b = 42;

#--EXPLAIN SELECT SUM(DISTINCT a), MAX(b) FROM t8 GROUP BY a; SELECT SUM(DISTINCT a), MAX(b) FROM t8 GROUP BY a;
SELECT SUM(DISTINCT a), MAX(b) FROM t8 GROUP BY a; SELECT SUM(DISTINCT a), MAX(b) FROM t8 GROUP BY a;

# On 32 bit platform the rows estimate is 10 vs 11 on 64 bit platforms.
#--replace_result 11 10
#--EXPLAIN SELECT 42 * (a + c + COUNT(DISTINCT c, a, b)) FROM t8 GROUP BY a, b, c; SELECT 42 * (a + c + COUNT(DISTINCT c, a, b)) FROM t8 GROUP BY a, b, c;
SELECT 42 * (a + c + COUNT(DISTINCT c, a, b)) FROM t8 GROUP BY a, b, c; SELECT 42 * (a + c + COUNT(DISTINCT c, a, b)) FROM t8 GROUP BY a, b, c;

#--EXPLAIN SELECT (SUM(DISTINCT a) + MAX(b)) FROM t8 GROUP BY a; SELECT (SUM(DISTINCT a) + MAX(b)) FROM t8 GROUP BY a;
SELECT (SUM(DISTINCT a) + MAX(b)) FROM t8 GROUP BY a; SELECT (SUM(DISTINCT a) + MAX(b)) FROM t8 GROUP BY a;

DROP TABLE t0;
DROP TABLE t8;

#--echo # end of WL#3220 tests

#--echo #
#--echo # Bug#50539: Wrong result when loose index scan is used for an aggregate
#--echo #            function with distinct
#--echo #
CREATE TABLE t1 (   id int(11) NOT NULL DEFAULT '0',   f2 char(1) NOT NULL DEFAULT '',   PRIMARY KEY (id,f2) ) ;
insert into t1 values(1,'A'),(1 , 'B'), (1, 'C'), (2, 'A'), (3, 'A'), (3, 'B'), (3, 'C'), (3, 'D');

SELECT id, COUNT(DISTINCT f2) FROM t1 GROUP BY id;
#--explain SELECT id, COUNT(DISTINCT f2) FROM t1 GROUP BY id;
 
drop table t1;
#--echo # End of test#50539.

#--echo #
#--echo # Bug#18497308 WRONG COST ESTIMATE FOR LOOSE INDEX SCAN WHEN
#--echo #              INDEX STATISTICS IS MISSING
#--echo #

CREATE TABLE t0 (   a INTEGER,   b INTEGER,   c INTEGER,   d INTEGER,   KEY foo (a,b,c,d) ) engine=InnoDB;

INSERT INTO t0 VALUES (1, 1, 1, 1), (1, 2, 1, 2), (1, 3, 1, 3), (1, 4, 1, 4);
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;
INSERT INTO t0 SELECT * FROM t0;

#-- let query= SELECT DISTINCT a FROM t0 WHERE b=4;

#--eval #--EXPLAIN $query;
#--eval $query;
SELECT DISTINCT a FROM t0 WHERE b=4;

DROP TABLE t0;

#--echo #
#--echo # Bug#17217128 -  BAD INTERACTION BETWEEN MIN/MAX AND
#--echo #                 "HAVING SUM(DISTINCT)": WRONG RESULTS.
#--echo #

CREATE TABLE t0 (a INT, b INT, KEY(a,b));
INSERT INTO t0 VALUES (1,1), (2,2), (3,3), (4,4), (1,0), (3,2), (4,5);
#-- let $DEFAULT_TRACE_MEM_SIZE=1048576; # 1MB
#--eval set optimizer_trace_max_mem_size=$DEFAULT_TRACE_MEM_SIZE;
set @@session.optimizer_trace='enabled=on';
set end_markers_in_json=on;

#--analyze TABLE t0;

SELECT a, SUM(DISTINCT a), MIN(b) FROM t0 GROUP BY a;
#--EXPLAIN SELECT a, SUM(DISTINCT a), MIN(b) FROM t0 GROUP BY a;
SELECT TRACE RLIKE 'have_both_agg_distinct_and_min_max' AS OK   FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SELECT a, SUM(DISTINCT a), MAX(b) FROM t0 GROUP BY a;
#--EXPLAIN SELECT a, SUM(DISTINCT a), MAX(b) FROM t0 GROUP BY a;
SELECT TRACE RLIKE 'have_both_agg_distinct_and_min_max' AS OK   FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SELECT a, MAX(b) FROM t0 GROUP BY a HAVING SUM(DISTINCT a);
#--EXPLAIN SELECT a, MAX(b) FROM t0 GROUP BY a HAVING SUM(DISTINCT a);
SELECT TRACE RLIKE 'have_both_agg_distinct_and_min_max' AS OK   FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SELECT SUM(DISTINCT a), MIN(b), MAX(b) FROM t0;
#--EXPLAIN SELECT SUM(DISTINCT a), MIN(b), MAX(b) FROM t0;
SELECT TRACE RLIKE 'have_both_agg_distinct_and_min_max' AS OK   FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SELECT a, SUM(DISTINCT a), MIN(b), MAX(b) FROM t0 GROUP BY a;
#--EXPLAIN SELECT a, SUM(DISTINCT a), MIN(b), MAX(b) FROM t0 GROUP BY a;
SELECT TRACE RLIKE 'have_both_agg_distinct_and_min_max' AS OK   FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SET optimizer_trace_max_mem_size=DEFAULT;
SET optimizer_trace=DEFAULT;
SET end_markers_in_json=DEFAULT;

DROP TABLE t0;

#--echo #
#--echo # Bug #18066518: THE COST VALUE IS A NEGATIVE NUMBER FOR MERGE ENGINE
#--echo #                TABLE
#--echo #
CREATE TABLE t0(a INT PRIMARY KEY)   ENGINE = MERGE;
#--EXPLAIN SELECT DISTINCT(a) FROM t0;
SELECT DISTINCT(a) FROM t0;
DROP TABLE t0;
#--echo # End of test#18066518.

#--echo #
#--echo # Bug #18486293: ASSERTION FAILED: KEYS >= 0.0 IN
#--echo #                COST_MODEL_TABLE::KEY_COMPARE_COST
#--echo #
CREATE TABLE t7 (b INT, KEY b_key (b)) ENGINE=INNODB   PARTITION BY RANGE COLUMNS(b) (PARTITION p_part VALUES LESS THAN (0)); SELECT 1 FROM t7 WHERE b IN ('') GROUP BY  b ;
DROP TABLE t7;
#--echo # End of test#18486293.

#--echo #
#--echo # Bug#18109609: LOOSE INDEX SCAN IS NOT USED WHEN IT SHOULD
#--echo #

CREATE TABLE t1 ( id INT AUTO_INCREMENT PRIMARY KEY, c1 INT, c2 INT, KEY(c1,c2));

INSERT INTO t1(c1,c2) VALUES (1, 1), (1,2), (2,1), (2,2), (3,1), (3,2), (3,3), (4,1), (4,2), (4,3), (4,4), (4,5), (4,6), (4,7), (4,8), (4,9), (4,10), (4,11), (4,12), (4,13), (4,14), (4,15), (4,16), (4,17), (4,18), (4,19), (4,20),(5,5);

#--EXPLAIN SELECT MAX(c2), c1 FROM t1 WHERE c1 = 4 GROUP BY c1;
FLUSH STATUS;
SELECT MAX(c2), c1 FROM t1 WHERE c1 = 4 GROUP BY c1;
SHOW SESSION STATUS LIKE 'Handler_read%';

DROP TABLE t1;

#--echo # End of test for Bug#18109609

#--echo #
#--echo # Bug#24423143 - WRONG RESULTS FOR AGGREGATE QUERY
#--echo #

#--echo # Test index merge tree scenario
CREATE TABLE a (   aggr_col int,   group_by_col int,   KEY aggr_col_key (aggr_col),   KEY group_by_col_key (group_by_col, aggr_col) ) ENGINE=InnoDB;

#-- let $DEFAULT_TRACE_MEM_SIZE=1048576; # 1MB
#--eval set optimizer_trace_max_mem_size=$DEFAULT_TRACE_MEM_SIZE;
set @@session.optimizer_trace='enabled=on';
set end_markers_in_json=on;

INSERT INTO a VALUES (2,3),(5,6),(6,3),(7,NULL),(9,NULL),(10,6);
#--analyze TABLE a;

SELECT group_by_col, MIN(aggr_col) FROM a WHERE (group_by_col IN (70, 9)) OR (aggr_col > 2) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col) FROM a WHERE (group_by_col IN (70 ,9)) OR (aggr_col > 2) GROUP BY group_by_col;

SELECT TRACE RLIKE 'disjuntive_predicate_present' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SELECT group_by_col, MAX(aggr_col) FROM a WHERE (group_by_col IN (70, 9)) OR (aggr_col < 9) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MAX(aggr_col) FROM a WHERE (group_by_col IN (70 , 9)) OR (aggr_col < 9) GROUP BY group_by_col;

SELECT TRACE RLIKE 'disjuntive_predicate_present' AS OK FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Test IMPOSSIBLE TREE scenario
ALTER TABLE a DROP KEY aggr_col_key;

SELECT group_by_col, MIN(aggr_col) FROM a WHERE (group_by_col IN (70 ,9)) OR (aggr_col > 2) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col) FROM a WHERE (group_by_col IN (70, 9)) OR (aggr_col > 2) GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK  FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SELECT group_by_col, MAX(aggr_col) FROM a WHERE (group_by_col IN (70, 9)) OR (aggr_col < 9) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MAX(aggr_col) FROM a WHERE (group_by_col IN (70, 9)) OR (aggr_col < 9) GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 3: aggregate field used as equal expression.
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE (group_by_col IN (3, 9)) OR (aggr_col = 9) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE (group_by_col IN (3, 9)) OR (aggr_col = 9) GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 4: non aggregate field used as equal expression.
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE (group_by_col = 3) OR (aggr_col > 8) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE (group_by_col = 3) OR (aggr_col > 8) GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 5: aggregate field used as non-zero expression.
INSERT INTO a VALUES(0, 3);
INSERT INTO a VALUES(0, 9);
INSERT INTO a VALUES(8, 0);
#--analyze TABLE a;

SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE (group_by_col = 9) OR aggr_col GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE group_by_col = 9 OR aggr_col GROUP BY group_by_col;
 SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;


#--echo # Scenario 6: non aggregate field used as non-zero expression.
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE group_by_col OR (aggr_col < 9) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE group_by_col OR (aggr_col < 9) GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;


#--echo # Scenario 7: aggregate field used in equal exp without a CONST
INSERT INTO a VALUES(1,1),(1,2),(2,1);

SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col = group_by_col GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col = group_by_col GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 8: aggregate field used in a non-eq exp without a CONST
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col < group_by_col GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col < group_by_col GROUP BY group_by_col;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 8
INSERT INTO a VALUES(0,1),(1,0),(0,0);

SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col OR group_by_col GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col OR group_by_col GROUP BY group_by_col;
SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 9
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col AND group_by_col GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col AND group_by_col GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 10: Added for comp# -- # -- letion. This fix does not have an impact.
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col<>0 AND group_by_col<>0 GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE aggr_col<>0 AND group_by_col<>0 GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

#--echo # Scenario 11: ITEM_FUNC as an argument of ITEM_FUNC
SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE group_by_col OR (group_by_col < (aggr_col = 1)) GROUP BY group_by_col;

#--EXPLAIN SELECT group_by_col, MIN(aggr_col), MAX(aggr_col) FROM a WHERE group_by_col OR (group_by_col < (aggr_col = 1)) GROUP BY group_by_col;

SELECT TRACE RLIKE 'minmax_keypart_in_disjunctive_query' AS OK                                 FROM INFORMATION_SCHEMA.OPTIMIZER_TRACE;

SET optimizer_trace_max_mem_size=DEFAULT;
SET optimizer_trace=DEFAULT;
SET end_markers_in_json=DEFAULT;

DROP TABLE a;

#--echo # End of test for Bug#24423143
