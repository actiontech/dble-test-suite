# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Modified by wujinling at 2019/8/29
Feature: test some import nodes attr in schema.xml

  @BLOCKER
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "needAddLimit=true" (for all table type) #1
    Given delete the following xml segment
      |file         | parent           | child                 |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="3">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
		     <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                 | success | schema1 |
        | test | 111111 | conn_0 | False    | create table test_table(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success | schema1 |
        | test | 111111 | conn_0 | False     | select * from test_table                        | length{(3)} | schema1 |
        | test | 111111 | conn_0 | False     | select * from test_table order by id limit 1                       | length{(1)} | schema1 |
        | test | 111111 | conn_0 | False     | drop table if exists test                        | success | schema1 |
        | test | 111111 | conn_0 | False    | create table test(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False     | insert into test values(1),(2),(3),(4),(5)                        | success | schema1 |
        | test | 111111 | conn_0 | False     | select * from test                        | length{(3)} | schema1 |
        | test | 111111 | conn_0 | False     | select * from test order by id limit 4                        | length{(4)} | schema1 |
        | test | 111111 | conn_0 | False     | drop table if exists sharding_4_t1                        | success | schema1 |
        | test | 111111 | conn_0 | False    | create table sharding_4_t1(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False     | insert into sharding_4_t1 values(1),(2),(3),(4),(5)                        | success | schema1 |
        | test | 111111 | conn_0 | True     | select * from sharding_4_t1 order by id limit 6                       | length{(5)} | schema1 |
#        | test | 111111 | conn_0 | False    | drop table if exists default_table              | success | schema1 |
#        | test | 111111 | conn_0 | False    | drop table if exists default_table              | success | schema1 |
#        | test | 111111 | conn_0 | False    | create table default_table(id int)              | success | schema1 |
#        | test | 111111 | conn_0 | False    | insert into default_table values(1),(2),(3),(4)/*dest_node:dn5*/    | success | schema1 |
#        | test | 111111 | conn_0 | False    | select * from default_table                     | length{(3)} | schema1 |

  @TRIVIAL
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "needAddLimit=false"(for all table type) #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema dataNode="dn1" name="schema1" sqlMaxLimit="3">
          <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" needAddLimit="false" />
		   <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" needAddLimit="false"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                 | success | schema1 |
        | test | 111111 | conn_0 | False    | create table test_table(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success | schema1 |
        | test | 111111 | conn_0 | False     | select * from test_table                        | length{(3)} | schema1 |
        | test | 111111 | conn_0 | False     | drop table if exists test                        | success | schema1 |
        | test | 111111 | conn_0 | False    | create table test(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False     | insert into test values(1),(2),(3),(4),(5)                        | success | schema1 |
        | test | 111111 | conn_0 | False     | select * from test                        | length{(5)} | schema1 |
        | test | 111111 | conn_0 | False     | drop table if exists sharding_4_t1                        | success | schema1 |
        | test | 111111 | conn_0 | False    | create table sharding_4_t1(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False     | insert into sharding_4_t1 values(1),(2),(3),(4),(5)                        | success | schema1 |
        | test | 111111 | conn_0 | True     | select * from sharding_4_t1                        | length{(5)} | schema1 |


  @TRIVIAL
  Scenario: config "table" node attr "name" with multiple values #3
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
     """
        <table name="test_table,test2_table" dataNode="dn1,dn2,dn3,dn4" type="global" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                               | expect              | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table   | success             | schema1 |
        | test | 111111 | conn_0 | False    | create table test_table(id int)   | success             | schema1 |
        | test | 111111 | conn_0 | False    | show all tables                   | has{('test_table','GLOBAL TABLE')}   | schema1 |
        | test | 111111 | conn_0 | False    | drop table if exists test2_table  | success             | schema1 |
        | test | 111111 | conn_0 | False    | create table test2_table(id int)  | success             | schema1 |
        | test | 111111 | conn_0 | True     | show all tables                   | has{('test_table','GLOBAL TABLE')}   | schema1 |

  @BLOCKER
  Scenario: test "dataHost" node attr "maxCon" #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn3" name="test" type="global" />
        </schema>
        <dataNode dataHost="dh1" database="db1" name="dn1" />
        <dataNode dataHost="dh1" database="db2" name="dn3" />
        <dataHost balance="0" maxCon="15" minCon="3" name="dh1" slaveThreshold="100" >
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
    | user | passwd | conn   | toClose  | sql                                | expect  | db     |
    | test | 111111 | conn_0 | True     | drop table if exists test_table    | success | schema1 |
    | test | 111111 | conn_0 | True     | create table test_table(id int)    | success | schema1 |
    Then create "14" conn while maxCon="15" finally close all conn
    Then create "15" conn while maxCon="15" finally close all conn
    """
    the max active Connections size can not be max than maxCon for data host\[dh1.hostM1\]
    """
  @NORMAL
  Scenario: if "dataHost" node attr "maxCon" less than or equal the count of related datanodes, maxCon will be count(related dataNodes)+1; A DDL will take 1 more than we can see, the invisible one is used to take ddl metadata #5
    Given delete the following xml segment
      |file        | parent          | child                |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn2" name="single_shard" />
            <table dataNode="dn1,dn3" name="global_2_t1" type="global" />
        </schema>
        <dataNode dataHost="dh1" database="db1" name="dn1" />
        <dataNode dataHost="dh1" database="db2" name="dn2" />
        <dataNode dataHost="dh1" database="db3" name="dn3" />
        <dataHost balance="0" maxCon="3" minCon="1" name="dh1" slaveThreshold="100" >
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                             | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists global_2_t1                                | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists single_shard                               | success | schema1 |
      | test | 111111 | conn_0 | True    | create table global_2_t1(id int,name varchar(33))               | success | schema1 |
      | test | 111111 | conn_0 | True    | create table single_shard(id int,name varchar(33))              | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into global_2_t1 set id = 1                              | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into single_shard set id = 1                             | success | schema1 |
      | test | 111111 | conn_0 | True    | select a.id from global_2_t1 a,single_shard b where a.id = b.id | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists global_2_t1                                | success | schema1 |
      | test | 111111 | conn_0 | True    | create table global_2_t1(id int)                                | success | schema1 |
#   maxCon config is 3, but real created is 4(=sum(datanodes)+1)
    Then create "3" conn while maxCon="3" finally close all conn
    Then create "4" conn while maxCon="3" finally close all conn
    """
    the max active Connections size can not be max than maxCon for data host\[dh1.hostM1\]
    """

  @CRITICAL
  Scenario: select (colomn is not cacheKey set in schema.xml) from table -- cacheKey cache invalid
             select (contains column which is set as cacheKey in schema.xml) from table -- cacheKey cache  effective #6
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                    | expect  | db      |
        | test | 111111 | conn_0 | False    |drop table if exists sharding_2_t1                      | success | schema1 |
        | test | 111111 | conn_0 | False    |create table sharding_2_t1(id int,name varchar(20))     | success | schema1 |
        | test | 111111 | conn_0 | False    |insert into sharding_2_t1 values(1,'test1'),(2,'test2') | success | schema1 |
        | test | 111111 | conn_0 | True     |select id from sharding_2_t1                            | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql          | expect      | db     |
        | root | 111111 | conn_0 | True     | show @@cache | length{(2)} |        |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                         | expect  | db      |
        | test | 111111 | conn_0 | True     | select * from sharding_2_t1 | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql           | expect                                                                             | db  |
        | root | 111111 | conn_0 | True     | show @@cache  | match{('TableID2DataNodeCache.`schema1`_`sharding_2_t1`',10000L,1L,1L,0L,1L,2018')}|     |

  @CRITICAL
  Scenario: primayKey cache effective when attribute "cacheKey" be set #7
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" cacheKey="k" rule="hash-four" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                             | expect         | db     |
        | test | 111111 | conn_0 | False    |drop table if exists test_table                              | success         | schema1 |
        | test | 111111 | conn_0 | False    |create table test_table(id int,k int,c int)                |success          | schema1 |
        | test | 111111 | conn_0 | False    |insert into test_table values(1,1,1),(2,2,2),(3,3,3),(4,4,4)      | success         | schema1 |
        | test | 111111 | conn_0 | True     |select id from test_table                                     | success          | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                              | expect      | db     |
        | root | 111111 | conn_0 | True     | show @@cache                                                    | length{(2)} |        |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                     | expect         | db     |
        | test | 111111 | conn_0 | True     |select * from test_table      | success        | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                              | expect                                                                                   | db     |
        | root | 111111 | conn_0 | True     | show @@cache                                                    | match{('TableID2DataNodeCache.`schema1`_`test_table`',10000L,4L,0L,0L,4L,2018')}| |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                              | expect         | db     |
        | test | 111111 | conn_0 | True     |select * from test_table where id=1                           | success        | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                              | expect                                                                                   | db     |
        | root | 111111 | conn_0 | True     | show @@cache                                                    | match{('TableID2DataNodeCache.`schema1`_`test_table`',10000L,4L,0L,0L,4L,2018')}| |

    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                              | expect         | db     |
        | test | 111111 | conn_0 | True     |select * from test_table where k=1                            | success        | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                              | expect                                                                                   | db     |
        | root | 111111 | conn_0 | True     | show @@cache                                                    | match{('TableID2DataNodeCache.`schema1`_`test_table`',10000L,4L,1L,1L,4L,2018')}| |

  @NORMAL
  Scenario: primayKey cache invalid when attribute "cacheKey" not be set #8
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4"  rule="hash-two" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                            | expect         | db     |
        | test | 111111 | conn_0 | True     |select * from test_table                                     | success        | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                            | expect         | db     |
        | root | 111111 | conn_0 | True     | show @@cache                                                  | length{(2)}   |        |

   Scenario: Use the RocksDB database engine as a cache implementation  issue:1029  author: maofei #9
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4"  rule="hash-four" />
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
        | user | passwd | conn   | toClose  | sql                                                            | expect         | db     |
        | test | 111111 | conn_0 | True     |drop table if exists test_table                             | success        | schema1 |
        | test | 111111 | conn_0 | True     |create table test_table(id int)                             | success        | schema1 |
        | test | 111111 | conn_0 | True     |insert into test_table values(1)                            | success        | schema1 |
        | test | 111111 | conn_0 | True     |select * from test_table                                     | success        | schema1 |
        | test | 111111 | conn_0 | True     |select * from test_table                                     | success        | schema1 |
    Then get resultset of admin cmd "show @@cache" named "cache_rs_A"
    Then check resultset "cache_rs_A" has lines with following column values
      | CACHE-0               | HIT-4   |
      | SQLRouteCache        | 1        |
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

  Scenario: execute `set @x=1` gets error when the max active Connections size max than "maxCon",heartbeat take account into maxCon   from issue:1177 author: maofei #10
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="5" minCon="0" name="ha_group1" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="5" minCon="0" name="ha_group2" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_table                  | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_table(id int,name varchar(33)) | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                            | success | schema1 |
      | test | 111111 | conn_0 | False   | select * from test_table                         | success | schema1 |
      | test | 111111 | conn_1 | False   | begin                                            | success | schema1 |
      | test | 111111 | conn_1 | False   | select * from test_table                         | success | schema1 |
      | test | 111111 | conn_2 | False   | set @x = 1                                       | error totally whack | schema1 |
      | test | 111111 | conn_0 | True    | commit                                           | success | schema1 |
      | test | 111111 | conn_1 | True    | commit                                           | success | schema1 |
      | test | 111111 | conn_2 | True    | set @x = 1                                       | success | schema1 |

  Scenario:  when minCon<= the number of db, the minimum number of surviving connections = (the number of db +1);
              increase in the number of connections after each test = (the minimum number of connections to survive - the number of connections already exists) / 3 from issue:1125 author: maofei #11
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="dataNodeIdleCheckPeriod">1000</property>
        <property name="dataNodeHeartbeatPeriod">300000000</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="1" name="ha_group1" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="1" name="ha_group2" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Given restart mysql in "mysql-master1"
    Given restart mysql in "mysql-master2"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                            | expect         | db     |
        | root | 111111 | conn_0 | True     | show @@backend                                                | length{(3)}   |        |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="3" name="ha_group1" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="1000" minCon="2" name="ha_group2" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all -f"
    Given restart mysql in "mysql-master1"
    Given restart mysql in "mysql-master2"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql                                                            | expect         | db     |
        | root | 111111 | conn_0 | True     | show @@backend                                                | length{(3)}   |        |

  Scenario:  when minCon > the number of db,if mysql restart, verify the minCon restore logic #12
#  minConRecover logic, take this case as example:
#  minCon_of_config=10, dataNodes in dataHost ha_group1 is 3,so at mysql first start up,already_created=num_dns+1=3+1=4
#  main logic: minConRecover_num_each_loop=floor((minCon_of_config-already_created)/3), end loop until this formula get result 0
#  minConRecover_num_loop1:(10-4)/3 = 2, already_created=already_created + minConRecover_num_loop1=4+2=6
#  minConRecover_num_loop2:(10-6)/3 = 1, already_created=already_created + minConRecover_num_loop2=6+1=7
#  minConRecover_num_loop3:(10-7)/3 = 1, already_created=already_created + minConRecover_num_loop3=7+1=8
#  minConRecover_num_loop4:(10-8)/3 = 0, formula get result 0,end loop, and the real restored conns num is 8, that is show @@backend resultset count
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="dataNodeIdleCheckPeriod">1000</property>
        <property name="dataNodeHeartbeatPeriod">300000000</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Given Restart dble in "dble-1" success
    Given restart mysql in "mysql-master1"
#   wait 2s for minConRecover is a duration, but not at once
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql             | expect        | db     |
        | root | 111111 | conn_0 | True     | show @@backend  | length{(8)}   |        |



