# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
Feature: test read load balance
#0：不做均衡，直接分发到当前激活的write dbInstance，read dbInstance将被忽略,不会尝试建立连接
#1：在除当前激活write dbInstance之外随机选择read dbInstance
#2：读操作在所有read dbInstance和write dbInstance中均衡。
#todo: may need take various of dbInstance with primary="true" or dbInstance with primary="false" status abnormal into consideration

  @CRITICAL
  Scenario: dbGroup rwSplitMode="0", do not balance, all read send to master #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@shardingNode ='dn1,dn2,dn3,dn4'"
    Then execute sql in "dble-1" in "user" mode
      | toClose | sql                                         | expect   | db      |
      | False   | drop table if exists test                   | success  | schema1 |
      | True    | create table test(id int,name varchar(20))  | success  | schema1 |
    Then connect "dble-1" to insert "1000" of data for "test"
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                             | expect  |
      | conn_0 | False   | set global general_log=on       | success |
      | conn_0 | False   | set global log_output='table'   | success |
      | conn_0 | True    | truncate table mysql.general_log| success |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             | expect  |
      | conn_0 | False   | set global general_log=on       | success |
      | conn_0 | False   | set global log_output='table'   | success |
      | conn_0 | True    | truncate table mysql.general_log| success |
    Given execute sql "1000" times in "dble-1" at concurrent
      | sql                                | db      |
      | select name from test where id ={} | schema1 |
    Then execute sql in "mysql-master2"
      | sql                                                                                | expect         |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | has{(1000L,),} |
    Then execute sql in "mysql-slave1"
      | sql                                                                                | expect       |
      | select count(*) from mysql.general_log where argument like'select name%from test%' |  has{(0L,),} |

  @CRITICAL
  Scenario: dbGroup rwSplitMode="1", do balance on read dbInstance #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="9" minCon="3"/>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Given execute sql "1000" times in "dble-1" at concurrent
      | sql                                | db      |
      | select name from test where id ={} | schema1 |
    Then execute sql in "mysql-slave1"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{1000} |
    Then execute sql in "mysql-master2"
      | sql                                                                                | expect     |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{0} |

  @NORMAL
  Scenario: dbGroup rwSplitMode="2", do balance bewteen read dbInstance and write dbInstance #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10"/>
      </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Given execute sql "10000" times in "dble-1" at concurrent
      | sql                                 | db      |
      | select name from test where id ={}  | schema1 |
    Then execute sql in "mysql-master2"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{5000} |
    Then execute sql in "mysql-slave1"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{5000} |

  @CRITICAL
  Scenario: dbGroup rwSplitMode="2", do balance bewteen read dbInstance and write dbInstance according to their readWeight #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" readWeight="1" primary="true"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="150" minCon="10" readWeight="2"/>
      </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Given execute sql "10000" times in "dble-1" at concurrent
      | sql                                 | db      |
      | select name from test where id ={}  | schema1 |
    Then execute sql in "mysql-master2"
      | sql                                                                                 | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%'  | balance{2500} |
    Then execute sql in "mysql-slave1"
      | sql                                                                                 | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%'  | balance{2500} |
    Then execute sql in "mysql-slave2"
      | sql                                                                                 | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%'  | balance{5000} |

  @NORMAL @restore_mysql_service
  Scenario: dbGroup rwSplitMode="1" and read dbInstance default available, do balance bewteen read dbInstance even write dbInstance down #6
     """
    {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
    """
     Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true">
              <property name="heartbeatPeriodMillis">1000</property>
          </dbInstance>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="9" minCon="3">
              <property name="heartbeatPeriodMillis">1000</property>
          </dbInstance>
      </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Given execute sql "1000" times in "dble-1" at concurrent
      | sql                                 | db      |
      | select name from test where id ={}  | schema1 |
    Then execute sql in "mysql-slave1"
      | sql                                                                                | expect         |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | has{(1000L,),} |
    Given start mysql in host "mysql-master2"

  @NORMAL @restore_mysql_service
  Scenario: dbGroup rwSplitMode="1" and read dbInstance default available, don't balance bewteen read dbInstance if write dbInstance  down #7
     """
    {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
    """
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true">
             <property name="heartbeatPeriodMillis">1000</property>
          </dbInstance>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="9" minCon="3">
             <property name="heartbeatPeriodMillis">1000</property>
          </dbInstance>
      </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
      | sql                   | expect              | db       |
      | select name from test | success             | schema1  |
    Given start mysql in host "mysql-master2"
    Then execute sql in "mysql-master2"
      | sql                            |
      | set global log_output='file'   |
    Then execute sql in "mysql-slave1"
      | sql                            |
      | set global log_output='file'   |
    Then execute sql in "mysql-slave2"
      | sql                            |
      | set global log_output='file'   |

  @CRITICAL @current
  Scenario: dbGroup rwSplitMode="2", 1m readWeight=1, 1s readWeight=1, 1s readWeight=0, and readWeight=0 indicates that traffic is not accepted   #8
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" primary="true" readWeight="1"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="150" minCon="10" readWeight="0"/>
      </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given restart mysql in "mysql-slave1" with sed cmds to update mysql config
    """
    /replicate-ignore-table/d
    /server-id/a replicate-ignore-table = mysql.general_log
    """
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Given execute sql "10000" times in "dble-1" at concurrent
      | sql                                 | db      |
      | select name from test where id ={}  | schema1 |
    Then execute sql in "mysql-master2"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{5000} |
    Then execute sql in "mysql-slave1"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{5000} |
    Then execute sql in "mysql-slave2"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' |  has{(0L,),}  |
    Then execute sql in "mysql-master2"
      | sql                          |
      | set global general_log=off   |
    Then execute sql in "mysql-slave1"
      | sql                          |
      | set global general_log=off   |
    Then execute sql in "mysql-slave2"
      | sql                          |
      | set global general_log=off   |

  @CRITICAL
  Scenario: dbGroup rwSplitMode="2", 1m readWeight=0, the write node only accepts write traffic and does not receive read traffic   #9
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn1" sqlMaxLimit="100">
          <shardingTable name="test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      <shardingNode dbGroup="ha_group2" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
      <shardingNode dbGroup="ha_group2" database="db3" name="dn3" />
      <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
      <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="150" minCon="10" primary="true" readWeight="0"/>
          <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
          <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="150" minCon="10" readWeight="1"/>
      </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect   | db      |
      | conn_0 | False   | drop table if exists test                  | success  | schema1 |
      | conn_0 | True    | create table test(id int,name varchar(20)) | success  | schema1 |
    Then connect "dble-1" to insert "1000" of data for "test"
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Then execute sql in "mysql-slave2"
      | conn   | toClose | sql                             |
      | conn_0 | False   | set global general_log=on       |
      | conn_0 | False   | set global log_output='table'   |
      | conn_0 | True    | truncate table mysql.general_log|
    Given execute sql "10000" times in "dble-1" at concurrent
      | sql                                 | db      |
      | select name from test where id ={}  | schema1 |
    Then execute sql in "mysql-master2"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | has{(0L,),}   |
    Then execute sql in "mysql-slave1"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{5000} |
    Then execute sql in "mysql-slave2"
      | sql                                                                                | expect        |
      | select count(*) from mysql.general_log where argument like'select name%from test%' | balance{5000} |
    Then execute sql in "mysql-master2"
      | sql                          |
      | set global general_log=off   |
    Then execute sql in "mysql-slave1"
      | sql                          |
      | set global general_log=off   |
    Then execute sql in "mysql-slave2"
      | sql                          |
      | set global general_log=off   |

