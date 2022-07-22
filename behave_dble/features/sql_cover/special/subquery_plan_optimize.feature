# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/9/5
Feature: subquery execute plan should be optimized for ER/Global table join #dble github issue #685 #1057
  As developer suggestion, the "explain ...(query)" resultset line count can indicate whether the query plan is optimized

  @NORMAL @restore_mysql_config @current
  Scenario: check ER tables subquery execute plan optimized #1
    """
    {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0},'mysql-slave1':{'lower_case_table_names':0},'mysql-slave2':{'lower_case_table_names':0}}}
    """
    Given update file content "/etc/my.cnf" in "mysql-master1" with sed cmds
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Given update file content "/etc/my.cnf" in "mysql-master2" with sed cmds
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Given update file content "/etc/my.cnf" in "mysql-slave1" with sed cmds
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given update file content "/etc/my.cnf" in "mysql-slave2" with sed cmds
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given restart mysql in "mysql-master1"
    Given restart mysql in "mysql-master2"
    Given restart mysql in "mysql-slave1"
    Given restart mysql in "mysql-slave2"
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="table_a" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="table_b" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    """
    Then execute admin cmd "reload @@config_all"
#    default heartbeat period is 10 seconds,wait enough time for heartbeat recover
    Given sleep "11" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | expect    | db      |
      | conn_0 | False    | drop table if exists table_a                  | success   | schema1 |
      | conn_0 | False    | drop table if exists table_b                  | success   | schema1 |
      | conn_0 | False    | create table table_a (id int,c_flag char(255))| success   | schema1 |
      | conn_0 | True     | create table table_b (id int,c_flag char(255))| success   | schema1 |
    Then get query plan and make sure it is optimized
      |query | expect_result_count |
      |explain select * from table_a a, table_b b on a.id =b.id | 4 |
      |explain select * from table_a a, table_b B on a.id =b.id | 4 |
      |explain select count(*) from ( select a.id from table_a a join table_b b on a.id =b.id) x | 7 |
  #add case https://github.com/actiontech/dble/issues/1714
      |explain select * from ( select a.id aid,b.id bid,3 mark from table_a a left join table_b b on a.id= b.id where a.id >3) t where t.mark IN(3) | 6 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | expect    | db      |
      | conn_0 | False    | drop table if exists table_a                  | success   | schema1 |
      | conn_0 | False    | drop table if exists table_b                  | success   | schema1 |

  @regression
  Scenario: check Global tables subquery execute plan optimized #2
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <globalTable name="table_a" shardingNode="dn1,dn2"/>
        <globalTable name="table_b" shardingNode="dn1,dn2"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                            | expect    | db      |
      | conn_0 | False    | drop table if exists table_a                   | success   | schema1 |
      | conn_0 | False    | drop table if exists table_b                   | success   | schema1 |
      | conn_0 | False    | create table table_a (id int,c_flag char(255)) | success   | schema1 |
      | conn_0 | True     | create table table_b (id int,c_flag char(255)) | success   | schema1 |
    Then get query plan and make sure it is optimized
        |query | expect_result_count |
        |explain select * from table_a a, table_b b on a.id =b.id | 1 |
        |explain select count(*) from ( select a.id from table_a a join table_b b on a.id =b.id) x; | 1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                            | expect    | db      |
      | conn_0 | False    | drop table if exists table_a                   | success   | schema1 |
      | conn_0 | False    | drop table if exists table_b                   | success   | schema1 |

  Scenario: the optimization of merge #3
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="tb_parent" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id">
             <childTable name="tb_child1" joinColumn="child1_id" parentColumn="id"/>
        </shardingTable>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect    | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1         | success   | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t1         | success   | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1         | success   | schema1 |
      | conn_0 | False   | drop table if exists tb_parent             | success   | schema1 |
      | conn_0 | False   | drop table if exists tb_child1             | success   | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_4_t1   | success   | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_4_t2   | success   | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_4_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t1(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_3_t1(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE tb_parent(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE tb_child1(`id` int(10) unsigned NOT NULL,`child1_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`child1_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE schema2.global_4_t2(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | False   | CREATE TABLE schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
      | conn_0 | True    | CREATE TABLE schema2.sharding_4_t2(`id` int(10) unsigned NOT NULL,`m_id` int(10) unsigned NOT NULL DEFAULT '0',`name` char(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`m_id`))DEFAULT CHARSET=UTF8 | success   | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_A"
      | sql                                               | db      |
      | explain select * from sharding_4_t1,sharding_2_t1 | schema1 |
    Then check resultset "explain_result_A" has lines with following column values
        | expect_result_line    | DATA_NODE-0     | TYPE-1      |
        | expect_result_line:5  | merge_1         | MERGE       |
        | expect_result_line:9  | merge_2         | MERGE       |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_B"
      | sql                                                                | db      |
      | explain select * from sharding_4_t1 a,sharding_2_t1 b on a.id=b.id | schema1 |
    Then check resultset "explain_result_B" has lines with following column values
        | expect_result_line     | DATA_NODE-0                | TYPE-1           |
        | expect_result_line:5   | merge_and_order_1          | MERGE_AND_ORDER  |
        | expect_result_line:9   | merge_and_order_2          | MERGE_AND_ORDER  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_C"
      | sql                                                                              | db      |
      | explain select * from sharding_4_t1 a,sharding_2_t1 b on a.id=b.id and a.id>b.id | schema1 |
    Then check resultset "explain_result_C" has lines with following column values
        | expect_result_line      | DATA_NODE-0                | TYPE-1          |
        | expect_result_line:5    | merge_and_order_1          | MERGE_AND_ORDER |
        | expect_result_line:9    | merge_and_order_2          | MERGE_AND_ORDER |
        | expect_result_line:12   | where_filter_1             | WHERE_FILTER    |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_D"
      | sql                                                                | db      |
      | explain select * from sharding_4_t1 a,sharding_2_t1 b on a.id>b.id | schema1 |
    Then check resultset "explain_result_D" has lines with following column values
        | expect_result_line                      | DATA_NODE-0     | TYPE-1       |
        | expect_result_line:5                    | merge_1         | MERGE        |
        | expect_result_line:9                    | merge_2         | MERGE        |
        | expect_result_line:12                   | where_filter_1  | WHERE_FILTER |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_E"
      | sql                                                                   | db      |
      | explain select * from sharding_4_t1 union select * from sharding_2_t1 | schema1 |
    Then check resultset "explain_result_E" has lines with following column values
        | expect_result_line                      | DATA_NODE-0     | TYPE-1       |
        | expect_result_line:5                    | merge_1          | MERGE       |
        | expect_result_line:9                    | merge_2          | MERGE       |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_F"
      | sql                                                                                                                  | db      |
      | explain select a.id,b.id,c.pad from sharding_4_t1 a,sharding_2_t1 b,sharding_3_t1 c where a.id=c.pad and b.id=c.m_id | schema1 |
    Then check resultset "explain_result_F" has lines with following column values
        | expect_result_line      | DATA_NODE-0         | TYPE-1            |
        | expect_result_line:5    | merge_1             | MERGE             |
        | expect_result_line:9    | merge_2             | MERGE             |
        | expect_result_line:17   | merge_and_order_1   | MERGE_AND_ORDER   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_G"
      | sql                                                        | db      |
      | explain select * from tb_parent a,tb_child1 b on a.id=b.id | schema1 |
    Then check resultset "explain_result_G" has lines with following column values
        | expect_result_line                      | DATA_NODE-0          | TYPE-1                |
        | expect_result_line:3                    | merge_and_order_1    | MERGE_AND_ORDER       |
        | expect_result_line:7                    | merge_and_order_2    | MERGE_AND_ORDER       |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_H"
      | sql                                                               | db      |
      | explain select * from tb_parent a,tb_child1 b on a.id=b.child1_id | schema1 |
    Then check resultset "explain_result_H" has lines with following column values
        | expect_result_line                      | DATA_NODE-0      | TYPE-1       |
        | expect_result_line:3                    | merge_1          | MERGE        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_er_child"
      | sql                                           | db      |
      | explain insert into tb_child1 values(1,1,1,1) | schema1 |
    Then check resultset "explain_result_er_child" has lines with following column values
        | expect_result_line                      | DATA_NODE-0  | TYPE-1       |
        | expect_result_line:1                    | dn2          |  BASE SQL    |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_I"
      | sql                                                                             | db      |
      | explain select * from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id | schema1 |
    Then check resultset "explain_result_I" has lines with following column values
        | expect_result_line                      | DATA_NODE-0      | TYPE-1       |
        | expect_result_line:5                    | merge_1          | MERGE        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_J"
      | sql                                                                               | db      |
      | explain select * from sharding_4_t1 a join schema2.sharding_4_t2 b on a.pad=b.pad | schema1 |
    Then check resultset "explain_result_J" has lines with following column values
        | expect_result_line     | DATA_NODE-0         | TYPE-1                 |
        | expect_result_line:5   | merge_and_order_1   | MERGE_AND_ORDER        |
        | expect_result_line:11  | merge_and_order_2   | MERGE_AND_ORDER        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_M"
      | sql                                                                           | db      |
      | explain select * from sharding_4_t1 a join schema2.global_4_t1 b on a.id=b.id | schema1 |
    Then check resultset "explain_result_M" has lines with following column values
        | expect_result_line                      | DATA_NODE-0      | TYPE-1       |
        | expect_result_line:5                    | merge_1          | MERGE        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "explain_result_L"
      | sql                                                                                           | db      |
      | explain select * from (select * from sharding_4_t1) a join schema2.global_4_t1 b on a.id=b.id | schema1 |
    Then check resultset "explain_result_L" has lines with following column values
        | expect_result_line     | DATA_NODE-0        | TYPE-1            |
        | expect_result_line:5   | merge_and_order_1  | MERGE_AND_ORDER   |
        | expect_result_line:10  | merge_1            | MERGE             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect    | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1         | success   | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t1         | success   | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1         | success   | schema1 |
      | conn_0 | False   | drop table if exists tb_parent             | success   | schema1 |
      | conn_0 | False   | drop table if exists tb_child1             | success   | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_4_t1   | success   | schema1 |
      | conn_0 | False   | drop table if exists schema2.global_4_t2   | success   | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2 | success   | schema1 |