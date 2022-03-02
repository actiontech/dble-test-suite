# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/9/20
Feature: verify issue http://10.186.18.21/universe/ushard/issues/92 #Enter feature name here
  # todo: the issue only occur under ushard ha env

  Scenario: #1 todo not complete yet #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-Dfile.encoding=UTF-8/-Dfile.encoding=GBK/
    a/charset=utf8mb4
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                            | expect  | db      | charset |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                                             | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table sharding_4_t1(`series` bigint(20) NOT NULL DEFAULT '1' COMMENT '行号',PRIMARY KEY (`series`)) DEFAULT CHARSET=utf8 | success | schema1 | utf8mb4 |
      | conn_0 | True    | drop table sharding_4_t1                                                                                                       | success | schema1 | utf8mb4 |


  @restore_mysql_config
  Scenario: check support utf8mb4: case from issue DBLE0REQ-582 #2
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
    #coz DBLE0REQ-688
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | drop table if exists cl_idx_data_monitor   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists sys_dict_entry        | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists rl_station_relation   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | CREATE TABLE cl_idx_data_monitor ( `CL_ID` int(11) NOT NULL AUTO_INCREMENT COMMENT '指标汇总结果标识', `ORG_NO` varchar(16) DEFAULT NULL COMMENT '单位编码',   `ORG_NAME` varchar(64) DEFAULT NULL COMMENT '单位名称',   `STAT_CALIBRE` varchar(8) DEFAULT NULL COMMENT '01全口径（市含县）、02市公司、03县公司、04供电所',   `BUSI_CODE` varchar(8) DEFAULT NULL COMMENT '业务类编码',   `MAJOR_NO` varchar(8) DEFAULT NULL COMMENT '专业分类',   `THEME_NO` varchar(64) DEFAULT NULL COMMENT '主题编码',   `THEME_NAME` varchar(128) DEFAULT NULL COMMENT '主题名称',   `IDX_NO` varchar(64) DEFAULT NULL COMMENT '指标（标签）编码', `IDX_NAME` varchar(128) DEFAULT NULL COMMENT '指标（标签）名称',   `STAT_TIME` varchar(64) DEFAULT NULL COMMENT '统计日期：日（20200303）月（202003）年（2020）',   `TG_NO` varchar(64) DEFAULT NULL COMMENT '台区编号',   `DIM1` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM2` varchar(256) DEFAULT NULL COMMENT '维度扩展字段',   `DIM3` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM4` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM5` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM6` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM7` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DIM8` varchar(16) DEFAULT NULL COMMENT '维度扩展字段',   `DATA_VALUE` decimal(20,6) DEFAULT NULL COMMENT '指标值',   `DATA_VALUE_SUM` decimal(20,6) DEFAULT NULL COMMENT '累计值',   `DATA_VALUE_LY` decimal(20,6) DEFAULT NULL COMMENT '同期值',   `DATA_VALUE_SUM_LY` decimal(20,6) DEFAULT NULL COMMENT '同期累计值',   `DATA_VALUE_LC` decimal(20,6) DEFAULT NULL COMMENT '上期值',   `DATA_VALUE_SUM_LC` decimal(20,6) DEFAULT NULL COMMENT '上期累计值',   `PERIOD_VALUE` decimal(20,6) DEFAULT NULL COMMENT '同比值',   `CHAIN_VALUE` decimal(20,6) DEFAULT NULL COMMENT '环比值',   `SUM_PERIOD_VALUE` decimal(20,6) DEFAULT NULL COMMENT '累计同比值',   `SUM_CHAIN_VALUE` decimal(20,6) DEFAULT NULL COMMENT '累计环比值',   `PERIOD_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '同比变化量',   `CHAIN_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '环比变化量',   `SUM_PERIOD_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '累计同比变化量',   `SUM_CHAIN_CHANGE` decimal(20,6) DEFAULT NULL COMMENT '累计环比变化量',   `EXT_VALUE01` varchar(128) DEFAULT NULL COMMENT '扩充值1：根据实际需要自行扩充，当为负载率指标时，那么存储可调负载率',   `EXT_VALUE02` varchar(128) DEFAULT NULL COMMENT '扩充值2：根据实际需要自行扩充',   `EXT_VALUE03` varchar(128) DEFAULT NULL COMMENT '扩充值3：根据实际需要自行扩充',   `EXT_VALUE04` varchar(128) DEFAULT NULL COMMENT '扩充值4：根据实际需要自行扩充',   `EXT_VALUE05` varchar(128) DEFAULT NULL COMMENT '扩充值5：根据实际需要自行扩充',   `OPER_NO` varchar(64) DEFAULT NULL COMMENT '操作人',   `OPER_TIME` datetime DEFAULT NULL COMMENT '操作时间',   `CREATE_TIME` datetime DEFAULT NULL COMMENT '创建时间',   `REMARK` varchar(128) DEFAULT NULL COMMENT '备注',   PRIMARY KEY (`CL_ID`) USING BTREE,   KEY `cl_idx_data_monitor_org_no1` (`ORG_NO`),   KEY `cl_idx_data_monitor_stat_time1` (`STAT_TIME`),   KEY `cl_idx_data_monitor_idx_no1` (`IDX_NO`),   KEY `cl_idx_data_monitor_statcalibre1` (`STAT_CALIBRE`) USING BTREE ) ENGINE=InnoDB AUTO_INCREMENT=13073021 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='指标结果表\r\n1)、存放指标汇总结果' | success  | schema1 |utf8mb4 |
      | conn_0 | False    | CREATE TABLE sys_dict_entry (`id` int(11) NOT NULL AUTO_INCREMENT, `CODE` varchar(64) DEFAULT NULL COMMENT '字典项编码',   `DICT_TYPE_ID` varchar(64) DEFAULT NULL COMMENT '字典类型ID',   `NAME` varchar(128) DEFAULT NULL COMMENT '字典项名称',   `DESCRIPTION` varchar(256) DEFAULT NULL COMMENT '描述',   `CREATE_TIME` datetime DEFAULT NULL COMMENT '创建时间',   `UPDATE_TIME` datetime DEFAULT NULL COMMENT '更新时间',   `TENANT_ID` varchar(64) DEFAULT NULL COMMENT '租户ID',   `PARENT_ID` varchar(64) DEFAULT NULL COMMENT '父字典项ID', `LOCALE` varchar(64) DEFAULT NULL COMMENT '默认语言',  `STATUS` varchar(64) DEFAULT NULL COMMENT '状态', `SORT_NO` int(11) DEFAULT NULL COMMENT '排序字段',   `IS_LEAF` tinyint(1) DEFAULT NULL COMMENT '是否叶节点',   `TREE_LEVEL` int(11) DEFAULT NULL COMMENT '层级',   `SEQ` varchar(256) DEFAULT NULL COMMENT '序列码',   `IS_FIXED` tinyint(1) DEFAULT NULL COMMENT '是否固定',   PRIMARY KEY (`id`) USING BTREE,   KEY `CODE` (`CODE`),   KEY `DICT_TYPE_ID` (`DICT_TYPE_ID`) ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='数据字典表' | success  | schema1 |utf8mb4 |
      | conn_0 | False    | CREATE TABLE rl_station_relation (`ID` decimal(18,0) NOT NULL COMMENT '标识', `MAIN_ORG_NO` varchar(32) NOT NULL COMMENT '主单位  工单需划分至的供电所',  `ORG_NO` varchar(32) NOT NULL COMMENT '从单位  工单所属真实供电所',   `VALID_STATE` varchar(8) NOT NULL COMMENT '有效状态 1有效  0无效',   `REMARK1` varchar(256) DEFAULT NULL COMMENT '备注1',   `REMARK2` varchar(256) DEFAULT NULL COMMENT '备注2',   `OPERATE_TIME` datetime DEFAULT NULL COMMENT '操作时间',   PRIMARY KEY (`ID`) USING BTREE ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='供电所主从关系表' | success  | schema1 | utf8mb4 |
#case support execute query is more quickly ATK-1379
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

#case support "STR_TO_DATE" function ATK-1382
    Given execute single sql in "dble-1" in "user" mode and save resultset in "3"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT IFNULL(SUM(t1.DATA_VALUE), 0) AS dataValue, '41101' AS orgCode , 'IND_07_ZGS_GDS' AS themeNo, '01' AS statCalibre, '04' AS busiCode, '07' AS majorNo , DATE_FORMAT(DATE_SUB(STR_TO_DATE('20201014', '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') AS endTime , f.leftIdxNo AS idxNo FROM ( SELECT t.DATA_VALUE, t.IDX_NO FROM cl_idx_data_monitor t, rl_station_relation s WHERE s.MAIN_ORG_NO = '41101' AND s.ORG_NO = t.org_no AND s.VALID_STATE = '1' AND t.THEME_NO = 'IND_07_ZGS_GDS' AND t.IDX_NO = 'JYGK41101070000000091' AND t.BUSI_CODE = '04' AND t.MAJOR_NO = '07' AND t.EXT_VALUE05 = DATE_FORMAT(DATE_SUB(STR_TO_DATE('20201014', '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') AND t.STAT_CALIBRE = '01' ) t1 RIGHT JOIN ( SELECT 'JYGK41101070000000091' AS leftIdxNo ) f ON f.leftIdxNo = t1.IDX_NO GROUP BY f.leftIdxNo | schema1 | utf8mb4 |
    Then check resultset "3" has lines with following column values
      | dataValue-0 | orgCode-1 | themeNo-2      | statCalibre-3 | busiCode-4 | majorNo-5 | endTime-6 | idxNo-7               |
      | 0           | 41101     | IND_07_ZGS_GDS | 01            | 04         | 07        | 20201013  | JYGK41101070000000091 |

#case the result support utf8 ATK-1383
    Given execute single sql in "dble-1" in "user" mode and save resultset in "4"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT t.stat_time AS statTime , CASE  WHEN length(round(t.DATA_VALUE)) > 8 THEN round(IFNULL(t.DATA_VALUE, 0) / 100000000, 2) WHEN length(round(t.DATA_VALUE)) > 4 AND length(round(t.DATA_VALUE)) < 9 THEN round(IFNULL(t.DATA_VALUE, 0) / 10000, 2) ELSE IFNULL(t.DATA_VALUE, 0) END AS dataValue , CASE  WHEN length(round(t.DATA_VALUE)) > 8 THEN '亿元' WHEN length(round(t.DATA_VALUE)) > 4 AND length(round(t.DATA_VALUE)) < 9 THEN '万元' ELSE '元' END AS unit FROM ( SELECT tem.stat_time , ifnull(round(tem.dianfei + tem.weiyujin, 2), 0) AS data_Value FROM ( SELECT d.stat_time, 'IND_03_WQJJXYJK' AS THEME_NO , sum(CASE  WHEN d.IDX_NO = 'JYGK41101030000000346' THEN D.DATA_VALUE_SUM ELSE 0 END) AS dianfei , sum(CASE  WHEN d.IDX_NO = 'JYGK41101030000000347' THEN D.DATA_VALUE_SUM ELSE 0 END) AS weiyujin FROM cl_idx_data_monitor D WHERE D.THEME_NO = 'IND_03_WQJJXYJK' AND d.IDX_NO IN ('JYGK41101030000000346', 'JYGK41101030000000347') AND D.STAT_TIME = DATE_FORMAT(SYSDATE(), '%Y%m%d') AND ((length('41101') = 5 AND org_no = '41101' AND stat_calibre = '01') OR (length('41101') = 7 AND RIGHT('41101', 2) = '99' AND org_no = LEFT('41101', 5) AND stat_calibre = '02') OR (length('41101') = 7 AND RIGHT('41101', 2) != '99' AND org_no = '41101')) AND D.DIM1 = '01' AND BUSI_CODE = '03' AND MAJOR_NO = '03' GROUP BY d.stat_time ) tem RIGHT JOIN ( SELECT 'IND_03_WQJJXYJK' AS THEME_NO ) ss ON ss.THEME_NO = tem.THEME_NO ) t | schema1 | utf8mb4 |
    Then check resultset "4" has lines with following column values
      | statTime-0 | dataValue-1 | unit-2  |
      | None       | 0           | 元      |

#case support "between and "function ATK-1388
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

#case the result support utf8 ATK-1398
    Given execute single sql in "dble-1" in "user" mode and save resultset in "6"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT CONCAT(c_year, '年') AS xValue, statTime , SUBSTRING(statTime, 1, 4) AS queryTimeHistogram , IFNULL(dataValue, 0) AS dataValue, ':statTime' AS queryStatTime , '41101' AS orgNo FROM ( SELECT YEAR(NOW()) AS c_year FROM DUAL UNION ALL (SELECT YEAR(NOW()) - 1 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 2 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 3 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 4 AS c_year FROM DUAL) ) ttt LEFT JOIN ( SELECT tem.stat_time AS statTime , round((tem.gong - tem.shou) / tem.gong * 100, 2) AS dataValue FROM ( SELECT a.stat_time , sum(CASE  WHEN a.IDX_NO = 'JYGK41101030000000338' THEN a.DATA_VALUE ELSE 0 END) AS gong , sum(CASE  WHEN a.IDX_NO = 'JYGK41101030000000339' THEN a.DATA_VALUE ELSE 0 END) AS shou FROM cl_idx_data_monitor a WHERE LENGTH(STAT_TIME) = 8 AND a.theme_no = 'IND_08_TGLOSSYEAR' AND a.stat_calibre = CASE  WHEN LENGTH('41101') = 5 THEN '01' WHEN LENGTH('41101') = 7 THEN '03' WHEN LENGTH('41101') = 8 THEN '04' END AND BUSI_CODE = '03' AND MAJOR_NO = '08' AND a.org_no = '41101' AND a.idx_no IN ('JYGK41101030000000338', 'JYGK41101030000000339') GROUP BY a.stat_time ) tem ) ddd ON ttt.c_year = SUBSTRING(ddd.statTime, 1, 4) ORDER BY c_year| schema1 | utf8mb4 |
    Then check resultset "6" has lines with following column values
      | xValue-0  | statTime-1 | queryTimeHistogram-2 | dataValue-3 | queryStatTime-4 | orgNo-5 |
      | 2018年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2019年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2020年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2021年    | None       | None                 | 0           | :statTime       | 41101   |
      | 2022年    | None       | None                 | 0           | :statTime       | 41101   |


##case the filed support utf8  ATK-1400
    Given execute single sql in "dble-1" in "user" mode and save resultset in "7"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT CASE  WHEN deno1 = '0' THEN 1 ELSE (deno1 - mole1) / deno1 END * 50 + CASE  WHEN deno2 = '0' THEN 1 ELSE (deno2 - mole2) / deno2 END * 30 + CASE  WHEN deno3 = '0' THEN 1 ELSE (deno3 - mole3) / deno3 END * 20 AS 达标率 , CASE  WHEN deno1 = '0' THEN 1 ELSE (deno1 - mole1) / deno1 END * 100 AS 高压 , deno1 AS 高压总, mole1 AS 高压异常 , CASE  WHEN deno2 = '0' THEN 1 ELSE (deno2 - mole2) / deno2 END * 100 AS 低压 , deno2 AS 低压总, mole2 AS 低压异常 , CASE  WHEN deno3 = '0' THEN 1 ELSE (deno3 - mole3) / deno3 END * 100 AS 变更 , deno3 AS 变更总, mole3 AS 变更异常 FROM ( SELECT ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '01' AND idx_no = 'JYGK41101020000000022' THEN data_value END), 0) AS deno1 , ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '01' AND idx_no = 'JYGK41101020000000023' THEN data_value END), 0) AS mole1 , ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '02' AND idx_no = 'JYGK41101020000000022' THEN data_value END), 0) AS deno2 , ifnull(SUM(CASE  WHEN dim2 IN ('01', '02') AND dim3 = '02' AND idx_no = 'JYGK41101020000000023' THEN data_value END), 0) AS mole2 , ifnull(SUM(CASE  WHEN dim2 = '03' AND idx_no = 'JYGK41101020000000022' THEN data_value END), 0) AS deno3 , ifnull(SUM(CASE  WHEN dim2 = '03' AND idx_no = 'JYGK41101020000000023' THEN data_value END), 0) AS mole3 FROM cl_idx_data_monitor c WHERE theme_no = 'ind_02_ykzb' AND idx_no IN ('JYGK41101020000000022', 'JYGK41101020000000023') AND stat_calibre = '03' AND EXT_VALUE05 LIKE '202009%' AND major_no = '02' AND org_no = '4140621' ) a | schema1 | utf8mb4 |
    Then check resultset "7" has lines with following column values
      | 达标率-0 | 高压-1 | 高压总-2 | 高压异常-3 | 低压-4 | 低压总-5 | 低压异常-6 | 变更-7 | 变更总-8 | 变更异常-9 |
      | 100     | 100   | 0       | 0         | 100   | 0       | 0        | 100    | 0       | 0        |

#case  the filed and result support utf8 ATK-1403 /ATK-1406  /ATK-1409
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | SELECT tem1.ORG_NO, tem1.org_name , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 12) AS 小于1个月 , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 6) AS 大于2个月 FROM ( SELECT a.ORG_NO, a.ORG_NAME, round(sum(a.DATA_VALUE)) AS yunxingshu FROM cl_idx_data_monitor a WHERE a.stat_time LIKE '20200%' AND a.theme_no = 'IND_03_ZCZCGDSLMONTH' AND a.ORG_NO = '999999999999999' AND a.STAT_CALIBRE = '04' AND a.DIM1 = '21' AND a.DIM2 = '01' GROUP BY a.ORG_NO, a.ORG_NAME UNION SELECT a.ORG_NO, a.ORG_NAME, round(sum(a.DATA_VALUE)) AS yunxingshu FROM cl_idx_data_monitor a WHERE a.stat_time LIKE '20200%' AND a.theme_no = 'IND_03_ZCZCGDSLMONTH' AND a.ORG_NO LIKE '999999999999999' AND substr(a.ORG_NO, 6, 2) > 1 AND a.STAT_CALIBRE = '04' AND a.DIM1 = '21' AND a.DIM2 = '01' GROUP BY a.ORG_NO, a.ORG_NAME ) tem1, ( SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('05', '00') AND d.ORG_NO = '999999999999999' AND d.STAT_CALIBRE = '04' AND substr(d.STAT_TIME, 1, 4) = substr('20200922', 1, 4) GROUP BY d.ORG_NO UNION SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('05', '00') AND d.ORG_NO = '999999999999999' AND d.STAT_CALIBRE = '04' AND substr(d.STAT_TIME, 1, 4) = substr('20200922', 1, 4) GROUP BY d.ORG_NO UNION SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('05', '00') AND d.ORG_NO = '999999999999999' AND substr(d.ORG_NO, 6, 2) > '20' AND d.STAT_CALIBRE = '04' AND substr(d.STAT_TIME, 1, 4) = substr('20200922', 1, 4) GROUP BY d.ORG_NO ) tem2 WHERE tem1.ORG_NO = tem2.ORG_NO | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT ifnull(aa.`大于2个月`, 0) AS 大于2个月 , ifnull(aa.`小于1个月`, 0) AS 小于1个月, bb.`CODE` AS ORG_NO , bb.`NAME` AS org_name FROM ( SELECT tem1.ORG_NO, tem1.org_name , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 12) AS 小于1个月 , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 6) AS 大于2个月 FROM ( SELECT a.ORG_NO, a.ORG_NAME, round(sum(a.DATA_VALUE)) AS yunxingshu FROM cl_idx_data_monitor a WHERE a.stat_time = '202007' AND a.theme_no = 'IND_03_ZCZCGDSLMONTH' AND a.ORG_NO LIKE '999%' AND a.STAT_CALIBRE IN ('04', '21') AND a.DIM1 = '21' AND a.DIM2 = '01' GROUP BY a.ORG_NO, a.ORG_NAME ) tem1, ( SELECT d.ORG_NO, round(sum(d.DATA_VALUE)) AS lunhuanshu FROM CL_IDX_DATA_MONITOR d WHERE d.THEME_NO = 'IND_03_ZCZCGDSLMONTH' AND d.DIM1 = '21' AND d.DIM2 NOT IN ('11', '00') AND d.ORG_NO LIKE '999999999999999' AND d.STAT_CALIBRE IN ('04', '21') AND substr(d.STAT_TIME, 1, 4) = substr('20200722', 1, 4) GROUP BY d.ORG_NO ) tem2 WHERE tem1.ORG_NO = tem2.ORG_NO ) aa RIGHT JOIN ( SELECT s.CODE, s.NAME FROM sys_dict_entry s WHERE s.`CODE` LIKE '999%' AND TREE_LEVEL IN ('3', '4') ) bb ON bb.`CODE` = aa.ORG_NO ORDER BY bb.`CODE`  | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT d.NAME NAME, d.CODE CODE, IFNULL( c.减容容量, 0 ) 减容容量, IFNULL( c.同期减容容量, 0 ) 同期减容容量, IFNULL( c.同比减容容量, 0 ) 同比减容容量  FROM  (  SELECT   org_no,   IFNULL( SUM( ifnull( c.jrrl, 0 )), 0 ) 减容容量,   IFNULL( SUM( ifnull( c.tqjrrl, 0 )), 0 ) 同期减容容量,   IFNULL(((      SUM(       ifnull( c.jrrl, 0 )) - SUM(      ifnull( c.tqjrrl, 0 ))) / SUM(      ifnull( c.tqjrrl, 0 ))) * 100,    0    ) 同比减容容量   FROM   (   SELECT    org_no,    tj jrrl,    tq tqjrrl    FROM    (    SELECT     a.org_no,     a.idx_no,     (     SUM( a.data_value )) tj,     (     SUM( a.data_value_ly )) tq     FROM     cl_idx_data_monitor a     WHERE     a.EXT_VALUE05 LIKE '202009%'      AND a.theme_no = 'IND_02_FBSBZ'      AND org_no LIKE '41406%'      AND a.stat_calibre = '03'      AND a.idx_no = 'JYGK41101020000000015'     GROUP BY     a.org_no,     a.idx_no     ) b    ) c   GROUP BY   c.org_no   ) c  RIGHT JOIN ( SELECT * FROM sys_dict_entry WHERE CODE LIKE '41406%' AND LENGTH( CODE ) = '7' AND NAME NOT LIKE '%自备电厂%' ) d ON c.org_no = d.CODE  ORDER BY  ( d.CODE = '4140601' ) DESC,  d.CODE  | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT d.NAME NAME, d.CODE CODE, IFNULL( c.jianrong, 0 ) 减容容量, IFNULL( c.tongqijianrong, 0 ) 同期减容容量, IFNULL( c.tongbijianrong, 0 ) 同比减容容量  FROM  (  SELECT   org_no,   IFNULL( SUM( ifnull( c.jrrl, 0 )), 0 ) jianrong,   IFNULL( SUM( ifnull( c.tqjrrl, 0 )), 0 ) tongqijianrong,   IFNULL(((      SUM(       ifnull( c.jrrl, 0 )) - SUM(      ifnull( c.tqjrrl, 0 ))) / SUM(      ifnull( c.tqjrrl, 0 ))) * 100,    0    ) tongbijianrong   FROM   (   SELECT    org_no,    tj jrrl,    tq tqjrrl    FROM    (    SELECT     a.org_no,     a.idx_no,     (     SUM( a.data_value )) tj,     (     SUM( a.data_value_ly )) tq     FROM     cl_idx_data_monitor a     WHERE     a.EXT_VALUE05 LIKE '202009%'      AND a.theme_no = 'IND_02_FBSBZ'      AND org_no LIKE '41406%'      AND a.stat_calibre = '03'      AND a.idx_no = 'JYGK41101020000000015'     GROUP BY     a.org_no,     a.idx_no     ) b    ) c   GROUP BY   c.org_no   ) c  RIGHT JOIN ( SELECT * FROM sys_dict_entry WHERE CODE LIKE '41406%' AND LENGTH( CODE ) = '7' AND NAME NOT LIKE '%自备电厂%' ) d ON c.org_no = d.CODE  ORDER BY  ( d.CODE = '4140601' ) DESC,  d.CODE | success      | schema1 | utf8mb4 |

#case function support utf8  ATK-1408
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

#case no cerate schema but in sql is used this schema then do not occur DBLE0REQ-627
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose   | sql                                        | expect    | charset |
      | conn_0 | false     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join (select * from mimc_be.cl_idx_data_monitor UNION ALL select * from mimc_be.cl_idx_data_monitor ) as B   | Table `mimc_be`.`cl_idx_data_monitor` doesn't exist | utf8mb4 |
      | conn_0 | false     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join mimc_be.cl_idx_data_monitor   |  Table `mimc_be`.`cl_idx_data_monitor` doesn't exist | utf8mb4 |
      | conn_0 | false     | select * from (SELECT '' dim1 FROM DUAL ) as A inner join (select * from mimc_be.cl_idx_data_monitor UNION ALL select * from mimc_be.cl_idx_data_monitor ) as B   | Table `mimc_be`.`cl_idx_data_monitor` doesn't exist | utf8mb4 |
      | conn_0 | false     | select * from (SELECT '' dim1 FROM DUAL ) as A inner join mimc_be.cl_idx_data_monitor   |  Table `mimc_be`.`cl_idx_data_monitor` doesn't exist | utf8mb4 |

#case no use schema ,then query sql ,the in sql schema is not exists do not occur npe DBLE0REQ-685
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect    | charset |
      | conn_1 | true     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join (select * from mimc_be.cl_idx_data_monitor UNION ALL select * from mimc_be.cl_idx_data_monitor ) as B   | Table `mimc_be`.`cl_idx_data_monitor` doesn't exist  | utf8mb4 |
      | conn_1 | true     | select * from (SELECT '新装增容' dim1 FROM DUAL ) as A inner join mimc_be.cl_idx_data_monitor   | Table `mimc_be`.`cl_idx_data_monitor` doesn't exist  | utf8mb4 |
      | conn_1 | true     | select * from (SELECT '' dim1 FROM DUAL ) as A inner join (select * from mimc_be.cl_idx_data_monitor UNION ALL select * from mimc_be.cl_idx_data_monitor ) as B   | Table `mimc_be`.`cl_idx_data_monitor` doesn't exist  | utf8mb4 |
      | conn_1 | true     | select * from (SELECT '' dim1 FROM DUAL ) as A inner join mimc_be.cl_idx_data_monitor   | Table `mimc_be`.`cl_idx_data_monitor` doesn't exist  | utf8mb4 |
#case no use schema ,then query sql ,the in sql schema is exists do not occur npe DBLE0REQ-638
      | conn_1 | true     | SELECT d.NAME AS NAME, d.CODE AS CODE, IFNULL(c.减容容量, 0) AS 减容容量 , IFNULL(c.同期减容容量, 0) AS 同期减容容量 , IFNULL(c.同比减容容量, 0) AS 同比减容容量 FROM ( SELECT org_no , IFNULL(SUM(ifnull(c.jrrl, 0)), 0) AS 减容容量 , IFNULL(SUM(ifnull(c.tqjrrl, 0)), 0) AS 同期减容容量 , IFNULL((SUM(ifnull(c.jrrl, 0)) - SUM(ifnull(c.tqjrrl, 0))) / SUM(ifnull(c.tqjrrl, 0)) * 100, 0) AS 同比减容容量 FROM ( SELECT org_no, tj AS jrrl, tq AS tqjrrl FROM ( SELECT a.org_no, a.idx_no, SUM(a.data_value) AS tj , SUM(a.data_value_ly) AS tq FROM cl_idx_data_monitor a WHERE a.EXT_VALUE05 LIKE '202009%' AND a.theme_no = 'IND_02_FBSBZ' AND org_no LIKE '41406%' AND a.stat_calibre = '03' AND a.idx_no = 'JYGK41101020000000015' GROUP BY a.org_no, a.idx_no ) b ) c GROUP BY c.org_no ) c RIGHT JOIN ( SELECT * FROM sys_dict_entry WHERE CODE LIKE '41406%' AND LENGTH(CODE) = '7' AND NAME NOT LIKE '%自备电厂%' ) d ON c.org_no = d.CODE ORDER BY d.CODE = '4140601' DESC, d.CODE   | No database selected | utf8mb4 |

#case clear table meta
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | drop table if exists cl_idx_data_monitor   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists sys_dict_entry        | success      | schema1 | utf8mb4 |
      | conn_0 | true     | drop table if exists rl_station_relation   | success      | schema1 | utf8mb4 |

   Scenario: check Functions and Operators support utf8mb4: case from issue DBLE0REQ-660 #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                           | expect                         | db      | charset |
      | conn_0 | False   | drop table if exists sharding_2_t2                                                                                                            | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | drop table if exists sharding_3_t1                                                                                                            | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | create table sharding_2_t2 (id decimal(10,0) NOT NULL,id2 bigint(20) NOT NULL,name varchar(250) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8  | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | create table sharding_3_t1 (id decimal(10,0) NOT NULL,id2 bigint(20) NOT NULL,name varchar(250) NOT NULL) ENGINE=InnoDB DEFAULT CHARSET=utf8  | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_2_t2 values (1,1,'测试1')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_3_t1 values (1,1,'测试1')                                                                                                 | success                        | schema1 | utf8mb4 |
#######
      #  example: select "function" from tal_a inner join tab_b
      #  example: select * from tal_a inner join tab_b on where "function"
      #  example: select * from tal_a inner join tab_b on "function"
########
## case 0 function :"case when"
      | conn_0 | False   | select (case a.id when 1 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                            | has{(('好',))}                 | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_2_t2 values (2,2,'测试2')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_3_t1 values (2,2,'测试2')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 1 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                            | has{(('好',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_3_t1 values (2,3,'测试3')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 2 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id                             | has{(('坏',),('好',),('好',))}  | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 3 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id                             | has{(('坏',),('坏',),('坏',))}  | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 3 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                            | has{(('坏',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 3 then '好' else '坏' end) from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                              | has{(('坏',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select (case 1 when a.name>c.name then '好' else '坏' end) from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id                      | has{(('坏',),('坏',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name in (case 1 when a.name<c.name then '测试2' else '测试1' end)     | has{(('测试1',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name not in (case 1 when a.name<c.name then '测试2' else '测试1' end)     | has{(('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name > (case 1 when a.name<c.name then '测试2' else '测试1' end)      | has{(('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name < (case 1 when a.name<c.name then '测试2' else '测试1' end)      | length{(0)}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) = (case c.name when a.name>c.name then '测试2' else '测试1' end)    | has{(('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) = (case c.name when a.name>c.name then '测试2' else '测试1' end)    | has{(('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) > (case c.name when a.name>c.name then '测试2' else '测试1' end)    | has{(('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) <> (case c.name when a.name>c.name then '测试2' else '测试1' end)  | has{(('测试1',),('测试2',),('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) != (case c.name when a.name>c.name then '测试2' else '测试1' end)   | has{(('测试1',),('测试2',),('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a , sharding_3_t1 c where  (case a.name when a.name<c.name then '测试2' else '测试1' end) = (case c.name when a.name>c.name then '测试2' else '测试1' end)          | has{(('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select * from sharding_2_t2 a , sharding_3_t1 c where exists ( select (case a.name when a.name<c.name then '测试2' else '测试1' end) )      | Correlated Sub Queries is not supported          | schema1 | utf8mb4 |
      | conn_0 | true    | select * from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where  exists ( select (case a.name when a.name<c.name then '测试2' else '测试1' end) )      | Correlated Sub Queries is not supported          | schema1 | utf8mb4 |
## case 1 function : Type Conversion in Expression Evaluation
      #case "concat" / "cast"
      | conn_0 | False   | select concat(a.name,b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id     | has{(('测试1测试1',),('测试2测试2',),('测试2测试3',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select concat(a.name,'中国') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id      | has{(('测试1中国',),('测试2中国',),('测试2中国',))}        | schema1 | utf8mb4 |
      | conn_0 | False   | select cast(b.name as char) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id      | has{(('测试1',),('测试2',),('测试3',))}                  | schema1 | utf8mb4 |
      | conn_0 | False   | select cast(b.name as UNSIGNED) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where b.name=(select cast(b.name as char))    |  Correlated Sub Queries is not supported               | schema1 | utf8mb4 |
      | conn_0 | False   | select b.name from sharding_2_t2 a inner join sharding_3_t1 b on concat(a.name,b.name)=concat(a.name,b.name)    |  length{(6)}              | schema1 | utf8mb4 |
      #case "+"
      | conn_0 | False   | select a.id + b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{((1,),(2,),(2,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name + '中国' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((0,),(0,),(0,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.name in (a.name + '中国')         | has{(('测试1',),('测试2',),('测试2',))}     | schema1 | utf8mb4 |
      #case "> " / "<"
      | conn_0 | False   | select a.id > b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{((1,),(1,),(1,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name < b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{((0,),(0,),(1,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name < '中国' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((0,),(0,),(0,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.name > '测试'    | has{(('测试1',),('测试2',),('测试2',))}      | schema1 | utf8mb4 |
      | conn_0 | True    | select a.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.name < '测试'    | length{(0)}                                | schema1 | utf8mb4 |
## case 2 function : Operator
      #case "DIV"  / "%" / "MOD"  issue:DBLE0REQ-733
      #| conn_0 | False   | select a.id DIV b.name,a.name % b.name,a.name MOD b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           |     | schema1 | utf8mb4 |
      #case "*" / "/"    issue:DBLE0REQ-734
      | conn_0 | False   | select '爱可生' * a.id,a.id2 / '中国' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                          | has{((0.0, None), (0.0, None), (0.0, None))}     | schema1 | utf8mb4 |
      #| conn_0 | False   | select a.id * '爱可生',a.id2 / '中国' from sharding_2_t2 a inner join sharding_3_t1 b on (a.id * '爱可生')=(b.id * '爱可生')  |      | schema1 | utf8mb4 |
      #case "IS"   issue:DBLE0REQ-735
      #| conn_0 | False   | select a.name is null,b.name is not unknown from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id       |     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name is null,b.name is not null from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{((0, 1), (0, 1), (0, 1))}     | schema1 | utf8mb4 |
      #case "LIKE" / " not like"
      | conn_0 | False   | select a.name like "测试",b.name not like "测试1" from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                               | has{((0, 0), (0, 1), (0, 1))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name like "测试",b.name not like "测试1" from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.name  like "测试"      | length{(0)}                       | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name like "测试",b.name not like "测试1" from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.name not like "测试"   | has{((0, 0), (0, 1), (0, 1))}     | schema1 | utf8mb4 |
      #case "REGEXP" / " not REGEXP"  issue:DBLE0REQ-737
      #| conn_0 | False   | select a.name REGEXP "测试",b.name not REGEXP "测试1" from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                               | has{((0, 0), (0, 1), (0, 1))}     | schema1 | utf8mb4 |
      # case "BETWEEN AND" / " not BETWEEN AND"  issue:DBLE0REQ-738
      #| conn_0 | False   | select a.name between '测试' and '测试3' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((1,),(1,))}  | schema1 | utf8mb4 |
      #| conn_0 | False   | select b.name not between '测试' and '测试3' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id      | has{((0,),(0,))}  | schema1 | utf8mb4 |
      #case "AND" / "&&"  / "xor"  /"or"  /"||"
      | conn_0 | False   | select a.name and b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((0,),(0,),(0,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name && b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{((0,),(0,),(0,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name xor b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((0,),(0,),(0,))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name or b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{((0,),(0,),(0,))}     | schema1 | utf8mb4 |
      #case ":= "  issue:DBLE0REQ-740
      #| conn_0 | False   | select @var1 := a.name ,@爱可生 := b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          |    | schema1 | utf8mb4 |
      #case "GREATEST"
      | conn_0 | False   | select GREATEST(a.name,b.name,'测试3') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                             | has{(('测试3',),('测试3',),('测试3',))}      | schema1 | utf8mb4 |
      | conn_0 | False   | select GREATEST(a.id,b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.id < GREATEST(a.id,b.name)   | length{(0)}                                | schema1 | utf8mb4 |
      #case "COALESCE"
      | conn_0 | False   | select COALESCE(a.id2 / b.name,b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id    | has{(('测试1',),('测试2',),('测试3',))}      | schema1 | utf8mb4 |
      #case "<=>" / "< ="
      | conn_0 | False   | select a.id2<=>b.name,b.name <= a.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id     | has{((0, 1), (0, 1), (0, 0))}      | schema1 | utf8mb4 |
      | conn_0 | False   | select '测试'<=>b.name,'爱可生' <= a.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id    | has{((0, 0), (0, 0), (0, 0))}      | schema1 | utf8mb4 |
      #case "IN" / "not IN"
      | conn_0 | False   | select '测试' in a.name,b.name not in '测试' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id | has{((0, 1), (0, 1), (0, 1))}      | schema1 | utf8mb4 |
      #case "INTERVAL"
      | conn_0 | False   | select INTERVAL(a.name,b.name,a.id,b.id2,'爱可生')from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id        | has{((1,), (1,), (1,))}         | schema1 | utf8mb4 |
      #case "ISNULL"
      | conn_0 | False   | select ISNULL(b.name + '爱可生'),ISNULL(a.id2 / b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{((0, 1), (0, 1), (0, 1))}    | schema1 | utf8mb4 |
      #case "LEAST"
      | conn_0 | False   | select LEAST(b.name,'爱可生',a.name,'开心') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{(('开心',),('开心',),('开心',))}     | schema1 | utf8mb4 |
      #case "RLIKE" issue:DBLE0REQ-742
      #| conn_0 | False   | select b.name RLIKE '爱可生',a.name RLIKE '测试' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  |      | schema1 | utf8mb4 |
      #case "SOUNDS LIKE" issue:DBLE0REQ-743
      #| conn_0 | False   | select b.name SOUNDS LIKE a.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  |      | schema1 | utf8mb4 |
      #| conn_0 | False   | select b.name SOUNDS LIKE '测试' from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  |     | schema1 | utf8mb4 |
      #case "IF" / "IFNULL " / "NULLIF " issue:DBLE0REQ-744
      | conn_0 | False   | select IF(b.name > a.name,'爱可生','开心') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id        | has{(('开心',),('开心',),('爱可生',))}   | schema1 | utf8mb4 |
      | conn_0 | False   | select IF(STRCMP(a.name,b.name),'爱可生','开心') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{(('开心',),('开心',),('爱可生',))}   | schema1 | utf8mb4 |
      | conn_0 | False   | select IFNULL(a.id2 / b.name,'爱可生') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id        | has{(('爱可生',),('爱可生',),('爱可生',))}   | schema1 | utf8mb4 |
      | conn_0 | False   | select IFNULL(a.name ,b.name,'爱可生') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id        | has{(('测试1',),('测试2',),('测试2',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select NULLIF(b.name,'测试1') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                 | has{((None,),('测试2',),('测试3',))}       | schema1 | utf8mb4 |
      | conn_0 | False   | select IF(STRCMP(a.name > b.name),'爱可生','开心') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | Incorrect parameter count in the call to native function 'STRCMP'  | schema1 | utf8mb4 |
##case 4 function : String Functions
      #case "ASCII"  / "BIT_LENGTH"   / "CHAR"   / "HEX" /  "CONV"  / "CHAR_LENGTH"  / "CHARACTER_LENGTH"    issue:DBLE0REQ-747
      | conn_0 | False   | select ASCII(b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id       | has{((230,),(230,),(230,))}                  | schema1 | utf8mb4 |
      | conn_0 | False   | select BIT_LENGTH(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{((56,),(56,),(56,))}                     | schema1 | utf8mb4 |
      | conn_0 | False   | select CHAR(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id        | has{((b'\x00',), (b'\x00',), (b'\x00',))}    | schema1 | utf8mb4 |
      | conn_0 | False   | select HEX(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id               | has{((u'E6B58BE8AF9531',), (u'E6B58BE8AF9532',), (u'E6B58BE8AF9532',))}    | schema1 | utf8mb4 |
      | conn_0 | False   | select CONV(HEX(a.name),16,10) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((u'64938857152353585',), (u'64938857152353586',), (u'64938857152353586',))}                  | schema1 | utf8mb4 |
      #DBLE0REQ-908
      | conn_0 | False   | select CONV(HEX(a.name)) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | Incorrect parameter count in the call to native function 'CONV'                 | schema1 | utf8mb4 |
      | conn_0 | False   | select HEX(CHAR(a.name)) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((u'00',), (u'00',), (u'00',))}                  | schema1 | utf8mb4 |
      | conn_0 | False   | select HEX(a.name),CONV(HEX(a.name),16,10) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((u'E6B58BE8AF9531', u'64938857152353585'), (u'E6B58BE8AF9532', u'64938857152353586'), (u'E6B58BE8AF9532', u'64938857152353586'))}                 | schema1 | utf8mb4 |
      | conn_0 | False   | select CHAR_LENGTH(a.name),CHARACTER_LENGTH('爱可生社区') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((3, 5), (3, 5), (3, 5))}           | schema1 | utf8mb4 |
      | conn_0 | False   | select 'a.name' '爱可生社区'  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                               | has{(('a.name爱可生社区',), ('a.name爱可生社区',), ('a.name爱可生社区',))}           | schema1 | utf8mb4 |
      #case "BIN"   / "CHARSET"   issue:DBLE0REQ-746/DBLE0REQ-748
      | conn_0 | False   | select BIN(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((u'0',), (u'0',), (u'0',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select BIN('测试1') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{((u'0',), (u'0',), (u'0',))}     | schema1 | utf8mb4 |

      #| conn_0 | False   | select CHARSET(CHAR(a.name)),CHARSET(CHAR(b.name USING utf8)) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   |                   | schema1 | utf8mb4 |
      #case "CONCAT_WS"
      | conn_0 | False   | select CONCAT_WS(',','a.name','爱可生社区')  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{(('a.name,爱可生社区',), ('a.name,爱可生社区',), ('a.name,爱可生社区',))}           | schema1 | utf8mb4 |
      #case "ELT"
      | conn_0 | False   | select ELT(1,a.name,'爱可生社区')  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id     | has{(('测试1',), ('测试2',), ('测试2',))}             | schema1 | utf8mb4 |
      | conn_0 | False   | select ELT(2,a.name,'爱可生社区')  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id     | has{(('爱可生社区',), ('爱可生社区',), ('爱可生社区',))}           | schema1 | utf8mb4 |
      | conn_0 | False   | select ELT(3,a.name,'爱可生社区')  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((None,), (None,), (None,))}           | schema1 | utf8mb4 |
      #case "EXPORT_SET"   issue:DBLE0REQ-749
      #| conn_0 | False   | select EXPORT_SET(2,'a.name','爱',',',3)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((None,), (None,), (None,))}           | schema1 | utf8mb4 |
      #case  "FIELD"
      | conn_0 | False   | select FIELD('测试2',a.name,b.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id   | has{((0,), (1,), (1,))}           | schema1 | utf8mb4 |
      #case "FIND_IN_SET"
      | conn_0 | False   | select FIND_IN_SET('测试3',b.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id    | has{((0,), (0,), (1,))}           | schema1 | utf8mb4 |
      #case "FORMAT"  issue:DBLE0REQ-750
      #| conn_0 | False   | select FORMAT('测试3',b.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         |            | schema1 | utf8mb4 |
      #case  " TO_BASE64"  / "FROM_BASE64"    issue:DBLE0REQ-751
      #| conn_0 | False   | select TO_BASE64(b.name),FROM_BASE64(TO_BASE64(a.name))  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id    |            | schema1 | utf8mb4 |
      #case "INSERT"
      | conn_0 | False   | select INSERT(b.name,1,2,a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id    | has{(('测试11',), ('测试22',), ('测试23',))}           | schema1 | utf8mb4 |
      #case "INSTR"
      | conn_0 | False   | select INSTR('测试1',a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{((1,), (0,), (0,))}                              | schema1 | utf8mb4 |
      #case "LCASE"  /  "LOWER" / "UCASE"  /   "UNHEX"   /   "UPPER"
      | conn_0 | False   | select LCASE(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('测试1',), ('测试2',), ('测试2',))}               | schema1 | utf8mb4 |
      | conn_0 | False   | select LOWER(b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('测试1',), ('测试2',), ('测试3',))}               | schema1 | utf8mb4 |
      | conn_0 | False   | select UCASE(b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('测试1',), ('测试2',), ('测试3',))}               | schema1 | utf8mb4 |
      | conn_0 | False   | select UNHEX(b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{((None,), (None,), (None,))}                      | schema1 | utf8mb4 |
      | conn_0 | False   | select UPPER(b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('测试1',), ('测试2',), ('测试3',))}               | schema1 | utf8mb4 |
      #case "LEFT"
      | conn_0 | False   | select LEFT(a.name,1) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id               | has{(('测',), ('测',), ('测',))}                      | schema1 | utf8mb4 |
      #case "length"
      | conn_0 | False   | select length(a.name*b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id        | has{((1,), (1,), (1,))}                              | schema1 | utf8mb4 |
      #case "REPEAT"
      | conn_0 | False   | select REPEAT(a.name,1024)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id             | length{(3)}                               | schema1 | utf8mb4 |
      | conn_0 | False   | select @aa = repeat(a.name,1024) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id       | has{((None,), (None,), (None,))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select @bb = concat(@aa, @aa, a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{((None,), (None,), (None,))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select @cc = concat(@bb, a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id       | has{((None,), (None,), (None,))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select concat(repeat(a.name,1024)) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id     | length{(3)}                               | schema1 | utf8mb4 |
      #case "LOCATE"
      | conn_0 | False   | select LOCATE(a.name,b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id             | has{((1,), (1,), (0,))}              | schema1 | utf8mb4 |
      | conn_0 | False   | select LOCATE(a.name,b.name,2) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{((0,), (0,), (0,))}              | schema1 | utf8mb4 |
      #case "LPAD"
      | conn_0 | False   | select LPAD(a.name,5,'爱') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id       | has{(('爱爱测试1',), ('爱爱测试2',), ('爱爱测试2',))}                | schema1 | utf8mb4 |
      #case "MAKE_SET"
      | conn_0 | False   | select MAKE_SET( 1\|4,a.name,a.id2,b.id) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{(('测试1,1',), ('测试2,2',), ('测试2,2',))}     | schema1 | utf8mb4 |
      #case "MID"     issue:DBLE0REQ-753
      #| conn_0 | False   | select MID(a.name,1,2)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         |     | schema1 | utf8mb4 |
      #case "OCT"  issue:DBLE0REQ-754
      #| conn_0 | False   | select OCT(a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         |      | schema1 | utf8mb4 |
      #case "OCTET_LENGTH"  issue:DBLE0REQ-755
      #| conn_0 | False   | select OCTET_LENGTH(a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         |     | schema1 | utf8mb4 |
      #case "ORD"
      | conn_0 | False   | select ORD(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{((15119755,), (15119755,), (15119755,))}     | schema1 | utf8mb4 |
      #case "POSITION"
      | conn_0 | False   | select POSITION('测试' in a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{((1,), (1,), (1,))}     | schema1 | utf8mb4 |
      #case "QUOTE"
      | conn_0 | False   | select QUOTE(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{((u"'\u6d4b\u8bd51'",), (u"'\u6d4b\u8bd52'",), (u"'\u6d4b\u8bd52'",))}      | schema1 | utf8mb4 |
      #case "REPLACE"
      | conn_0 | False   | select REPLACE(a.name,'测试1','爱可生') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id | has{(('爱可生',), ('测试2',), ('测试2',))}     | schema1 | utf8mb4 |
      #case "REVERSE"
      | conn_0 | False   | select REVERSE(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('1试测',), ('2试测',), ('2试测',))}      | schema1 | utf8mb4 |
      #case "RIGHT"
      | conn_0 | False   | select RIGHT(a.name,1) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('1',), ('2',), ('2',))}      | schema1 | utf8mb4 |
      #case "RPAD"
      | conn_0 | False   | select RPAD(a.name,5,'中国') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | has{(('测试1中国',),('测试2中国',),('测试2中国',))}      | schema1 | utf8mb4 |
      #case "SOUNDEX"
      | conn_0 | False   | select SOUNDEX(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                | has{(('测000',), ('测000',), ('测000',))}      | schema1 | utf8mb4 |
      #case "SPACE"
      | conn_0 | False   | select SPACE(a.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                  | success      | schema1 | utf8mb4 |
      #case "STRCMP"
      | conn_0 | False   | select STRCMP(a.name,b.name) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id          | has{((0,), (0,), (-1,))}      | schema1 | utf8mb4 |
      #case "SUBSTR" / "SUBSTRING"   /  "SUBSTRING_INDEX"      DBLE0REQ-757
      | conn_0 | False   | select SUBSTR(a.name,1),SUBSTR(b.name,1,2) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                       | has{(('测试1','测试',), ('测试2','测试',), ('测试2','测试',))}              | schema1 | utf8mb4 |
      | conn_0 | False   | select SUBSTRING(a.name,1),SUBSTRING(b.name,1,2) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                 | has{(('测试1','测试',), ('测试2','测试',), ('测试2','测试',))}              | schema1 | utf8mb4 |
      | conn_0 | False   | select SUBSTRING(a.name from 2),SUBSTRING(a.name -1 from 1) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id      | has{(('试1','-1',), ('试2','-1',), ('试2','-1',))}                        | schema1 | utf8mb4 |
      | conn_0 | False   | select SUBSTRING(a.name from 2),SUBSTRING(a.name from -1 for 1) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{(('试1','1',), ('试2','2',), ('试2','2',))}                           | schema1 | utf8mb4 |
      | conn_0 | False   | select SUBSTRING(a.name from 1 for 2) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                            | has{(('测试',), ('测试',), ('测试',))}                                     | schema1 | utf8mb4 |
      | conn_0 | False   | select SUBSTRING_INDEX(a.name ,'测', 1) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | has{(('',), ('',), ('',))}        | schema1 | utf8mb4 |
        #case "LTRIM" / "RTRIM"  /  "TRIM"
      | conn_0 | False   | select LTRIM(    a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{(('测试1',), ('测试2',), ('测试2',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select RTRIM(a.name    )  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{(('测试1',), ('测试2',), ('测试2',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select TRIM(   a.name  )  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id         | has{(('测试1',), ('测试2',), ('测试2',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select TRIM(LEADING '测试2' FROM a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.id=2   | has{((u'',), (u'',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select TRIM(BOTH '测试2' FROM a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.id=2      | has{((u'',), (u'',))}     | schema1 | utf8mb4 |
      | conn_0 | False   | select TRIM(TRAILING '测试2' FROM a.name)  from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.id=2  | has{((u'',), (u'',))}     | schema1 | utf8mb4 |
      #case "@"   DBLE0REQ-765
      | conn_0 | False   | select @s = cast('爱可生' as BINARY )               | success      | schema1 | utf8mb4 |
      #| conn_0 | False   | select @s, HEX(@s), HEX(WEIGHT_STRING(@s)) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id                 |   | schema1 | utf8mb4 |
      | conn_0 | False   | select @s, HEX(@s), HEX(WEIGHT_STRING(@s)) from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id where a.id=2         | success      | schema1 | utf8mb4 |
      #case "EXISTS"   /  "not exists"
      | conn_0 | False   | select a.name from sharding_2_t2 a where exists (select b.name from sharding_3_t1 b)                  | has{(('测试1',), ('测试2',))}       | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a where not exists (select b.name from sharding_3_t1 b)              | length{(0)}                        | schema1 | utf8mb4 |
      #case "MINUS"  github:2026
      | conn_0 | False   | select id from sharding_2_t2 where id=1 minus select id from sharding_2_t2 where id=2           | You have an error in your SQL syntax;MINUS                       | schema1 | utf8mb4 |



##case 5 function : Mathematical Functions ,no need
##case 6 function : Date and Time Functions ,no need

####case unsupported funtion  "not"
      | conn_0 | False   | select a.name not b.name from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id           | sql syntax error, no terminated. DOT     | schema1 | utf8mb4 |
#case drop table
      | conn_0 | False   | drop table if exists sharding_2_t2      | success                        | schema1 | utf8mb4 |
      | conn_0 | True    | drop table if exists sharding_3_t1      | success                        | schema1 | utf8mb4 |
