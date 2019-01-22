#!default_db:schema1
# Created by zhaohongjie at 2019/1/16
#github issue #817
drop table if exists test1
drop table if exists schema2.test2
CREATE TABLE schema2.test2(id int(10),t_time timestamp(6),name char(120),pad int(11),PRIMARY KEY (id))
CREATE TABLE test1(`id` int(10),`o_time` timestamp(6),`name` char(120),`pad` int(11),PRIMARY KEY (`id`))
select * from schema2.test2 a inner join test1 b on a.pad=b.pad where b.o_time>=STR_TO_DATE('2018-11-08 00:00:00','%Y-%m-%d %H:%i: %s')