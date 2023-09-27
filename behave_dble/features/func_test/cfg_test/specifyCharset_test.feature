# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2023/09/21

Feature: specifyCharset basic test, from DBLE0REQ-1411

  Scenario: specifyCharset="true",语句需要用iso-8859-1转码，sql执行成功且结果符合预期 #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" specifyCharset="true"/>
        <singleTable name="single1" shardingNode="dn5" specifyCharset= "true"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" specifyCharset="true">
            <childTable name="tb_child1" joinColumn="id" parentColumn="id" specifyCharset="true">
                <childTable name="tb_grandson1" joinColumn="id" parentColumn="id" specifyCharset= "true"/>
            </childTable>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |charset|
      | conn_1 | False   | drop table if exists test                              | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists single1                           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists tb_child1                         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists tb_grandson1                      | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists vertical1                         | success                    | schema1 |utf8mb4|

      | conn_1 | False   | create table test(id int, col1 binary(100) ,col2 bigint(20))              | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table single1(id int, col1 binary(100) ,col2 bigint(20))           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table sharding_4_t1(id int, col1 binary(100) ,col2 bigint(20))     | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table tb_child1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table tb_grandson1(id int, col1 binary(100) ,col2 bigint(20))      | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table vertical1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |utf8mb4|
      # python3 不指定编码会报错：ordinal not in range(256)，所以指定连接的编码为utf8mb4
      | conn_1 | False   | insert into test values (1,'▒▒ɍ▒▒>▒r',12345)                              | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into single1 values (1,'▒▒ɍ▒▒>▒r',12345)                           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into schema1.sharding_4_t1 values (1,'▒▒ɍ▒▒>▒r',12345)             | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into tb_child1 values (1,'▒▒ɍ▒▒>▒r',12345)                         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into tb_grandson1 values (1,'▒▒ɍ▒▒>▒r',12345)                      | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into vertical1 values (1,'▒▒ɍ▒▒>▒r',12345)                         | success                    | schema1 |utf8mb4|

      | conn_1 | False   | select hex(col1) from test             | has{(('E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from single1          | has{(('E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from sharding_4_t1    | has{(('E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from tb_child1        | has{(('E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from tb_grandson1     | has{(('E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | True    | select hex(col1) from vertical1        | has{(('E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|

  Scenario: specifyCharset="true"，语句需要用iso-8859-1转码，sql执行成功但结果不符合预期  #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" specifyCharset="true"/>
        <singleTable name="single1" shardingNode="dn5" specifyCharset= "true"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" specifyCharset="true">
            <childTable name="tb_child1" joinColumn="id" parentColumn="id" specifyCharset="true">
                <childTable name="tb_grandson1" joinColumn="id" parentColumn="id" specifyCharset= "true"/>
            </childTable>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | drop table if exists test                              | success                    | schema1 |
      | conn_1 | False   | drop table if exists single1                           | success                    | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_1 | False   | drop table if exists tb_child1                         | success                    | schema1 |
      | conn_1 | False   | drop table if exists tb_grandson1                      | success                    | schema1 |
      | conn_1 | False   | drop table if exists vertical1                         | success                    | schema1 |

      | conn_1 | False   | create table test(id int, col1 binary(100) ,col2 bigint(20))              | success                    | schema1 |
      | conn_1 | False   | create table single1(id int, col1 binary(100) ,col2 bigint(20))           | success                    | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int, col1 binary(100) ,col2 bigint(20))     | success                    | schema1 |
      | conn_1 | False   | create table tb_child1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |
      | conn_1 | False   | create table tb_grandson1(id int, col1 binary(100) ,col2 bigint(20))      | success                    | schema1 |
      | conn_1 | False   | create table vertical1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |

      | conn_1 | False   | insert into test values (2,'A¼µÙE®¿÷ÐÞå',2345)                              | success                    | schema1 |
      | conn_1 | False   | insert into single1 values (2,'A¼µÙE®¿÷ÐÞå',23456)                           | success                    | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (2,'A¼µÙE®¿÷ÐÞå',23456)                     | success                    | schema1 |
      | conn_1 | False   | insert into tb_child1 values (2,'A¼µÙE®¿÷ÐÞå',23456)                         | success                    | schema1 |
      | conn_1 | False   | insert into tb_grandson1 values (2,'A¼µÙE®¿÷ÐÞå',23456)                      | success                    | schema1 |
      | conn_1 | False   | insert into vertical1 values (2,'A¼µÙE®¿÷ÐÞå',23456)                         | success                    | schema1 |
      # dble接收到的语句的16进制为：41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A5
      | conn_1 | False   | select hex(col1) from test             | has{(('41BCB5D945AEBFF7D0DEE50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from single1          | has{(('41BCB5D945AEBFF7D0DEE50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from sharding_4_t1    | has{(('41BCB5D945AEBFF7D0DEE50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from tb_child1        | has{(('41BCB5D945AEBFF7D0DEE50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from tb_grandson1     | has{(('41BCB5D945AEBFF7D0DEE50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | True    | select hex(col1) from vertical1        | has{(('41BCB5D945AEBFF7D0DEE50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |

  Scenario: specifyCharset="true"，byte数组转为string与string转换为byte数组，2byte数组一致无需用iso-8859-1转码，sql执行成功且结果符合预期  #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" specifyCharset="true"/>
        <singleTable name="single1" shardingNode="dn5" specifyCharset= "true"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" specifyCharset="true">
            <childTable name="tb_child1" joinColumn="id" parentColumn="id" specifyCharset="true">
                <childTable name="tb_grandson1" joinColumn="id" parentColumn="id" specifyCharset= "true"/>
            </childTable>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | drop table if exists test                              | success                    | schema1 |
      | conn_1 | False   | drop table if exists single1                           | success                    | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_1 | False   | drop table if exists tb_child1                         | success                    | schema1 |
      | conn_1 | False   | drop table if exists tb_grandson1                      | success                    | schema1 |
      | conn_1 | False   | drop table if exists vertical1                         | success                    | schema1 |

      | conn_1 | False   | create table test(id int, col1 binary(100) ,col2 bigint(20))              | success                    | schema1 |
      | conn_1 | False   | create table single1(id int, col1 binary(100) ,col2 bigint(20))           | success                    | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int, col1 binary(100) ,col2 bigint(20))     | success                    | schema1 |
      | conn_1 | False   | create table tb_child1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |
      | conn_1 | False   | create table tb_grandson1(id int, col1 binary(100) ,col2 bigint(20))      | success                    | schema1 |
      | conn_1 | False   | create table vertical1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |

      | conn_1 | False   | insert into test values (2,'ABCdef123',11111)                              | success                    | schema1 |
      | conn_1 | False   | insert into single1 values (2,'ABCdef123',11111)                           | success                    | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (2,'ABCdef123',11111)                     | success                    | schema1 |
      | conn_1 | False   | insert into tb_child1 values (2,'ABCdef123',11111)                         | success                    | schema1 |
      | conn_1 | False   | insert into tb_grandson1 values (2,'ABCdef123',11111)                      | success                    | schema1 |
      | conn_1 | False   | insert into vertical1 values (2,'ABCdef123',11111)                         | success                    | schema1 |

      | conn_1 | False   | select hex(col1) from test             | has{(('41424364656631323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from single1          | has{(('41424364656631323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from sharding_4_t1    | has{(('41424364656631323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from tb_child1        | has{(('41424364656631323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | False   | select hex(col1) from tb_grandson1     | has{(('41424364656631323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |
      | conn_1 | True    | select hex(col1) from vertical1        | has{(('41424364656631323300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |

  Scenario: specifyCharset="true"，分片列也被iso-8859-1编码，分片列和server编码一致，能正确路由且结果正确  #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-string-into-two" shardingColumn="id" specifyCharset="true">
            <childTable name="tb_child2" joinColumn="id" parentColumn="id" specifyCharset="true">
                <childTable name="tb_grandson2" joinColumn="id" parentColumn="id" specifyCharset= "true"/>
            </childTable>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |charset|
      | conn_1 | False   | drop table if exists sharding_2_t1                     | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists tb_child2                         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists tb_grandson2                      | success                    | schema1 |utf8mb4|

      | conn_1 | False   | create table sharding_2_t1(id varchar(64), col1 binary(100) ,col2 bigint(20)) DEFAULT CHARSET=utf8mb4     | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table tb_child2(id varchar(64), col1 binary(100) ,col2 bigint(20)) DEFAULT CHARSET=utf8mb4         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table tb_grandson2(id varchar(64), col1 binary(100) ,col2 bigint(20)) DEFAULT CHARSET=utf8mb4      | success                    | schema1 |utf8mb4|

      | conn_1 | False   | explain insert into sharding_2_t1 values ('😄','A¼µÙE®¿÷ÐÞå',34567)                | hasStr{dn2}                    | schema1 |utf8mb4|
      | conn_1 | False   | explain insert into tb_child2 values ('你好','▒▒ɍ▒▒>▒r',34567)                      | hasStr{dn2}                    | schema1 |utf8mb4|
      | conn_1 | False   | explain insert into tb_grandson2 values ('上海闵行','E@©§õF¾ä#$¶¦',34567)            | hasStr{dn1}                    | schema1 |utf8mb4|

      | conn_1 | False   | insert into sharding_2_t1 values ('😄','A¼µÙE®¿÷ÐÞå',34567)          | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into tb_child2 values ('你好','▒▒ɍ▒▒>▒r',34567)            | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into tb_grandson2 values ('上海闵行','E@©§õF¾ä#$¶¦',34567)      | success                    | schema1 |utf8mb4|

      | conn_1 | False   | select id,hex(col1),col2 from sharding_2_t1    | has{(('😄','41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',34567),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select id,hex(col1),col2 from tb_child2        | has{(('你好','E29692E29692C98DE29692E296923EE2969272000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',34567),)}  | schema1 |utf8mb4|
      | conn_1 | True    | select id,hex(col1),col2 from tb_grandson2     | has{(('上海闵行','4540C2A9C2A7C3B546C2BEC3A42324C2B6C2A6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',34567),)}  | schema1 |utf8mb4|

  Scenario: specifyCharset="false",不使用iso-8859-1进行转码，sql执行成功且结果符合预期  #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" specifyCharset="false"/>
        <singleTable name="single1" shardingNode="dn5" specifyCharset= "false"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" specifyCharset="false">
            <childTable name="tb_child1" joinColumn="id" parentColumn="id" specifyCharset="false">
                <childTable name="tb_grandson1" joinColumn="id" parentColumn="id" specifyCharset= "false"/>
            </childTable>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |charset|
      | conn_1 | False   | drop table if exists test                              | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists single1                           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists tb_child1                         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists tb_grandson1                      | success                    | schema1 |utf8mb4|
      | conn_1 | False   | drop table if exists vertical1                         | success                    | schema1 |utf8mb4|

      | conn_1 | False   | create table test(id int, col1 binary(100) ,col2 bigint(20))              | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table single1(id int, col1 binary(100) ,col2 bigint(20))           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table sharding_4_t1(id int, col1 binary(100) ,col2 bigint(20))     | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table tb_child1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table tb_grandson1(id int, col1 binary(100) ,col2 bigint(20))      | success                    | schema1 |utf8mb4|
      | conn_1 | False   | create table vertical1(id int, col1 binary(100) ,col2 bigint(20))         | success                    | schema1 |utf8mb4|

      | conn_1 | False   | insert into test values (1,'A¼µÙE®¿÷ÐÞå',12345)                           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into single1 values (1,'A¼µÙE®¿÷ÐÞå',12345)                           | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into schema1.sharding_4_t1 values (1,'A¼µÙE®¿÷ÐÞå',12345)             | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into tb_child1 values (1,'A¼µÙE®¿÷ÐÞå',12345)                         | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into tb_grandson1 values (1,'A¼µÙE®¿÷ÐÞå',12345)                      | success                    | schema1 |utf8mb4|
      | conn_1 | False   | insert into vertical1 values (1,'A¼µÙE®¿÷ÐÞå',12345)                         | success                    | schema1 |utf8mb4|

      | conn_1 | False   | select hex(col1) from test             | has{(('41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from single1          | has{(('41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from sharding_4_t1    | has{(('41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from tb_child1        | has{(('41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | False   | select hex(col1) from tb_grandson1     | has{(('41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
      | conn_1 | True    | select hex(col1) from vertical1        | has{(('41C2BCC2B5C39945C2AEC2BFC3B7C390C39EC3A50000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',),)}  | schema1 |utf8mb4|
