# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/9/20
Feature: verify issue 92 #Enter feature name here

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
       <shardingTable name="shard12" function="fixed_uniform_string" shardingNode="dn1,dn2,dn3,dn4" shardingColumn="ben_tim12"/>
       <singleTable name="shard13" shardingNode="dn1" />
    </schema>

     <function name="fixed_uniform_string" class="StringHash">
        <property name="partitionCount">4</property>
        <property name="partitionLength">256</property>
        <property name="hashSlice">0:8</property>
     </function>
    """
    #coz DBLE0REQ-688
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                 | expect       | db      | charset |
      | conn_0 | False    | drop table if exists shard12        | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists shard13        | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists shard14        | success      | schema1 | utf8mb4 |
      | conn_0 | False    | CREATE TABLE shard12 ( `clid` int(11) NOT NULL AUTO_INCREMENT COMMENT '指汇结标', `OG_NO` varchar(16) DEFAULT NULL COMMENT '单编', `OG_NE` varchar(64) DEFAULT NULL COMMENT '单名', `SAT_CRE` varchar(8) DEFAULT NULL COMMENT '01全口）、02市、03县、04供所',`BI_CE` varchar(8) DEFAULT NULL COMMENT '业码', `MO_N` varchar(8) DEFAULT NULL COMMENT '专类', `TE_N` varchar(64) DEFAULT NULL COMMENT '主码', `TEME_E` varchar(128) DEFAULT NULL COMMENT '题称', `IX123_NO` varchar(64) DEFAULT NULL COMMENT '指编码',`IDAME` varchar(128) DEFAULT NULL COMMENT '（标）名称', `ben_tim12` varchar(64) DEFAULT NULL COMMENT '统期：日 月 年 ',   `T_O123` varchar(64) DEFAULT NULL COMMENT '台12编23号',   `DI23M123` varchar(16) DEFAULT NULL COMMENT '维段',   `DI78M234` varchar(256) DEFAULT NULL COMMENT '维度字段',`8M23` varchar(16) DEFAULT NULL COMMENT '维99段',   `8M2` varchar(16) DEFAULT NULL COMMENT '维',  `DA12_VALE` decimal(20,6) DEFAULT NULL COMMENT '指123值',   `DA12_V_S` decimal(20,6) DEFAULT NULL COMMENT '累值',   `DA12_V123_S43` decimal(20,6) DEFAULT NULL COMMENT '同值',`DA12_V_S_LY` decimal(20,6) DEFAULT NULL COMMENT '同',   `C1E_TI` datetime DEFAULT NULL COMMENT '创间',  `EXTUE05` varchar(128) DEFAULT NULL COMMENT '行扩充',   `RK123` varchar(128) DEFAULT NULL COMMENT '备注',   PRIMARY KEY (`clid`) USING BTREE,   KEY `shard12_OG_NO1` (`OG_NO`),   KEY `shard12_ben_tim121` (`ben_tim12`),KEY `shard12_IX123_NO1` (`IX123_NO`),   KEY `shard12_statcalibre1` (`SAT_CRE`) USING BTREE ) ENGINE=InnoDB AUTO_INCREMENT=13073021 DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT COMMENT='指标表\r\n1)、存放果' | success  | schema1 |utf8mb4 |
      | conn_0 | False    | CREATE TABLE shard13 (`id` int(11) NOT NULL AUTO_INCREMENT, `C66E` varchar(64) DEFAULT NULL COMMENT '字码',   `DT_TYPEID` varchar(64) DEFAULT NULL COMMENT '字型ID',  `NAME` varchar(128) DEFAULT NULL COMMENT '字典项名称',`DESTION` varchar(256) DEFAULT NULL COMMENT '描述',   `C1E_TI` datetime DEFAULT NULL COMMENT '创建时间',   `UPDATE_TIME` datetime DEFAULT NULL COMMENT '更新时间',   `TENANT_ID` varchar(64) DEFAULT NULL COMMENT '租户ID',`PARENT_ID` varchar(64) DEFAULT NULL COMMENT '父字典项ID', `LOCALE` varchar(64) DEFAULT NULL COMMENT '默认语言',  `STATUS` varchar(64) DEFAULT NULL COMMENT '状态',`SORT_NO` int(11) DEFAULT NULL COMMENT '排序字段',   `IS_LEAF` tinyint(1) DEFAULT NULL COMMENT '是否叶节点',`TREE_LEVEL` int(11) DEFAULT NULL COMMENT '层级',   `SEQ` varchar(256) DEFAULT NULL COMMENT '序列码',   `IS_FIXED` tinyint(1) DEFAULT NULL COMMENT '是固定',   PRIMARY KEY (`id`) USING BTREE,   KEY `C66E` (`C66E`),   KEY `DT_TYPEID` (`DT_TYPEID`) ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='数据字典表' | success  | schema1 |utf8mb4 |
      | conn_0 | False    | CREATE TABLE shard14 (`ID` decimal(18,0) NOT NULL COMMENT '标识', `MIN_O12_NO` varchar(32) NOT NULL COMMENT '需分',  `OG_NO` varchar(32) NOT NULL COMMENT '所真爱心',   `VALID_STATE` varchar(8) NOT NULL COMMENT '有状态 ',   `RK1231` varchar(256) DEFAULT NULL COMMENT '备注1',   `RK1232` varchar(256) DEFAULT NULL COMMENT '备注2',`OPATE_TIME` datetime DEFAULT NULL COMMENT '操时间',   PRIMARY KEY (`ID`) USING BTREE ) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='供系表' | success  | schema1 | utf8mb4 |


#case support execute query is more quickly ATK-1379
    Given execute single sql in "dble-1" in "user" mode and save resultset in "1"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT round(IF(( SELECT IFNULL(sum(t.DA12_VALE), 0) FROM shard12 t, shard14 f WHERE t.TE_N = 'IND_03_ZNZZGSY' AND t.IX123_NO = '56643' AND t.BI_CE = '03' AND t.MO_N = '03' AND t.ben_tim12 = '20201013' AND t.SAT_CRE = '01' AND f.MIN_O12_NO = '41101' AND f.OG_NO = t.OG_NO AND f.VALID_STATE = '1' ) = 0, 1, IFNULL(( SELECT CASE  WHEN SUM(t.DA12_VALE) IS NULL THEN 0 ELSE SUM(t.DA12_VALE) END FROM shard12 t, shard14 f WHERE t.TE_N = 'IND_03_ZNZZGSY' AND t.IX123_NO = '56065' AND t.BI_CE = '03' AND t.MO_N = '03' AND t.ben_tim12 = '20201013' AND t.SAT_CRE = '01' AND f.MIN_O12_NO = '41101' AND f.OG_NO = t.OG_NO AND f.VALID_STATE = '1' ) / ( SELECT CASE  WHEN SUM(t.DA12_VALE) IS NULL THEN 0 ELSE SUM(t.DA12_VALE) END FROM shard12 t, shard14 f WHERE t.TE_N = 'IND_03_ZNZZGSY' AND t.IX123_NO = '56643' AND t.BI_CE = '03' AND t.MO_N = '03' AND t.ben_tim12 = '20201013' AND t.SAT_CRE = '01' AND f.MIN_O12_NO = '41101' AND f.OG_NO = t.OG_NO AND f.VALID_STATE = '1' ), 0)), 4) * 100 AS dataValue , '03' AS busiC66E, '01' AS statCalibre, '41101' AS orgC66E, '03' AS majorNo, '20201013' AS statTime , 'IND_03_ZNZZGSY' AS themeNo , '56643,56065' AS idxNo | schema1 | utf8mb4 |
    Then check resultset "1" has lines with following column values
      | dataValue-0 | busiC66E-1 | statCalibre-2 | orgC66E-3 | majorNo-4 | statTime-5 | themeNo-6      | idxNo-7                                     |
      | 100.0       | 03         | 01            | 41101     | 03        | 20201013   | IND_03_ZNZZGSY | 56643,56065 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "2"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | select '03' busiC66E, '01' statCalibre, '41101' orgC66E, '03' majorNo, '20201013' statTime, 'IND_03_ZNZZGSY' themeNo, (case when tt.sum447 IS NULL then '1' when tt.sum447 = 0 then '0' when tt.sum448 IS NULL then '0' when tt.sum448 = 0 then '0' else round(tt.sum448/tt.sum447,4)* 100 end) as datavalue from ( select sum(CASE WHEN t.IX123_NO='56643' and t.DA12_VALE is NULL THEN 0 ELSE t.DA12_VALE end) as sum447, sum(CASE WHEN t.IX123_NO='56065' and t.DA12_VALE is NULL THEN 0 ELSE t.DA12_VALE end) as sum448 from shard12 t,shard14 f where t.TE_N= 'IND_03_ZNZZGSY' AND t.BI_CE= '03' AND t.MO_N = '03' AND t.ben_tim12 = '20201013' AND t.SAT_CRE = '01' AND f.MIN_O12_NO = '41101' AND f.OG_NO = t.OG_NO AND f.VALID_STATE = '1' and t.IX123_NO in ('56643','56065')) tt| schema1 | utf8mb4 |
    Then check resultset "2" has lines with following column values
      | busiC66E-0 | statCalibre-1 | orgC66E-2 | majorNo-3 | statTime-4 | themeNo-5      | datavalue-6 |
      | 03         | 01            | 41101     | 03        | 20201013   | IND_03_ZNZZGSY | 1           |

#case support "STR_TO_DATE" function ATK-1382
    Given execute single sql in "dble-1" in "user" mode and save resultset in "3"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT IFNULL(SUM(t1.DA12_VALE), 0) AS dataValue, '41101' AS orgC66E , 'IND_07_ZGS_GDS' AS themeNo, '01' AS statCalibre, '04' AS busiC66E, '07' AS majorNo , DATE_FORMAT(DATE_SUB(STR_TO_DATE('20201014', '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') AS endTime , f.leftIdxNo AS idxNo FROM ( SELECT t.DA12_VALE, t.IX123_NO FROM shard12 t, shard14 s WHERE s.MIN_O12_NO = '41101' AND s.OG_NO = t.OG_NO AND s.VALID_STATE = '1' AND t.TE_N = 'IND_07_ZGS_GDS' AND t.IX123_NO = 'lll411010734091' AND t.BI_CE = '04' AND t.MO_N = '07' AND t.EXTUE05 = DATE_FORMAT(DATE_SUB(STR_TO_DATE('20201014', '%Y%m%d'), INTERVAL 1 DAY), '%Y%m%d') AND t.SAT_CRE = '01' ) t1 RIGHT JOIN ( SELECT 'lll411010734091' AS leftIdxNo ) f ON f.leftIdxNo = t1.IX123_NO GROUP BY f.leftIdxNo | schema1 | utf8mb4 |
    Then check resultset "3" has lines with following column values
      | dataValue-0 | orgC66E-1 | themeNo-2      | statCalibre-3 | busiC66E-4 | majorNo-5 | endTime-6 | idxNo-7               |
      | 0           | 41101     | IND_07_ZGS_GDS | 01            | 04         | 07        | 20201013  | lll411010734091 |

#case the result support utf8 ATK-1383
    Given execute single sql in "dble-1" in "user" mode and save resultset in "4"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT t.ben_tim12 AS statTime , CASE  WHEN length(round(t.DA12_VALE)) > 8 THEN round(IFNULL(t.DA12_VALE, 0) / 1340, 2) WHEN length(round(t.DA12_VALE)) > 4 AND length(round(t.DA12_VALE)) < 9 THEN round(IFNULL(t.DA12_VALE, 0) / 10000, 2) ELSE IFNULL(t.DA12_VALE, 0) END AS dataValue , CASE  WHEN length(round(t.DA12_VALE)) > 8 THEN '亿元' WHEN length(round(t.DA12_VALE)) > 4 AND length(round(t.DA12_VALE)) < 9 THEN '万元' ELSE '元' END AS unit FROM ( SELECT tem.ben_tim12 , ifnull(round(tem.dianfei + tem.weiyujin, 2), 0) AS DA12_VALE FROM ( SELECT d.ben_tim12, 'IND_03_WQJJXYJK' AS TE_N , sum(CASE  WHEN d.IX123_NO = 'lll411010334346' THEN D.DA12_V_S ELSE 0 END) AS dianfei , sum(CASE  WHEN d.IX123_NO = 'lll411010334347' THEN D.DA12_V_S ELSE 0 END) AS weiyujin FROM shard12 D WHERE D.TE_N = 'IND_03_WQJJXYJK' AND d.IX123_NO IN ('lll411010334346', 'lll411010334347') AND D.ben_tim12 = DATE_FORMAT(SYSDATE(), '%Y%m%d') AND ((length('41101') = 5 AND OG_NO = '41101' AND SAT_CRE = '01') OR (length('41101') = 7 AND RIGHT('41101', 2) = '99' AND OG_NO = LEFT('41101', 5) AND SAT_CRE = '02') OR (length('41101') = 7 AND RIGHT('41101', 2) != '99' AND OG_NO = '41101')) AND D.DI23M123 = '01' AND BI_CE = '03' AND MO_N = '03' GROUP BY d.ben_tim12 ) tem RIGHT JOIN ( SELECT 'IND_03_WQJJXYJK' AS TE_N ) ss ON ss.TE_N = tem.TE_N ) t | schema1 | utf8mb4 |
    Then check resultset "4" has lines with following column values
      | statTime-0 | dataValue-1 | unit-2  |
      | None       | 0           | 元      |

#case support "between and "function ATK-1388
    Given execute single sql in "dble-1" in "user" mode and save resultset in "5"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT DATE_FORMAT(DATE_ADD(ttt.EACHDAY, INTERVAL -1 DAY), '%Y%m%d') AS statTime , CONCAT(IF(SUBSTRING(DATE_FORMAT(DATE_ADD(eachDay, INTERVAL -1 DAY), '%Y%m%d'), 7, 2) > 9, SUBSTRING(DATE_FORMAT(DATE_ADD(eachDay, INTERVAL -1 DAY), '%Y%m%d'), 7, 2), SUBSTRING(DATE_FORMAT(DATE_ADD(eachDay, INTERVAL -1 DAY), '%Y%m%d'), 8, 1)), '日') AS xValue , IFNULL(ddd.DA12_VALE, 0) AS dataValue , IFNULL(ddd.DA12_V123_S43, 0) AS dataValueLy, '41101' AS orgNo , ddd.SAT_CRE AS statCalibre FROM ( SELECT REPLACE(A.DATE, '-', '') AS eachDay FROM ( SELECT date_sub(CURDATE(), INTERVAL A.A + 10 * B.A + 100 * C.A - 1 DAY) AS DATE FROM ( SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) A CROSS JOIN ( SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) B CROSS JOIN ( SELECT 0 AS A UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 ) C ) A WHERE A.DATE BETWEEN DATE_SUB(DATE_FORMAT('20201015', '%y%m%d'), INTERVAL 12 DAY) AND DATE_FORMAT('20201015', '%y%m%d') ORDER BY eachDay ) ttt LEFT JOIN ( SELECT cidm.ben_tim12, SUM(DA12_VALE) AS DA12_VALE, SUM(DA12_V123_S43) AS DA12_V123_S43 , '41101' AS orgNo, cidm.SAT_CRE FROM shard12 cidm WHERE OG_NO = '41101' AND SAT_CRE = '01' AND ben_tim12 BETWEEN REPLACE(DATE_SUB('20201015', INTERVAL 12 DAY), '-', '') AND '20201015' AND TE_N = 'IND_08_TQXSYLVJZQJSLV' AND IX123_NO = 'lll411010334433' GROUP BY IX123_NO, ben_tim12 ORDER BY ben_tim12 ) ddd ON ttt.EACHDAY = ddd.ben_tim12 ORDER BY ttt.EACHDAY | schema1 | utf8mb4 |
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
      | conn_0 | False    | SELECT cidm.ben_tim12, SUM(DA12_VALE) AS DA12_VALE, SUM(DA12_V123_S43) AS DA12_V123_S43 , '41101' AS orgNo, cidm.SAT_CRE FROM shard12 cidm WHERE OG_NO = '41101' AND SAT_CRE = '01' AND ben_tim12 BETWEEN REPLACE(DATE_SUB('20201015', INTERVAL 12 DAY), '-', '') AND '20201015' AND TE_N = 'IND_08_TQXSYLVJZQJSLV' AND IX123_NO = 'lll411010334433' GROUP BY IX123_NO, ben_tim12 ORDER BY ben_tim12| success      | schema1 | utf8mb4 |

#case the result support utf8 ATK-1398
    Given execute single sql in "dble-1" in "user" mode and save resultset in "6"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT CONCAT(c_year, '年') AS xValue, statTime , SUBSTRING(statTime, 1, 4) AS queryTimeHistogram , IFNULL(dataValue, 0) AS dataValue, ':statTime' AS queryStatTime , '41101' AS orgNo FROM ( SELECT YEAR(NOW()) AS c_year FROM DUAL UNION ALL (SELECT YEAR(NOW()) - 1 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 2 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 3 AS c_year FROM DUAL) UNION ALL (SELECT YEAR(NOW()) - 4 AS c_year FROM DUAL) ) ttt LEFT JOIN ( SELECT tem.ben_tim12 AS statTime , round((tem.gong - tem.shou) / tem.gong * 100, 2) AS dataValue FROM ( SELECT a.ben_tim12 , sum(CASE  WHEN a.IX123_NO = 'lll411010334338' THEN a.DA12_VALE ELSE 0 END) AS gong , sum(CASE  WHEN a.IX123_NO = 'lll411010334339' THEN a.DA12_VALE ELSE 0 END) AS shou FROM shard12 a WHERE LENGTH(ben_tim12) = 8 AND a.TE_N = 'IND_08_TGLOSSYEAR' AND a.SAT_CRE = CASE  WHEN LENGTH('41101') = 5 THEN '01' WHEN LENGTH('41101') = 7 THEN '03' WHEN LENGTH('41101') = 8 THEN '04' END AND BI_CE = '03' AND MO_N = '08' AND a.OG_NO = '41101' AND a.IX123_NO IN ('lll411010334338', 'lll411010334339') GROUP BY a.ben_tim12 ) tem ) ddd ON ttt.c_year = SUBSTRING(ddd.statTime, 1, 4) ORDER BY c_year| schema1 | utf8mb4 |
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
      | conn_0 | False   | SELECT CASE  WHEN deno1 = '0' THEN 1 ELSE (deno1 - mole1) / deno1 END * 50 + CASE  WHEN deno2 = '0' THEN 1 ELSE (deno2 - mole2) / deno2 END * 30 + CASE  WHEN deno3 = '0' THEN 1 ELSE (deno3 - mole3) / deno3 END * 20 AS 达标率 , CASE  WHEN deno1 = '0' THEN 1 ELSE (deno1 - mole1) / deno1 END * 100 AS 测39 , deno1 AS 测39总, mole1 AS 测39异常 , CASE  WHEN deno2 = '0' THEN 1 ELSE (deno2 - mole2) / deno2 END * 100 AS 低港 , deno2 AS 低港总, mole2 AS 低港异常 , CASE  WHEN deno3 = '0' THEN 1 ELSE (deno3 - mole3) / deno3 END * 100 AS 变更 , deno3 AS 变更总, mole3 AS 艾出纳港 FROM ( SELECT ifnull(SUM(CASE  WHEN DI78M234 IN ('01', '02') AND 8M23 = '01' AND IX123_NO = 'lll411010234022' THEN DA12_VALE END), 0) AS deno1 , ifnull(SUM(CASE  WHEN DI78M234 IN ('01', '02') AND 8M23 = '01' AND IX123_NO = 'lll411010234023' THEN DA12_VALE END), 0) AS mole1 , ifnull(SUM(CASE  WHEN DI78M234 IN ('01', '02') AND 8M23 = '02' AND IX123_NO = 'lll411010234022' THEN DA12_VALE END), 0) AS deno2 , ifnull(SUM(CASE  WHEN DI78M234 IN ('01', '02') AND 8M23 = '02' AND IX123_NO = 'lll411010234023' THEN DA12_VALE END), 0) AS mole2 , ifnull(SUM(CASE  WHEN DI78M234 = '03' AND IX123_NO = 'lll411010234022' THEN DA12_VALE END), 0) AS deno3 , ifnull(SUM(CASE  WHEN DI78M234 = '03' AND IX123_NO = 'lll411010234023' THEN DA12_VALE END), 0) AS mole3 FROM shard12 c WHERE TE_N = 'ind_02_ykzb' AND IX123_NO IN ('lll411010234022', 'lll411010234023') AND SAT_CRE = '03' AND EXTUE05 LIKE '202009%' AND MO_N = '02' AND OG_NO = '4140621' ) a | schema1 | utf8mb4 |
    Then check resultset "7" has lines with following column values
      | 达标率-0 | 测39-1 | 测39总-2 | 测39异常-3 | 低港-4 | 低港总-5 | 低港异常-6 | 变更-7 | 变更总-8 | 艾出纳港-9 |
      | 100     | 100   | 0       | 0         | 100   | 0       | 0        | 100    | 0       | 0        |

#case  the filed and result support utf8 ATK-1403 /ATK-1406  /ATK-1409
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | SELECT tem1.OG_NO, tem1.OG_NE , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 12) AS 小于1个月 , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 6) AS 大于2个月 FROM ( SELECT a.OG_NO, a.OG_NE, round(sum(a.DA12_VALE)) AS yunxingshu FROM shard12 a WHERE a.ben_tim12 LIKE '20200%' AND a.TE_N = 'INDNTH' AND a.OG_NO = '999999999999999' AND a.SAT_CRE = '04' AND a.DI23M123 = '21' AND a.DI78M234 = '01' GROUP BY a.OG_NO, a.OG_NE UNION SELECT a.OG_NO, a.OG_NE, round(sum(a.DA12_VALE)) AS yunxingshu FROM shard12 a WHERE a.ben_tim12 LIKE '20200%' AND a.TE_N = 'INDNTH' AND a.OG_NO LIKE '999999999999999' AND substr(a.OG_NO, 6, 2) > 1 AND a.SAT_CRE = '04' AND a.DI23M123 = '21' AND a.DI78M234 = '01' GROUP BY a.OG_NO, a.OG_NE ) tem1, ( SELECT d.OG_NO, round(sum(d.DA12_VALE)) AS lunhuanshu FROM shard12 d WHERE d.TE_N = 'INDNTH' AND d.DI23M123 = '21' AND d.DI78M234 NOT IN ('05', '00') AND d.OG_NO = '999999999999999' AND d.SAT_CRE = '04' AND substr(d.ben_tim12, 1, 4) = substr('20200922', 1, 4) GROUP BY d.OG_NO UNION SELECT d.OG_NO, round(sum(d.DA12_VALE)) AS lunhuanshu FROM shard12 d WHERE d.TE_N = 'INDNTH' AND d.DI23M123 = '21' AND d.DI78M234 NOT IN ('05', '00') AND d.OG_NO = '999999999999999' AND d.SAT_CRE = '04' AND substr(d.ben_tim12, 1, 4) = substr('20200922', 1, 4) GROUP BY d.OG_NO UNION SELECT d.OG_NO, round(sum(d.DA12_VALE)) AS lunhuanshu FROM shard12 d WHERE d.TE_N = 'INDNTH' AND d.DI23M123 = '21' AND d.DI78M234 NOT IN ('05', '00') AND d.OG_NO = '999999999999999' AND substr(d.OG_NO, 6, 2) > '20' AND d.SAT_CRE = '04' AND substr(d.ben_tim12, 1, 4) = substr('20200922', 1, 4) GROUP BY d.OG_NO ) tem2 WHERE tem1.OG_NO = tem2.OG_NO | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT ifnull(aa.`大于2个月`, 0) AS 大于2个月 , ifnull(aa.`小于1个月`, 0) AS 小于1个月, bb.`C66E` AS OG_NO , bb.`NAME` AS OG_NE FROM ( SELECT tem1.OG_NO, tem1.OG_NE , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 12) AS 小于1个月 , round((tem1.yunxingshu * 0.04 + tem2.lunhuanshu / 8) / 6) AS 大于2个月 FROM ( SELECT a.OG_NO, a.OG_NE, round(sum(a.DA12_VALE)) AS yunxingshu FROM shard12 a WHERE a.ben_tim12 = '202007' AND a.TE_N = 'INDNTH' AND a.OG_NO LIKE '999%' AND a.SAT_CRE IN ('04', '21') AND a.DI23M123 = '21' AND a.DI78M234 = '01' GROUP BY a.OG_NO, a.OG_NE ) tem1, ( SELECT d.OG_NO, round(sum(d.DA12_VALE)) AS lunhuanshu FROM shard12 d WHERE d.TE_N = 'INDNTH' AND d.DI23M123 = '21' AND d.DI78M234 NOT IN ('11', '00') AND d.OG_NO LIKE '999999999999999' AND d.SAT_CRE IN ('04', '21') AND substr(d.ben_tim12, 1, 4) = substr('20200722', 1, 4) GROUP BY d.OG_NO ) tem2 WHERE tem1.OG_NO = tem2.OG_NO ) aa RIGHT JOIN ( SELECT s.C66E, s.NAME FROM shard13 s WHERE s.`C66E` LIKE '999%' AND TREE_LEVEL IN ('3', '4') ) bb ON bb.`C66E` = aa.OG_NO ORDER BY bb.`C66E`  | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT d.NAME NAME, d.C66E C66E, IFNULL( c.测试1, 0 ) 测试1, IFNULL( c.同期测试1, 0 ) 同期测试1, IFNULL( c.同比测试1, 0 ) 同比测试1  FROM  (  SELECT   OG_NO,   IFNULL( SUM( ifnull( c.jrrl, 0 )), 0 ) 测试1,   IFNULL( SUM( ifnull( c.tqjrrl, 0 )), 0 ) 同期测试1,   IFNULL(((      SUM(       ifnull( c.jrrl, 0 )) - SUM(      ifnull( c.tqjrrl, 0 ))) / SUM(      ifnull( c.tqjrrl, 0 ))) * 100,    0    ) 同比测试1   FROM   (   SELECT    OG_NO,    tj jrrl,    tq tqjrrl    FROM    (    SELECT     a.OG_NO,     a.IX123_NO,     (     SUM( a.DA12_VALE )) tj,     (     SUM( a.DA12_V123_S43 )) tq     FROM     shard12 a     WHERE     a.EXTUE05 LIKE '202009%'      AND a.TE_N = 'IND_02_FBSBZ'      AND OG_NO LIKE '41406%'      AND a.SAT_CRE = '03'      AND a.IX123_NO = 'lll411010234015'     GROUP BY     a.OG_NO,     a.IX123_NO     ) b    ) c   GROUP BY   c.OG_NO   ) c  RIGHT JOIN ( SELECT * FROM shard13 WHERE C66E LIKE '41406%' AND LENGTH( C66E ) = '7' AND NAME NOT LIKE '%爱可生社区%' ) d ON c.OG_NO = d.C66E  ORDER BY  ( d.C66E = '4140601' ) DESC,  d.C66E  | success      | schema1 | utf8mb4 |
      | conn_0 | False    | SELECT d.NAME NAME, d.C66E C66E, IFNULL( c.jll, 0 ) 测试1, IFNULL( c.tongqijll, 0 ) 同期测试1, IFNULL( c.tongbijll, 0 ) 同比测试1  FROM  (  SELECT   OG_NO,   IFNULL( SUM( ifnull( c.jrrl, 0 )), 0 ) jll,   IFNULL( SUM( ifnull( c.tqjrrl, 0 )), 0 ) tongqijll,   IFNULL(((      SUM(       ifnull( c.jrrl, 0 )) - SUM(      ifnull( c.tqjrrl, 0 ))) / SUM(      ifnull( c.tqjrrl, 0 ))) * 100,    0    ) tongbijll   FROM   (   SELECT    OG_NO,    tj jrrl,    tq tqjrrl    FROM    (    SELECT     a.OG_NO,     a.IX123_NO,     (     SUM( a.DA12_VALE )) tj,     (     SUM( a.DA12_V123_S43 )) tq     FROM     shard12 a     WHERE     a.EXTUE05 LIKE '202009%'      AND a.TE_N = 'IND_02_FBSBZ'      AND OG_NO LIKE '41406%'      AND a.SAT_CRE = '03'      AND a.IX123_NO = 'lll411010234015'     GROUP BY     a.OG_NO,     a.IX123_NO     ) b    ) c   GROUP BY   c.OG_NO   ) c  RIGHT JOIN ( SELECT * FROM shard13 WHERE C66E LIKE '41406%' AND LENGTH( C66E ) = '7' AND NAME NOT LIKE '%爱可生社区%' ) d ON c.OG_NO = d.C66E  ORDER BY  ( d.C66E = '4140601' ) DESC,  d.C66E | success      | schema1 | utf8mb4 |

#case function support utf8  ATK-1408
    Given execute single sql in "dble-1" in "user" mode and save resultset in "10"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT A1.DI23M123 AS dim, IFNULL(A2.dataValue, 0) AS dataValue FROM ( SELECT '测33' AS DI23M123 FROM DUAL UNION SELECT '测27' AS DI23M123 FROM DUAL UNION SELECT '测29' AS DI23M123 FROM DUAL UNION SELECT '测39' AS DI23M123 FROM DUAL UNION SELECT '测23' AS DI23M123 FROM DUAL UNION SELECT '测25' AS DI23M123 FROM DUAL UNION SELECT '过户' AS DI23M123 FROM DUAL UNION SELECT '测37' AS DI23M123 FROM DUAL UNION SELECT '更名' AS DI23M123 FROM DUAL UNION SELECT '减容' AS DI23M123 FROM DUAL UNION SELECT '暂停' AS DI23M123 FROM DUAL UNION SELECT '改类' AS DI23M123 FROM DUAL UNION SELECT '测31' AS DI23M123 FROM DUAL UNION SELECT '测35' AS DI23M123 FROM DUAL UNION SELECT '其他' AS DI23M123 FROM DUAL ) A1 LEFT JOIN ( SELECT b.dim, SUM(b.tj) AS dataValue FROM ( SELECT CASE  WHEN DI23M123 IN ('101', '109') THEN '测27' WHEN DI23M123 IN ('102', '110') THEN '测29' WHEN DI23M123 IN ('104', '111') THEN '测39' WHEN DI23M123 IN ('105') THEN '测23' WHEN DI23M123 IN ('112') THEN '测25' WHEN DI23M123 IN ('211') THEN '过户' WHEN DI23M123 IN ('216') THEN '测37' WHEN DI23M123 IN ('210') THEN '更名' WHEN DI23M123 IN ('201') THEN '减容' WHEN DI23M123 IN ('203') THEN '暂停' WHEN DI23M123 IN ('215') THEN '改类' WHEN DI23M123 IN ('217') THEN '测31' WHEN DI23M123 IN ('302') THEN '测35' ELSE '其他' END AS dim, IFNULL(SUM(a.DA12_VALE), 0) AS tj FROM shard12 a WHERE SUBSTR(a.EXTUE05, 1, 6) = '202009' AND a.TE_N = 'IND_02_YWBL' AND OG_NO = '4140621' AND a.SAT_CRE = '03' AND a.DI23M123 NOT IN ( '471',  '502',  '504',  '505',  '506',  '507',  '508',  '509',  '510',  '511' ) AND a.IX123_NO IN ('lll411010234002') GROUP BY a.DI23M123 UNION ALL SELECT '测33' AS dim, IFNULL(SUM(a.DA12_VALE), 0) AS tj FROM shard12 a WHERE SUBSTR(a.EXTUE05, 1, 6) = '202009' AND a.TE_N = 'IND_02_YWBL' AND OG_NO = '4140621' AND a.SAT_CRE = '03' AND a.DI23M123 IN ( '101',  '102',  '104',  '105',  '109',  '110',  '111',  '112' ) AND a.IX123_NO IN ('lll411010234002') ) b GROUP BY b.dim ) A2 ON A1.DI23M123 = A2.dim | schema1 | utf8mb4 |
    Then check resultset "10" has lines with following column values
      | dim-0      | dataValue-1 |
      | 测23     | 0           |
      | 测25     | 0           |
      | 测27     | 0           |
      | 测29     | 0           |
      | 其他        | 0           |
      | 减容        | 0           |
      | 测31     | 0           |
      | 改类        | 0           |
      | 测33     | 0           |
      | 暂停        | 0           |
      | 更名        | 0           |
      | 测35 | 0           |
      | 过户        | 0           |
      | 测37        | 0           |
      | 测39        | 0           |

#case function support utf8 from github :2021
    Given execute single sql in "dble-1" in "user" mode and save resultset in "12"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "wsgw", SUM(CASE t.name WHEN "支" THEN t.dataValue END) "zfb", SUM(CASE t.name WHEN "信" THEN t.dataValue END) "wx", SUM(CASE t.name WHEN "宝" THEN t.dataValue END) "deb", SUM(CASE t.name WHEN "线" THEN t.dataValue END) "rx", SUM(CASE t.name WHEN "办" THEN t.dataValue END) "bdczqlb", SUM(CASE t.name WHEN "一" THEN t.dataValue END) "ywtb", SUM(CASE t.name WHEN "站" THEN t.dataValue END) "wz" , SUM(CASE t.name WHEN "道" THEN t.dataValue END) "xxqd" , SUM(CASE t.name WHEN " 其他" THEN t.dataValue END) "qt" , "况" AS 'lb', s.DESTION "dw" FROM ( SELECT "国" AS name, ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 ='05' UNION ALL SELECT "支" AS "name", ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 = "04" UNION ALL SELECT "信" AS "name", ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 ='03' UNION ALL SELECT "宝" AS "name", ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 = "01" ) t LEFT JOIN shard13 s ON s.`C66E` = '41101' | schema1 | utf8mb4 |
    Then check resultset "12" has lines with following column values
      | wsgw-0 | zfb-1 | wx-2 | deb-3 | rx-4 | bdczqlb-5 | ywtb-6 | wz-7 | xxqd-8 | qt-9 | lb-10 | dw-11 |
      | None   | 0.0   | 0.0  | 0.0   | None | None      | None   | None | None   | None | 况     | None  |

#case function support utf8 from github :2022
    Given execute single sql in "dble-1" in "user" mode and save resultset in "13"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "wsgw", SUM(CASE t.name WHEN "宝" THEN t.dataValue END) "zfb", SUM(CASE t.name WHEN "测试1" THEN t.dataValue END) "wx", SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "deb", SUM(CASE t.name WHEN "测试2" THEN t.dataValue END) "rx", SUM(CASE t.name WHEN "测试4" THEN t.dataValue END) "bdczqlb", SUM(CASE t.name WHEN "测试3" THEN t.dataValue END) "ywtb", SUM(CASE t.name WHEN "测试5" THEN t.dataValue END) "wz" , SUM(CASE t.name WHEN "测试" THEN t.dataValue END) "xxqd" , SUM(CASE t.name WHEN "其他" THEN t.dataValue END) "qt" , "测试" AS 'lb', s.DESTION "dw" FROM ( SELECT "社区服务上" AS name, ROUND(IFNULL(SUM(`DA12_VALE`),0)) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 ='05' UNION ALL SELECT "支" AS name, ROUND(IFNULL(SUM(`DA12_VALE`),0)) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 = "04" UNION ALL SELECT "测试34" AS name, ROUND(IFNULL(SUM(`DA12_VALE`),0)) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 ='03' UNION ALL SELECT "爱心" AS name, ROUND(IFNULL(SUM(`DA12_VALE`),0)) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 = "01") t LEFT JOIN shard13 s ON s.`C66E` = '41101'  | schema1 | utf8mb4 |
    Then check resultset "13" has lines with following column values
      | wsgw-0 | zfb-1 | wx-2 | deb-3 | rx-4 | bdczqlb-5 | ywtb-6 | wz-7 | xxqd-8 | qt-9 | lb-10 | dw-11 |
      | None   | None  | None | None  | None | None      | None   | None | None   | None | 测试    | None  |

#case function support utf8 from github :2025
    Given execute single sql in "dble-1" in "user" mode and save resultset in "14"
      | conn   | toClose | sql                          | db      | charset |
      | conn_0 | False   | SELECT SUM(CASE t.name WHEN "测试" THEN t.dataValue else 0 end ) "wsgw","test" AS 'lb'  FROM ( SELECT "社区服务" AS name,ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 ='05' UNION ALL SELECT "支之" AS "name",ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = 'lll411010434001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE = '01' AND DI23M123 =  "04" UNION ALL SELECT "test23" AS "name",ROUND(IFNULL(SUM(`DA12_VALE`),0),0) dataValue FROM shard12 cidm WHERE cidm.OG_NO = '41101' AND cidm.IX123_NO = '134001' AND cidm.ben_tim12 >= '20200802' AND cidm.ben_tim12 <= '20200803' AND cidm.SAT_CRE  = '01' AND DI23M123 ='03' ) t | schema1 | utf8mb4 |
    Then check resultset "14" has lines with following column values
      | wsgw-0 | lb-1 |
      | 0.0    | test |

#case no create schema but in sql is used this schema then do not occur DBLE0REQ-627
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose   | sql                                        | expect    | charset |
      | conn_0 | false     | select * from (SELECT '测33' DI23M123 FROM DUAL ) as A inner join (select * from mimc_be.shard12 UNION ALL select * from mimc_be.shard12 ) as B   | Table `mimc_be`.`shard12` doesn't exist | utf8mb4 |
      | conn_0 | false     | select * from (SELECT '测33' DI23M123 FROM DUAL ) as A inner join mimc_be.shard12   |  Table `mimc_be`.`shard12` doesn't exist | utf8mb4 |
      | conn_0 | false     | select * from (SELECT '' DI23M123 FROM DUAL ) as A inner join (select * from mimc_be.shard12 UNION ALL select * from mimc_be.shard12 ) as B   | Table `mimc_be`.`shard12` doesn't exist | utf8mb4 |
      | conn_0 | false     | select * from (SELECT '' DI23M123 FROM DUAL ) as A inner join mimc_be.shard12   |  Table `mimc_be`.`shard12` doesn't exist | utf8mb4 |

#case no use schema ,then query sql ,the in sql schema is not exists do not occur npe DBLE0REQ-685
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect    | charset |
      | conn_1 | true     | select * from (SELECT '测33' DI23M123 FROM DUAL ) as A inner join (select * from mimc_be.shard12 UNION ALL select * from mimc_be.shard12 ) as B   | Table `mimc_be`.`shard12` doesn't exist  | utf8mb4 |
      | conn_1 | true     | select * from (SELECT '测33' DI23M123 FROM DUAL ) as A inner join mimc_be.shard12   | Table `mimc_be`.`shard12` doesn't exist  | utf8mb4 |
      | conn_1 | true     | select * from (SELECT '' DI23M123 FROM DUAL ) as A inner join (select * from mimc_be.shard12 UNION ALL select * from mimc_be.shard12 ) as B   | Table `mimc_be`.`shard12` doesn't exist  | utf8mb4 |
      | conn_1 | true     | select * from (SELECT '' DI23M123 FROM DUAL ) as A inner join mimc_be.shard12   | Table `mimc_be`.`shard12` doesn't exist  | utf8mb4 |
#case no use schema ,then query sql ,the in sql schema is exists do not occur npe DBLE0REQ-638
      | conn_1 | true     | SELECT d.NAME AS NAME, d.C66E AS C66E, IFNULL(c.测试1, 0) AS 测试1 , IFNULL(c.同期测试1, 0) AS 同期测试1 , IFNULL(c.同比测试1, 0) AS 同比测试1 FROM ( SELECT OG_NO , IFNULL(SUM(ifnull(c.jrrl, 0)), 0) AS 测试1 , IFNULL(SUM(ifnull(c.tqjrrl, 0)), 0) AS 同期测试1 , IFNULL((SUM(ifnull(c.jrrl, 0)) - SUM(ifnull(c.tqjrrl, 0))) / SUM(ifnull(c.tqjrrl, 0)) * 100, 0) AS 同比测试1 FROM ( SELECT OG_NO, tj AS jrrl, tq AS tqjrrl FROM ( SELECT a.OG_NO, a.IX123_NO, SUM(a.DA12_VALE) AS tj , SUM(a.DA12_V123_S43) AS tq FROM shard12 a WHERE a.EXTUE05 LIKE '202009%' AND a.TE_N = 'IND_02_FBSBZ' AND OG_NO LIKE '41406%' AND a.SAT_CRE = '03' AND a.IX123_NO = 'lll411010234015' GROUP BY a.OG_NO, a.IX123_NO ) b ) c GROUP BY c.OG_NO ) c RIGHT JOIN ( SELECT * FROM shard13 WHERE C66E LIKE '41406%' AND LENGTH(C66E) = '7' AND NAME NOT LIKE '%爱可生社区%' ) d ON c.OG_NO = d.C66E ORDER BY d.C66E = '4140601' DESC, d.C66E   | No database selected | utf8mb4 |

#case clear table meta
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect       | db      | charset |
      | conn_0 | False    | drop table if exists shard12   | success      | schema1 | utf8mb4 |
      | conn_0 | False    | drop table if exists shard13        | success      | schema1 | utf8mb4 |
      | conn_0 | true     | drop table if exists shard14   | success      | schema1 | utf8mb4 |


    Scenario: check Functions and O09Rs support utf8mb4: case from issue DBLE0REQ-660 #3
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
      | conn_0 | False   | select (case a.id when 1 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                            | has{(('好',),)}                 | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_2_t2 values (2,2,'测试2')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_3_t1 values (2,2,'测试2')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 1 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                            | has{(('好',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | insert into sharding_3_t1 values (2,3,'测试3')                                                                                                 | success                        | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 2 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id                             | has{(('坏',),('好',),('好',))}  | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 3 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id                             | has{(('坏',),('坏',),('坏',))}  | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 3 then '好' else '坏' end) b from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                            | has{(('坏',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select (case a.id when 3 then '好' else '坏' end) from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2                              | has{(('坏',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select (case 1 when a.name>c.name then '好' else '坏' end) from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id                      | has{(('坏',),('坏',),('坏',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name in (case 1 when a.name<c.name then '测试2' else '测试1' end)     | has{(('测试1',),)}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name not in (case 1 when a.name<c.name then '测试2' else '测试1' end)     | has{(('测试2',),)}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name > (case 1 when a.name<c.name then '测试2' else '测试1' end)      | has{(('测试2',),)}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on a.id = c.id2 where a.name < (case 1 when a.name<c.name then '测试2' else '测试1' end)      | length{(0)}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) = (case c.name when a.name>c.name then '测试2' else '测试1' end)    | has{(('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) = (case c.name when a.name>c.name then '测试2' else '测试1' end)    | has{(('测试1',),('测试2',))}          | schema1 | utf8mb4 |
      | conn_0 | False   | select a.name from sharding_2_t2 a inner join sharding_3_t1 c on  (case a.name when a.name<c.name then '测试2' else '测试1' end) > (case c.name when a.name>c.name then '测试2' else '测试1' end)    | has{(('测试2',),)}          | schema1 | utf8mb4 |
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
## case 2 function : O09R
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
#      | conn_0 | False   | select IF(STRCMP(a.name > b.name),'爱可生','开心') from sharding_2_t2 a inner join sharding_3_t1 b on a.id=b.id  | Incorrect parameter count in the call to native function 'STRCMP'  | schema1 | utf8mb4 |
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
      | conn_0 | False   | select b.id from sharding_2_t2 a join sharding_3_t1 b group by substring(a.name,1,2),b.id  | has{((1,), (2,))}        | schema1 | utf8mb4 |

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