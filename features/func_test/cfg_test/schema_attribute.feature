Feature: test some import nodes attr in schema.xml

  @smoke
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "needAddLimit=true" #1
    Given delete the following xml segment
      |file         | parent           | child                 |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn1" name="mytest" sqlMaxLimit="3">
            <table dataNode="dn1,dn3" name="test_table" type="global"/>
        </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                 | success | mytest |
        | test | 111111 | conn_0 | False    | create table test_table(id int)                 | success | mytest |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success | mytest |
        | test | 111111 | conn_0 | True     | select * from test_table                        | length{(3)} | mytest |
#        | test | 111111 | conn_0 | False    | drop table if exists default_table              | success | mytest |
#        | test | 111111 | conn_0 | False    | create table default_table(id int)              | success | mytest |
#        | test | 111111 | conn_0 | False    | insert into default_table values(1),(2),(3),(4)/*dest_node:dn5*/    | success | mytest |
#        | test | 111111 | conn_0 | False    | select * from default_table                     | length{(3)} | mytest |

  @regression
  Scenario: config "schema" node attr "sqlMaxLimit" while "table" node attr "needAddLimit=false" #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema dataNode="dn1" name="mytest" sqlMaxLimit="3">
          <table dataNode="dn1,dn3" name="test_table" type="global" needAddLimit="false"/>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                             | expect  | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table                 | success | mytest |
        | test | 111111 | conn_0 | False    | create table test_table(id int)                 | success | mytest |
        | test | 111111 | conn_0 | False    | insert into test_table values(1),(2),(3),(4),(5)| success | mytest |
        | test | 111111 | conn_0 | True     | select * from test_table    | length{(5)} | mytest |

  @regression
  Scenario: config "table" node attr "name" with multiple values #3
     Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
     """
        <table name="test_table,test2_table" dataNode="dn1,dn2,dn3,dn4" type="global" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                               | expect              | db     |
        | test | 111111 | conn_0 | False    | drop table if exists test_table   | success             | mytest |
        | test | 111111 | conn_0 | False    | create table test_table(id int)   | success             | mytest |
        | test | 111111 | conn_0 | False    | show all tables                   | has{('test_table','GLOBAL TABLE')}   | mytest |
        | test | 111111 | conn_0 | False    | drop table if exists test2_table  | success             | mytest |
        | test | 111111 | conn_0 | False    | create table test2_table(id int)  | success             | mytest |
        | test | 111111 | conn_0 | True     | show all tables                   | has{('test_table','GLOBAL TABLE')}   | mytest |

  @smoke
  Scenario: test "dataHost" node attr "maxCon" #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
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
    | test | 111111 | conn_0 | True     | drop table if exists test_table    | success | mytest |
    | test | 111111 | conn_0 | True     | create table test_table(id int)    | success | mytest |
    Then create "15" conn while maxCon="15" finally close all conn
    Then create "16" conn while maxCon="15" finally close all conn
    """
    error totally whack
    """
  @regression
  Scenario: if "dataHost" node attr "maxCon" less than or equal the count of related datanodes, maxCon will be count(related dataNodes)+1 #5
    Given delete the following xml segment
      |file        | parent          | child                |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
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
      | test | 111111 | conn_0 | True    | drop table if exists test_shard                                 | success | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_no_shard                              | success | mytest |
      | test | 111111 | conn_0 | True    | create table test_shard(id int,name varchar(33))                | success | mytest |
      | test | 111111 | conn_0 | True    | create table test_no_shard(id int,name varchar(33))             | success | mytest |
      | test | 111111 | conn_0 | True    | insert into test_shard set id = 1                               | success | mytest |
      | test | 111111 | conn_0 | True    | insert into test_no_shard set id = 1                            | success | mytest |
      | test | 111111 | conn_0 | True    | select a.id from test_shard a,test_no_shard b where a.id = b.id | success | mytest |
      | test | 111111 | conn_0 | True    | drop table if exists test_table                                 | success | mytest |
      | test | 111111 | conn_0 | True    | create table test_table(id int)                                 | success | mytest |
    Then create "3" conn while maxCon="3" finally close all conn
    Then create "4" conn while maxCon="3" finally close all conn
    """
    error totally whack
    """

  @regression
  Scenario: select (colomn is not primarykey set in schema.xml) from table -- primarykey cache invalid
             select (contains column which is set as primarykey in schema.xml) from table -- primarykey cache  effective  #6
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" primaryKey="name" rule="hash-two" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                                         | expect         | db     |
        | test | 111111 | conn_0 | False    |drop table if exists test_table                              | success       | mytest |
        | test | 111111 | conn_0 | False    |create table test_table(id int,name varchar(20)) |success        | mytest |
        | test | 111111 | conn_0 | False    |insert into test_table values(1,'test1'),(2,'test2')         | success      | mytest |
        | test | 111111 | conn_0 | True     |select id from test_table                  | success       | mytest |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql          | expect      | db     |
        | root | 111111 | conn_0 | True     | show @@cache | length{(2)} |        |
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql                                     | expect         | db     |
        | test | 111111 | conn_0 | True     |select * from test_table      | success        | mytest |
    Then execute sql in "dble-1" in "admin" mode
        | user | passwd | conn   | toClose  | sql           | expect                                                                                   | db     |
        | root | 111111 | conn_0 | True     | show @@cache  | match{('TableID2DataNodeCache.`mytest`_`test_table`',10000L,1L,1L,0L,1L,2018')}| |