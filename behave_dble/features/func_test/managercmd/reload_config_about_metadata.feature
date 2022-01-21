# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by maofei at 2019/3/7
Feature: Do not reload all metadata when reload config/config_all if no need

  Scenario: Do not reload all metadata when reload config if no need #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                             | expect             |
      | check full @@metadata where schema='schema1'    | hasStr{test_shard} |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                        | expect   | db  |
      | conn_0 | False   | drop table if exists test_shard                            | success  | db1 |
      | conn_0 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db1 |
      | conn_1 | False   | drop table if exists test_shard                            | success  | db2 |
      | conn_1 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db2 |
     Then execute sql in "mysql-master2"
      | sql                             | db  |
      | drop table if exists test_shard | db1 |
      | drop table if exists test_shard | db2 |
    #新增表,仅对新增表reload metadata
    Then execute sql in "dble-1" in "admin" mode
      | sql                                             | expect                       |
      | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    <shardingTable name="test1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                             | expect                       |
      | conn_0 | False   | check full @@metadata where schema='schema1'    | hasStr{test1}                |
      | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  |
    #删除表+表的type属性发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                             | expect                     |
      | conn_0 | False   | check full @@metadata where schema='schema1'    | hasStr{test_shard_column}  |
      | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test1}            |
    #表的shardingNode发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                       |
      | check full @@metadata where schema='schema1' | hasNoStr{test_shard_column}  |
    #新增schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <shardingTable name="test2" shardingNode="dn2,dn4" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect         |
      | check full @@metadata where schema='schema2' | hasStr{test2}  |
    #删除schema
     Given delete the following xml segment
      |file         | parent         | child             |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | sql                        | expect           |
      | check full @@metadata      | hasNoStr{test2}  |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                        | expect   | db  |
      | conn_0 | False   | drop table if exists test3 | success  | db1 |
      | conn_0 | True    | create table test3(id int) | success  | db1 |
    #schema的默认shardingNode发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn2">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | sql                   | expect         |
      | check full @@metadata | hasStr{test3}  |
    #恢复被污染的环境
    Then execute sql in "mysql-master1"
      | sql                             | db  |
      | drop table if exists test_shard | db1 |
      | drop table if exists test_shard | db2 |
    Then execute sql in "mysql-master2"
      | sql                        | expect   | db  |
      | drop table if exists test3 | success  | db1 |

  Scenario: Do not reload all metadata when reload config_all if no need #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <shardingTable name="test_shard" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                |
      | check full @@metadata where schema='schema1' | hasStr{test_shard}    |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                        | expect   | db  |
      | conn_0 | False   | drop table if exists test_shard                            | success  | db1 |
      | conn_0 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db1 |
      | conn_1 | False   | drop table if exists test_shard                            | success  | db2 |
      | conn_1 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db2 |
    #新增表
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <shardingTable name="test_shard" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    <shardingTable name="test1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                         | expect                       |
      | conn_0 | False   | check full @@metadata where schema='schema1'| hasStr{test1}                |
      | conn_0 | True    | check full @@metadata where schema='schema1'| hasNoStr{test_shard_column}  |
    #删除表+表的type属性变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn1,dn3"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                         | expect                    |
      | conn_0 | False   | check full @@metadata where schema='schema1'| hasStr{test_shard_column} |
      | conn_0 | True    | check full @@metadata where schema='schema1'| hasNoStr{test1}           |
    #表的物理节点发生变更
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                         | expect   | db  |
      | conn_0 | False   | drop database if exists da1 | success  | db1 |
      | conn_0 | False   | create database da1         | success  | db1 |
      | conn_0 | False   | drop database if exists da2 | success  | db1 |
      | conn_0 | True    | create database da2         | success  | db1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn1,dn3"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="da1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="da2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                       |
      | check full @@metadata where schema='schema1' | hasNoStr{test_shard_column}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn1,dn3"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all"
    #表的dbInstance发生变更
    Then execute sql in "mysql-master3"
      | conn   | toClose | sql                          |
      | conn_0 | False   | drop database if exists db1  |
      | conn_0 | False   | create database db1          |
      | conn_0 | False   | drop database if exists db2  |
      | conn_0 | True    | create database db2          |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn1,dn3"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                             | expect                       |
      | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                             | expect                       |
      | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  |
    #新增schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <shardingTable name="test2" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                             | expect        |
      | check full @@metadata where schema='schema2'    | hasStr{test2} |
    #删除schema
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                   | expect          |
      | check full @@metadata | hasNoStr{test2} |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                         | expect   | db  |
      | conn_0 | False   | drop database if exists db3 | success  |     |
      | conn_0 | True    | create database db3         | success  |     |
      | conn_1 | True    | create table test3(id int)  | success  | db3 |
    #schema 的默认shardingNode属性发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                        | expect           |
      | check full @@metadata      | hasStr{test3}    |

    #sharding的shardingNode对应的物理节点发生变更
     Then execute sql in "mysql-master1"
      | conn   | toClose | sql                         |
      | conn_0 | False   | drop database if exists da3 |
      | conn_0 | True    | create database da3         |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="da3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                   | expect           |
      | check full @@metadata | hasNoStr{test3}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """

    Then execute admin cmd "reload @@config_all"
    #sharding对应的shardingNode对应的dbInstance发生变更
    Then execute sql in "mysql-master3"
      | conn   | toClose | sql                         | expect   |
      | conn_0 | False   | drop database if exists db3 | success  |
      | conn_0 | True    | create database db3         | success  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
    <globalTable name="test_shard" shardingNode="dn2,dn4"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                   | expect           |
      | check full @@metadata | hasNoStr{test3}  |
    #恢复被污染的环境
    Then execute sql in "mysql-master1"
      | sql                              | expect   | db  |
      | drop table if exists test_shard  | success  | db1 |
      | drop table if exists test_shard  | success  | db2 |
      | drop table if exists test3       | success  | db3 |

  Scenario: "reload @@config_all " contains parameter -r (reload @@config_all -r),reload config will reload all tables metadata #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <shardingTable name="test_shard" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                           | expect              |
      | check full @@metadata where schema='schema1'  | hasStr{test_shard}  |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                        | expect   | db  |
      | conn_0 | False   | drop table if exists test_shard                            | success  | db1 |
      | conn_0 | False   | create table test_shard(id int,test_shard_column char(20)) | success  | db1 |
      | conn_1 | False   | drop table if exists test_shard                            | success  | db2 |
      | conn_1 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db2 |
    Then execute admin cmd "reload @@config_all -r"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                     |
      | check full @@metadata where schema='schema1' | hasStr{test_shard_column}  |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                           | expect   | db  |
      | conn_0 | False   | alter table test_shard add test_shard_add int | success  | db1 |
      | conn_1 | True    | alter table test_shard add test_shard_add int | success  | db2 |
    Then execute admin cmd "reload @@config_all -rf"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                             | expect                  |
      | check full @@metadata where schema='schema1'    | hasStr{test_shard_add}  |
    Then execute sql in "mysql-master3"
      | conn   | toClose | sql                         | expect   |
      | conn_0 | False   | drop database if exists db1 | success  |
      | conn_0 | False   | create database db1         | success  |
      | conn_0 | False   | drop database if exists db2 | success  |
      | conn_0 | True    | create database db2         | success  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <globalTable name="test_shard" shardingNode="dn1,dn3"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -rs"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                       |
      | check full @@metadata where schema='schema1' | hasNoStr{test_shard_column}  |
    #清环境
    Then execute sql in "mysql-master1"
      | sql                             | expect   | db  |
      | drop table if exists test_shard | success  | db1 |
      | drop table if exists test_shard | success  | db2 |

  Scenario:  "reload @@config_all " contains parameter -s and not contains -r ,the dbGroup changes will not treat as table/schema changes #4
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                        | expect   | db  |
      | conn_0 | False   | drop table if exists test_shard                            | success  | db1 |
      | conn_0 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db1 |
      | conn_1 | False   | drop table if exists test_shard                            | success  | db2 |
      | conn_1 | True    | create table test_shard(id int,test_shard_column char(20)) | success  | db2 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <shardingTable name="test_shard" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all -s"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                     |
      | check full @@metadata where schema='schema1' | hasStr{test_shard_column} |
    Then execute sql in "mysql-master3"
      | conn   | toClose | sql                         |
      | conn_0 | False   | drop database if exists db1 |
      | conn_0 | False   | create database db1         |
      | conn_0 | False   | drop database if exists db2 |
      | conn_0 | True    | create database db2         |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -s"
    Then execute sql in "dble-1" in "admin" mode
      | sql                                          | expect                     |
      | check full @@metadata where schema='schema1' | hasStr{test_shard_column}  |
    #清环境
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                              | expect   | db  |
      | conn_0 | False   | drop table if exists test_shard  | success  | db1 |
      | conn_0 | True    | drop table if exists test_shard  | success  | db2 |
