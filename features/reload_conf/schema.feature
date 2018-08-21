Feature: #
  Scenario: #1 test add schema/sharding_table/global_table schema+table+user
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" type="global" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql
        | user | passwd | conn   | toClose  | sql                                           | expect                             | db     |
        | test | 111111 | conn_0 | False    | create table if not exists test_table(id int) | success                            | mytest |
        | test | 111111 | conn_0 | False    | show full tables                              | has{('test_table','BASE TABLE')}   | mytest |
        | test | 111111 | conn_0 | True    | drop table test_table                         | success                            | mytest |
    Then execute admin cmd "rollback @@config"
    Given delete the following xml segment
      |file        | parent                                       | child                                           |
      |schema.xml  |{'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'test_table'}}  |

  Scenario: #2 test add/drop child table
    Given add xml segment to node with attribute "{'tag':'schema','kv_map':{'name':'mytest'}}" in "schema.xml"
    """
        <table name="test_table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" >
            <childTable name="child_table" primaryKey="id" joinKey="id" parentKey="id" />
        </table>
    """
    #test add/drop dataNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="172.100.9.6" database="db3" name="testdn"/>
    """
    Then execute admin cmd "reload @@config_all"
    Given delete the following xml segment
      |file        | parent                                       | child                                          |
      |schema.xml  |{'tag':'schema','kv_map':{'name':'mytest'}}   | {'tag':'table','kv_map':{'name':'test_table'}}  |
    Then execute admin cmd "reload @@config_all"

  @current
  Scenario: #3 schema.xml stable test
    #3.1 schema.xml with least content,  dble starts, reload @@config_all success, manager sql success
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
      |server.xml  |{'tag':'root'}   | {'tag':'user', 'kv_map':{'name':'test'}}  |
    Then execute admin cmd "reload @@config_all"
    Given Restart dble in "dble-1"
#    Then execute sql in "manager/manager.sql" to check manager work fine
    Then execute admin cmd "reload @@config_all"

    #3.2 schema.xml contains stopped mysqld, start the mysqld, delete the mysqld
    Given stop mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    	<schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn3" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn3" />
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
    """
#    todo: dble should start up even datahost is down, wait dev to fix
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    Given start mysql in host "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
        <user name="test">
            <property name="password">111111</property>
            <property name="schemas">mytest</property>
        </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql
        | user | passwd | conn   | toClose  | sql      | expect   | db     |
        | test | 111111 | conn_0 | True     | select 2 | success  | mytest |
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
      |server.xml  |{'tag':'root'}   | {'tag':'user', 'kv_map':{'name':'test'}}  |
    Then execute admin cmd "reload @@config_all"

    #3.3 add mysqld with only heartbeat, no readhost or writehost
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    	<schema dataNode="dn2" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn2,dn4" name="test2" type="global" />
	    </schema>
	    <dataNode dataHost="dh2" database="db1" name="dn2" />
	    <dataNode dataHost="dh2" database="db2" name="dn4" />
	    <dataHost balance="1" maxCon="100" minCon="10" name="dh2" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test" disabled="true"></writeHost>
	    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
        <user name="test">
            <property name="password">111111</property>
            <property name="schemas">mytest</property>
        </user>
    """
    Then execute admin cmd "reload @@config_all"

    #3.4 add mysqld with only readhost, no writehost, then delete
    Given add xml segment to node with attribute "{'tag':'dataHost/writeHost','kv_map':{'host':'hostM1'}, 'childIdx':1}" in "schema.xml"
    """
        <readHost host="hosts1" url="172.100.9.5:3306" user="test" password="111111"/>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql
        | user | passwd | conn   | toClose  | sql      | expect   | db     |
        | test | 111111 | conn_0 | True     | select 2 | success  | mytest |

  Scenario: #4 schema.xml only contain partial content
    #4.1 schema.xml only has dataNodes,  dble starts successful,
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    # todo : dble should start only with <dataNode>
    Given Restart dble in "dble-1"
    """
    Restart dble failure
    """

    ##4.2 schema.xml only has <dataHost>,  dble starts successful
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
    """
    Given Restart dble in "dble-1"

  Scenario:# when configuration file contains illegal label<test/>
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
	    <dataHost balance="0" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
	    <test>
	    </test>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
  Scenario: # test when <dataNode> with "$" and the label closure
    #1.when <dataNode> wirh "$"
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
    	<schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="dh1" database="db$1-2" name="dn$1-2" />
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "Reload @@config_all"
    Then execute sql
     | user | passwd | conn   | toClose  | sql                                           | expect                             | db     |
     | test | 111111 | conn_0 | False    | drop table if exists test                 | success                            | mytest |
     | test | 111111 | conn_0 | True    | create table test(id int)                 | success                            | mytest |

     #2.when <readHost> closure is <readHost></readHost>
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
    	<schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="dh1" database="db$1-2" name="dn$1-2" />
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		         <readHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
		         </readHost>
		    </writeHost>
	    </dataHost>
    """
    #todo: reload should success
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
    #2.when <readHost> put outside <wirteHost>
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
    	<schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="dh1" database="db$1-2" name="dn$1-2" />
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
		    <readHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test"/>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """
  Scenario: # test when rule is not defined in rule.xml
     Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
    	<schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2" name="test" rule="sharding-test" />
	    </schema>
	    <dataNode dataHost="dh1" database="db$1-2" name="dn$1-2" />
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh1" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload config failure
    """

  Scenario: # test create physical database
     Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
    	 <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>

	    <dataNode dataHost="172.100.9.5" database="da1" name="dn1" />
	    <dataNode dataHost="172.100.9.6" database="da1" name="dn2" />
	    <dataNode dataHost="172.100.9.5" database="da2" name="dn3" />
	    <dataNode dataHost="172.100.9.6" database="da2" name="dn4" />
	    <dataNode dataHost="172.100.9.5" database="da3" name="dn5" />

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
		    </writeHost>
	    </dataHost>
    """
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                            | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da3 | success  |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                            | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |         |
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                          | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da1' | has{('da1',)}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da2' | has{('da2',)}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da3' | has{('da3',)}  |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                           | expect           | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da1'  |  has{('da1',)}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da2'  |  has{('da2',)}  |         |
   Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
   Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
   """
        <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>

     	 <dataNode dataHost="172.100.9.5" database="da11" name="dn1" />
	    <dataNode dataHost="172.100.9.6" database="da11" name="dn2" />
	    <dataNode dataHost="172.100.9.5" database="da21" name="dn3" />
	    <dataNode dataHost="172.100.9.6" database="da21" name="dn4" />
	    <dataNode dataHost="172.100.9.5" database="da31" name="dn5" />

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
		    </writeHost>
	    </dataHost>
   """
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                             | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da11 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da21 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da31 | success  |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                             | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da11 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da21 | success  |         |
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin cmd "create database @@dataNode ='dn1,dn2'"
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                           | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da11' | has{('da11',)} |        |
        | test | 111111 | conn_0 | True     | show databases like 'da21' | length{(0)}    |         |
        | test | 111111 | conn_0 | True     | show databases like 'da31' | length{(0)}    |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                              | expect           | db    |
        | test | 111111 | conn_0 | True     | show databases like 'da11'    |  has{('da11',)} |       |
        | test | 111111 | conn_0 | True     | show databases like 'da21'  |  length{(0)}    |       |
    Then execute admin cmd "create database @@dataNode ='dn1,dn2,dn3,dn4,dn5'"
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                          | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da1' | has{('da1',)}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da2' | has{('da2',)}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da3' | has{('da3',)}  |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                           | expect           | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da1'  |  has{('da1',)}  |         |
        | test | 111111 | conn_0 | True     | show databases like 'da2'  |  has{('da2',)}  |         |
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
        <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn10,dn11,dn20,dn21" name="test" rule="hash-four" />
	    </schema>

     	 <dataNode dataHost="172.100.9.5" database="da0$0-1" name="dn1$0-1" />
	    <dataNode dataHost="172.100.9.6" database="da0$0-1" name="dn2$0-1" />
	    <dataNode dataHost="172.100.9.5" database="da31" name="dn5" />

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
		    </writeHost>
	    </dataHost>
     """
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                             | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da00 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da01 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da31 | success  |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                             | expect   | db      |
        | test | 111111 | conn_0 | True     | drop database if exists da00 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da01 | success  |         |
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin cmd "create database @@dataNode ='dn10,dn11,dn20,dn21'"
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                           | expect          | db     |
        | test | 111111 | conn_0 | True     | show databases like 'da00' | has{('da00',)} |        |
        | test | 111111 | conn_0 | True     | show databases like 'da01' | has{('da01',)} |         |
        | test | 111111 | conn_0 | True     | show databases like 'da31' | length{(0)}    |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                              | expect           | db    |
        | test | 111111 | conn_0 | True     | show databases like 'da00'    |  has{('da00',)} |       |
        | test | 111111 | conn_0 | True     | show databases like 'da01'    |  has{('da01',)} |       |


  Scenario: # github issue 598+636
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    	 <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>

	    <dataNode dataHost="172.100.9.5" database="da1" name="dn1" />
	    <dataNode dataHost="172.100.9.6" database="da1" name="dn2" />
	    <dataNode dataHost="172.100.9.5" database="da2" name="dn3" />
	    <dataNode dataHost="172.100.9.6" database="da2" name="dn4" />
	    <dataNode dataHost="172.100.9.5" database="da3" name="dn5" />

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
		    </writeHost>
	    </dataHost>
    """
    Then execute sql in mysql
        | user | passwd | conn   | toClose  | sql                            | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da3 | success  |         |
    Then execute sql in node2
        | user | passwd | conn   | toClose  | sql                            | expect   | db     |
        | test | 111111 | conn_0 | True     | drop database if exists da1 | success  |         |
        | test | 111111 | conn_0 | True     | drop database if exists da2 | success  |         |
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute admin sql
        | user         | passwd    | conn   | toClose | sql      | expect  | db     |
        | root         | 111111    | conn_0 | True    | show @@version | success | mytest |
    Then execute sql
        | user | passwd | conn   | toClose | sql                             | expect   | db      |
        | test | 111111 | conn_0 | True    | create table if not exists test(id int,name varchar(20))    | ConnectionException  | mytest |

  Scenario: #test balance
    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="0" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute sql
    | user | passwd | conn   | toClose | sql                                              | expect   | db      |tb  |count|
    | test | 111111 | conn_0 | True    | drop table if exists test                     | success  | mytest |test|1000 |
    | test | 111111 | conn_0 | True    | create table test(id int,name varchar(20))  | success  | mytest |test|1000 |
    | test | 111111 | conn_0 | True    | batch_insert                                    | success | mytest |test|1000 |
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success | db1 |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success | db1 |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |tb   |count|
    | test  | 111111    | conn_0 | True    | batch_select     | success | mytest  |test |1001 |
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(1000L,)} | db1 |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  has{(0L,)} | db1 |

    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="1" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success | db1 |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success | db1 |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success | db1 |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success | db1 |
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |tb   |count|
    | test  | 111111    | conn_0 | True    | batch_select     | success | mytest  |test |1001 |
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(0L,)} | db1 |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  has{(1000L,)} | db1 |

    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="2" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |tb   |count|
    | test  | 111111    | conn_0 | True    | batch_select     | success | mytest  |test |1001 |
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{500} |  |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  balance{500} |  |

    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="3" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
              <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test"/>
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in slave2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |tb   |count|
    | test  | 111111    | conn_0 | True    | batch_select     | success | mytest  |test |1001 |
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(0L,)} |  |
    Then execute sql in slave2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{500} |  |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  balance{500} |  |

    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="3" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
              <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test" weight="1"/>
              <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test" weight="2"/>
		    </writeHost>
	    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql in slave2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |tb   |count|
    | test  | 111111    | conn_0 | True    | batch_select     | success | mytest  |test |1001 |
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(0L,)} |  |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | balance{333} |  |
    Then execute sql in slave2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        |  balance{666} |  |

     Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="3" tempReadHostAvailable="1" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
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
    Given Restart dble in "dble-1"
    Given stop mysql in host "mysql-master2"
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global general_log=on        | success |     |
    | test  | 111111    | conn_0 | True    | set global log_output='table'   | success |     |
    | test  | 111111    | conn_0 | True    | truncate table mysql.general_log| success |     |
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |tb   |count|
    | test  | 111111    | conn_0 | True    | batch_select     | success | mytest  |test |1001 |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db     |
    | test  | 111111    | conn_0 | True    | select count(*) from mysql.general_log where argument like'SELECT name%FROM test%'        | has{(1000L,)} |  |
    Given start mysql in host "mysql-master2"

    Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" rule="hash-four" />
	    </schema>
	    <dataNode dataHost="dh1" database="db1" name="dn1" />
	    <dataNode dataHost="dh1" database="db2" name="dn2" />
	    <dataNode dataHost="dh1" database="db3" name="dn3" />
	    <dataNode dataHost="dh1" database="db4" name="dn4" />
	    <dataHost balance="3" tempReadHostAvailable="0" maxCon="9" minCon="3" name="dh1" slaveThreshold="100" switchType="1">
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
    Given Restart dble in "dble-1"
    Given stop mysql in host "mysql-master2"
    Then execute sql
    | user  | passwd    | conn   | toClose | sql               | expect  | db       |
    | test  | 111111    | conn_0 | True    | select name from test;   | error totally whack | mytest  |
    Given start mysql in host "mysql-master2"
    Then execute sql in node2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |
    Then execute sql in slave1
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |
    Then execute sql in slave2
    | user  | passwd    | conn   | toClose | sql                                 | expect  | db  |
    | test  | 111111    | conn_0 | True    | set global log_output='file'   | success |     |



