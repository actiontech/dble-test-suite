# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/9/20
Feature: verify issue http://10.186.18.21/universe/ushard/issues/92 #Enter feature name here
  # todo: the issue only occur under ushard ha env

  @skip
  Scenario: #1 todo not complete yet #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dfile.encoding=UTF-8/-Dfile.encoding=GBK/
    a/charset=utf8mb4
    """
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_table" shardingNode="dn1,dn2,dn3,dn4" shardingColumn="id" function="hash-four" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                             | expect       | db     |
      | conn_0 | False    | drop table if exists test_table | success      | schema1 |
      | conn_0 | False    | create table test_table(`series` bigint(20) NOT NULL DEFAULT '1' COMMENT '行号',PRIMARY KEY (`series`)) DEFAULT CHARSET=utf8; | success  | schema1 |
      | conn_0 | True     | drop table test_table           | success       | schema1 |


  @restore_mysql_config
  Scenario: check support utf8mb4: case from issue http://10.186.18.11/jira/browse/DBLE0REQ-582 #2
   """
   {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0}}}
   """
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
   Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
       <shardingTable name="cl_idx_data_monitor" function="fixed_uniform_string_rule1" shardingNode="dn1,dn2,dn3,dn4" shardingColumn="stat_time"/>
       <singleTable name="sys_dict_entry" shardingNode="dn1" />
    </schema>

     <function name="fixed_uniform_string_rule1" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:8</property>
     </function>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | drop table if exists cl_idx_data_monitor   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists sys_dict_entry        | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists rl_station_relation   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | CREATE TABLE cl_idx_data_monitor ( `CL_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '指标汇总结果标识', `ORG_NO` varchar(16) DEFAULT NULL COMMENT '单位编码',   `ORG_NAME` varchar(64) DEFAULT NULL COMMENT '单位名称',   `STAT_CALIBRE` varchar(8) DEFAULT NULL COMMENT '01全口径（市含县）、02市公司、03县公司、04供电所',   `BUSI_CODE` varchar(8) DEFAULT NULL COMMENT '业务类编码',   `MAJOR_NO` varchar(8) DEFAULT NULL COMMENT '专业分类',   `THEME_NO` varchar(64) DEFAULT NULL COMMENT '主题编码',   `THEME_NAME` varchar(128) DEFAULT NULL COMMENT '主题名称',   `IDX_NO` varchar(64) DEFAULT NULL COMMENT '指标（标签）编码', `IDX_NAME` varchar(128) DEFAULT NULL COMMENT '指标（标签）名称',   `STAT_TIME` varchar(64) DEFAULT NULL COMMENT '统计日期：日（20200303）月（202003）年（2020）',   `TG_NO` varchar(64) DEFAULT NULL COMMENT '台区编号',   `DIM1` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM2` varchar(256) DEFAULT NULL COMMENT '维度扩展字段',   `DIM3` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM4` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM5` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM6` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM7` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM8` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DATA_VALUE` decimal(20,6) DEFAULT NULL COMMENT '指标值',   `DATA_VALUE_SUM` decimal(20,6) DEFAULT NULL COMMENT '累计值',   `DATA_VALUE_LY` decimal(20,6) DEFAULT NULL COMMENT '同期值',   `DATA_VALUE_SUM_LY` decimal(20,6) DEFAULT NULL COMMENT '同期累计值',   `DATA_VALUE_LC` decimal(20,6) DEFAULT NULL COMMENT '上期值',   `DATA_VALUE_SUM_LC` decimal(20,6) DEFAULT NULL COMMENT '上期累计值',   `PERIOD_VALUE` decimal(20,6) DEFAULT NULL COMMENT '同比值',   `CHAIN_VALUE` decimal(20,6) DEFAULT NULL COMMENT '环比值',   `SUM_PERIOD_VALUE` decimal(20,6) DEFAULT NULL COMMENT '累计同比值',   `SUM_CHAIN_VALUE` decimal(20,6) DEFAULT NULL COMMENT '累计环比值',   `PERIOD_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '同比变化量',   `CHAIN_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '环比变化量',   `SUM_PERIOD_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '累计同比变化量',   `SUM_CHAIN_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '累计环比变化量',   `EXT_VALUE01` varchar(128) DEFAULT NULL COMMENT '扩充值1：根据实际需要自行扩充，当为负载率指标时，那么存储可调负载率',   `EXT_VALUE02` varchar(128) DEFAULT NULL COMMENT '扩充值2：根据实际需要自行扩充',   `EXT_VALUE03` varchar(128) DEFAULT NULL COMMENT '扩充值3：根据实际需要自行扩充',   `EXT_VALUE04` varchar(128) DEFAULT NULL COMMENT '扩充值4：根据实际需要自行扩充',   `EXT_VALUE05` varchar(128) DEFAULT NULL COMMENT '扩充值5：根据实际需要自行扩充',   `OPER_NO` varchar(64) DEFAULT NULL COMMENT '操作人',   `OPER_TIME` datetime DEFAULT NULL COMMENT '操作时间',   `CREATE_TIME` datetime DEFAULT NULL COMMENT '创建时间',   `REMARK` varchar(128) DEFAULT NULL COMMENT '备注',   PRIMARY KEY (`CL_ID`) USING BTREE,   KEY `cl_idx_data_monitor_org_no1` (`ORG_NO`),   KEY `cl_idx_data_monitor_stat_time1` (`STAT_TIME`),   KEY `cl_idx_data_monitor_idx_no1` (`IDX_NO`),   KEY `cl_idx_data_monitor_statcalibre1` (`STAT_CALIBRE`) USING BTREE ) ENGINE=InnoDB AUTO_INCREMENT=13073021 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='指标结果表\r\n1)、存放指标汇总结果' | success  | schema1 |utf8mb4 |
      | conn_0 | False    | CREATE TABLE sys_dict_entry (`id` int(11) NOT NULL AUTO_INCREMENT, `CODE` varchar(64) DEFAULT NULL COMMENT '字典项编码',   `DICT_TYPE_ID` varchar(64) DEFAULT NULL COMMENT '字典类型ID',   `NAME` varchar(128) DEFAULT NULL COMMENT '字典项名称',   `DESCRIPTION` varchar(256) DEFAULT NULL COMMENT '描述',   `CREATE_TIME` datetime DEFAULT NULL COMMENT '创建时间',   `UPDATE_TIME` datetime DEFAULT NULL COMMENT '更新时间',   `TENANT_ID` varchar(64) DEFAULT NULL COMMENT '租户ID',   `PARENT_ID` varchar(64) DEFAULT NULL COMMENT '父字典项ID', `LOCALE` varchar(64) DEFAULT NULL COMMENT '默认语言',  `STATUS` varchar(64) DEFAULT NULL COMMENT '状态', `SORT_NO` int(11) DEFAULT NULL COMMENT '排序字段',   `IS_LEAF` tinyint(1) DEFAULT NULL COMMENT '是否叶节点',   `TREE_LEVEL` int(11) DEFAULT NULL COMMENT '层级',   `SEQ` varchar(256) DEFAULT NULL COMMENT '序列码',   `IS_FIXED` tinyint(1) DEFAULT NULL COMMENT '是否固定',   PRIMARY KEY (`id`) USING BTREE,   KEY `CODE` (`CODE`),   KEY `DICT_TYPE_ID` (`DICT_TYPE_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='数据字典表' | success  | schema1 |utf8mb4 |
      | conn_0 | False    | CREATE TABLE rl_station_relation (`ID` decimal(18,0) NOT NULL COMMENT '标识', `MAIN_ORG_NO` varchar(32) NOT NULL COMMENT '主单位  工单需划分至的供电所',  `ORG_NO` varchar(32) NOT NULL COMMENT '从单位  工单所属真实供电所',   `VALID_STATE` varchar(8) NOT NULL COMMENT '有效状态 1有效  0无效',   `REMARK1` varchar(256) DEFAULT NULL COMMENT '备注1',   `REMARK2` varchar(256) DEFAULT NULL COMMENT '备注2',   `OPERATE_TIME` datetime DEFAULT NULL COMMENT '操作时间',   PRIMARY KEY (`ID`) USING BTREE ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='供电所主从关系表' | success  | schema1 | utf8mb4 |
#case support execute query is more quickly  https://support.actionsky.com/service_desk/browse/ATK-1379
    Given execute single sql in "dble-1" in "user" mode and save resultset in "1"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT round(IF(( SELECT IFNULL(sum(t.DATA_VALUE), 0) FROM cl_idx_data_monitor t, rl_station_relation f WHERE t.THEME_NO = 'IND_03_ZNZZGSY' AND t.IDX_NO = 'JYGK41101030000000447' AND t.BUSI_CODE = '03' AND t.MAJOR_NO = '03' AND t.STAT_TIME = '20201013' AND t.STAT_CALIBRE = '01' AND f.MAIN_ORG_NO = '41101' AND f.ORG_NO = t.ORG_NO AND f.VALID_STATE = '1' ) = 0, 1, IFNULL(( SELECT CASE  WHEN SUM(t.data_value) IS NULL THEN 0 ELSE SUM(t.data_value) END FROM cl_idx_data_monitor t, rl_station_relation f WHERE t.THEME_NO = 'IND_03_ZNZZGSY' AND t.IDX_NO = 'JYGK41101030000000448' AND t.BUSI_CODE = '03' AND t.MAJOR_NO = '03' AND t.STAT_TIME = '20201013' AND t.STAT_CALIBRE = '01' AND f.MAIN_ORG_NO = '41101' AND f.ORG_NO = t.ORG_NO AND f.VALID_STATE = '1' ) / ( SELECT CASE  WHEN SUM(t.data_value) IS NULL THEN 0 ELSE SUM(t.data_value) END FROM cl_idx_data_monitor t, rl_station_relation f WHERE t.THEME_NO = 'IND_03_ZNZZGSY' AND t.IDX_NO = 'JYGK41101030000000447' AND t.BUSI_CODE = '03' AND t.MAJOR_NO = '03' AND t.STAT_TIME = '20201013' AND t.STAT_CALIBRE = '01' AND f.MAIN_ORG_NO = '41101' AND f.ORG_NO = t.ORG_NO AND f.VALID_STATE = '1' ), 0)), 4) * 100 AS dataValue , '03' AS busiCode, '01' AS statCalibre, '41101' AS orgCode, '03' AS majorNo, '20201013' AS statTime , 'IND_03_ZNZZGSY' AS themeNo , 'JYGK41101030000000447,JYGK41101030000000448' AS idxNo | schema1 | utf8mb4 |
    Then check resultset "1" has lines with following column values
      | dataValue-0 | busiCode-1 | statCalibre-2 | orgCode-3 | majorNo-4 | statTime-5 | themeNo-6      | idxNo-7                                     |
      | 100.0       | 03         | 01            | 41101     | 03        | 20201013   | IND_03_ZNZZGSY | JYGK41101030000000447,JYGK41101030000000448 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "2"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | select '03' busiCode, '01' statCalibre, '41101' orgCode, '03' majorNo, '20201013' statTime, 'IND_03_ZNZZGSY' themeNo, (case when tt.sum447 IS NULL then '1' when tt.sum447 = 0 then '0' when tt.sum448 IS NULL then '0' when tt.sum448 = 0 then '0' else round(tt.sum448/tt.sum447,4)* 100 end) as datavalue from ( select sum(CASE WHEN t.IDX_NO='JYGK41101030000000447' and t.data_value is NULL THEN 0 ELSE t.data_value end) as sum447, sum(CASE WHEN t.IDX_NO='JYGK41101030000000448' and t.data_value is NULL THEN 0 ELSE t.data_value end) as sum448 from cl_idx_data_monitor t,rl_station_relation f where t.THEME_NO= 'IND_03_ZNZZGSY' AND t.BUSI_CODE= '03' AND t.MAJOR_NO = '03' AND t.STAT_TIME = '20201013' AND t.STAT_CALIBRE = '01' AND f.MAIN_ORG_NO = '41101' AND f.ORG_NO = t.ORG_NO AND f.VALID_STATE = '1' and t.IDX_NO in ('JYGK41101030000000447','JYGK41101030000000448')) tt| schema1 | utf8mb4 |
    Then check resultset "2" has lines with following column values
      | busiCode-0 | statCalibre-1 | orgCode-2 | majorNo-3 | statTime-4 | themeNo-5      | datavalue-6 |
      | 03         | 01            | 41101     | 03        | 20201013   | IND_03_ZNZZGSY | 1           |

#case support "STR_TO_DATE" function https://support.actionsky.com/service_desk/browse/ATK-1382
    Given execute single sql in "dble-1" in "user" mode and save resultset in "3"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT IFNULL(SUM(t1.DATA_VALUE), 0) AS dataValue, '41101' AS orgCode , 'IND_07_ZGS_GDS' AS themeNo, '01' AS statCalibre, '04' AS busiCode, '07' AS majorNo , DATE_FORMAT(DATE_SUB(STR_TO_DATE('20201014', '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') AS endTime , f.leftIdxNo AS idxNo FROM ( SELECT t.DATA_VALUE, t.IDX_NO FROM cl_idx_data_monitor t, rl_station_relation s WHERE s.MAIN_ORG_NO = '41101' AND s.ORG_NO = t.org_no AND s.VALID_STATE = '1' AND t.THEME_NO = 'IND_07_ZGS_GDS' AND t.IDX_NO = 'JYGK41101070000000091' AND t.BUSI_CODE = '04' AND t.MAJOR_NO = '07' AND t.EXT_VALUE05 = DATE_FORMAT(DATE_SUB(STR_TO_DATE('20201014', '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') AND t.STAT_CALIBRE = '01' ) t1 RIGHT JOIN ( SELECT 'JYGK41101070000000091' AS leftIdxNo ) f ON f.leftIdxNo = t1.IDX_NO GROUP BY f.leftIdxNo | schema1 | utf8mb4 |
    Then check resultset "3" has lines with following column values
      | dataValue-0 | orgCode-1 | themeNo-2      | statCalibre-3 | busiCode-4 | majorNo-5 | endTime-6 | idxNo-7               |
      | 0           | 41101     | IND_07_ZGS_GDS | 01            | 04         | 07        | 20201013  | JYGK41101070000000091 |

#case the result support utf8 https://support.actionsky.com/service_desk/browse/ATK-1383
    Given execute single sql in "dble-1" in "user" mode and save resultset in "4"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT t.stat_time AS statTime , CASE  WHEN length(round(t.DATA_VALUE)) > 8 THEN round(IFNULL(t.DATA_VALUE, 0) / 100000000, 2) WHEN length(round(t.DATA_VALUE)) > 4 AND length(round(t.DATA_VALUE)) < 9 THEN round(IFNULL(t.DATA_VALUE, 0) / 10000, 2) ELSE IFNULL(t.DATA_VALUE, 0) END AS dataValue , CASE  WHEN length(round(t.DATA_VALUE)) > 8 THEN '亿元' WHEN length(round(t.DATA_VALUE)) > 4 AND length(round(t.DATA_VALUE)) < 9 THEN '万元' ELSE '元' END AS unit FROM ( SELECT tem.stat_time , ifnull(round(tem.dianfei + tem.weiyujin, 2), 0) AS data_Value FROM ( SELECT d.stat_time, 'IND_03_WQJJXYJK' AS THEME_NO , sum(CASE  WHEN d.IDX_NO = 'JYGK41101030000000346' THEN D.DATA_VALUE_SUM ELSE 0 END) AS dianfei , sum(CASE  WHEN d.IDX_NO = 'JYGK41101030000000347' THEN D.DATA_VALUE_SUM ELSE 0 END) AS weiyujin FROM cl_idx_data_monitor D WHERE D.THEME_NO = 'IND_03_WQJJXYJK' AND d.IDX_NO IN ('JYGK41101030000000346', 'JYGK41101030000000347') AND D.STAT_TIME = DATE_FORMAT(SYSDATE(), '%Y%m%d') AND ((length('41101') = 5 AND org_no = '41101' AND stat_calibre = '01') OR (length('41101') = 7 AND RIGHT('41101', 2) = '99' AND org_no = LEFT('41101', 5) AND stat_calibre = '02') OR (length('41101') = 7 AND RIGHT('41101', 2) != '99' AND org_no = '41101')) AND D.DIM1 = '01' AND BUSI_CODE = '03' AND MAJOR_NO = '03' GROUP BY d.stat_time ) tem RIGHT JOIN ( SELECT 'IND_03_WQJJXYJK' AS THEME_NO ) ss ON ss.THEME_NO = tem.THEME_NO ) t | schema1 | utf8mb4 |
    Then check resultset "4" has lines with following column values
      | statTime-0 | dataValue-1 | unit-2  |
      | None       | 0           | 元      |

#case support "between and "function https://support.actionsky.com/service_desk/browse/ATK-1388
    Given execute single sql in "dble-1" in "user" mode and save resultset in "5"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT DATE_FORMAT(DATE_ADD(ttt.EACHDAY, INTERVAL -1 DAY), '%Y%m%d') AS statTime , CONCAT(IF(SUBSTRING(DATE_FORMAT(DATE_ADD(eachDay, INTERVAL -1 DAY), '%Y%m%d'), 7, 2) > 9, SUBSTRING(DATE_FORMAT(DATE_ADD(eachDay, INTERVAL -1 DAY), '%Y%m%d'), 7, 2), SUBSTRING(DATE_FORMAT(DATE_ADD(eachDay, INTERVAL -1 DAY), '%Y%m%d'), 8, 1)), '日') AS xValue , IFNULL(ddd.DATA_VALUE, 0) AS dataValue , IFNULL(ddd.DATA_VALUE_LY, 0) AS dataValueLy, '41101' AS orgNo , ddd.STAT_CALIBRE AS statCalibre FROM ( SELECT REPLACE(A.DATE, '-', '') AS eachDay FROM ( SELECT date_sub(CURDATE(), INTERVAL A.A + 10 * B.A + 100 * C.A - 1 DAY) AS DATE FROM ( SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) A CROSS JOIN ( SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) B CROSS JOIN ( SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) C ) A WHERE A.DATE BETWEEN DATE_SUB(DATE_FORMAT('20201015', '%y%m%d'), INTERVAL 12 DAY) AND DATE_FORMAT('20201015', '%y%m%d') ORDER BY eachDay ) ttt LEFT JOIN ( SELECT cidm.STAT_TIME, SUM(DATA_VALUE) AS DATA_VALUE, SUM(DATA_VALUE_LY) AS DATA_VALUE_LY , '41101' AS orgNo, cidm.STAT_CALIBRE FROM cl_idx_data_monitor cidm WHERE ORG_NO = '41101' AND STAT_CALIBRE = '01' AND STAT_TIME BETWEEN REPLACE(DATE_SUB('20201015', INTERVAL 12 DAY), '-', '') AND '20201015' AND THEME_NO = 'IND_08_TQXSYLVJZQJSLV' AND IDX_NO = 'JYGK41101030000000433' GROUP BY IDX_NO, STAT_TIME ORDER BY STAT_TIME ) ddd ON ttt.EACHDAY = ddd.STAT_TIME ORDER BY ttt.EACHDAY | schema1 | utf8mb4 |
    Then check resultset "5" has lines with following column values
      | statTime-0 | xValue-1  | dataValue-2 | dataValueLy-3 | orgNo-4 | statCalibre-5 |
      | 20201002   | 2日       | 0           | 0             | 41101   | None          |
      | 20201003   | 3日       | 0           | 0             | 41101   | None          |
      | 20201004   | 4日       | 0           | 0             | 41101   | None          |
      | 20201005   | 5日       | 0           | 0             | 41101   | None          |
      | 20201006   | 6日       | 0           | 0             | 41101   | None          |
      | 20201007   | 7日       | 0           | 0             | 41101   | None          |
      | 20201008   | 8日       | 0           | 0             | 41101   | None          |
      | 20201009   | 9日       | 0           | 0             | 41101   | None          |
      | 20201010   | 10日      | 0           | 0             | 41101   | None          |
      | 20201011   | 11日      | 0           | 0             | 41101   | None          |
      | 20201012   | 12日      | 0           | 0             | 41101   | None          |
      | 20201013   | 13日      | 0           | 0             | 41101   | None          |
      | 20201014   | 14日      | 0           | 0             | 41101   | None          |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | SELECT cidm.STAT_TIME, SUM(DATA_VALUE) AS DATA_VALUE, SUM(DATA_VALUE_LY) AS DATA_VALUE_LY , '41101' AS orgNo, cidm.STAT_CALIBRE FROM cl_idx_data_monitor cidm WHERE ORG_NO = '41101' AND STAT_CALIBRE = '01' AND STAT_TIME BETWEEN REPLACE(DATE_SUB('20201015', INTERVAL 12 DAY), '-', '') AND '20201015' AND THEME_NO = 'IND_08_TQXSYLVJZQJSLV' AND IDX_NO = 'JYGK41101030000000433' GROUP BY IDX_NO, STAT_TIME ORDER BY STAT_TIME| success      | schema1 | utf8mb4 |

#case the result support utf8 https://support.actionsky.com/service_desk/browse/ATK-1398
    Given execute single sql in "dble-1" in "user" mode and save resultset in "6"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT CONCAT(c_year, '年') AS xValue, statTime , SUBSTRING(statTime, 1, 4) AS queryTimeHistogram , IFNULL(dataValue, 0) AS dataValue, ':statTime' AS queryStatTime , '41101' AS orgNo FROM ( SELECT YEAR(NOW()) AS c_year FROM DUAL UNION ALL (SELECT YEAR(NOW()) - 1 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 2 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 3 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 4 AS c_year FROM DUAL) ) ttt LEFT JOIN ( SELECT tem.stat_time AS statTime , round((tem.gong - tem.shou) / tem.gong * 100, 2) AS dataValue FROM ( SELECT a.stat_time , sum(CASE  WHEN a.IDX_NO = 'JYGK41101030000000338' THEN a.DATA_VALUE ELSE 0 END) AS gong , sum(CASE  WHEN a.IDX_NO = 'JYGK41101030000000339' THEN a.DATA_VALUE ELSE 0 END) AS shou FROM cl_idx_data_monitor a WHERE LENGTH(STAT_TIME) = 8 AND a.theme_no = 'IND_08_TGLOSSYEAR' AND a.stat_calibre = CASE  WHEN LENGTH('41101') = 5 THEN '01' WHEN LENGTH('41101') = 7 THEN '03' WHEN LENGTH('41101') = 8 THEN '04' END AND BUSI_CODE = '03' AND MAJOR_NO = '08' AND a.org_no = '41101' AND a.idx_no IN ('JYGK41101030000000338', 'JYGK41101030000000339') GROUP BY a.stat_time ) tem ) ddd ON ttt.c_year = SUBSTRING(ddd.statTime, 1, 4) ORDER BY c_year| schema1 | utf8mb4 |
    Then check resultset "6" has lines with following column values
      | xValue-0  | statTime-1 | queryTimeHistogram-2 | dataValue-3 | queryStatTime-4 | orgNo-5 |
      | 2016年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2017年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2018年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2019年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2020年    | None       | None                 | 0           | :statTime       | 41101   |


##case the filed support utf8  https://support.actionsky.com/service_desk/browse/ATK-1400
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT CASE  WHEN deno1 = '0' THEN 1 ELSE (deno1 - mole1) / deno1 END * 50 + CASE  WHEN deno2 = '0' THEN 1 ELSE (deno2 - mole2) / deno2 END * 30 + CASE  WHEN deno3 = '0' THEN 1 ELSE (deno3 - mole3) / deno3 END * 20 AS 达标率 , CASE  WHEN deno1 = '0' THEN 1 ELSE (deno1 - mole1) / deno1 END * 100 AS 高压 , deno1 AS 高压总, mole1 AS 高压异常 , CASE  WHEN deno2 = '0' THEN 1 ELSE (deno2 - mole2) / deno2 END * 100 AS 低压 , deno2 AS 低压总, mole2 AS 低压异常 , CASE  WHEN deno3 = '0' THEN 1 ELSE (deno3 - mole3) / deno3 END * 100 AS 变更 , deno3 AS 变更总, mole3 AS 变更异常 FROM ( SELECT ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '01' AND idx_no = 'JYGK41101020000000022' THEN data_value END), 0) AS deno1 , ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '01' AND idx_no = 'JYGK41101020000000023' THEN data_value END), 0) AS mole1 , ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '02' AND idx_no = 'JYGK41101020000000022' THEN data_value END), 0) AS deno2 , ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '02' AND idx_no = 'JYGK41101020000000023' THEN data_value END), 0) AS mole2 , ifnull(SUM(CASE  WHEN dim2 = '03' AND idx_no = 'JYGK41101020000000022' THEN data_value END), 0) AS deno3 , ifnull(SUM(CASE  WHEN dim2 = '03' AND idx_no = 'JYGK41101020000000023' THEN data_value END), 0) AS mole3 FROM cl_idx_data_monitor c WHERE theme_no = 'ind_02_ykzb' AND idx_no IN ('JYGK41101020000000022', 'JYGK41101020000000023') AND stat_calibre = '03' AND EXT_VALUE05 LIKE '202009%' AND major_no = '02' AND org_no = '4140621' ) a | schema1 | utf8mb4 |
    Then check resultset "7" has lines with following column values
      | 达标率-0 | 高压-1 | 高压总-2 | 高压异常-3 | 低压-4 | 低压总-5 | 低压异常-6 | 变更-7 | 变更总-8 | 变更异常-9 |
      | 100     | 100   | 0       | 0         | 100   | 0       | 0        | 100    | 0       | 0        |

#case  the filed and result support utf8 https://support.actionsky.com/service_desk/browse/ATK-1403 /ATK-1406  /ATK-1409
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | SELECT tem1.ORG_NO, tem1.org_name , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 12) AS 小于1个月 , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 6) AS 大于2个月 FROM ( SELECT a.ORG_NO, a.ORG_NAME, round(sum(a.DATA_VALUE)) AS yunxingshu FROM cl_idx_data_monitor a WHERE a.stat_time LIKE '20200%' AND a.theme_no = 'IND_03_ZCZCGDSLMONTH' AND a.ORG_NO = '999999999999999' AND a.STAT_CALIBRE = '04' AND a.DIM1 = '21' AND a.DIM2 = '01' GROUP BY a.ORG_NO, a.ORG_NAME UNION SELECT a.ORG_NO, a.ORG_NAME, round(sum(a.DATA_VALUE)) AS yunxingshu FROM cl_idx_data_monitor a WHERE a.stat_time LIKE '20200%' AND a.theme_no = 'IND_03_ZCZCGDSLMONTH' AND a.ORG_NO LIKE '999999999999999' AND substr(a.ORG_NO, 6, 2) > 1 AND a.STAT_CALIBRE = '04' AND a.DIM1 = '21' AND a.DIM2 = '01' GROUP BY a.ORG_NO, a.ORG_NAME ) tem1, ( SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('05', '00') AND d.ORG_NO = '999999999999999' AND d.STAT_CALIBRE = '04' AND substr(d.STAT_TIME, 1, 4) = substr('20200922', 1, 4) GROUP BY d.ORG_NO UNION SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('05', '00') AND d.ORG_NO = '999999999999999' AND d.STAT_CALIBRE = '04' AND substr(d.STAT_TIME, 1, 4) = substr('20200922', 1, 4) GROUP BY d.ORG_NO UNION SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('05', '00') AND d.ORG_NO = '999999999999999' AND substr(d.ORG_NO, 6, 2) > '20' AND d.STAT_CALIBRE = '04' AND substr(d.STAT_TIME, 1, 4) = substr('20200922', 1, 4) GROUP BY d.ORG_NO ) tem2 WHERE tem1.ORG_NO = tem2.ORG_NO | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT ifnull(aa.`大于2个月`, 0) AS 大于2个月 , ifnull(aa.`小于1个月`, 0) AS 小于1个月, bb.`CODE` AS ORG_NO , bb.`NAME` AS org_name FROM ( SELECT tem1.ORG_NO, tem1.org_name , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 12) AS 小于1个月 , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 6) AS 大于2个月 FROM ( SELECT a.ORG_NO, a.ORG_NAME, round(sum(a.DATA_VALUE)) AS yunxingshu FROM cl_idx_data_monitor a WHERE a.stat_time = '202007' AND a.theme_no = 'IND_03_ZCZCGDSLMONTH' AND a.ORG_NO LIKE '999%' AND a.STAT_CALIBRE IN ('04', '21') AND a.DIM1 = '21' AND a.DIM2 = '01' GROUP BY a.ORG_NO, a.ORG_NAME ) tem1, ( SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('11', '00') AND d.ORG_NO LIKE '999999999999999' AND d.STAT_CALIBRE IN ('04', '21') AND substr(d.STAT_TIME, 1, 4) = substr('20200722', 1, 4) GROUP BY d.ORG_NO ) tem2 WHERE tem1.ORG_NO = tem2.ORG_NO ) aa RIGHT JOIN ( SELECT s.CODE, s.NAME FROM sys_dict_entry s WHERE s.`CODE` LIKE '999%' AND TREE_LEVEL IN ('3', '4') ) bb ON bb.`CODE` = aa.ORG_NO ORDER BY bb.`CODE`  | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT d.NAME NAME, d.CODE CODE, IFNULL( c.减容容量, 0 ) 减容容量, IFNULL( c.同期减容容量, 0 ) 同期减容容量, IFNULL( c.同比减容容量, 0 ) 同比减容容量  FROM  (  SELECT   org_no,   IFNULL( SUM( ifnull( c.jrrl, 0 )), 0 ) 减容容量,   IFNULL( SUM( ifnull( c.tqjrrl, 0 )), 0 ) 同期减容容量,   IFNULL(((      SUM(       ifnull( c.jrrl, 0 )) - SUM(      ifnull( c.tqjrrl, 0 ))) / SUM(      ifnull( c.tqjrrl, 0 ))) * 100,    0    ) 同比减容容量   FROM   (   SELECT    org_no,    tj jrrl,    tq tqjrrl    FROM    (    SELECT     a.org_no,     a.idx_no,     (     SUM( a.data_value )) tj,     (     SUM( a.data_value_ly )) tq     FROM     cl_idx_data_monitor a     WHERE     a.EXT_VALUE05 LIKE '202009%'      AND a.theme_no = 'IND_02_FBSBZ'      AND org_no LIKE '41406%'      AND a.stat_calibre = '03'      AND a.idx_no = 'JYGK41101020000000015'     GROUP BY     a.org_no,     a.idx_no     ) b    ) c   GROUP BY   c.org_no   ) c  RIGHT JOIN ( SELECT * FROM sys_dict_entry WHERE CODE LIKE '41406%' AND LENGTH( CODE ) = '7' AND NAME NOT LIKE '%自备电厂%' ) d ON c.org_no = d.CODE  ORDER BY  ( d.CODE = '4140601' ) DESC,  d.CODE  | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT d.NAME NAME, d.CODE CODE, IFNULL( c.jianrong, 0 ) 减容容量, IFNULL( c.tongqijianrong, 0 ) 同期减容容量, IFNULL( c.tongbijianrong, 0 ) 同比减容容量  FROM  (  SELECT   org_no,   IFNULL( SUM( ifnull( c.jrrl, 0 )), 0 ) jianrong,   IFNULL( SUM( ifnull( c.tqjrrl, 0 )), 0 ) tongqijianrong,   IFNULL(((      SUM(       ifnull( c.jrrl, 0 )) - SUM(      ifnull( c.tqjrrl, 0 ))) / SUM(      ifnull( c.tqjrrl, 0 ))) * 100,    0    ) tongbijianrong   FROM   (   SELECT    org_no,    tj jrrl,    tq tqjrrl    FROM    (    SELECT     a.org_no,     a.idx_no,     (     SUM( a.data_value )) tj,     (     SUM( a.data_value_ly )) tq     FROM     cl_idx_data_monitor a     WHERE     a.EXT_VALUE05 LIKE '202009%'      AND a.theme_no = 'IND_02_FBSBZ'      AND org_no LIKE '41406%'      AND a.stat_calibre = '03'      AND a.idx_no = 'JYGK41101020000000015'     GROUP BY     a.org_no,     a.idx_no     ) b    ) c   GROUP BY   c.org_no   ) c  RIGHT JOIN ( SELECT * FROM sys_dict_entry WHERE CODE LIKE '41406%' AND LENGTH( CODE ) = '7' AND NAME NOT LIKE '%自备电厂%' ) d ON c.org_no = d.CODE  ORDER BY  ( d.CODE = '4140601' ) DESC,  d.CODE | success      | schema1 | utf8mb4 |

#case function support utf8  https://support.actionsky.com/service_desk/browse/ATK-1408
    Given execute single sql in "dble-1" in "user" mode and save resultset in "10"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT A1.dim1 AS dim, IFNULL(A2.dataValue, 0) AS dataValue FROM ( SELECT '新装增容' AS dim1 FROM DUAL UNION SELECT '低压新装' AS dim1 FROM DUAL UNION SELECT '低压非居' AS dim1 FROM DUAL UNION SELECT '高压' AS dim1 FROM DUAL UNION SELECT '临时用电' AS dim1 FROM DUAL UNION SELECT '低压批量' AS dim1 FROM DUAL UNION SELECT '过户' AS dim1 FROM DUAL UNION SELECT '销户' AS dim1 FROM DUAL UNION SELECT '更名' AS dim1 FROM DUAL UNION SELECT '减容' AS dim1 FROM DUAL UNION SELECT '暂停' AS dim1 FROM DUAL UNION SELECT '改类' AS dim1 FROM DUAL UNION SELECT '批量销户' AS dim1 FROM DUAL UNION SELECT '计量装置故障' AS dim1 FROM DUAL UNION SELECT '其他' AS dim1 FROM DUAL ) A1 LEFT JOIN ( SELECT b.dim, SUM(b.tj) AS dataValue FROM ( SELECT CASE  WHEN dim1 IN ('101', '109') THEN '低压新装' WHEN dim1 IN ('102', '110') THEN '低压非居' WHEN dim1 IN ('104', '111') THEN '高压' WHEN dim1 IN ('105') THEN '临时用电' WHEN dim1 IN ('112') THEN '低压批量' WHEN dim1 IN ('211') THEN '过户' WHEN dim1 IN ('216') THEN '销户' WHEN dim1 IN ('210') THEN '更名' WHEN dim1 IN ('201') THEN '减容' WHEN dim1 IN ('203') THEN '暂停' WHEN dim1 IN ('215') THEN '改类' WHEN dim1 IN ('217') THEN '批量销户' WHEN dim1 IN ('302') THEN '计量装置故障' ELSE '其他' END AS dim, IFNULL(SUM(a.data_value), 0) AS tj FROM cl_idx_data_monitor a WHERE SUBSTR(a.EXT_VALUE05, 1, 6) = '202009' AND a.theme_no = 'IND_02_YWBL' AND org_no = '4140621' AND a.stat_calibre = '03' AND a.dim1 NOT IN ( '471',  '502',  '504',  '505',  '506',  '507',  '508',  '509',  '510',  '511' ) AND a.idx_no IN ('JYGK41101020000000002') GROUP BY a.dim1 UNION ALL SELECT '新装增容' AS dim, IFNULL(SUM(a.data_value), 0) AS tj FROM cl_idx_data_monitor a WHERE SUBSTR(a.EXT_VALUE05, 1, 6) = '202009' AND a.theme_no = 'IND_02_YWBL' AND org_no = '4140621' AND a.stat_calibre = '03' AND a.dim1 IN ( '101',  '102',  '104',  '105',  '109',  '110',  '111',  '112' ) AND a.idx_no IN ('JYGK41101020000000002') ) b GROUP BY b.dim ) A2 ON A1.dim1 = A2.dim | schema1 | utf8mb4 |
    Then check resultset "10" has lines with following column values
      | dim-0      | dataValue-1 |
      | 临时用电     | 0           |
      | 低压批量     | 0           |
      | 低压新装     | 0           |
      | 低压非居     | 0           |
      | 其他        | 0           |
      | 减容        | 0           |
      | 批量销户     | 0           |
      | 改类        | 0           |
      | 新装增容     | 0           |
      | 暂停        | 0           |
      | 更名        | 0           |
      | 计量装置故障 | 0           |
      | 过户        | 0           |
      | 销户        | 0           |
      | 高压        | 0           |

#case function support utf8 from github  https://github.com/actiontech/dble/issues/2021
    Given execute single sql in "dble-1" in "user" mode and save resultset in "12"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "wsgw", SUM(CASE t.name WHEN "支" THEN t.dataValue END) "zfb", SUM(CASE t.name WHEN "信" THEN t.dataValue END) "wx", SUM(CASE t.name WHEN "宝" THEN t.dataValue END) "deb", SUM(CASE t.name WHEN "线" THEN t.dataValue END) "rx", SUM(CASE t.name WHEN "办" THEN t.dataValue END) "bdczqlb", SUM(CASE t.name WHEN "一" THEN t.dataValue END) "ywtb", SUM(CASE t.name WHEN "站" THEN t.dataValue END) "wz" , SUM(CASE t.name WHEN "道" THEN t.dataValue END) "xxqd" , SUM(CASE t.name WHEN " 其他" THEN t.dataValue END) "qt" , "况" AS 'lb', s.DESCRIPTION "dw" FROM ( SELECT "国" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='05' UNION ALL SELECT "支" AS "name", ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "04" UNION ALL SELECT "信" AS "name", ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='03' UNION ALL SELECT "宝" AS "name", ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "01" ) t LEFT JOIN sys_dict_entry s ON s.`CODE` = '41101' | schema1 | utf8mb4 |
    Then check resultset "12" has lines with following column values
      | wsgw-0 | zfb-1 | wx-2 | deb-3 | rx-4 | bdczqlb-5 | ywtb-6 | wz-7 | xxqd-8 | qt-9 | lb-10 | dw-11 |
      | None   | 0.0   | 0.0  | 0.0   | None | None      | None   | None | None   | None | 况     | None  |

#case function support utf8 from github  https://github.com/actiontech/dble/issues/2022
    Given execute single sql in "dble-1" in "user" mode and save resultset in "13"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "wsgw", SUM(CASE t.name WHEN "宝" THEN t.dataValue END) "zfb", SUM(CASE t.name WHEN "测试1" THEN t.dataValue END) "wx", SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "deb", SUM(CASE t.name WHEN "测试2" THEN t.dataValue END) "rx", SUM(CASE t.name WHEN "测试4" THEN t.dataValue END) "bdczqlb", SUM(CASE t.name WHEN "测试3" THEN t.dataValue END) "ywtb", SUM(CASE t.name WHEN "测试5" THEN t.dataValue END) "wz" , SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "xxqd" , SUM(CASE t.name WHEN "其他" THEN t.dataValue END) "qt" , "测试" AS 'lb', s.DESCRIPTION "dw" FROM ( SELECT "网上" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='05' UNION ALL SELECT "支" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "04" UNION ALL SELECT "测试34" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='03' UNION ALL SELECT "电" AS name, ROUND(IFNULL(SUM(`DATA_VALUE`),0)) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 = "01") t LEFT JOIN sys_dict_entry s ON s.`CODE` = '41101'  | schema1 | utf8mb4 |
    Then check resultset "13" has lines with following column values
      | wsgw-0 | zfb-1 | wx-2 | deb-3 | rx-4 | bdczqlb-5 | ywtb-6 | wz-7 | xxqd-8 | qt-9 | lb-10 | dw-11 |
      | None   | None  | None | None  | None | None      | None   | None | None   | None | 测试    | None  |

#case function support utf8 from github  https://github.com/actiontech/dble/issues/2025
    Given execute single sql in "dble-1" in "user" mode and save resultset in "14"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "测试" THEN t.dataValue else 0 end ) "wsgw","test" AS 'lb'  FROM ( SELECT "网" AS name,ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 ='05' UNION ALL SELECT "支之" AS "name",ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = 'JYGK41101040000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE = '01' AND dim1 =  "04" UNION ALL SELECT "test23" AS "name",ROUND(IFNULL(SUM(`DATA_VALUE`),0),0) dataValue FROM cl_idx_data_monitor cidm WHERE cidm.ORG_NO = '41101' AND cidm.IDX_NO = '10000000001' AND cidm.STAT_TIME >= '20200802' AND cidm.STAT_TIME <= '20200803' AND cidm.STAT_CALIBRE  = '01' AND dim1 ='03' ) t | schema1 | utf8mb4 |
    Then check resultset "14" has lines with following column values
      | wsgw-0 | lb-1 |
      | 0.0    | test |

#case no cerate schema but in sql is used this schema then do not occur npe http://10.186.18.11/jira/browse/DBLE0REQ-627
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose   | sql                                        | expect    | charset |
#      | conn_0 | false     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join (select * from mimc_be.cl_idx_data_monitor UNION ALL select * from mimc_be.cl_idx_data_monitor ) as B   | schema mimc_be doesn't exist! | utf8mb4 |
#      | conn_0 | false     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join mimc_be.cl_idx_data_monitor   |  Table `mimc_be`.`cl_idx_data_monitor` doesn't exist | utf8mb4 |

#case no use schema then do not occur npe http://10.186.18.11/jira/browse/DBLE0REQ-638 and http://10.186.18.11/jira/browse/DBLE0REQ-685
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect    | charset |
#      | conn_1 | true     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join (select * from mimc_be.cl_idx_data_monitor UNION ALL select * from mimc_be.cl_idx_data_monitor ) as B   |   | utf8mb4 |
#      | conn_1 | true     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join mimc_be.cl_idx_data_monitor   |   | utf8mb4 |
      | conn_1 | true     | SELECT d.NAME AS NAME, d.CODE AS CODE, IFNULL(c.减容容量, 0) AS 减容容量 , IFNULL(c.同期减容容量, 0) AS 同期减容容量 , IFNULL(c.同比减容容量, 0) AS 同比减容容量 FROM ( SELECT org_no , IFNULL(SUM(ifnull(c.jrrl, 0)), 0) AS 减容容量 , IFNULL(SUM(ifnull(c.tqjrrl, 0)), 0) AS 同期减容容量 , IFNULL((SUM(ifnull(c.jrrl, 0)) - SUM(ifnull(c.tqjrrl, 0))) / SUM(ifnull(c.tqjrrl, 0)) * 100, 0) AS 同比减容容量 FROM ( SELECT org_no, tj AS jrrl, tq AS tqjrrl FROM ( SELECT a.org_no, a.idx_no, SUM(a.data_value) AS tj , SUM(a.data_value_ly) AS tq FROM cl_idx_data_monitor a WHERE a.EXT_VALUE05 LIKE '202009%' AND a.theme_no = 'IND_02_FBSBZ' AND org_no LIKE '41406%' AND a.stat_calibre = '03' AND a.idx_no = 'JYGK41101020000000015' GROUP BY a.org_no, a.idx_no ) b ) c GROUP BY c.org_no ) c RIGHT JOIN ( SELECT * FROM sys_dict_entry WHERE CODE LIKE '41406%' AND LENGTH(CODE) = '7' AND NAME NOT LIKE '%自备电厂%' ) d ON c.org_no = d.CODE ORDER BY d.CODE = '4140601' DESC, d.CODE   | No database selected | utf8mb4 |

#case clear table meta
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | drop table if exists cl_idx_data_monitor   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists sys_dict_entry        | success      | schema1 | utf8mb4 |
      | conn_0 | true     | drop table if exists rl_station_relation   | success      | schema1 | utf8mb4 |