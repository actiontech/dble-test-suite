#!default_db:schema1
drop table if exists test1
CREATE TABLE test1(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
drop table if exists schema2.test2
CREATE TABLE schema2.test2(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))DEFAULT CHARSET=UTF8
show databases
show schemas
show tables
show full tables
show tables from schema1
show full tables from schema1 like 'test%'
show table status
#
#SHOW COLUMNS Syntax
#
show columns from test1
show columns in test1
show columns from test1 from schema1
show columns from test1 from schema2
show columns in test1 in schema1
show columns from test1 in schema1
show full fields from test1 from schema1 like '%i%'
show full fields from test1 from schema1 where true
#
#dble ONLY
#
show all tables
#
#clear tables
#
drop table if exists test1
drop table if exists schema2.test2