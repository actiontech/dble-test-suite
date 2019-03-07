# Created by maofei at 2019/3/7
Feature: Do not reload all metadata when reload config/config_all if no need

  Scenario: Do not reload all metadata when reload config if no need #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                  | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard}    | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db2 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db2 |
     Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db2 |
    #新增表,仅对新增表reload metadata
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    <table name="test1" dataNode="dn1,dn3" rule="hash-two"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test1}                  | schema1 |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    #删除表+表的type属性发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" type="global"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                        | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard_column}  | schema1 |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test1}              | schema1 |
    #表的datanode发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    #新增schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <table name="test2" dataNode="dn2,dn4" rule="hash-two"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
    <property name="password">111111</property>
    <property name="schemas">schema1,schema2</property>
    </user>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema2'    | hasStr{test2}  | schema1 |
    #删除schema
     Given delete the following xml segment
      |file         | parent           | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
    <property name="password">111111</property>
    <property name="schemas">schema1</property>
    </user>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                          | expect            | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata      | hasNoStr{test2}  | schema1 |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                           | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test3 | success  | db1 |
      | test | 111111 | conn_0 | True    | create table test3(id int) | success  | db1 |
    #schema的默认datanode发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn2">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                          | expect          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata     | hasStr{test3}  | schema1 |
    #恢复被污染的环境
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db2 |
    Then execute sql in "mysql-master2"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test3                                            | success  | db1 |

  Scenario: Do not reload all metadata when reload config_all if no need #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" rule="hash-two"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                  | db      |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard}    | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db2 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db2 |
    #新增表
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" rule="hash-two"/>
    <table name="test1" dataNode="dn1,dn3" rule="hash-two"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test1}                  | schema1 |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    #删除表+表的type属性变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" type="global"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                         | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard_column}   | schema1 |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test1}              | schema1 |
    #表的物理节点发生变更
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                     | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists da1                          | success  | db1 |
      | test | 111111 | conn_0 | True    | create database da1                                   | success  | db1 |
      | test | 111111 | conn_0 | True    | drop database if exists da2                          | success  | db1 |
      | test | 111111 | conn_0 | True    | create database da2                                   | success  | db1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="da1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="da2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    """
    Then execute admin cmd "reload @@config_all"
    #表的datasource发生变更
    Then execute sql in "mysql-master3"
      | user | passwd | conn   | toClose | sql                                                       | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists db1                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db1                                     | success  |     |
      | test | 111111 | conn_0 | True    | drop database if exists db2                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db2                                     | success  |     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.1:3306" user="test">
    </writeHost>
    </dataHost>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    #新增schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <table name="test2" dataNode="dn1,dn3" rule="hash-two"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
    <property name="password">111111</property>
    <property name="schemas">schema1,schema2</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect            | db      |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema2'    | hasStr{test2}    | schema1 |
    #删除schema
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <user name="test">
    <property name="password">111111</property>
    <property name="schemas">schema1</property>
    </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                          | expect            | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata      | hasNoStr{test2} | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                   | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists db3        | success  |     |
      | test | 111111 | conn_0 | True    | create database db3                 | success  |     |
      | test | 111111 | conn_0 | True    | create table test3(id int)         | success  | db3 |
    #schema 的默认datanode属性发生变更
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                          | expect            | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata      | hasStr{test3}    | schema1 |

    #schema的datanode对应的物理节点发生变更
     Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                              | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists da3                   | success  |     |
      | test | 111111 | conn_0 | True    | create database da3                            | success  |     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="da3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    """

    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                          | expect            | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata     | hasNoStr{test3}  | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    """

    Then execute admin cmd "reload @@config_all"
    #schema对应的Datanode对应的DataSource发生变更
    Then execute sql in "mysql-master3"
      | user | passwd | conn   | toClose | sql                                                       | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists db3                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db3                                     | success  |     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
    <table name="test_shard" dataNode="dn2,dn4" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.1:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                          | expect            | db      |
      | root  | 111111 | conn_0 | True    | check full @@metadata     | hasNoStr{test3}  | schema1 |
    #恢复被污染的环境
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                       | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard       | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard       | success  | db2 |
      | test | 111111 | conn_0 | True    | drop table if exists test3             | success  | db3 |

  Scenario: "reload @@config_all " contains parameter -r (reload @@config_all -r),reload config will reload all tables metadata #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" rule="hash-two"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                  | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard}    | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db2 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db2 |
    Then execute admin cmd "reload @@config_all -r"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                        | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard_column}  | schema1 |
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | alter table test_shard add test_shard_add int                       | success  | db1 |
      | test | 111111 | conn_0 | True    | alter table test_shard add test_shard_add int                       | success  | db2 |
    Then execute admin cmd "reload @@config_all -rf"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                     | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard_add}  | schema1 |
    Then execute sql in "mysql-master3"
      | user | passwd | conn   | toClose | sql                                                       | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists db1                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db1                                     | success  |     |
      | test | 111111 | conn_0 | True    | drop database if exists db2                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db2                                     | success  |     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" type="global"/>
    </schema>
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.1:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -rs"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                          | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasNoStr{test_shard_column}  | schema1 |
    #清环境
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                    | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                    | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                    | success  | db2 |

  Scenario:  "reload @@config_all " contains parameter -s and not contains -r ,the datahost changes will not treat as table/schema changes #4
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                                      | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                      | success  | db2 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,test_shard_column char(20))       | success  | db2 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
    <table name="test_shard" dataNode="dn1,dn3" rule="hash-two"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all -s"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                        | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard_column}  | schema1 |
    Then execute sql in "mysql-master3"
      | user | passwd | conn   | toClose | sql                                                       | expect   | db  |
      | test | 111111 | conn_0 | True    | drop database if exists db1                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db1                                     | success  |     |
      | test | 111111 | conn_0 | True    | drop database if exists db2                            | success  |     |
      | test | 111111 | conn_0 | True    | create database db2                                     | success  |     |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.1:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -s"
    Then execute sql in "dble-1" in "admin" mode
      | user  | passwd | conn   | toClose | sql                                                   | expect                        | db     |
      | root  | 111111 | conn_0 | True    | check full @@metadata where schema='schema1'    | hasStr{test_shard_column}  | schema1 |
    #清环境
    Then execute sql in "mysql-master1"
      | user | passwd | conn   | toClose | sql                                                    | expect   | db  |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                    | success  | db1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                    | success  | db2 |
