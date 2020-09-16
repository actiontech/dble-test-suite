# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Modified by wujinling at 2019/8/29
Feature: test some import nodes attr in sharding.xml

  @BLOCKER
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "sqlMaxLimit=true" (for all table type) #1
    Given delete the following xml segment
      |file         | parent           | child                 |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
        <schema name="schema1" shardingNode="dn1" sqlMaxLimit="3">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect      | db      |
      | conn_0 | False   | drop table if exists test_table                 | success     | schema1 |
      | conn_0 | False   | create table test_table(id int)                 | success     | schema1 |
      | conn_0 | False   | insert into test_table values(1),(2),(3),(4),(5)| success     | schema1 |
      | conn_0 | False   | select * from test_table                        | length{(3)} | schema1 |
      | conn_0 | False   | select * from test_table order by id limit 1    | length{(1)} | schema1 |
      | conn_0 | False   | drop table if exists test                       | success     | schema1 |
      | conn_0 | False   | create table test(id int)                       | success     | schema1 |
      | conn_0 | False   | insert into test values(1),(2),(3),(4),(5)      | success     | schema1 |
      | conn_0 | False   | select * from test                              | length{(3)} | schema1 |
      | conn_0 | False   | select * from test order by id limit 4          | length{(4)} | schema1 |
      | conn_0 | False   | drop table if exists sharding_4_t1              | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int)              | success     | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 values(1),(2),(3),(4),(5) | success     | schema1 |
      | conn_0 | True    | select * from sharding_4_t1 order by id limit 6     | length{(5)} | schema1 |
#      | conn_0 | False    | drop table if exists default_table              | success | schema1 |
#      | conn_0 | False    | drop table if exists default_table              | success | schema1 |
#      | conn_0 | False    | create table default_table(id int)              | success | schema1 |
#      | conn_0 | False    | insert into default_table values(1),(2),(3),(4)| dest_node:mysql-master1 | schema1 |
#      | conn_0 | False    | select * from default_table                     | length{(3)} | schema1 |

  @TRIVIAL
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "sqlMaxLimit=-1"(for all table type,means unlimited) #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="3">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" sqlMaxLimit="-1"/>
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" sqlMaxLimit="-1"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                 | expect      | db      |
      | conn_0 | False    | drop table if exists test_table                     | success     | schema1 |
      | conn_0 | False    | create table test_table(id int)                     | success     | schema1 |
      | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)    | success     | schema1 |
      | conn_0 | False    | select * from test_table                            | length{(3)} | schema1 |
      | conn_0 | False    | drop table if exists test                           | success     | schema1 |
      | conn_0 | False    | create table test(id int)                           | success     | schema1 |
      | conn_0 | False    | insert into test values(1),(2),(3),(4),(5)          | success     | schema1 |
      | conn_0 | False    | select * from test                                  | length{(5)} | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t1                  | success     | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)                  | success     | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2),(3),(4),(5) | success     | schema1 |
      | conn_0 | True     | select * from sharding_4_t1                         | length{(5)} | schema1 |


  @TRIVIAL
  Scenario: config "table" attr "name" with multiple values #3
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
     """
        <globalTable name="test_table,test2_table" shardingNode="dn1,dn2,dn3,dn4" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                               | expect              | db     |
      | conn_0 | False    | drop table if exists test_table   | success             | schema1 |
      | conn_0 | False    | create table test_table(id int)   | success             | schema1 |
      | conn_0 | False    | show all tables                   | has{('test_table','GLOBAL TABLE')}   | schema1 |
      | conn_0 | False    | drop table if exists test2_table  | success             | schema1 |
      | conn_0 | False    | create table test2_table(id int)  | success             | schema1 |
      | conn_0 | True     | show all tables                   | has{('test_table','GLOBAL TABLE')}   | schema1 |

  @BLOCKER
  Scenario: test "dbInstance" node attr "maxCon" #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn3" />
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    """
    #set connectionTimeout=4000ms in case the 15 created connections commit after 5s.
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="15" minCon="3" primary="true">
          <property name="connectionTimeout">4000</property>
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                | expect  | db      |
      | conn_0 | False    | drop table if exists test_table    | success | schema1 |
      | conn_0 | True     | create table test_table(id int)    | success | schema1 |
    Then create "15" conn while maxCon="15" finally close all conn
    Then create "16" conn while maxCon="15" finally close all conn
    """
    Connection is not available
   """
  @NORMAL
  Scenario: if "dbGroup" node attr "maxCon" less than or equal the count of related dbGroups, maxCon will be equal dbGroups; A DDL will take 1 more than we can see, the invisible one is used to take ddl metadata #5
    Given delete the following xml segment
      |file        | parent          | child                |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
   Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <globalTable name="global_2_t1" shardingNode="dn1,dn3" />
          <singleTable name="single_shard" shardingNode="dn2"/>
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    """
    #set connectionTimeout=4000ms in case the 15 created connections commit after 5s.
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="3" minCon="1" primary="true">
          <property name="connectionTimeout">4000</property>
          </dbInstance>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                             | expect  | db      |
      | conn_0 | False   | drop table if exists global_2_t1                                | success | schema1 |
      | conn_0 | False   | drop table if exists single_shard                               | success | schema1 |
      | conn_0 | False   | create table global_2_t1(id int,name varchar(33))               | success | schema1 |
      | conn_0 | False   | create table single_shard(id int,name varchar(33))              | success | schema1 |
      | conn_0 | False   | insert into global_2_t1 set id = 1                              | success | schema1 |
      | conn_0 | False   | insert into single_shard set id = 1                             | success | schema1 |
      | conn_0 | False   | select a.id from global_2_t1 a,single_shard b where a.id = b.id | success | schema1 |
      | conn_0 | False   | drop table if exists global_2_t1                                | success | schema1 |
      | conn_0 | True    | create table global_2_t1(id int)                                | success | schema1 |
#   maxCon config is 3, but real created is 4(=sum(dbGroups)+1)
    Then create "3" conn while maxCon="3" finally close all conn
    Then create "4" conn while maxCon="3" finally close all conn
    """
    Connection is not available
    """

   Scenario: Use the RocksDB database engine as a cache implementation  issue:1029  author: maofei #6
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "sharding.xml"
    """
        <shardingTable name="test_table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    """
    Given update file content "/opt/dble/conf/cacheservice.properties" in "dble-1" with sed cmds
    """
    s/encache/rocksdb/
    s/ehcache/rocksdb/
    s/10000,1800/10000,0/
    """
    Given create filder content "/opt/dble/rocksdb" in "dble-1"
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
    """
    s/debug/info/
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                             | expect  | db      |
      | conn_0 | False    |drop table if exists test_table  | success | schema1 |
      | conn_0 | False    |create table test_table(id int)  | success | schema1 |
      | conn_0 | False    |insert into test_table values(1) | success | schema1 |
      | conn_0 | False    |select * from test_table         | success | schema1 |
      | conn_0 | True     |select * from test_table         | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "cache_rs_A"
      | sql          |
      | show @@cache |
    Then check resultset "cache_rs_A" has lines with following column values
      | CACHE-0              | HIT-4   |
      | SQLRouteCache        | 1       |
    Given update file content "/opt/dble/conf/cacheservice.properties" in "dble-1" with sed cmds
    """
    s/rocksdb/encache/
    s/=rocksdb/=ehcache/
    """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
    """
    s/info/debug/
    """
    Given delete file "/opt/dble/rocksdb" on "dble-1"

  Scenario: execute `set @x=1` gets error when the max active Connections size max than "maxCon",heartbeat not account into maxCon from version 3.20.07. from issue:1177 author: maofei #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="4" minCon="0" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="4" minCon="0" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                  | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(33)) | success | schema1 |
      | conn_0 | False   | begin                                            | success | schema1 |
      | conn_0 | False   | select * from sharding_4_t1                         | success | schema1 |
      | conn_1 | False   | begin                                            | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                         | success | schema1 |
      | conn_2 | False   | set @x = 1                                       | error totally whack | schema1 |
      | conn_0 | True    | commit                                           | success | schema1 |
      | conn_1 | True    | commit                                           | success | schema1 |
      | conn_2 | True    | set @x = 1                                       | success | schema1 |

  Scenario:  when minCon<=the number of db, verify the minCon restore logic #8
   #minConRecover logic: the minimum number = the number of dbs;
   #minConRecover_num ignore heartbeat conn, so the total conns need add extra heartbeat conn,that is dbs + two heartbeats = 3+2 + 1+1 =7
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="1" primary="true">
           <property name="timeBetweenEvictionRunsMillis">1000</property>
           <property name="heartbeatPeriodMillis">300000000</property>
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="1" primary="true">
            <property name="timeBetweenEvictionRunsMillis">1000</property>
            <property name="heartbeatPeriodMillis">300000000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given execute linux command in "dble-1" and save result in "heartbeat_Ids_master1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep '172.100.9.5'| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill all backend conns in "mysql-master1" except ones in "heartbeat_Ids_master1"
    Given execute linux command in "dble-1" and save result in "heartbeat_Ids_master2"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep '172.100.9.6'| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill all backend conns in "mysql-master2" except ones in "heartbeat_Ids_master2"
    #wait 1s for minCon recover
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql            | expect        |
      | show @@backend | length{(7)}   |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="3" primary="true">
            <property name="timeBetweenEvictionRunsMillis">1000</property>
            <property name="heartbeatPeriodMillis">300000000</property>
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="2" primary="true">
           <property name="timeBetweenEvictionRunsMillis">1000</property>
           <property name="heartbeatPeriodMillis">300000000</property>
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -f"
    Given execute linux command in "dble-1" and save result in "heartbeat_Ids_master1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep '172.100.9.5'| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill all backend conns in "mysql-master1" except ones in "heartbeat_Ids_master1"
    Given execute linux command in "dble-1" and save result in "heartbeat_Ids_master2"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" |grep '172.100.9.6'| awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill all backend conns in "mysql-master2" except ones in "heartbeat_Ids_master2"
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql            | expect      |
      | show @@backend | length{(7)} |
 @cur
  Scenario:  when minCon>the number of db, verify the minCon restore logic #9
   #  minConRecover logic: min(the value of minCon - the current idle conns in pool, the value of maxCon - total conns in pool) - the creating conns
   #  minConRecover_num ignore heartbeat conn, so the total conns need add extra heartbeat conn,that is 10+1=11
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
            <property name="timeBetweenEvictionRunsMillis">1000</property>
            <property name="heartbeatPeriodMillis">300000000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given execute linux command in "dble-1" and save result in "heartbeat_Ids_master1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -e "show @@backend" | awk '{print $3, $NF}' | grep true | awk '{print $1}'
    """
    Given kill all backend conns in "mysql-master1" except ones in "heartbeat_Ids_master1"
    #wait 1s for minCon recover
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql             | expect      |
      | show @@backend where host='172.100.9.5'  | length{(11)} |
      #the not used dbInstance will only have one heartbeat connection
      | show @@backend  | length{(12)} |



