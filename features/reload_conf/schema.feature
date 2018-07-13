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
        | test | 111111 | conn_0 | False    | drop table test_table                         | success                            | mytest |
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
	    <dataHost balance="0" maxCon="100" minCon="10" name="dh2" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
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
    Given add xml segment to node with attribute "{'tag':'dataHost','kv_map':{'name':'dh2'}, 'childIdx':1}" in "schema.xml"
    """
        <readHost host="hosts1" url="172.100.9.5:3306" user="test" password="111111" weight="" usingDecrypt=""/>
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
     | test | 111111 | conn_0 | False    | create table test(id int)                 | success                            | mytest |

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
