# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# create by wujinling at 2023/08/18


Feature: htap basic functionality test


  Scenario: test basic htap #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema name="htapDb1" apNode="apNode1" shardingNode="dn5" sqlMaxLimit="-1">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>

      <schema name="htapDb2" apNode="apNode2" shardingNode="dn5" sqlMaxLimit="-1">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
      <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />

      <apNode name="apNode1" dbGroup="ha_group4" database="ckdb1"/>
      <apNode name="apNode2" dbGroup="ha_group5" database="ckdb2"/>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group5" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM5" password="111111" url="172.100.9.10:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <hybridTAUser name="htap1" password="111111" schemas="htapDb1,htapDb2"  maxCon="20"/>
      <hybridTAUser name="htap2" password="111111" schemas="htapDb1"  maxCon="20"/>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DenableStatisticAnalysis=1
      """
    Then restart dble in "dble-1" success

    # dble暂未支持APNode相关的管理端命令，所以需连接后端手动建立后ck实例的物理库
    Then execute sql in "clickhouse-server_1" in "clickhouse" mode
      | user  | passwd    | conn   | toClose | sql                                                                                 | expect  |
      | test  | 111111    | conn_1 | True    | create database if not exists ckdb1                                                 | success |
      | test  | 111111    | conn_1 | True    | create database if not exists ckdb2                                                 | success |
    # ck中准备和dble一样的数据
    Then execute sql in "clickhouse-server_1" in "clickhouse" mode
      | user | passwd    | conn   | toClose | sql                                                                                          | expect  | db       |
      | test | 111111    | conn_1 | False   | drop table if exists ck1_sing1                                                               | success | ckdb1    |
      | test | 111111    | conn_1 | False   | create table ck1_sing1(id int,name varchar(10),age int) ENGINE = MergeTree order by id       | success | ckdb1    |
      | test | 111111    | conn_1 | False   | insert into ck1_sing1 values (1,1,1),(2,2,2),(9,9,9)                                         | success | ckdb1    |
      | test | 111111    | conn_1 | False   | drop table if exists test                                                                    | success | ckdb1    |
      | test | 111111    | conn_1 | False   | create table test(id int,name varchar(10),age int) ENGINE = MergeTree order by id            | success | ckdb1    |
      | test | 111111    | conn_1 | False   | insert into test values (1,1,1),(2,2,2),(9,9,9),(10,10,10)                                   | success | ckdb1    |
      | test | 111111    | conn_1 | False   | drop table if exists sharding_2_t1                                                           | success | ckdb1    |
      | test | 111111    | conn_1 | False   | create table sharding_2_t1(id int,name varchar(10),age int) ENGINE = MergeTree order by id   | success | ckdb1    |
      | test | 111111    | conn_1 | False   | insert into sharding_2_t1 values (1,1,1),(4,4,4),(9,9,9),(10,10,10)                          | success | ckdb1    |
      | test | 111111    | conn_1 | False   | drop table if exists sharding_4_t1                                                                 | success | ckdb1    |
      | test | 111111    | conn_1 | False   | create table sharding_4_t1(id int,name varchar(10),age int) ENGINE = MergeTree order by id         | success | ckdb1    |
      | test | 111111    | conn_1 | False   | insert into sharding_4_t1 values (1,1,1),(3,3,3),(9,9,9),(10,10,10)                                | success | ckdb1    |
      | test | 111111    | conn_1 | False   | drop table if exists ckdb2.ck2_sing1                                                               | success | ckdb1    |
      | test | 111111    | conn_1 | False   | create table ckdb2.ck2_sing1(id int,name varchar(10),age int) ENGINE = MergeTree order by id       | success | ckdb1    |
      | test | 111111    | conn_1 | False   | insert into ckdb2.ck2_sing1 values (1,1,1),(4,4,4),(9,9,9),(2,2,2)                                 | success | ckdb1    |
      | test | 111111    | conn_1 | False   | drop table if exists ckdb2.sharding_4_t2                                                           | success | ckdb1    |
      | test | 111111    | conn_1 | False   | create table ckdb2.sharding_4_t2(id int,name varchar(10),age int) ENGINE = MergeTree order by id   | success | ckdb1    |
      | test | 111111    | conn_1 | True    | insert into ckdb2.sharding_4_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(9,9,9),(10,10,10)          | success | ckdb1    |

    ##开启SQL统计的参数，记录hybridTAUser用户执行的sql
    Then execute admin cmd "enable @@statistic"

    # 1.路由到TP，并准备数据(explain及结果集检测)
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose | sql                                                                                  | expect  | db      |
      | htap1 | 111111    | conn_1 | False   | drop table if exists ck1_sing1                                                       | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | create table ck1_sing1(id int,name varchar(10),age int)                              | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | insert into ck1_sing1 values (1,1,1),(2,2,2),(9,9,9)                                 | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | drop table if exists test                                                            | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | create table test(id int,name varchar(10),age int)                                   | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | insert into test values (1,1,1),(2,2,2),(9,9,9),(10,10,10)                           | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | drop table if exists sharding_2_t1                                                   | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | create table sharding_2_t1(id int,name varchar(10),age int)                          | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | insert into sharding_2_t1 values (1,1,1),(4,4,4),(9,9,9),(10,10,10)                  | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | drop table if exists sharding_4_t1                                                   | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | create table sharding_4_t1(id int,name varchar(10),age int)                          | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | insert into sharding_4_t1 values (1,1,1),(3,3,3),(9,9,9),(10,10,10)                  | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | drop table if exists htapDb2.ck2_sing1                                               | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | create table htapDb2.ck2_sing1(id int,name varchar(10),age int)                      | success | htapDb1 |
      | htap1 | 111111    | conn_1 | True    | insert into htapDb2.ck2_sing1 values (1,1,1),(4,4,4),(9,9,9),(2,2,2)                 | success | htapDb1 |
      | htap1 | 111111    | conn_1 | False   | drop table if exists sharding_4_t2                                                   | success | htapDb2 |
      | htap1 | 111111    | conn_1 | False   | create table sharding_4_t2(id int,name varchar(10),age int)                          | success | htapDb2 |
      | htap1 | 111111    | conn_1 | True    | insert into sharding_4_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(9,9,9),(10,10,10)  | success | htapDb2 |

    ##校验sql是否被正确记录
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | new_a0 | False   | show @@sql.sum.user  | hasStr{'htap1'} | 5       |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_11"
      | conn   | toClose | sql                                                                 | db               |
      | new_a1 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user | dble_information |
    Then check resultset "resultset_11" has lines with following column values and has "5" lines
      | entry-0 | user-1  | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 1       | htap1   | 172.100.9.6    | 3306           | dn2             | hostM2        | 12         | 10        | 4                   | 10                 | 0                   | 0                  | 0                   | 0                  | 0                   | 0                  |
      | 1       | htap1   | 172.100.9.5    | 3306           | dn1             | hostM1        | 11         | 7         | 3                   | 7                  | 0                   | 0                  | 0                   | 0                  | 0                   | 0                  |
      | 1       | htap1   | 172.100.9.6    | 3306           | dn4             | hostM2        | 9          | 6         | 3                   | 6                  | 0                   | 0                  | 0                   | 0                  | 0                   | 0                  |
      | 1       | htap1   | 172.100.9.5    | 3306           | dn3             | hostM1        | 9          | 7         | 3                   | 7                  | 0                   | 0                  | 0                   | 0                  | 0                   | 0                  |
      | 1       | htap1   | 172.100.9.5    | 3306           | dn5             | hostM1        | 6          | 7         | 2                   | 7                  | 0                   | 0                  | 0                   | 0                  | 0                   | 0                  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_21"
      | conn   | toClose | sql                                                                 | db               |
      | new_a1 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
    Then check resultset "resultset_21" has lines with following column values and has "6" lines
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 1       | htap1  | htapDb1.test          | 1                  | 4                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |
      | 1       | htap1  | htapDb1.sharding_2_t1 | 1                  | 4                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |
      | 1       | htap1  | htapDb1.sharding_4_t1 | 1                  | 4                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |
      | 1       | htap1  | htapDb2.ck2_sing1     | 1                  | 4                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |
      | 1       | htap1  | htapDb1.ck1_sing1     | 1                  | 3                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |
      | 1       | htap1  | htapDb2.sharding_4_t2 | 1                  | 6                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resulte_1"
      | conn   | toClose | sql                     | db               |
      | new_a1 | False   | select * from sql_log   | dble_information |
    Then check resultset "resulte_1" has lines with following column values and has "18" lines
      | sql_id-0 | sql_stmt-1                                                                          | sql_digest-2                                                            | sql_type-3 | tx_id-4 | entry-5 | user-6 | source_host-7 | source_port-8 | rows-9 | examined_rows-10 | result_size-11 |
      | 1        | drop table if exists ck1_sing1                                                      | DROP TABLE IF EXISTS ck1_sing1                                          | DDL        | 1       | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 11             |
      | 2        | create table ck1_sing1(id int,name varchar(10),age int)                             | CREATE TABLE ck1_sing1 (  id int,  name varchar(10),  age int )         | DDL        | 2       | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 11             |
      | 3        | insert into ck1_sing1 values (1,1,1),(2,2,2),(9,9,9)                                | INSERT INTO ck1_sing1 VALUES (?, ?, ?)                                  | Insert     | 3       | 1       | htap1  | 172.100.9.8   | 8066          | 3      | 3               | 50             |
      | 4        | drop table if exists test                                                           | DROP TABLE IF EXISTS test                                               | DDL        | 4       | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 44             |
      | 5        | create table test(id int,name varchar(10),age int)                                  | CREATE TABLE test (  id int,  name varchar(10),  age int )              | DDL        | 5       | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 44             |
      | 6        | insert into test values (1,1,1),(2,2,2),(9,9,9),(10,10,10)                          | INSERT INTO test VALUES (?, ?, ?)                                       | Insert     | 6       | 1       | htap1  | 172.100.9.8   | 8066          | 4      | 16              | 200            |
      | 7        | drop table if exists sharding_2_t1                                                  | DROP TABLE IF EXISTS sharding_2_t1                                      | DDL        | 7       | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 22             |
      | 8        | create table sharding_2_t1(id int,name varchar(10),age int)                         | CREATE TABLE sharding_2_t1 (  id int,  name varchar(10),  age int )     | DDL        | 8       | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 22             |
      | 9        | insert into sharding_2_t1 values (1,1,1),(4,4,4),(9,9,9),(10,10,10)                 | INSERT INTO sharding_2_t1 VALUES (?, ?, ?)                              | Insert     | 9       | 1       | htap1  | 172.100.9.8   | 8066          | 4      | 4               | 100            |
      | 10       | drop table if exists sharding_4_t1                                                  | DROP TABLE IF EXISTS sharding_4_t1                                      | DDL        | 10      | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 44             |
      | 11       | create table sharding_4_t1(id int,name varchar(10),age int)                         | CREATE TABLE sharding_4_t1 (  id int,  name varchar(10),  age int )     | DDL        | 11      | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 44             |
      | 12       | insert into sharding_4_t1 values (1,1,1),(3,3,3),(9,9,9),(10,10,10)                 | INSERT INTO sharding_4_t1 VALUES (?, ?, ?)                              | Insert     | 12      | 1       | htap1  | 172.100.9.8   | 8066          | 4      | 4               | 72             |
      | 13       | drop table if exists htapDb2.ck2_sing1                                              | DROP TABLE IF EXISTS htapDb2.ck2_sing1                                  | DDL        | 13      | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 11             |
      | 14       | create table htapDb2.ck2_sing1(id int,name varchar(10),age int)                     | CREATE TABLE htapDb2.ck2_sing1 (  id int,  name varchar(10),  age int ) | DDL        | 14      | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 11             |
      | 15       | insert into htapDb2.ck2_sing1 values (1,1,1),(4,4,4),(9,9,9),(2,2,2)                | INSERT INTO htapDb2.ck2_sing1 VALUES (?, ?, ?)                          | Insert     | 15      | 1       | htap1  | 172.100.9.8   | 8066          | 4      | 4               | 50             |
      | 16       | drop table if exists sharding_4_t2                                                  | DROP TABLE IF EXISTS sharding_4_t2                                      | DDL        | 16      | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 44             |
      | 17       | create table sharding_4_t2(id int,name varchar(10),age int)                         | CREATE TABLE sharding_4_t2 (  id int,  name varchar(10),  age int )     | DDL        | 17      | 1       | htap1  | 172.100.9.8   | 8066          | 0      | 0               | 44             |
      | 18       | insert into sharding_4_t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(9,9,9),(10,10,10) | INSERT INTO sharding_4_t2 VALUES (?, ?, ?)                              | Insert     | 18      | 1       | htap1  | 172.100.9.8   | 8066          | 6      | 6               | 122            |

    ## ddl-->TP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "ddl_rs"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    | explain drop table if exists sharding_4_t1 | success | htapDb1 |
    Then check resultset "ddl_rs" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1           | BASE SQL | drop table if exists sharding_4_t1 |
      | dn2           | BASE SQL | drop table if exists sharding_4_t1 |
      | dn3           | BASE SQL | drop table if exists sharding_4_t1 |
      | dn4           | BASE SQL | drop table if exists sharding_4_t1 |
    ## dml-->TP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "dml_rs"
      | user  | passwd    | conn   | toClose | sql                                                                       | expect  | db      |
      | htap1 | 111111    | conn_1 | true    | explain insert into sharding_4_t1 values (1000,1000,1000),(1501,1501,1501)| success | htapDb1 |
    Then check resultset "dml_rs" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1             | BASE SQL   | INSERT INTO sharding_4_t1 VALUES (1000, 1000, 1000) |
      | dn2             | BASE SQL   | INSERT INTO sharding_4_t1 VALUES (1501, 1501, 1501) |

    ## 不包含聚合函数的select -->TP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "none_agre_select_rs"
      | user  | passwd    | conn   | toClose | sql                                                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    | explain select * from sharding_4_t1 t1 join sharding_4_t2 t2 on t1.id=t2.id | success | htapDb2 |
    Then check resultset "none_agre_select_rs" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1_0           | BASE SQL      | select `t1`.`id`,`t1`.`name`,`t1`.`age`,`t2`.`id`,`t2`.`name`,`t2`.`age` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  |
      | dn2_0           | BASE SQL      | select `t1`.`id`,`t1`.`name`,`t1`.`age`,`t2`.`id`,`t2`.`name`,`t2`.`age` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  |
      | dn3_0           | BASE SQL      | select `t1`.`id`,`t1`.`name`,`t1`.`age`,`t2`.`id`,`t2`.`name`,`t2`.`age` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  |
      | dn4_0           | BASE SQL      | select `t1`.`id`,`t1`.`name`,`t1`.`age`,`t2`.`id`,`t2`.`name`,`t2`.`age` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  |
      | merge_1         | MERGE         | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                         |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                                                            |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                                                          | expect       | db      |
      | htap1 | conn_0 | True    | select * from sharding_4_t1 t1 join sharding_4_t2 t2 on t1.id=t2.id                          | length{(4)}  | htapDb2  |

    # trx-->TP
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose | sql                                                                         | expect                                                                             | db      |
      | test  | 111111    | conn_1 | true    | set autocommit=0;explain select count(*) from sharding_4_t2                 | hasStr{(), (('dn5', 'BASE SQL', 'SELECT count(*) FROM sharding_4_t2 LIMIT 100'),)} | schema1 |

    ## hint -->TP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "hint_agre_rs"
      | user  | passwd    | conn   | toClose | sql                                                                         | expect  | db      |
      | test  | 111111    | conn_1 | true    | explain /*!dble:shardingnode=dn1*/select count(*) from sharding_4_t1        | success | schema1 |
    Then check resultset "hint_agre_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1    | SQL/REF-2                                                    |
      | dn1               | BASE SQL  | select count(*) from sharding_4_t1 |

    ## ck不支持的聚合函数,直接转发类型-->TP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STD_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STD(id) from ck1_sing1     | success | htapDb1 |
    Then check resultset "select_STD_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | dn5             | BASE SQL   | select STD(id) from ck1_sing1    |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                              | db      |
      | htap1 | conn_0 | True    | select STD(id) from ck1_sing1                          | hasStr{((3.559026084010437,),)}     | htapDb1  |


    # 2.路由到AP，主要为包含聚合函数的简单语句查询(explain及结果集检测)
    ## 2.1 简单sql包含聚合函数
    ### 2.1.1 转发类型(全局表、单分片表)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_count_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select count(*) from test         | success | htapDb1 |
    Then check resultset "select_count_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1         | BASE SQL   | select count(*) from test   |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select count(*) from test                              | hasStr{((4,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_count_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select count(*) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_count_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select count(*) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select count(*) from ck1_sing1                         | hasStr{((3,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_min_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select min(age) from test         | success | htapDb1 |
    Then check resultset "select_min_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select min(age) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select min(age) from test                         | hasStr{((1,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_min_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select min(age) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_min_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select min(age) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select min(age) from ck1_sing1                         | hasStr{((1,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_max_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select max(age) from test         | success | htapDb1 |
    Then check resultset "select_max_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select max(age) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select max(age) from test                              | hasStr{((10,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_max_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select max(age) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_max_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select max(age) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select max(age) from ck1_sing1                         | hasStr{((9,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_avg_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select avg(age) from test         | success | htapDb1 |
    Then check resultset "select_avg_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select avg(age) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select avg(age) from test                              | hasStr{((5.5,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_avg_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select avg(age) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_avg_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select avg(age) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select avg(age) from ck1_sing1                         | hasStr{((4.0,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_sum_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select sum(id) from test         | success | htapDb1 |
    Then check resultset "select_sum_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select sum(id) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select sum(id) from test;                         | hasStr{((22,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_sum_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select sum(id) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_sum_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select sum(id) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect          | db      |
      | htap1 | conn_0 | True    | select sum(id) from ck1_sing1                         | hasStr{((12,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_POP_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV_POP(id) from test         | success | htapDb1 |
    Then check resultset "select_STDDEV_POP_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select STDDEV_POP(id) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                     | expect                           | db      |
      | htap1 | conn_0 | True    | select STDDEV_POP(id) from test                         | hasStr{((4.031128874149275,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_POP_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV_POP(id) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_STDDEV_POP_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select STDDEV_POP(id) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                          | db      |
      | htap1 | conn_0 | True    | select STDDEV_POP(id) from ck1_sing1                   | hasStr{((3.559026084010437,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_SAMP_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV_SAMP(id) from test         | success | htapDb1 |
    Then check resultset "select_STDDEV_SAMP_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select STDDEV_SAMP(id) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                          | db      |
      | htap1 | conn_0 | True    | select STDDEV_SAMP(id) from test                       | hasStr{((4.654746681256314,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_SAMP_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV_SAMP(id) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_STDDEV_SAMP_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select STDDEV_SAMP(id) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                          | db      |
      | htap1 | conn_0 | True    | select STDDEV_SAMP(id) from ck1_sing1                   | hasStr{((4.358898943540674,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_VAR_POP_1"
      | user  | passwd    | conn   | toClose | sql                                           | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select VAR_POP(id) from test         | success | htapDb1 |
    Then check resultset "select_VAR_POP_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select VAR_POP(id) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                          | db      |
      | htap1 | conn_0 | True    | select VAR_POP(id) from test                           | hasStr{((16.25,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_VAR_POP_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select VAR_POP(id) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_VAR_POP_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select VAR_POP(id) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                          | db      |
      | htap1 | conn_0 | True    | select VAR_POP(id) from ck1_sing1                      | hasStr{((12.666666666666666,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_VAR_SAMP_1"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select VAR_SAMP(id) from test         | success | htapDb1 |
    Then check resultset "select_VAR_SAMP_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                   |
      | apNode1       | BASE SQL | select VAR_SAMP(id) from test |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                          | db      |
      | htap1 | conn_0 | True    | select VAR_SAMP(id) from test                          | hasStr{((21.666666666666668,),)}     | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_VAR_SAMP_2"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select VAR_SAMP(id) from ck1_sing1    | success | htapDb1 |
    Then check resultset "select_VAR_SAMP_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                        |
      | apNode1       | BASE SQL | select VAR_SAMP(id) from ck1_sing1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select VAR_SAMP(id) from ck1_sing1                     | hasStr{((19.0,),)}     | htapDb1  |

    ### 2.1.2 分片表类型
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_count_3"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    | explain select count(*) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_count_3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                    |
      | apNode1       | BASE SQL | select count(*) from sharding_4_t1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select count(*) from sharding_4_t1                     | hasStr{((4,),)}  | htapDb1  |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_count_4"
      | user  | passwd    | conn   | toClose | sql                                        | expect  | db      |
      | htap1 | 111111    | conn_1 | true    | explain select count(*) from sharding_4_t2 | success | htapDb2 |
    Then check resultset "select_count_4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                    |
      | apNode2       | BASE SQL | select count(*) from sharding_4_t2 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select count(*) from sharding_4_t2                     | hasStr{((6,),)}  | htapDb2  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_min_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select min(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_min_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                          |
      | apNode1          | BASE SQL        | select min(age) from sharding_4_t1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select min(age) from sharding_4_t1                     | hasStr{((1,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_max_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select max(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_max_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                          |
      | apNode1          | BASE SQL        | select max(age) from sharding_4_t1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select max(age) from sharding_4_t1                     | hasStr{((10,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_avg_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select avg(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_avg_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                                   |
      | apNode1          | BASE SQL        | select avg(age) from sharding_4_t1  |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select avg(age) from sharding_4_t1                     | hasStr{((5.75,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_sum_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select sum(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_sum_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                                   |
      | apNode1          | BASE SQL        | select sum(age) from sharding_4_t1  |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select sum(age) from sharding_4_t1                     | hasStr{((23,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_POP_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV_POP(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_STDDEV_POP_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                                   |
      | apNode1          | BASE SQL        | select STDDEV_POP(age) from sharding_4_t1  |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select STDDEV_POP(age) from sharding_4_t1              | hasStr{((3.832427429188973,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_SAMP_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV_SAMP(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_STDDEV_SAMP_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                                   |
      | apNode1          | BASE SQL        | select STDDEV_SAMP(age) from sharding_4_t1|
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select STDDEV_SAMP(age) from sharding_4_t1             | hasStr{((4.425306015783918,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_VAR_POP_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select VAR_POP(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_VAR_POP_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                                   |
      | apNode1          | BASE SQL        | select VAR_POP(age) from sharding_4_t1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect           | db      |
      | htap1 | conn_0 | True    | select VAR_POP(age) from sharding_4_t1                 | hasStr{((14.6875,),)}     | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_VAR_SAMP_3"
      | user  | passwd    | conn   | toClose | sql                                              | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select VAR_SAMP(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_VAR_SAMP_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1       | SQL/REF-2                                |
      | apNode1          | BASE SQL     | select VAR_SAMP(age) from sharding_4_t1  |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                           | db      |
      | htap1 | conn_0 | True    | select VAR_SAMP(age) from sharding_4_t1                | hasStr{((19.583333333333332,),)}     | htapDb1  |

    #### 不支持的函数，如果转换后支持，也发给AP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STD_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STD(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_STD_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                    |
      | apNode1          | BASE SQL | select STD(age) from sharding_4_t1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                  | db      |
      | htap1 | conn_0 | True    | select STD(age) from sharding_4_t1                     | Unknown function STD    | htapDb1  |

    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_STDDEV_3"
      | user  | passwd    | conn   | toClose | sql                                         | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select STDDEV(age) from sharding_4_t1 | success | htapDb1 |
    Then check resultset "select_STDDEV_3" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                              |
      | apNode1          | BASE SQL        | select STDDEV(age) from sharding_4_t1  |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                    | expect                     | db      |
      | htap1 | conn_0 | True    | select STDDEV(age) from sharding_4_t1                  | Unknown function STDDEV    | htapDb1  |

    #### hint -->AP
    Given execute single sql in "dble-1" in "user" mode and save resultset in "hint_agre_rs2"
      | user  | conn   | toClose | sql                                                                       | expect  | db      |
      | htap1 |conn_1  | true    | explain /*!dble:db_type=master*/select count(*) from sharding_4_t1        | success | htapDb1 |
    Then check resultset "hint_agre_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1    | SQL/REF-2                                                    |
      | apNode1           | BASE SQL  | select count(*) from sharding_4_t1 |

    ### 跨库，且包含相同字段名 , 目前发给会TP，issue:DBLE0REQ-2328
    Given execute single sql in "dble-1" in "user" mode and save resultset in "select_DB_1"
      | user  | passwd    | conn   | toClose | sql                                                                                                                          | expect  | db      |
      | htap1 | 111111    | conn_1 | true    |  explain select t1.id,t2.id,count(*) from sharding_4_t1 t1 join htapDb2.sharding_4_t2 t2 on t1.id=t2.id group by t1.id,t2.id  | success | htapDb1 |
    Then check resultset "select_DB_1" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1          | SQL/REF-2                                                                                                         |
      | dn1_0             | BASE SQL        | select `t1`.`id`,`t2`.`id`,count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  GROUP BY `t1`.`id`,`t2`.`id` ORDER BY `t1`.`id` ASC,`t2`.`id` ASC |
      | dn2_0             | BASE SQL        | select `t1`.`id`,`t2`.`id`,count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  GROUP BY `t1`.`id`,`t2`.`id` ORDER BY `t1`.`id` ASC,`t2`.`id` ASC |
      | dn3_0             | BASE SQL        | select `t1`.`id`,`t2`.`id`,count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  GROUP BY `t1`.`id`,`t2`.`id` ORDER BY `t1`.`id` ASC,`t2`.`id` ASC |
      | dn4_0             | BASE SQL        | select `t1`.`id`,`t2`.`id`,count(*) as `_$COUNT$_rpda_0` from  `sharding_4_t1` `t1` join  `sharding_4_t2` `t2` on `t1`.`id` = `t2`.`id` where 1=1  GROUP BY `t1`.`id`,`t2`.`id` ORDER BY `t1`.`id` ASC,`t2`.`id` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                          |
      | aggregate_1       | AGGREGATE       | merge_and_order_1                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | aggregate_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                                                                                     | expect                                                    | db      |
      | htap1 | conn_0 | True    | select t1.id,t2.id,count(*) from sharding_4_t1 t1 join htapDb2.sharding_4_t2 t2 on t1.id=t2.id group by t1.id,t2.id     | hasStr{((1, 1, 1), (3, 3, 1), (9, 9, 1), (10, 10, 1))}    | htapDb1  |