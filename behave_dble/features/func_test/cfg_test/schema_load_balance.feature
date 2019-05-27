# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/12/7
Feature: test read load balance
  requirements reference:
  1.https://actiontech.github.io/dble-docs-cn/2.Function/2.03_separate_RW.html
  2.https://actiontech.github.io/dble-docs-cn/1.config_file/1.2_schema.xml.html balance part
  todo: may need take various of writehost or readhost status abnormal into consideration

  @CRITICAL
  Scenario: dataHost balance="0", do not balance, all read send to master #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4'"
    Then execute sql in "dble-1" in "user" mode
    | user | passwd | conn   | toClose | sql                                         | expect   | db      |tb  |count|
    | test | 111111 | conn_0 | True    | drop table if exists test                   | success  | schema1 |test|     |
    | test | 111111 | conn_0 | True    | create table test(id int,name varchar(20))  | success  | schema1 |test|     |
    Then connect "dble-1" to insert "1000" of data for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db     |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success | db1 |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db     |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success | db1 |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then connect "dble-1" to execute "1000" of select for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(1000L,),} | db1 |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  has{(0L,),} | db1 |

  @CRITICAL
  Scenario: dataHost balance="1", do balance on read host or standby write host #2
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="1" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | False   | set global general_log=on       | success | db1 |
    | test  | 111111    | conn_0 | False   | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | False   | set global general_log=on       | success | db1 |
    | test  | 111111    | conn_0 | False   | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then connect "dble-1" to execute "1000" of select for "test"
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%' | balance{1000} |  |
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%' | balance{0} |  |

  @NORMAL
  Scenario: dataHost balance="2", do balance bewteen read host and write host #3
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="2" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then connect "dble-1" to execute "10000" of select for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{5000} |  |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  balance{5000} |  |

  @CRITICAL
  Scenario: dataHost balance="2", do balance bewteen read host and write host according to their weight #4
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="2" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test" weight="1">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test" weight="1"/>
              <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test" weight="2"/>
            </writeHost>
        </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then connect "dble-1" to execute "10000" of select for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{2500}|  |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{2500} |  |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  balance{5000} |  |

  @CRITICAL
  Scenario: dataHost balance="3", do balance bewteen read host #5
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="3" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
              <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test"/>
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then connect "dble-1" to execute "10000" of select for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(0L,),} |  |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{5000} |  |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  balance{5000} |  |

  @NORMAL
  Scenario: dataHost balance="3" and tempReadHostAvailable="1", do balance bewteen read host even writehost down #6
     Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="3" tempReadHostAvailable="1" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
            </writeHost>
        </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="dataNodeHeartbeatPeriod">1000</property>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then connect "dble-1" to execute "1000" of select for "test"
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%' | has{(1000L,),} |  |
    Given start mysql in host "mysql-master2"

  @NORMAL
  Scenario: dataHost balance="3" and tempReadHostAvailable="0", don't balance bewteen read host if writehost down #7
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="3" tempReadHostAvailable="0" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
            </writeHost>
        </dataHost>
    """
     Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
        <property name="dataNodeHeartbeatPeriod">1000</property>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Then execute sql in "dble-1" in "user" mode
    | user  | passwd    | conn   | toClose | sql                   | expect  | db       |
    | test  | 111111    | conn_0 | True    | select name from test | error totally whack | schema1  |
    Given start mysql in host "mysql-master2"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                            | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                            | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                            | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |

  @CRITICAL
  Scenario: dataHost balance="2", 1m weight=1, 1s weight=1, 1s weight=0, and weight=0 indicates that traffic is not accepted   #8
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="2" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test" weight="1">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test" weight="1"/>
              <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test" weight="0"/>
            </writeHost>
        </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then connect "dble-1" to execute "10000" of select for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{5000}|  |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{5000} |  |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  has{(0L,),}  |  |
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=off   | success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=off   | success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=off   | success |     |

  @CRITICAL
  Scenario: dataHost balance="2", 1m weight=0, the write node only accepts write traffic and does not receive read traffic   #9
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db3" name="dn3" />
        <dataNode dataHost="172.100.9.6" database="db4" name="dn4" />
        <dataHost balance="2" maxCon="9" minCon="3" name="172.100.9.6" slaveThreshold="100" switchType="1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test" weight="0">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test" weight="1"/>
              <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test" weight="1"/>
            </writeHost>
        </dataHost>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
    | user | passwd | conn   | toClose | sql                                              | expect   | db      |tb  |
    | test | 111111 | conn_0 | True    | drop table if exists test                     | success  | schema1 |test|
    | test | 111111 | conn_0 | True    | create table test(id int,name varchar(20))  | success  | schema1 |test|
    Then connect "dble-1" to insert "1000" of data for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on       | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then connect "dble-1" to execute "10000" of select for "test"
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(0L,),}  |  |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{5000} |  |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{5000} |  |
    Then execute sql in "mysql-master2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=off   | success |     |
    Then execute sql in "mysql-slave1"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=off   | success |     |
    Then execute sql in "mysql-slave2"
    | user  | passwd    | conn   | toClose | sql                             | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=off   | success |     |

