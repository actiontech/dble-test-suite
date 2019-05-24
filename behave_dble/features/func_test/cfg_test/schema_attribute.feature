# Copyright (C) 2016-2019 ActionTech.
# License: http://www.gnu.org/licenses/gpl.html GPL version 2 or higher.
Feature: test some import nodes attr in schema.xml

  @BLOCKER
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "needAddLimit=true" #1
    Given delete the following xml segment
      |file         | parent           | child                 |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="3">
            <table dataNode="dn1,dn3" name="test_table" type="global"/>
        </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                 | success | schema1 |
        | test | 111111 | conn_0 | False    | create table test_table(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success | schema1 |
        | test | 111111 | conn_0 | True     | select * from test_table                        | length{(3)} | schema1 |
#        | test | 111111 | conn_0 | False    | drop table if exists default_table              | success | schema1 |
#        | test | 111111 | conn_0 | False    | create table default_table(id int)              | success | schema1 |
#        | test | 111111 | conn_0 | False    | insert into default_table values(1),(2),(3),(4)/*dest_node:dn5*/    | success | schema1 |
#        | test | 111111 | conn_0 | False    | select * from default_table                     | length{(3)} | schema1 |

  @TRIVIAL
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "needAddLimit=false" #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema dataNode="dn1" name="schema1" sqlMaxLimit="3">
          <table dataNode="dn1,dn3" name="test_table" type="global" needAddLimit="false"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                 | success | schema1 |
        | test | 111111 | conn_0 | False    | create table test_table(id int)                 | success | schema1 |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success | schema1 |
        | test | 111111 | conn_0 | True     | select * from test_table    | length{(5)} | schema1 |

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
        <dataHost balance="0" maxCon="15" minCon="3" name="dh1" slaveThreshold="100" switchType="-1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
    | user | passwd | conn   | toClose  | sql                                    | expect  | db     |
    | test | 111111 | conn_0 | True     | drop table if exists test_table    | success | schema1 |
    | test | 111111 | conn_0 | True     | create table test_table(id int)    | success | schema1 |
    Then create "15" conn while maxCon="15" finally close all conn
    Then create "16" conn while maxCon="15" finally close all conn
    """
    error totally whack
    """
  @NORMAL
  Scenario: if "dataHost" node attr "maxCon" less than or equal the count of related datanodes, maxCon will be count(related dataNodes)+1 #5
    Given delete the following xml segment
      |file        | parent          | child                |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn3" name="test_shard" type="global" />
        </schema>
        <dataNode dataHost="dh1" database="db1" name="dn1" />
        <dataNode dataHost="dh1" database="db2" name="dn3" />
        <dataHost balance="0" maxCon="2" minCon="1" name="dh1" slaveThreshold="100" switchType="-1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                             | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                 | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard                              | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,name varchar(33))                | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_no_shard(id int,name varchar(33))             | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_shard set id = 1                               | success | schema1 |
      | test | 111111 | conn_0 | True    | insert into test_no_shard set id = 1                            | success | schema1 |
      | test | 111111 | conn_0 | True    | select a.id from test_shard a,test_no_shard b where a.id = b.id | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists test_table                                 | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_table(id int)                                 | success | schema1 |
    Then create "3" conn while maxCon="3" finally close all conn
    Then create "4" conn while maxCon="3" finally close all conn
    """
    error totally whack
    """

  @CRITICAL
  Scenario: select (colomn is not primarykey set in schema.xml) from table -- primarykey cache invalid
             select (contains column which is set as primarykey in schema.xml) from table -- primarykey cache  effective  #6
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" primaryKey="name" rule="hash-two" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                         | expect         | db     |
        | test | 111111 | conn_0 | False    |drop table if exists test_table                              | success       | schema1 |
        | test | 111111 | conn_0 | False    |create table test_table(id int,name varchar(20)) |success        | schema1 |
        | test | 111111 | conn_0 | False    |insert into test_table values(1,'test1'),(2,'test2')         | success      | schema1 |
        | test | 111111 | conn_0 | True     |select id from test_table                  | success       | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql          | expect      | db     |
        | root | 111111 | conn_0 | True     | show @@cache | length{(2)} |        |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                     | expect         | db     |
        | test | 111111 | conn_0 | True     |select * from test_table      | success        | schema1 |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql           | expect                                                                                   | db     |
        | root | 111111 | conn_0 | True     | show @@cache  | match{('TableID2DataNodeCache.`schema1`_`test_table`',10000L,1L,1L,0L,1L,2018')}| |

  @CRITICAL
  Scenario: primayKey cache effective when attribute "primaryKey" be set#6
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" primaryKey="k" rule="hash-four" />
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
  Scenario: primayKey cache invalid when attribute "primaryKey" not be set #7
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

   Scenario: Use the RocksDB database engine as a cache implementation  issue:1029  author: maofei #8
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4"  rule="hash-four" />
    """
    Given update file content "/opt/dble/conf/cacheservice.properties" in "dble-1"
    """
    s/encache/rocksdb/
    s/ehcache/rocksdb/
    s/10000,1800/10000,0/
    """
    Given create filder content "/opt/dble/rocksdb" in "dble-1"
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1"
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
    Given update file content "/opt/dble/conf/cacheservice.properties" in "dble-1"
    """
    s/rocksdb/encache/
    s/=rocksdb/=ehcache/
    """
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1"
    """
    s/info/debug/
    """
    Given delete file "/opt/dble/rocksdb" on "dble-1"

  Scenario:  test execute `set @x=1` when the max active Connections size max than "maxCon"   from issue:1177 author: maofei #9
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'schema1'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="4" minCon="0" name="172.100.9.5" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
    </writeHost>
    </dataHost>
    <dataHost balance="0" maxCon="4" minCon="0" name="172.100.9.6" slaveThreshold="100" switchType="1">
    <heartbeat>select user()</heartbeat>
    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
    </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                         | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists test_table                         | success | schema1 |
      | test | 111111 | conn_0 | True    | create table test_table(id int,name varchar(33))      | success | schema1 |
      | test | 111111 | conn_0 | False   | begin                                                       | success | schema1 |
      | test | 111111 | conn_0 | False   | select * from test_table                                 | success | schema1 |
      | test | 111111 | conn_1 | False   | begin                                                       | success | schema1 |
      | test | 111111 | conn_1 | False   | select * from test_table                                 | success | schema1 |
      | test | 111111 | conn_2 | False   | set @x = 1                                                 | error totally whack | schema1 |
      | test | 111111 | conn_0 | True    | commit                                                      | success | schema1 |
      | test | 111111 | conn_1 | True    | commit                                                      | success | schema1 |
      | test | 111111 | conn_2 | True    | set @x = 1                                                 | success | schema1 |




