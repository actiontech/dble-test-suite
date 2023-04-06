# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2022/5/12
Feature: Transaction query error due to connection used error

  # according to http://10.186.18.11/jira/browse/DBLE0REQ-1744


  Scenario: test with commit will not hang, from ATK-2600  #1

    Given delete the following xml segment
      |file          | parent          | child                   |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="-1">
            <globalTable name="mb_rule" shardingNode="dn_1,dn_2,dn_3,dn_4,dn_5,dn_6,dn_7,dn_8,dn_9,dn_10,dn_11,dn_12,dn_13,dn_14,dn_15,dn_16,dn_17,dn_18,dn_19,dn_20,dn_21,dn_22,dn_23,dn_24,dn_25,dn_26,dn_27,dn_28,dn_29,dn_30,dn_31,dn_32,dn_33,dn_34,dn_35,dn_36,dn_37,dn_38,dn_39,dn_40,dn_41,dn_42,dn_43,dn_44,dn_45,dn_46,dn_47,dn_48,dn_49,dn_50,dn_51,dn_52,dn_53,dn_54,dn_55,dn_56,dn_57,dn_58,dn_59,dn_60,dn_61,dn_62,dn_63,dn_64,dn_65,dn_66,dn_67,dn_68,dn_69,dn_70,dn_71,dn_72,dn_73,dn_74,dn_75,dn_76,dn_77,dn_78,dn_79,dn_80,dn_81,dn_82,dn_83,dn_84,dn_85,dn_86,dn_87,dn_88,dn_89,dn_90,dn_91,dn_92,dn_93,dn_94,dn_95,dn_96,dn_97,dn_98,dn_99,dn_100,dn_101,dn_102,dn_103,dn_104,dn_105,dn_106,dn_107,dn_108,dn_109,dn_110,dn_111,dn_112,dn_113,dn_114,dn_115,dn_116,dn_117,dn_118,dn_119,dn_120,dn_121,dn_122,dn_123,dn_124,dn_125,dn_126,dn_127,dn_128" sqlMaxLimit="-1" checkClass="CHECKSUM" cron="0 0 0 * * ?"></globalTable>
            <globalTable name="mb_rule_dtl" shardingNode="dn_1,dn_2,dn_3,dn_4,dn_5,dn_6,dn_7,dn_8,dn_9,dn_10,dn_11,dn_12,dn_13,dn_14,dn_15,dn_16,dn_17,dn_18,dn_19,dn_20,dn_21,dn_22,dn_23,dn_24,dn_25,dn_26,dn_27,dn_28,dn_29,dn_30,dn_31,dn_32,dn_33,dn_34,dn_35,dn_36,dn_37,dn_38,dn_39,dn_40,dn_41,dn_42,dn_43,dn_44,dn_45,dn_46,dn_47,dn_48,dn_49,dn_50,dn_51,dn_52,dn_53,dn_54,dn_55,dn_56,dn_57,dn_58,dn_59,dn_60,dn_61,dn_62,dn_63,dn_64,dn_65,dn_66,dn_67,dn_68,dn_69,dn_70,dn_71,dn_72,dn_73,dn_74,dn_75,dn_76,dn_77,dn_78,dn_79,dn_80,dn_81,dn_82,dn_83,dn_84,dn_85,dn_86,dn_87,dn_88,dn_89,dn_90,dn_91,dn_92,dn_93,dn_94,dn_95,dn_96,dn_97,dn_98,dn_99,dn_100,dn_101,dn_102,dn_103,dn_104,dn_105,dn_106,dn_107,dn_108,dn_109,dn_110,dn_111,dn_112,dn_113,dn_114,dn_115,dn_116,dn_117,dn_118,dn_119,dn_120,dn_121,dn_122,dn_123,dn_124,dn_125,dn_126,dn_127,dn_128" sqlMaxLimit="-1" checkClass="CHECKSUM" cron="0 0 0 * * ?"></globalTable>
            <globalTable name="mb_rule_edit" shardingNode="dn_1,dn_2,dn_3,dn_4,dn_5,dn_6,dn_7,dn_8,dn_9,dn_10,dn_11,dn_12,dn_13,dn_14,dn_15,dn_16,dn_17,dn_18,dn_19,dn_20,dn_21,dn_22,dn_23,dn_24,dn_25,dn_26,dn_27,dn_28,dn_29,dn_30,dn_31,dn_32,dn_33,dn_34,dn_35,dn_36,dn_37,dn_38,dn_39,dn_40,dn_41,dn_42,dn_43,dn_44,dn_45,dn_46,dn_47,dn_48,dn_49,dn_50,dn_51,dn_52,dn_53,dn_54,dn_55,dn_56,dn_57,dn_58,dn_59,dn_60,dn_61,dn_62,dn_63,dn_64,dn_65,dn_66,dn_67,dn_68,dn_69,dn_70,dn_71,dn_72,dn_73,dn_74,dn_75,dn_76,dn_77,dn_78,dn_79,dn_80,dn_81,dn_82,dn_83,dn_84,dn_85,dn_86,dn_87,dn_88,dn_89,dn_90,dn_91,dn_92,dn_93,dn_94,dn_95,dn_96,dn_97,dn_98,dn_99,dn_100,dn_101,dn_102,dn_103,dn_104,dn_105,dn_106,dn_107,dn_108,dn_109,dn_110,dn_111,dn_112,dn_113,dn_114,dn_115,dn_116,dn_117,dn_118,dn_119,dn_120,dn_121,dn_122,dn_123,dn_124,dn_125,dn_126,dn_127,dn_128" sqlMaxLimit="-1" checkClass="CHECKSUM" cron="0 0 0 * * ?"></globalTable>
            <globalTable name="mb_rule_rights" shardingNode="dn_1,dn_2,dn_3,dn_4,dn_5,dn_6,dn_7,dn_8,dn_9,dn_10,dn_11,dn_12,dn_13,dn_14,dn_15,dn_16,dn_17,dn_18,dn_19,dn_20,dn_21,dn_22,dn_23,dn_24,dn_25,dn_26,dn_27,dn_28,dn_29,dn_30,dn_31,dn_32,dn_33,dn_34,dn_35,dn_36,dn_37,dn_38,dn_39,dn_40,dn_41,dn_42,dn_43,dn_44,dn_45,dn_46,dn_47,dn_48,dn_49,dn_50,dn_51,dn_52,dn_53,dn_54,dn_55,dn_56,dn_57,dn_58,dn_59,dn_60,dn_61,dn_62,dn_63,dn_64,dn_65,dn_66,dn_67,dn_68,dn_69,dn_70,dn_71,dn_72,dn_73,dn_74,dn_75,dn_76,dn_77,dn_78,dn_79,dn_80,dn_81,dn_82,dn_83,dn_84,dn_85,dn_86,dn_87,dn_88,dn_89,dn_90,dn_91,dn_92,dn_93,dn_94,dn_95,dn_96,dn_97,dn_98,dn_99,dn_100,dn_101,dn_102,dn_103,dn_104,dn_105,dn_106,dn_107,dn_108,dn_109,dn_110,dn_111,dn_112,dn_113,dn_114,dn_115,dn_116,dn_117,dn_118,dn_119,dn_120,dn_121,dn_122,dn_123,dn_124,dn_125,dn_126,dn_127,dn_128" sqlMaxLimit="-1" checkClass="CHECKSUM" cron="0 0 0 * * ?"></globalTable>
            <globalTable name="mb_rule_rights_dtl" shardingNode="dn_1,dn_2,dn_3,dn_4,dn_5,dn_6,dn_7,dn_8,dn_9,dn_10,dn_11,dn_12,dn_13,dn_14,dn_15,dn_16,dn_17,dn_18,dn_19,dn_20,dn_21,dn_22,dn_23,dn_24,dn_25,dn_26,dn_27,dn_28,dn_29,dn_30,dn_31,dn_32,dn_33,dn_34,dn_35,dn_36,dn_37,dn_38,dn_39,dn_40,dn_41,dn_42,dn_43,dn_44,dn_45,dn_46,dn_47,dn_48,dn_49,dn_50,dn_51,dn_52,dn_53,dn_54,dn_55,dn_56,dn_57,dn_58,dn_59,dn_60,dn_61,dn_62,dn_63,dn_64,dn_65,dn_66,dn_67,dn_68,dn_69,dn_70,dn_71,dn_72,dn_73,dn_74,dn_75,dn_76,dn_77,dn_78,dn_79,dn_80,dn_81,dn_82,dn_83,dn_84,dn_85,dn_86,dn_87,dn_88,dn_89,dn_90,dn_91,dn_92,dn_93,dn_94,dn_95,dn_96,dn_97,dn_98,dn_99,dn_100,dn_101,dn_102,dn_103,dn_104,dn_105,dn_106,dn_107,dn_108,dn_109,dn_110,dn_111,dn_112,dn_113,dn_114,dn_115,dn_116,dn_117,dn_118,dn_119,dn_120,dn_121,dn_122,dn_123,dn_124,dn_125,dn_126,dn_127,dn_128" sqlMaxLimit="-1" checkClass="CHECKSUM" cron="0 0 0 * * ?"></globalTable>
            <globalTable name="pm_verify" shardingNode="dn_1,dn_2,dn_3,dn_4,dn_5,dn_6,dn_7,dn_8,dn_9,dn_10,dn_11,dn_12,dn_13,dn_14,dn_15,dn_16,dn_17,dn_18,dn_19,dn_20,dn_21,dn_22,dn_23,dn_24,dn_25,dn_26,dn_27,dn_28,dn_29,dn_30,dn_31,dn_32,dn_33,dn_34,dn_35,dn_36,dn_37,dn_38,dn_39,dn_40,dn_41,dn_42,dn_43,dn_44,dn_45,dn_46,dn_47,dn_48,dn_49,dn_50,dn_51,dn_52,dn_53,dn_54,dn_55,dn_56,dn_57,dn_58,dn_59,dn_60,dn_61,dn_62,dn_63,dn_64,dn_65,dn_66,dn_67,dn_68,dn_69,dn_70,dn_71,dn_72,dn_73,dn_74,dn_75,dn_76,dn_77,dn_78,dn_79,dn_80,dn_81,dn_82,dn_83,dn_84,dn_85,dn_86,dn_87,dn_88,dn_89,dn_90,dn_91,dn_92,dn_93,dn_94,dn_95,dn_96,dn_97,dn_98,dn_99,dn_100,dn_101,dn_102,dn_103,dn_104,dn_105,dn_106,dn_107,dn_108,dn_109,dn_110,dn_111,dn_112,dn_113,dn_114,dn_115,dn_116,dn_117,dn_118,dn_119,dn_120,dn_121,dn_122,dn_123,dn_124,dn_125,dn_126,dn_127,dn_128" sqlMaxLimit="-1" checkClass="CHECKSUM" cron="0 0 0 * * ?"></globalTable>
        </schema>
            <shardingNode name="dn_1" dbGroup="ha_group1" database="dh_dn_1"></shardingNode>
            <shardingNode name="dn_2" dbGroup="ha_group1" database="dh_dn_2"></shardingNode>
            <shardingNode name="dn_3" dbGroup="ha_group1" database="dh_dn_3"></shardingNode>
            <shardingNode name="dn_4" dbGroup="ha_group1" database="dh_dn_4"></shardingNode>
            <shardingNode name="dn_5" dbGroup="ha_group1" database="dh_dn_5"></shardingNode>
            <shardingNode name="dn_6" dbGroup="ha_group1" database="dh_dn_6"></shardingNode>
            <shardingNode name="dn_7" dbGroup="ha_group1" database="dh_dn_7"></shardingNode>
            <shardingNode name="dn_8" dbGroup="ha_group1" database="dh_dn_8"></shardingNode>
            <shardingNode name="dn_9" dbGroup="ha_group1" database="dh_dn_9"></shardingNode>
            <shardingNode name="dn_10" dbGroup="ha_group1" database="dh_dn_10"></shardingNode>
            <shardingNode name="dn_11" dbGroup="ha_group1" database="dh_dn_11"></shardingNode>
            <shardingNode name="dn_12" dbGroup="ha_group1" database="dh_dn_12"></shardingNode>
            <shardingNode name="dn_13" dbGroup="ha_group1" database="dh_dn_13"></shardingNode>
            <shardingNode name="dn_14" dbGroup="ha_group1" database="dh_dn_14"></shardingNode>
            <shardingNode name="dn_15" dbGroup="ha_group1" database="dh_dn_15"></shardingNode>
            <shardingNode name="dn_16" dbGroup="ha_group1" database="dh_dn_16"></shardingNode>
            <shardingNode name="dn_17" dbGroup="ha_group1" database="dh_dn_17"></shardingNode>
            <shardingNode name="dn_18" dbGroup="ha_group1" database="dh_dn_18"></shardingNode>
            <shardingNode name="dn_19" dbGroup="ha_group1" database="dh_dn_19"></shardingNode>
            <shardingNode name="dn_20" dbGroup="ha_group1" database="dh_dn_20"></shardingNode>
            <shardingNode name="dn_21" dbGroup="ha_group1" database="dh_dn_21"></shardingNode>
            <shardingNode name="dn_22" dbGroup="ha_group1" database="dh_dn_22"></shardingNode>
            <shardingNode name="dn_23" dbGroup="ha_group1" database="dh_dn_23"></shardingNode>
            <shardingNode name="dn_24" dbGroup="ha_group1" database="dh_dn_24"></shardingNode>
            <shardingNode name="dn_25" dbGroup="ha_group1" database="dh_dn_25"></shardingNode>
            <shardingNode name="dn_26" dbGroup="ha_group1" database="dh_dn_26"></shardingNode>
            <shardingNode name="dn_27" dbGroup="ha_group1" database="dh_dn_27"></shardingNode>
            <shardingNode name="dn_28" dbGroup="ha_group1" database="dh_dn_28"></shardingNode>
            <shardingNode name="dn_29" dbGroup="ha_group1" database="dh_dn_29"></shardingNode>
            <shardingNode name="dn_30" dbGroup="ha_group1" database="dh_dn_30"></shardingNode>
            <shardingNode name="dn_31" dbGroup="ha_group1" database="dh_dn_31"></shardingNode>
            <shardingNode name="dn_32" dbGroup="ha_group1" database="dh_dn_32"></shardingNode>

            <shardingNode name="dn_33" dbGroup="ha_group2" database="dh_dn_33"></shardingNode>
            <shardingNode name="dn_34" dbGroup="ha_group2" database="dh_dn_34"></shardingNode>
            <shardingNode name="dn_35" dbGroup="ha_group2" database="dh_dn_35"></shardingNode>
            <shardingNode name="dn_36" dbGroup="ha_group2" database="dh_dn_36"></shardingNode>
            <shardingNode name="dn_37" dbGroup="ha_group2" database="dh_dn_37"></shardingNode>
            <shardingNode name="dn_38" dbGroup="ha_group2" database="dh_dn_38"></shardingNode>
            <shardingNode name="dn_39" dbGroup="ha_group2" database="dh_dn_39"></shardingNode>
            <shardingNode name="dn_40" dbGroup="ha_group2" database="dh_dn_40"></shardingNode>
            <shardingNode name="dn_41" dbGroup="ha_group2" database="dh_dn_41"></shardingNode>
            <shardingNode name="dn_42" dbGroup="ha_group2" database="dh_dn_42"></shardingNode>
            <shardingNode name="dn_43" dbGroup="ha_group2" database="dh_dn_43"></shardingNode>
            <shardingNode name="dn_44" dbGroup="ha_group2" database="dh_dn_44"></shardingNode>
            <shardingNode name="dn_45" dbGroup="ha_group2" database="dh_dn_45"></shardingNode>
            <shardingNode name="dn_46" dbGroup="ha_group2" database="dh_dn_46"></shardingNode>
            <shardingNode name="dn_47" dbGroup="ha_group2" database="dh_dn_47"></shardingNode>
            <shardingNode name="dn_48" dbGroup="ha_group2" database="dh_dn_48"></shardingNode>
            <shardingNode name="dn_49" dbGroup="ha_group2" database="dh_dn_49"></shardingNode>
            <shardingNode name="dn_50" dbGroup="ha_group2" database="dh_dn_50"></shardingNode>
            <shardingNode name="dn_51" dbGroup="ha_group2" database="dh_dn_51"></shardingNode>
            <shardingNode name="dn_52" dbGroup="ha_group2" database="dh_dn_52"></shardingNode>
            <shardingNode name="dn_53" dbGroup="ha_group2" database="dh_dn_53"></shardingNode>
            <shardingNode name="dn_54" dbGroup="ha_group2" database="dh_dn_54"></shardingNode>
            <shardingNode name="dn_55" dbGroup="ha_group2" database="dh_dn_55"></shardingNode>
            <shardingNode name="dn_56" dbGroup="ha_group2" database="dh_dn_56"></shardingNode>
            <shardingNode name="dn_57" dbGroup="ha_group2" database="dh_dn_57"></shardingNode>
            <shardingNode name="dn_58" dbGroup="ha_group2" database="dh_dn_58"></shardingNode>
            <shardingNode name="dn_59" dbGroup="ha_group2" database="dh_dn_59"></shardingNode>
            <shardingNode name="dn_60" dbGroup="ha_group2" database="dh_dn_60"></shardingNode>
            <shardingNode name="dn_61" dbGroup="ha_group2" database="dh_dn_61"></shardingNode>
            <shardingNode name="dn_62" dbGroup="ha_group2" database="dh_dn_62"></shardingNode>
            <shardingNode name="dn_63" dbGroup="ha_group2" database="dh_dn_63"></shardingNode>
            <shardingNode name="dn_64" dbGroup="ha_group2" database="dh_dn_64"></shardingNode>

            <shardingNode name="dn_65" dbGroup="ha_group3" database="dh_dn_65"></shardingNode>
            <shardingNode name="dn_66" dbGroup="ha_group3" database="dh_dn_66"></shardingNode>
            <shardingNode name="dn_67" dbGroup="ha_group3" database="dh_dn_67"></shardingNode>
            <shardingNode name="dn_68" dbGroup="ha_group3" database="dh_dn_68"></shardingNode>
            <shardingNode name="dn_69" dbGroup="ha_group3" database="dh_dn_69"></shardingNode>
            <shardingNode name="dn_70" dbGroup="ha_group3" database="dh_dn_70"></shardingNode>
            <shardingNode name="dn_71" dbGroup="ha_group3" database="dh_dn_71"></shardingNode>
            <shardingNode name="dn_72" dbGroup="ha_group3" database="dh_dn_72"></shardingNode>
            <shardingNode name="dn_73" dbGroup="ha_group3" database="dh_dn_73"></shardingNode>
            <shardingNode name="dn_74" dbGroup="ha_group3" database="dh_dn_74"></shardingNode>
            <shardingNode name="dn_75" dbGroup="ha_group3" database="dh_dn_75"></shardingNode>
            <shardingNode name="dn_76" dbGroup="ha_group3" database="dh_dn_76"></shardingNode>
            <shardingNode name="dn_77" dbGroup="ha_group3" database="dh_dn_77"></shardingNode>
            <shardingNode name="dn_78" dbGroup="ha_group3" database="dh_dn_78"></shardingNode>
            <shardingNode name="dn_79" dbGroup="ha_group3" database="dh_dn_79"></shardingNode>
            <shardingNode name="dn_80" dbGroup="ha_group3" database="dh_dn_80"></shardingNode>
            <shardingNode name="dn_81" dbGroup="ha_group3" database="dh_dn_81"></shardingNode>
            <shardingNode name="dn_82" dbGroup="ha_group3" database="dh_dn_82"></shardingNode>
            <shardingNode name="dn_83" dbGroup="ha_group3" database="dh_dn_83"></shardingNode>
            <shardingNode name="dn_84" dbGroup="ha_group3" database="dh_dn_84"></shardingNode>
            <shardingNode name="dn_85" dbGroup="ha_group3" database="dh_dn_85"></shardingNode>
            <shardingNode name="dn_86" dbGroup="ha_group3" database="dh_dn_86"></shardingNode>
            <shardingNode name="dn_87" dbGroup="ha_group3" database="dh_dn_87"></shardingNode>
            <shardingNode name="dn_88" dbGroup="ha_group3" database="dh_dn_88"></shardingNode>
            <shardingNode name="dn_89" dbGroup="ha_group3" database="dh_dn_89"></shardingNode>
            <shardingNode name="dn_90" dbGroup="ha_group3" database="dh_dn_90"></shardingNode>
            <shardingNode name="dn_91" dbGroup="ha_group3" database="dh_dn_91"></shardingNode>
            <shardingNode name="dn_92" dbGroup="ha_group3" database="dh_dn_92"></shardingNode>
            <shardingNode name="dn_93" dbGroup="ha_group3" database="dh_dn_93"></shardingNode>
            <shardingNode name="dn_94" dbGroup="ha_group3" database="dh_dn_94"></shardingNode>
            <shardingNode name="dn_95" dbGroup="ha_group3" database="dh_dn_95"></shardingNode>
            <shardingNode name="dn_96" dbGroup="ha_group3" database="dh_dn_96"></shardingNode>

            <shardingNode name="dn_97" dbGroup="ha_group4" database="dh_dn_97"></shardingNode>
            <shardingNode name="dn_98" dbGroup="ha_group4" database="dh_dn_98"></shardingNode>
            <shardingNode name="dn_99" dbGroup="ha_group4" database="dh_dn_99"></shardingNode>
            <shardingNode name="dn_100" dbGroup="ha_group4" database="dh_dn_100"></shardingNode>
            <shardingNode name="dn_101" dbGroup="ha_group4" database="dh_dn_101"></shardingNode>
            <shardingNode name="dn_102" dbGroup="ha_group4" database="dh_dn_102"></shardingNode>
            <shardingNode name="dn_103" dbGroup="ha_group4" database="dh_dn_103"></shardingNode>
            <shardingNode name="dn_104" dbGroup="ha_group4" database="dh_dn_104"></shardingNode>
            <shardingNode name="dn_105" dbGroup="ha_group4" database="dh_dn_105"></shardingNode>
            <shardingNode name="dn_106" dbGroup="ha_group4" database="dh_dn_106"></shardingNode>
            <shardingNode name="dn_107" dbGroup="ha_group4" database="dh_dn_107"></shardingNode>
            <shardingNode name="dn_108" dbGroup="ha_group4" database="dh_dn_108"></shardingNode>
            <shardingNode name="dn_109" dbGroup="ha_group4" database="dh_dn_109"></shardingNode>
            <shardingNode name="dn_110" dbGroup="ha_group4" database="dh_dn_110"></shardingNode>
            <shardingNode name="dn_111" dbGroup="ha_group4" database="dh_dn_111"></shardingNode>
            <shardingNode name="dn_112" dbGroup="ha_group4" database="dh_dn_112"></shardingNode>
            <shardingNode name="dn_113" dbGroup="ha_group4" database="dh_dn_113"></shardingNode>
            <shardingNode name="dn_114" dbGroup="ha_group4" database="dh_dn_114"></shardingNode>
            <shardingNode name="dn_115" dbGroup="ha_group4" database="dh_dn_115"></shardingNode>
            <shardingNode name="dn_116" dbGroup="ha_group4" database="dh_dn_116"></shardingNode>
            <shardingNode name="dn_117" dbGroup="ha_group4" database="dh_dn_117"></shardingNode>
            <shardingNode name="dn_118" dbGroup="ha_group4" database="dh_dn_118"></shardingNode>
            <shardingNode name="dn_119" dbGroup="ha_group4" database="dh_dn_119"></shardingNode>
            <shardingNode name="dn_120" dbGroup="ha_group4" database="dh_dn_120"></shardingNode>
            <shardingNode name="dn_121" dbGroup="ha_group4" database="dh_dn_121"></shardingNode>
            <shardingNode name="dn_122" dbGroup="ha_group4" database="dh_dn_122"></shardingNode>
            <shardingNode name="dn_123" dbGroup="ha_group4" database="dh_dn_123"></shardingNode>
            <shardingNode name="dn_124" dbGroup="ha_group4" database="dh_dn_124"></shardingNode>
            <shardingNode name="dn_125" dbGroup="ha_group4" database="dh_dn_125"></shardingNode>
            <shardingNode name="dn_126" dbGroup="ha_group4" database="dh_dn_126"></shardingNode>
            <shardingNode name="dn_127" dbGroup="ha_group4" database="dh_dn_127"></shardingNode>
            <shardingNode name="dn_128" dbGroup="ha_group4" database="dh_dn_128"></shardingNode>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
         <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
        </dbGroup>
         <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
        </dbGroup>
         <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
        </dbGroup>
         <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM4" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
          </dbInstance>
        </dbGroup>
      """
    Given execute admin cmd "reload @@config_all" success
    Given execute admin cmd "create database @@shardingnode='dn_$1-128'" success

    # may use lots of connections
    Given execute sql in "mysql-master1" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=1000  | success     |
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=1000  | success     |
    Given execute sql in "mysql-master3" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=1000  | success     |
    Given execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=1000  | success     |

    #prepare tables
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                          | expect      | db      |
      | conn_0 | false   | DROP TABLE if exists `pm_verify`                                                                                                             | success     | schema1 |
      | conn_0 | false   | DROP TABLE if exists `mb_rule_edit`                                                                                                          | success     | schema1 |
      | conn_0 | false   | DROP TABLE if exists `mb_rule`                                                                                                               | success     | schema1 |
      | conn_0 | false   | DROP TABLE if exists `mb_rule_dtl`                                                                                                           | success     | schema1 |
      | conn_0 | false   | DROP TABLE if exists `mb_rule_rights`                                                                                                        | success     | schema1 |
      | conn_0 | false   | DROP TABLE if exists `mb_rule_rights_dtl`                                                                                                    | success     | schema1 |
      | conn_0 | false   | CREATE TABLE `pm_verify` (`ID` bigint NOT NULL AUTO_INCREMENT,`VERIFY_OBJ` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`VERIFY_TYPE` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`OBJ_ID` bigint DEFAULT NULL,`OBJ_NAME` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`APPLY_USER` int DEFAULT NULL,`APPLY_TIME` datetime DEFAULT NULL,`APPLY_REASON` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`VERIFY_ROLE` int DEFAULT NULL,`VERIFY_USER` int DEFAULT NULL,`VERIFY_TIME` datetime DEFAULT NULL,`VERIFY_RESULT` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`VERIFY_REASON` varchar(2000) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`STATE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`CREATE_TIME` datetime DEFAULT NULL,`UPDATE_TIME` datetime DEFAULT NULL,`CREATE_USER` int DEFAULT NULL,`UPDATE_USER` int DEFAULT NULL,PRIMARY KEY (`ID`)) ENGINE=InnoDB AUTO_INCREMENT=5203 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin | success | schema1|
      | conn_0 | false   | CREATE TABLE `mb_rule_edit` (`ID` bigint NOT NULL AUTO_INCREMENT,`NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`CODE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`ACTIVE_ID` int DEFAULT NULL,`ACTIVE_TYPE` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`START_TIME` datetime DEFAULT NULL,`END_TIME` datetime DEFAULT NULL,`FIRST_START_TIME` datetime DEFAULT NULL,`FIRST_END_TIME` datetime DEFAULT NULL,`IS_NORMAL` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`ACTIVE_TIME_TYPE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`ACTIVE_TIME_INTF` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SALE_ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`OFFER_START_TIME` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SUB_RULE` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`RATE_TYPE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`RATE_LIMIT` int DEFAULT NULL,`LIMIT` int DEFAULT NULL,`IS_EXPIRE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SHOP_CODE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`STATE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`FIRST_VERIFY_USER` int DEFAULT NULL,`CONFIRM_VERIFY_USER` int DEFAULT NULL,`FIRST_VERIFY_TIME` datetime DEFAULT NULL,`CONFIRM_VERIFY_TIME` datetime DEFAULT NULL,`CREATE_TIME` datetime DEFAULT NULL,`UPDATE_TIME` datetime DEFAULT NULL,`CREATE_USER` int DEFAULT NULL,`UPDATE_USER` int DEFAULT NULL,`PROV_DEPT_ID` int DEFAULT NULL,PRIMARY KEY (`ID`),KEY `IDX_MB_RULE_EDIT_CODE` (`CODE`)) ENGINE=InnoDB AUTO_INCREMENT=1173 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin | success| schema1 |
      | conn_0 | false   | CREATE TABLE `mb_rule` (`ID` bigint NOT NULL AUTO_INCREMENT,`NAME` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`CODE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`ACTIVE_ID` int DEFAULT NULL,`ACTIVE_TYPE` varchar(1) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`START_TIME` datetime DEFAULT NULL,`END_TIME` datetime DEFAULT NULL,`FIRST_START_TIME` datetime DEFAULT NULL,`FIRST_END_TIME` datetime DEFAULT NULL,`IS_NORMAL` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`ACTIVE_TIME_TYPE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`ACTIVE_TIME_INTF` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SALE_ID` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`OFFER_START_TIME` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SUB_RULE` varchar(2) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`RATE_TYPE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`RATE_LIMIT` int DEFAULT NULL,`LIMIT` int DEFAULT NULL,`IS_EXPIRE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SHOP_CODE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`STATE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`FIRST_VERIFY_USER` int DEFAULT NULL,`CONFIRM_VERIFY_USER` int DEFAULT NULL,`FIRST_VERIFY_TIME` datetime DEFAULT NULL,`CONFIRM_VERIFY_TIME` datetime DEFAULT NULL,`CREATE_TIME` datetime DEFAULT NULL,`UPDATE_TIME` datetime DEFAULT NULL,`CREATE_USER` int DEFAULT NULL,`UPDATE_USER` int DEFAULT NULL,`PROV_DEPT_ID` int DEFAULT NULL,PRIMARY KEY (`ID`),KEY `IDX_MB_RULE_CODE` (`CODE`)) ENGINE=InnoDB AUTO_INCREMENT=1173 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin           | success| schema1 |
      | conn_0 | false   | CREATE TABLE `mb_rule_dtl` (`ID` bigint NOT NULL AUTO_INCREMENT,`RULE_ID` bigint NOT NULL,`TYPE` varchar(3) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`VALUE` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`VALUE2` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`VALUE3` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SORT` int DEFAULT NULL,PRIMARY KEY (`ID`),KEY `IDX_MB_RULE_DTL_RULEID` (`RULE_ID`)) ENGINE=InnoDB AUTO_INCREMENT=1037 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin     |  success| schema1|
      | conn_0 | false   | CREATE TABLE `mb_rule_rights_dtl` (`ID` bigint NOT NULL AUTO_INCREMENT,`RULE_RIGHTS_ID` int DEFAULT NULL,`RIGHTS_NAME` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`RIGHTS_CODE` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SORT` int DEFAULT NULL,PRIMARY KEY (`ID`)) ENGINE=InnoDB AUTO_INCREMENT=1561 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin | success| schema1|
      | conn_0 | false   | CREATE TABLE `mb_rule_rights` (`ID` bigint NOT NULL AUTO_INCREMENT,`RULE_ID` bigint DEFAULT NULL,`CHANNEL` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`OFFER` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,`SORT` int DEFAULT NULL,`IS_ACTIVE_TIME` varchar(3) COLLATE utf8mb4_bin DEFAULT NULL,PRIMARY KEY (`ID`),KEY `IDX_MB_RULE_RIGHTS_RULEID` (`RULE_ID`)) ENGINE=InnoDB AUTO_INCREMENT=1313 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin | success| schema1|
      # main test
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                          | expect      | db      |
      | conn_0 | false   | begin                                                                                                                                        | success     | schema1 |
      | conn_0 | false   | update pm_verify set state = 'S0C', verify_time=now() where id = 5183                                                                        | success     | schema1 |
      | conn_0 | false   | update mb_rule_edit set state = 'S0A', confirm_verify_time=now() where id=770                                                                | success     | schema1 |
      | conn_0 | false   | delete from mb_rule where id=770                                                                                                             | success     | schema1 |
      | conn_0 | false   | delete from mb_rule_dtl where rule_id=770                                                                                                    | success     | schema1 |
      | conn_0 | false   | select id from mb_rule_rights where rule_id =770                                                                                             | success     | schema1 |
      | conn_0 | false   | delete from mb_rule_rights_dtl where RULE_RIGHTS_ID in(1084)                                                                                 | success     | schema1 |
      | conn_0 | false   | delete from mb_rule_rights where id = 1084                                                                                                   | success     | schema1 |
      | conn_0 | false   | select * from mb_rule_edit where id = 770                                                                                                    | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule`(`ID`, `NAME`, `CODE`, `ACTIVE_ID`, `ACTIVE_TYPE`, `START_TIME`, `END_TIME`, `FIRST_START_TIME`, `FIRST_END_TIME`, `IS_NORMAL`, `ACTIVE_TIME_TYPE`, `ACTIVE_TIME_INTF`, `SALE_ID`, `OFFER_START_TIME`, `SUB_RULE`, `RATE_TYPE`, `RATE_LIMIT`, `LIMIT`, `IS_EXPIRE`, `SHOP_CODE`, `STATE`, `FIRST_VERIFY_USER`, `CONFIRM_VERIFY_USER`, `FIRST_VERIFY_TIME`, `CONFIRM_VERIFY_TIME`, `CREATE_TIME`, `UPDATE_TIME`, `CREATE_USER`, `UPDATE_USER`, `PROV_DEPT_ID`) VALUES (770, 'ljj20201110', 'VIP20000770', 421, '1', '2020-12-01 00:00:00', '2021-01-28 23:59:59', '2020-11-04 00:00:00', '2020-12-26 23:59:59', '0', '0', '4G', NULL, '0', '0', '1', 2, 12, '1', '', 'S0A', 1, 1, '2022-04-27 11:47:11', '2022-04-27 14:23:04', '2020-11-10 16:17:21', '2022-04-27 11:45:30', 1, 1, 1)     | success     | schema1 |
      | conn_0 | false   | select * from mb_rule_dtl where rule_id=770                                                                                                  | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule_dtl`(`ID`, `RULE_ID`, `TYPE`, `VALUE`, `VALUE2`, `VALUE3`, `SORT`) VALUES (1031, 770, '1', '1111111aa', NULL, NULL, 1)  | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule_dtl`(`ID`, `RULE_ID`, `TYPE`, `VALUE`, `VALUE2`, `VALUE3`, `SORT`) VALUES (1032, 770, '3', 'limit', NULL, NULL, 1)      | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule_dtl`(`ID`, `RULE_ID`, `TYPE`, `VALUE`, `VALUE2`, `VALUE3`, `SORT`) VALUES (1033, 770, '2', '0', NULL, NULL, NULL)       | success     | schema1 |
      | conn_0 | false   | select * from mb_rule_rights where rule_id=770                                                                                               | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule_rights`(`ID`, `RULE_ID`, `CHANNEL`, `OFFER`, `SORT`, `IS_ACTIVE_TIME`) VALUES (1084, 770, 'abc', '1233', 1, NULL)       | success     | schema1 |
      | conn_0 | false   | select * from mb_rule_rights_dtl where rule_rights_id = 1084                                                                                 | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule_rights_dtl`(`ID`, `RULE_RIGHTS_ID`, `RIGHTS_NAME`, `RIGHTS_CODE`, `SORT`) VALUES (1264, 1084, '123', '123', 0)          | success     | schema1 |
      | conn_0 | false   | INSERT INTO `mb_rule_rights_dtl`(`ID`, `RULE_RIGHTS_ID`, `RIGHTS_NAME`, `RIGHTS_CODE`, `SORT`) VALUES (1265, 1084, '123', '22', 1)           | success     | schema1 |
      | conn_0 | false   | commit                                                                                                                                       | success     | schema1 |

    Given execute admin cmd "drop database @@shardingnode='dn_$1-128'" success

    # recover mysql connection
    Given execute sql in "mysql-master1" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=151   | success     |
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=151   | success     |
    Given execute sql in "mysql-master3" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=151   | success     |
    Given execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                              | expect      |
      | conn_0 | true    | set GLOBAL max_connections=151   | success     |


    @skip
      ###3.21.06修复，不确定是否合到3.21.02
  Scenario: connection distinguished with two ways   #2
    # backend connection naming changed liked:  shardingNode-flag-{schema.table},
    # flag is a variable with boolean
    # true: connection distinguished with shardingNode && schema.table
    # false: connection distinguished only with shardingNode, schema.table will not participate in distinguished connections
    # only sql contains duplicate nodes, flag is true

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
          <shardingTable name="table1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
          <shardingTable name="table2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="code"/>
          <globalTable name="pm_rule_edit"  shardingNode="dn1,dn2"/>
          <globalTable name="pm_rule"  shardingNode="dn1,dn2"/>
        </schema>
      """
    Given execute admin cmd "reload @@config_all" success
    # dble.log not easy and not necessary to verify, more details could find in dble.log

    # shardingNode-true-{schema.table}【complex query】 && shardingNode-false-{schema.table}【delete from table2】
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect      | db      |
      | conn_0 | False   | drop table if exists table1                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists table2                                      | success     | schema1 |
      | conn_0 | False   | create table table1(id int)                                      | success     | schema1 |
      | conn_0 | False   | create table table2(id int, code int)                            | success     | schema1 |
      | conn_0 | False   | insert  into table1 values(1),(2),(3)                            | success     | schema1 |
      | conn_0 | False   | insert into  table2 values(1,1),(2,2),(3,3)                      | success     | schema1 |
      | conn_0 | False   | begin                                                            | success     | schema1 |
      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(3)} | schema1 |
      | conn_0 | False   | delete from table2                                               | success     | schema1 |
      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |
      | conn_0 | False   | commit                                                           | success     | schema1 |
      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |

    # shardingNode-false-{schema.table}
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect      | db      |
      | conn_0 | False   | drop table if exists pm_rule                                     | success     | schema1 |
      | conn_0 | False   | drop table if exists pm_rule_edit                                | success     | schema1 |
      | conn_0 | False   | create table pm_rule(id int, state varchar(20))                  | success     | schema1 |
      | conn_0 | False   | create table pm_rule_edit(id int, state varchar(20))             | success     | schema1 |
      | conn_0 | False   | insert  into pm_rule_edit values(449, 'SOA')                     | success     | schema1 |
      | conn_0 | False   | begin                                                            | success     | schema1 |
      | conn_0 | False   | update pm_rule_edit set state='S0X' where id=449                 | success     | schema1 |
      | conn_0 | False   | delete from pm_rule                                              | success     | schema1 |
      | conn_0 | False   | insert into pm_rule select * from pm_rule_edit where id=449      | success     | schema1 |
      | conn_0 | False   | select state from pm_rule where id = 449                         | has{(('S0X',),)}     | schema1 |
      | conn_0 | False   | select state from pm_rule_edit where id = 449                    | has{(('S0X',),)}     | schema1 |
      | conn_0 | False   | commit                                                           | success     | schema1 |
      | conn_0 | False   | select state from pm_rule where id = 449                         | has{(('S0X',),)}     | schema1 |
      | conn_0 | False   | select state from pm_rule_edit where id = 449                    | has{(('S0X',),)}     | schema1 |

# issue: http://10.186.18.11/jira/browse/DBLE0REQ-1757
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                              | expect      | db      |
#      | conn_0 | False   | insert into  table2 values(1,1),(2,2),(3,3)                      | success     | schema1 |
#      | conn_0 | False   | begin                                                            | success     | schema1 |
#      | conn_0 | False   | delete from table2                                               | success     | schema1 |
#      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |
#      | conn_0 | False   | commit                                                           | success     | schema1 |
#      | conn_0 | False   | select * from table1 inner join table2 on table1.id=table2.id    | length{(0)} | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect      | db      |
      | conn_0 | False   | drop table if exists table1                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists table2                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists pm_rule                                     | success     | schema1 |
      | conn_0 | False   | drop table if exists pm_rule_edit                                | success     | schema1 |

