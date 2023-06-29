# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/7/28

# DBLE0REQ-225
Feature: schema.xml support fake host

  @init_dble_meta
  Scenario: The managerPort/serverPort does not use the default value, fake host use the default managerPort/serverPort #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="managerPort">9011</property>
        <property name="serverPort">8011</property>
    </system>
    """
    Then restart dble in "dble-1" success use manager port "9011"
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" password="111111" url="127.0.0.1:8066" user="test">
        </writeHost>
    </dataHost>
    <dataHost balance="1" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="localhost:9066" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is Can't get variables from any data host, because all of data host can't connect to MySQL correctly
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10" >
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" password="111111" url="127.0.0.1:8011" user="test">
        </writeHost>
    </dataHost>
    <dataHost balance="1" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="localhost:9011" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"


  Scenario: The dataHost use fake write host and fake read host #2
    Given delete the following xml segment
      | file        | parent          | child                   |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataHost'}      |
      | schema.xml  | {'tag':'root'}  | {'tag':'schema'}        |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataNode'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="127.0.0.1:8066" user="test">
        <readHost host="hostS2" password="111111" url="localhost:9066" user="test" />
      </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
        <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>

    <dataNode dataHost="ha_group2" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db2" name="dn2" />
    <dataNode dataHost="ha_group2" database="db3" name="dn3" />
    <dataNode dataHost="ha_group2" database="db4" name="dn4" />
    """
    Then restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dataHosts/fake dataSources"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "result_1"
      | conn   | toClose | sql                   |
      | conn_0 | false   | check full @@metadata |
    Then check resultset "result_1" has lines with following column values
      | schema-0 | table-1       | reload_time-2 | table_structure-3 | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | test          | null          | null              | 0                              | 0                      |
      | schema1  | sharding_2_t1 | null          | null              | 0                              | 0                      |
      | schema1  | sharding_4_t1 | null          | null              | 0                              | 0                      |


  Scenario: The dataHost use fake write host and fake read host, disabled=true #3
    Given delete the following xml segment
      | file        | parent          | child                   |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataHost'}      |
      | schema.xml  | {'tag':'root'}  | {'tag':'schema'}        |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataNode'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="127.0.0.1:9066" user="test" disabled="true">
        <readHost host="hostS2" password="111111" url="localhost:8066" user="test" />
      </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
        <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>

    <dataNode dataHost="ha_group2" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db2" name="dn2" />
    <dataNode dataHost="ha_group2" database="db3" name="dn3" />
    <dataNode dataHost="ha_group2" database="db4" name="dn4" />
    """
    Then restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dataHosts/fake dataSources"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """
    Then execute admin cmd "reload @@config_all"
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="127.0.0.1:8066" user="test">
        <readHost host="hostS2" password="111111" url="localhost:9066" user="test" />
      </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dataHosts/fake dataSources"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """


  Scenario: The dataHost changed from right host to fake host #4
    Given delete the following xml segment
      | file        | parent          | child                   |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataHost'}      |
      | schema.xml  | {'tag':'root'}  | {'tag':'schema'}        |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataNode'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="hostS2" password="111111" url="172.100.9.6:3307" user="test" />
      </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
        <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>

    <dataNode dataHost="ha_group2" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db2" name="dn2" />
    <dataNode dataHost="ha_group2" database="db3" name="dn3" />
    <dataNode dataHost="ha_group2" database="db4" name="dn4" />
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1              | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int)             | success | schema1 |
      | conn_0 | false   | begin                                           | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
    ####结果类似 MySQLConnection [backendId=13, lastTime=1681277667995, user=test, schema=db2, old schema=db2, fromSlaveDB=false, mysqlId=327,character_set_client=utf8,character_set_results=utf8,collation_connection=utf8_general_ci, txIsolation=3, autocommit=false,
    # attachment=dn3{INSERT INTO sharding_4_t1 VALUES (2)}.0, respHandler=com.actiontech.dble.backend.mysql.nio.handler.MultiNodeQueryHandler@416f04b8, host=172.100.9.5, port=3306, statusSync=null, writeQueue=0, xaStatus=0]
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                          | expect                             |
      | conn_1 | false   | show @@session               | hasStr{INSERT INTO sharding_4_t1}  |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="127.0.0.1:9066" user="test">
        <readHost host="hostS2" password="111111" url="localhost:8066" user="test" />
      </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql              | expect      |
      | conn_1 | false   | show @@session   | length{(0)} |



  Scenario: some dataNode have null dataHost #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="" database="db2" name="dn4" />
    <dataNode dataHost="" database="db3" name="dn5" />
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: dataNode dn4 define error ,attribute can't be empty
    """


  Scenario: The dataHost have right write host and fake read host #6
    Given delete the following xml segment
      | file        | parent           | child                   |
      | schema.xml  | {'tag':'root'}   | {'tag':'dataHost'}      |
      | schema.xml  | {'tag':'root'}   | {'tag':'schema'}        |
      | schema.xml  | {'tag':'root'}   | {'tag':'dataNode'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="hostS2" password="111111" url="127.0.0.1:8066" user="test" />
      </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
        <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>

    <dataNode dataHost="ha_group2" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db2" name="dn2" />
    <dataNode dataHost="ha_group2" database="db3" name="dn3" />
    <dataNode dataHost="ha_group2" database="db4" name="dn4" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect  | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1                                  | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int, name varchar(10))               | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1,'11'),(2,'22'),(3,'33'),(4,'44') | success | schema1 |
      | conn_0 | false   | select * from sharding_4_t1                                         | success | schema1 |
      | conn_0 | false   | update sharding_4_t1 set name='test' where id=3                     | success | schema1 |
      | conn_0 | false   | delete from sharding_4_t1 where id>2                                | success | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1                                  | success | schema1 |


  Scenario: The dataHost have fake write host and write read host #7
    Given delete the following xml segment
      | file        | parent          | child                   |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataHost'}      |
      | schema.xml  | {'tag':'root'}  | {'tag':'schema'}        |
      | schema.xml  | {'tag':'root'}  | {'tag':'dataNode'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="hostS2" password="111111" url="172.100.9.6:3307" user="test" />
      </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
        <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
        <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
    </schema>

    <dataNode dataHost="ha_group2" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db2" name="dn2" />
    <dataNode dataHost="ha_group2" database="db3" name="dn3" />
    <dataNode dataHost="ha_group2" database="db4" name="dn4" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect  | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1                                  | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int, name varchar(10))               | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1,'11'),(2,'22'),(3,'33'),(4,'44') | success | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="127.0.0.1:8066" user="test">
        <readHost host="hostS2" password="111111" url="172.100.9.6:3307" user="test" />
      </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    ### balance="2"  读操作在所有实例中均衡。 所以上文建好表了，这边select不一定能立马查询到
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db      | timeout |
      | conn_0 | false   | select * from sharding_4_t1                       | success | schema1 | 6,2     |
      | conn_0 | false   | update sharding_4_t1 set name='test' where id=3   | is fake node | schema1 ||
      | conn_0 | false   | delete from sharding_4_t1 where id>2              | is fake node | schema1 ||
      | conn_0 | true    | drop table if exists sharding_4_t1                | is fake node | schema1 ||


  Scenario: tow dataHosts - one dataHost have fake write host and fake read host #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM2" password="111111" url="localhost:8066" user="test">
        <readHost host="hostS2" password="111111" url="127.0.0.1:9066" user="test" />
      </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" success


  Scenario: two dataHosts have fake write host #9
    Given delete the following xml segment
      | file          | parent          | child                   |
      | schema.xml    | {'tag':'root'}  | {'tag':'dataHost'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" password="111111" url="localhost:9066" user="test">
        </writeHost>
    </dataHost>
    <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="127.0.0.1:9066" user="test">
        </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dataHosts/fake dataSources"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """