# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/24
  Feature: support special sql

  Scenario: can support special sql like when don't set a value for variable "@id_a" #1
#case https://github.com/actiontech/dble/issues/1650
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                              | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1                                              | schema1 |
      | conn_0 | False   | create table sharding_2_t1(id int(4), B float(8,2))                             | schema1 |
      | conn_0 | False   | insert into sharding_2_t1 values(1,234.25),(2,67.29),(3,1.25),(12,1),(1,234.25) | schema1 |
      | conn_0 | False   | create table sharding_3_t1(id int(4), B int(4))                                 | schema1 |
      | conn_0 | False   | insert into sharding_3_t1 values (10, 1),(11, 2),(10,2)                         | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
      | conn   | toClose | sql                                                                                 | db      |
      | conn_0 | False   | select * from sharding_2_t1 a left join sharding_3_t1 c on a.id=c.id and a.id=@id_a | schema1 |
    Then check resultset "A" has lines with following column values
      | id-0 | B-1    | id-2 | B-3  |
      | 1    | 234.25 | None | None |
      | 1    | 234.25 | None | None |
      | 2    | 67.29  | None | None |
      | 3    | 1.25   | None | None |
      | 12   | 1.0    | None | None |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1 | schema1 |
      | conn_0 | False   | drop table if exists sharding_3_t1 | schema1 |


  Scenario: can support special sql like when execute a complex query after executing insert into multi-nodes query  #2
#case https://github.com/actiontech/dble/issues/1762
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect       | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                       | success      | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int, code int)             | success      | schema1 |
      | conn_0 | False   | set autocommit=0                                         | success      | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values (5,5),(6,6),(7,7),(8,8) | success      | schema1 |
      | conn_0 | False   | select count(*) from sharding_4_t1 order by id           | success      | schema1 |
      | conn_0 | False   | commit                                                   | success      | schema1 |
      | conn_0 | False   | select count(*) from sharding_4_t1 order by id           | has{((4,),)} | schema1 |
      | conn_0 | False   | drop table if exists sharding_4_t1                       | success      | schema1 |



  Scenario: can support special sql like when try to pushdown the OR condition   #3
#case https://github.com/actiontech/dble/issues/1705
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="s1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="s2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="s3" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect       | db      |
      | conn_0 | False   | drop table if exists s1                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s2                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s3                                                 | success      | schema1 |
      | conn_0 | False   | create table s1(pk_id int,remark int,audit_status int,`status` int)     | success      | schema1 |
      | conn_0 | False   | create table s2(fk_store_comp_id int)                                   | success      | schema1 |
      | conn_0 | False   | create table s3(fk_store_comp_id int,audit_status int)                  | success      | schema1 |
      | conn_0 | False   | SELECT count(0) FROM( SELECT c.pk_id, c.remark FROM s1 c LEFT JOIN s2 s ON c.pk_id = s.fk_store_comp_id INNER JOIN s3 ca ON ca.fk_store_comp_id = c.pk_id WHERE c.`status` = 1 AND ( c.audit_status = 2 OR ca.audit_status = 2) ) t    | success      | schema1 |
      | conn_0 | False   | drop table if exists s1                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s2                                                 | success      | schema1 |
      | conn_0 | False   | drop table if exists s3                                                 | success      | schema1 |


  Scenario: can support special sql like when select same column with different alias   #4
#case https://github.com/actiontech/dble/issues/1716
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <shardingTable name="s1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    <shardingTable name="s2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                               | expect  | db      |
      | conn_0 | False   | drop table if exists s1                                                                           | success | schema1 |
      | conn_0 | False   | drop table if exists s2                                                                           | success | schema1 |
      | conn_0 | False   | create table s1(id int,code int )                                                                 | success | schema1 |
      | conn_0 | False   | create table s2(id int,code int )                                                                 | success | schema1 |
      | conn_0 | False   | select * from (select a.id aid,b.id bid,a.id xid,3 mark from s1 a left join s2 b on a.id= b.id) t | success | schema1 |
      | conn_0 | False   | drop table if exists s1                                                                           | success | schema1 |
      | conn_0 | true    | drop table if exists s2                                                                           | success | schema1 |


  Scenario: can support special sql like when selecting from global table more times in xa transaction   #5
#case https://github.com/actiontech/dble/issues/1725
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2" sqlMaxLimit="100" shardingNode="dn5">
        <globalTable name="global_4_t2" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists global_4_t2                       | success | schema2 |
      | conn_0 | False   | create table `global_4_t2` (`id` int(11) DEFAULT NULL) | success | schema2 |
      | conn_0 | False   | set autocommit=0                                       | success | schema2 |
      | conn_0 | False   | set xa=on                                              | success | schema2 |
      | conn_0 | False   | delete from global_4_t2                                | success | schema2 |
      | conn_0 | False   | commit                                                 | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | False   | select * from global_4_t2                              | success | schema2 |
      | conn_0 | true    | insert into global_4_t2 values (1)                     | success | schema2 |
      | conn_0 | False   | drop table if exists global_4_t2                       | success | schema2 |



   Scenario: can support special sql like when selecting from global table more times in xa transaction   #6
#case https://github.com/actiontech/dble/issues/2030
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1           | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(col1 varchar(15),col2 varchar(15),col3 varchar(15), col4 varchar(15),col5 varchar(15),col6 varchar(15),col7 varchar(15),col8 varchar(15))     | success | schema1 |
      | conn_0 | False   | SELECT ttt.EACHDAY statTime, CONCAT(if(SUBSTRING( eachDay, 7, 2 ) > 9, SUBSTRING( eachDay, 7, 2 ),SUBSTRING( eachDay, 8, 1 )),'d') xValue, IFNULL( ddd.col6, 0 ) dataValue, IFNULL( ddd.col7, 0 ) dataValueLy, ':orgNo' orgNo, ddd.col4 statCalibre FROM (SELECT REPLACE(A.DATE,'-','') eachDay FROM ( SELECT CURDATE() - INTERVAL(A.A+(10*B.A)+(100*C.A)-1) DAY AS DATE FROM (SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS A CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS B CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS C ) A WHERE A.DATE BETWEEN DATE_SUB(DATE_FORMAT(':statTime','%y%m%d'),INTERVAL 12 day) AND DATE_FORMAT(':statTime','%y%m%d') ORDER BY eachDay ) ttt LEFT JOIN ( SELECT s4t.col1, round(sum(case when col2 = 'JYGK41101030000000627' then col6 else 0 end)/sum(case when col2 = 'JYGK41101030000000628' then col6 else 0 end) * 100,2) col6, round(sum(case when col2 = 'JYGK41101030000000627' then col7 else 0 end)/sum(case when col2 = 'JYGK41101030000000628' then col7 else 0 end) * 100,2) col7, ':col3' orgNo, s4t.col4 FROM sharding_4_t1 s4t WHERE col3 = ':col3' and col4 = ':statCalibre' AND col1 in (SELECT REPLACE(A.DATE,'-','') eachDay FROM ( SELECT CURDATE() - INTERVAL(A.A+(10*B.A)+(100*C.A)-1) DAY AS DATE FROM (SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS A CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS B CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS C ) A WHERE A.DATE BETWEEN DATE_SUB(DATE_FORMAT(':statTime','%y%m%d'),INTERVAL 12 day) AND DATE_FORMAT(':statTime','%y%m%d') ORDER BY eachDay) AND col5 = 'IND_08_XSHGL' GROUP BY col1 ORDER BY col1 ) ddd ON ttt.EACHDAY = ddd.col1 ORDER BY ttt.EACHDAY         | success | schema1 |
      | conn_0 | False   | SELECT ttt.EACHDAY statTime, CONCAT(if(SUBSTRING( eachDay, 7, 2 ) > 9, SUBSTRING( eachDay, 7, 2 ),SUBSTRING( eachDay, 8, 1 )),'d') xValue, IFNULL( ddd.col6, 0 ) dataValue, IFNULL( ddd.col7, 0 ) dataValueLy, ':col3' col3, 'JYGK41101030000000472' idxNo, ddd.col4 statCalibre FROM (SELECT REPLACE(A.DATE,'-','') eachDay FROM ( SELECT CURDATE() - INTERVAL(A.A+(10*B.A)+(100*C.A)-1) DAY AS DATE FROM (SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS A CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS B CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS C ) A WHERE A.DATE BETWEEN DATE_SUB(DATE_FORMAT(':statTime','%y%m%d'),INTERVAL 12 day) AND DATE_FORMAT(':statTime','%y%m%d') ORDER BY eachDay ) ttt LEFT JOIN ( SELECT cidm.col1, round(sum(case when col8 = '01' then col6 else 0 end)/sum(col6) * 100,2) col6, round(sum(case when col8 = '01' then col7 else 0 end)/sum(col7) * 100,2) col7, ':col3' col3, cidm.col4 FROM sharding_4_t1 cidm WHERE col3 = ':col3' and col4 = ':statCalibre' AND col1 in (SELECT REPLACE(A.DATE,'-','') eachDay FROM ( SELECT CURDATE() - INTERVAL(A.A+(10*B.A)+(100*C.A)-1) DAY AS DATE FROM (SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) AS A CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS B CROSS JOIN(SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) AS C ) A WHERE A.DATE BETWEEN DATE_SUB(DATE_FORMAT(':statTime','%y%m%d'),INTERVAL 12 day) AND DATE_FORMAT(':statTime','%y%m%d') ORDER BY eachDay) AND col5 = 'IND_08_GSFSTQJK' AND col2 = 'JYGK41101030000000344' GROUP BY col2, col1 ORDER BY col1 ) ddd ON ttt.EACHDAY = ddd.col1 ORDER BY ttt.EACHDAY                                                                                      | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1           | success | schema1 |
#case https://github.com/actiontech/dble/issues/2021/2025/2022
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="cl_idx_data_monitor" shardingNode="dn1,dn2,dn3,dn4" function="fixed_uniform_string_rule1" shardingColumn="id"/>
        <singleTable name="sys_dict_entry" shardingNode="dn1" />
    </schema>

     <function name="fixed_uniform_string_rule1" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:15</property>
     </function>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                | expect  | db      |
      | conn_0 | False   | drop table if exists cl_idx_data_monitor           | success | schema1 |
      | conn_0 | False   | drop table if exists sys_dict_entry                | success | schema1 |
      | conn_0 | False   | CREATE TABLE `cl_idx_data_monitor` ( `cl_id` int(10) NOT NULL DEFAULT '0', `org_no` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `org_name` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `stat_calibre` varchar(8) COLLATE utf8mb4_bin DEFAULT NULL, `busi_code` varchar(8) COLLATE utf8mb4_bin DEFAULT NULL, `major_no` varchar(8) COLLATE utf8mb4_bin DEFAULT NULL, `theme_no` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL, `theme_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `idx_no` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL, `idx_name` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `tg_no` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL, `dim1` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim2` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim3` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim4` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim5` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim6` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim7` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `dim8` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `data_value` decimal(20,6) DEFAULT NULL, `data_value_sum` decimal(20,6) DEFAULT NULL, `data_value_ly` decimal(20,6) DEFAULT NULL, `data_value_sum_ly` decimal(20,6) DEFAULT NULL, `data_value_lc` decimal(20,6) DEFAULT NULL, `data_value_sum_lc` decimal(20,6) DEFAULT NULL,   `period_value` decimal(20,6) DEFAULT NULL,   `chain_value` decimal(20,6) DEFAULT NULL,   `sum_period_value` decimal(20,6) DEFAULT NULL,   `sum_chain_value` decimal(20,6) DEFAULT NULL,   `period_change` decimal(20,6) DEFAULT NULL,   `chain_change` decimal(20,6) DEFAULT NULL,   `sum_period_change` decimal(20,6) DEFAULT NULL, `sum_chain_change` decimal(20,6) DEFAULT NULL, `ext_value01` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `ext_value02` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `ext_value03` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `ext_value04` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `ext_value05` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL,   `oper_no` varchar(32) COLLATE utf8mb4_bin DEFAULT NULL, `oper_time` datetime DEFAULT NULL, `create_time` datetime DEFAULT NULL, `remark` varchar(128) COLLATE utf8mb4_bin DEFAULT NULL, `stat_time` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL, `_dble_op_time` bigint(20) DEFAULT NULL COMMENT 'field for checking consistency', KEY `me_idx_org_no` (`org_no`), KEY `me_timeindex` (`stat_time`), KEY `me_idx_magor_no` (`major_no`), KEY `me_idx_theme_no` (`theme_no`), KEY `me_idx_idx_no` (`idx_no`), KEY `me_idx_stat_calibre` (`stat_calibre`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin     | success | schema1 |
      | conn_0 | False   | CREATE TABLE `sys_dict_entry` ( `code` varchar(18) COLLATE utf8mb4_bin DEFAULT NULL, `dict_type_id` varchar(24) COLLATE utf8mb4_bin DEFAULT NULL, `name` varchar(64) COLLATE utf8mb4_bin DEFAULT NULL, `_dble_op_time` bigint(20) DEFAULT NULL COMMENT 'field for checking consistency', `TREE_LEVEL` int(11) DEFAULT NULL, `id` int(11) DEFAULT NULL, `charge_emp_code` varchar(18) COLLATE utf8mb4_bin DEFAULT NULL, `cons_sort_code` varchar(18) COLLATE utf8mb4_bin DEFAULT NULL, `DESCRIPTION` varchar(16) COLLATE utf8mb4_bin DEFAULT NULL, `month_code` varchar(18) COLLATE utf8mb4_bin DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin                | success | schema1 |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "cs" THEN t.dataValue else 0 end ) "wsgw","test" AS 'lb'  FROM ( SELECT "w" AS name,ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='05' UNION ALL SELECT "zz" AS "name",ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 =  "04" UNION ALL SELECT "test23" AS "name",ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = '10000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE  = '01' AND dim1 ='03' ) t ;       | success | schema1 |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "cs" THEN t.dataValue END) "wsgw", SUM(CASE t.name WHEN "b" THEN t.dataValue END) "zfb", SUM(CASE t.name WHEN "cs1" THEN t.dataValue END) "wx", SUM(CASE t.name WHEN "cs" THEN t.dataValue END) "deb", SUM(CASE t.name WHEN "cs2" THEN t.dataValue END) "rx", SUM(CASE t.name WHEN "cs4" THEN t.dataValue END) "bdczqlb", SUM(CASE t.name WHEN "cs3" THEN t.dataValue END) "ywtb", SUM(CASE t.name WHEN "cs5" THEN t.dataValue END) "wz" , SUM(CASE t.name WHEN "cs" THEN t.dataValue END) "xxqd" , SUM(CASE t.name WHEN "qt" THEN t.dataValue END) "qt" , "cs" AS 'lb', s.DESCRIPTION "dw" FROM ( SELECT "ws" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='05' UNION ALL SELECT "z" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "04" UNION ALL SELECT "cs34" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='03' UNION ALL SELECT "d" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "01") t LEFT JOIN sys_dict_entry s ON s.`CODE` = '41101'                             | success | schema1 |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "cs" THEN t.dataValue END) "wsgw", SUM(CASE t.name WHEN "z" THEN t.dataValue END) "zfb", SUM(CASE t.name WHEN "x" THEN t.dataValue END) "wx", SUM(CASE t.name WHEN "b" THEN t.dataValue END) "deb", SUM(CASE t.name WHEN "xian" THEN t.dataValue END) "rx", SUM(CASE t.name WHEN "ban" THEN t.dataValue END) "bdczqlb", SUM(CASE t.name WHEN "yi" THEN t.dataValue END) "ywtb", SUM(CASE t.name WHEN "zhan" THEN t.dataValue END) "wz" , SUM(CASE t.name WHEN "dao" THEN t.dataValue END) "xxqd" , SUM(CASE t.name WHEN "qita" THEN t.dataValue END) "qt" , "kuang" AS 'lb', s.DESCRIPTION "dw" FROM ( SELECT "guo" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='05' UNION ALL SELECT "zhi" AS "name", ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "04" UNION ALL SELECT "xin" AS "name", ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='03' UNION ALL SELECT "bao" AS "name", ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "01" ) t LEFT JOIN sys_dict_entry s ON s.`CODE` = '41101'      | success | schema1 |
      | conn_0 | False   | drop table if exists cl_idx_data_monitor           | success | schema1 |
      | conn_0 | true    | drop table if exists sys_dict_entry                | success | schema1 |



   Scenario: can support special sql like when when two sharding_table inner join select DATEDIFF()   #7
#case https://github.com/actiontech/dble/issues/1913
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_2_t2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t2                                                                               | success | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t1 (id int(11),APPLY_TIME DATE,CREAT_TIME DATETIME)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 | success | schema1 |
      | conn_0 | False   | CREATE TABLE sharding_2_t2 (id int(11),APPLY_TIME DATE)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4                     | success | schema1 |
      | conn_0 | False   | INSERT INTO sharding_2_t1  (id,APPLY_TIME,CREAT_TIME) VALUES (1,'2020-07-08','2020-07-01 21:34:50')              | success | schema1 |
      | conn_0 | False   | INSERT INTO sharding_2_t2  (id,APPLY_TIME) VALUES (1,'2020-07-08')                                               | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7A"
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | SELECT tb.id,tb.APPLY_TIME,tb.CREAT_TIME,CURDATE(),DATEDIFF(tb.APPLY_TIME, CURDATE()) T1,DATEDIFF(tb.APPLY_TIME, NOW()) T2,DATEDIFF('2020-07-08', '2020-07-02') T3,DATEDIFF(tb.CREAT_TIME, CURDATE()) T4 FROM sharding_2_t1 tb INNER JOIN sharding_2_t2 tb1 ON tb.APPLY_TIME=tb1.APPLY_TIME WHERE tb1.APPLY_TIME='2020-07-08'           | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7B"
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_0 | False   | SELECT tb.id,tb.APPLY_TIME,tb.CREAT_TIME,CURDATE(),DATEDIFF(tb.APPLY_TIME, CURDATE()) T1,DATEDIFF(tb.APPLY_TIME, NOW()) T2,DATEDIFF('2020-07-08', '2020-07-02') T3,DATEDIFF(tb.CREAT_TIME, CURDATE()) T4 FROM sharding_2_t1 tb WHERE tb.id=1           | success | schema1 |
    Then check resultsets "7A" and "7B" are same in following columns
      | column     | column_index |
      | id         | 0            |
      | APPLY_TIME | 1            |
      | CREAT_TIME | 2            |
      | CURDATE()  | 3            |
      | T1         | 4            |
      | T2         | 5            |
      | T3         | 6            |
      | T4         | 7            |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1        | success | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t2        | success | schema1 |