# Created by zhaohongjie at 2018/12/7
Feature: schema config stable test

  Background delete default configs not must，reload @@config_all success
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
      |server.xml  |{'tag':'root'}   | {'tag':'user', 'kv_map':{'name':'test'}}  |
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1" success

  @NORMAL
  Scenario: config contains only 1 stopped mysqld, reload @@config_all fail, start the mysqld, reload @@config_all success #1
    Given stop mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn1" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn1,dn3" name="test" type="global" />
        </schema>
        <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
        <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
        <dataHost balance="0" maxCon="100" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="-1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    Given start mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
        <user name="test">
            <property name="password">111111</property>
            <property name="schemas">schema1</property>
        </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql      | expect   | db     |
        | test | 111111 | conn_0 | True     | select 2 | success  | schema1 |

  @BLOCKER
  Scenario: add mysqld with disabled="true", no readhost, reload success #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn2" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn2,dn4" name="test2" type="global" />
        </schema>
        <dataNode dataHost="172.100.9.5" database="db1" name="dn2" />
        <dataNode dataHost="172.100.9.5" database="db2" name="dn4" />
        <dataHost balance="1" maxCon="100" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="-1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true"></writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all"

  @NORMAL
  Scenario: add readhost for writehost in disabled state, execute select success with balance not 0 #3
    Given add xml segment to node with attribute "{'tag':'dataHost/writeHost','kv_map':{'host':'hostM1'}, 'childIdx':1}" in "schema.xml"
    """
        <readHost host="hosts1" url="172.100.9.5:3306" user="test" password="111111"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose  | sql      | expect   | db     |
        | test | 111111 | conn_0 | True     | select 2 | success  | schema1 |

  @NORMAL
  Scenario: set dataHost balance=0 in case which readHost will not be used, dble should still check whether readhost connectable #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema dataNode="dn2" name="schema1" sqlMaxLimit="100">
            <table dataNode="dn2,dn4" name="test2" type="global" />
        </schema>
        <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
        <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
        <dataHost maxCon="100" minCon="10" name="172.100.9.6" balance="0" switchType="-1">
            <heartbeat>select user()</heartbeat>
            <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
                <readHost host="hosts1" url="172.100.9.2:3306" user="test" password="222"/>
            </writeHost>
        </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    Given add xml segment to node with attribute "{'tag':'dataHost/writeHost','kv_map':{'host':'hostM2'}}" in "schema.xml"
    """
        <readHost host="hosts1" url="172.100.9.2:3306" user="test" password="111111"/>
    """
    Then execute admin cmd "reload @@config_all"