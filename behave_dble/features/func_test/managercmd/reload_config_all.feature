Feature: reload @@config_all base test, not including all cases in testlink
  reload @@config_all, which do diff and reserve in use backend conn
  reload @@config_all -f, which do diff and kill in use backend conn
  reload @@config_all -r which don't do diff, rebuild backend conn, skip in use backend conn
  reload @@config_all -s,  skip test new connections

  Background: prepare for reload @@config_all -?
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn1">
    <table name="test_shard" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>
    <dataNode name="dn1" dataHost="host1" database="db1"/>
    <dataNode name="dn2" dataHost="host1" database="db2"/>
    <dataNode name="dn3" dataHost="host1" database="db3"/>
    <dataNode name="dn4" dataHost="host1" database="db4"/>
    <dataHost balance="0" maxCon="1000" minCon="5" name="host1" switchType="2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
    </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
    <property name="backendProcessorExecutor">4</property>
    </system>
    """
    Given Restart dble in "dble-1" success

  @CRITICAL
  Scenario: reload @@config_all, eg:no writehost change, reload @@config_all does not rebuild backend connection pool #1
    Then get resultset of admin cmd "show @@backend" named "backend_rs_A"
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_B"
    Then check resultsets "backend_rs_A" and "backend_rs_B" are same in following columns
      |column               | column_index |
      |processor            | 0            |
      |ID                   | 1            |
      |MYSQLID              | 2            |
      |HOST                 | 3            |
      |PORT                 | 4            |
      |LOACL_TCP_PORT       | 5            |
      |CLOSED               | 9            |
      |SYS_VARIABLES        | 18           |
      |USER_VARIABLES       | 19           |

  @BLOCKER
  Scenario: reload @@config_all, eg:remove old writeHost and add new, drop backend connection pool for old writeHost, create new connection pool, backend conn in use will not be dropped even the writehost was removed, reload @@config_all -f, reload @@config_all -r, reload @@config_all -s #2

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="5" name="host1" switchType="2" slaveThreshold="100">
        <heartbeat>show slave status</heartbeat>
        <writeHost host="hostW1" url="172.100.9.6:3306" password="111111" user="test"/>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_C"
    Then check resultset "backend_rs_C" has not lines with following column values
      | HOST-3      | PORT-4       |
      | 3306        | 172.100.9.5  |
    Then check resultset "backend_rs_C" has lines with following column values
      | PORT-4    | HOST-3      |
      | 3306      | 172.100.9.6 |

    #reload @@config_all, eg: backend conn in use will not be dropped even the writehost was removed, reload @@config_all -f, reload @@config_all -r, reload @@config_all -s
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                                   | expect     | db     |
      | test | 111111 | conn_0 | False    | drop table if exists test_shard       | success    | schema1 |
      | test | 111111 | conn_0 | False    | create table test_shard(id int)       | success    | schema1 |
      | test | 111111 | conn_0 | False    | begin                                 | success    | schema1 |
      | test | 111111 | conn_0 | False    | insert into test_shard values(1),(2),(3),(4)  | success    | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="5" name="host1" switchType="2" slaveThreshold="100">
    <heartbeat>show slave status</heartbeat>
    <writeHost host="hostM1" url="172.100.9.5:3306" password="111111" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_D"
    Then check resultset "backend_rs_D" has lines with following column values
      | PORT-4      | HOST-3      |
      | 3306        | 172.100.9.6 |
    #2 reload @@config_all -f, kill in use backend conn, do diff
    Then execute admin cmd "reload @@config_all -f"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_E"
    Then check resultset "backend_rs_E" has not lines with following column values
      | HOST-3      | PORT-4       |
      | 3306        | 172.100.9.6  |
    Then check resultsets "backend_rs_D" including resultset "backend_rs_E" in following columns
      |column               | column_index |
      |processor            | 0            |
      |ID                   | 1            |
      |MYSQLID              | 2            |
      |HOST                 | 3            |
      |PORT                 | 4            |
      |LOACL_TCP_PORT       | 5            |
      |CLOSED               | 9            |
      |SYS_VARIABLES        | 18           |
      |USER_VARIABLES       | 19           |
    #3 reload @@config_all -r, donot do diff, rebuild backend conn, skip in use backend conn
    Then execute admin cmd "reload @@config_all -r"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_F"
    Then check resultsets "backend_rs_F" does not including resultset "backend_rs_E" in following columns
      |column            | column_index |
      |ID                | 1     |
      |MYSQLID           | 2     |
      |HOST              | 3     |
      |PORT              | 4     |

    #4 reload @@config_all -s,  skip test new connections
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="1">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -f -r"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_G"
    Given stop mysql in host "mysql-master2"
    Then execute admin cmd "reload @@config_all -s"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_H"
    Then check resultset "backend_rs_H" has not lines with following column values
      | HOST-3      | PORT-4       |
      | 3306        | 172.100.9.6  |
    Then check resultsets "backend_rs_G" including resultset "backend_rs_H" in following columns
      |column               | column_index |
      |processor            | 0            |
      |ID                   | 1            |
      |MYSQLID              | 2            |
      |HOST                 | 3            |
      |PORT                 | 4            |
      |LOACL_TCP_PORT       | 5            |
      |CLOSED               | 9            |
      |SYS_VARIABLES        | 18           |
      |USER_VARIABLES       | 19           |
    Given start mysql in host "mysql-master2"
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose  | sql                            | expect     | db     |
      | test | 111111 | conn_1 | False    | drop table if exists test_shard       | success    | schema1 |
      | test | 111111 | conn_1 | False    | create table test_shard(id int)       | success    | schema1 |
      | test | 111111 | conn_1 | False    | begin                                 | success    | schema1 |
      | test | 111111 | conn_1 | False    | insert into test_shard values(1),(2),(3),(4)  | success    | schema1 |
    Then execute admin cmd "reload @@config_all -r -f -s"
    Then get resultset of admin cmd "show @@backend" named "backend_rs_I"
    Then check resultsets "backend_rs_I" does not including resultset "backend_rs_H" in following columns
      |column            | column_index |
      |ID                | 1     |
      |MYSQLID           | 2     |
      |HOST              | 3     |
      |PORT              | 4     |

  Scenario: Do not reload all metadata when reload config if no need #3
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

  Scenario: Do not reload all metadata when reload config_all if no need #4
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

  Scenario: "reload @@config_all " contains parameter -r (reload @@config_all -r),reload config will reload all tables metadata #5
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

  Scenario:  "reload @@config_all " contains parameter -s and not contains -r ,the datahost changes will not treat as table/schema changes #6
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
