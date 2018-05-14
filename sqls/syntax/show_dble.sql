drop table if exists test_shard
CREATE TABLE test_shard(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
drop table if exists testdb.tb_test
CREATE TABLE testdb.tb_test(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`k`))DEFAULT CHARSET=UTF8
drop table if exists test_global
CREATE TABLE test_global(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8
drop table if exists test_no_shard
CREATE TABLE test_no_shard(`id` int(10) unsigned NOT NULL,`k` int(10) unsigned NOT NULL DEFAULT '0',`c` char(120),`pad` int(11) NOT NULL,PRIMARY KEY (`id`),UNIQUE KEY (`k`))DEFAULT CHARSET=UTF8
drop table if exists global_table2
drop table if exists global_table3
CREATE TABLE global_table2(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE global_table3(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
drop table if exists a_order_no_shard
drop table if exists a_manager_no_shard
CREATE TABLE a_order_no_shard(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8
CREATE TABLE a_manager_no_shard(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8
show databases
show schemas
show tables
show full tables
show tables from mytest
show full tables from mytest like 'test%'
show table status
#
#SHOW COLUMNS Syntax
#
show columns from test_shard
show columns in test_shard
show columns from test_shard from mytest
show columns from tb_test_shard from testdb
show columns in test_shard in mytest
show columns from test_shard in mytest
show full fields from test_shard from mytest like '%i%'
show full fields from test_shard from mytest where true
#
#dble ONLY
#
show all tables
#
#clear tables
#
drop table if exists test_shard
drop table if exists testdb.tb_test
drop table if exists test_global
drop table if exists test_no_shard
drop table if exists global_table2
drop table if exists global_table3
drop table if exists a_order_no_shard
drop table if exists a_manager_no_shard
