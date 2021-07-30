# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/7/28

# DBLE0REQ-225
Feature: db.xml support fake host

  @init_dble_meta
  Scenario: The managerPort/serverPort does not use the default value, fake host use the default managerPort/serverPort #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DmanagerPort=9011
    $a -DserverPort=8011
    """
    Then restart dble in "dble-1" success use manager port "9011"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="127.0.0.1:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="localhost:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is Can't get variables from any dbInstance, because all of dbGroup can't connect to MySQL correctly
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="127.0.0.1:8011" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="localhost:9011" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"


  Scenario: The dbGroup use fake write dbInstance and fake read dbInstance #2
    Given delete the following xml segment
      |file          | parent          | child                   |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="127.0.0.1:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="localhost:9066" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Then restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dbGroup/fake dbInstance"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "result_1"
      | conn   | toClose | sql                   | db               |
      | conn_0 | false   | check full @@metadata | dble_information |
    Then check resultset "result_1" has lines with following column values
      | schema-0 | table-1       | reload_time-2 | table_structure-3 | consistent_in_sharding_nodes-4 | consistent_in_memory-5 |
      | schema1  | test          | null          | null              | 0                              | 0                      |
      | schema1  | sharding_2_t1 | null          | null              | 0                              | 0                      |
      | schema1  | sharding_4_t1 | null          | null              | 0                              | 0                      |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect      | db               |
      | conn_0 | true    | select * from backend_connections | length{(0)} | dble_information |


  Scenario: The dbGroup use fake write dbInstance and fake read dbInstance, disabled=true #3
    Given delete the following xml segment
      |file          | parent          | child                   |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="127.0.0.1:9066" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="localhost:8066" user="test" maxCon="1000" minCon="10" primary="false" disabled="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Then restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dbGroup/fake dbInstance"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """
    Then execute admin cmd "reload @@config_all"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="127.0.0.1:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="localhost:9066" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dbGroup/fake dbInstance"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """


  Scenario: The dbInstance changed from right dbInstance to fake dbInstance #4
    Given delete the following xml segment
      |file          | parent          | child                   |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect  | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1              | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int)             | success | schema1 |
      | conn_0 | false   | begin                                           | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1),(2),(3),(4) | success | schema1 |
      Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                  | expect       | db               |
      | conn_1 | false   | select * from backend_connections where state='IN USE' and db_group_name='ha_group2' | length{(4)} | dble_information |
      | conn_1 | false   | select * from session_connections                                                    | length{(2)}  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "result_2"
      | conn   | toClose | sql                   | db               |
      | conn_1 | false   | select remote_port,processor_id,user,schema,sql,sql_stage from session_connections | dble_information |
    Then check resultset "result_2" has lines with following column values
      | remote_port-0 | processor_id-1  | user-2 | schema-3         | sql-4                                                                              | sql_stage-5        |
      | 9066          | frontProcessor0 | root   | dble_information | select remote_port,processor_id,user,schema,sql,sql_stage from session_connections | Manager connection |
      | 8066          | frontProcessor0 | test   | schema1          | insert into sharding_4_t1 values(1),(2),(3),(4)                                    | Finished           |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="127.0.0.1:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="localhost:8066" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect      | db               |
      | conn_1 | false   | select * from backend_connections | length{(0)} | dble_information |
      | conn_1 | false   | select * from session_connections | length{(1)} | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "result_3"
      | conn   | toClose | sql                   | db               |
      | conn_1 | true    | select remote_port,processor_id,user,schema,sql,sql_stage from session_connections | dble_information |
    Then check resultset "result_3" has lines with following column values
      | remote_port-0 | processor_id-1  | user-2 | schema-3         | sql-4                                                                              | sql_stage-5        |
      | 9066          | frontProcessor0 | root   | dble_information | select remote_port,processor_id,user,schema,sql,sql_stage from session_connections | Manager connection |


  Scenario: some shardingNode have null dbGroup #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="" database="db2" name="dn4" />
    <shardingNode dbGroup="" database="db3" name="dn5" />
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: shardingNode dn4 define error ,attribute can't be empty
    """


  Scenario: The dbGroup have right write dbInstance and fake read dbInstance #6
    Given delete the following xml segment
      |file          | parent          | child                   |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="127.0.0.1:8066" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
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


  Scenario: The dbGroup have fake write dbInstance and write read dbInstance #7
    Given delete the following xml segment
      |file          | parent          | child                   |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}        |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect  | db      |
      | conn_0 | false   | drop table if exists sharding_4_t1                                  | success | schema1 |
      | conn_0 | false   | create table sharding_4_t1 (id int, name varchar(10))               | success | schema1 |
      | conn_0 | false   | insert into sharding_4_t1 values(1,'11'),(2,'22'),(3,'33'),(4,'44') | success | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="127.0.0.1:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect  | db      |
      | conn_0 | false   | select * from sharding_4_t1                       | success | schema1 |
      | conn_0 | false   | update sharding_4_t1 set name='test' where id=3   | the dbInstance[127.0.0.1:8066] is fake node. Please check the dbInstance whether or not it is used | schema1 |
      | conn_0 | false   | delete from sharding_4_t1 where id>2              | the dbInstance[127.0.0.1:8066] is fake node. Please check the dbInstance whether or not it is used | schema1 |
      | conn_0 | true    | drop table if exists sharding_4_t1                | the dbInstance[127.0.0.1:8066] is fake node. Please check the dbInstance whether or not it is used | schema1 |


  Scenario: tow dbGroups - one dbGroup have fake write dbInstance and fake read dbInstance #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="localhost:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="127.0.0.1:9066" user="test" maxCon="1000" minCon="10" primary="false">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success


  Scenario: two dbGroups have fake write dbInstance #9
    Given delete the following xml segment
      |file          | parent          | child                   |
      |db.xml        |{'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="localhost:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="127.0.0.1:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given execute linux command in "dble-1" and contains exception "Access denied for user 'test', because there are some empty dbGroup/fake dbInstance"
    """
    mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "select version()"
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                            | expect      | db               |
      | conn_0 | false   | select * from session_connections              | length{(1)} | dble_information |
      | conn_0 | true    | select * from backend_connections              | length{(0)} | dble_information |


  Scenario: fake host doesn't support ipv6 and local ip address #10
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="0:0:0:0:0:0:0:1:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: com.actiontech.dble.config.util.ConfigException: db json to map occurred  parse errors, The detailed results are as follows . java.lang.NumberFormatException: For input string: "0:0:0:0:0:0:1:9066"
    """
    Then restart dble in "dble-1" failed for
    """
    com.actiontech.dble.config.util.ConfigException: db json to map occurred  parse errors, The detailed results are as follows . java.lang.NumberFormatException: For input string: \"0:0:0:0:0:0:1:9066\"
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.1:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: SelfCheck### there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group2.hostM2]},
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.1:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: SelfCheck### there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group2.hostM2]},
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.1:9066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.1:8066" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" failed for
    """
    java.io.IOException: Can't get variables from all dbGroups
    """