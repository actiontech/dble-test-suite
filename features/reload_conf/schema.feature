Feature: #
  @current
  Scenario: #test add schema/sharding_table/global_table schema+table+user
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

  Scenario: #test add/drop child table
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

  Scenario: #test almost empty schema.xml
    # test no dataNode in schema.xml
    Given delete the following xml segment
      |file        | parent                                       | child                                          |
      |schema.xml  |{'tag':'root'}                              | {'tag':'schema'}  |
      |schema.xml  |{'tag':'root'}                              | {'tag':'dataNode'}  |
    Then execute admin cmd "reload @@config_all"
    #test nothing in schema.xml
    Given delete the following xml segment
      |file        | parent                                       | child                                          |
      |schema.xml  |{'tag':'root'}                              | {'tag':'dataHost'}  |
    Then execute admin cmd "reload @@config_all"
    #add datahost
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.5" slaveThreshold="100" switchType="1" writeType="0">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>

	    <dataHost balance="0" maxCon="1000" minCon="10" name="172.100.9.6" slaveThreshold="100" switchType="1" writeType="0">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
		    </writeHost>
	    </dataHost>

    """
    #add datanode
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
	    <dataNode dataHost="172.100.9.6" database="db1" name="dn2" />
	    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
	    <dataNode dataHost="172.100.9.6" database="db2" name="dn4" />
	    <dataNode dataHost="172.100.9.5" database="db3" name="dn5" />


    """
    #add schema
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
	    <schema dataNode="dn5" name="mytest" sqlMaxLimit="100">
		    <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
	    </schema>


    """
    Then execute admin cmd "reload @@config_all"