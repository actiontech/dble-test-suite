Feature: #test dataNode_caseSensitive ,whatever default dataNode is lower case or upper case ,dble should start success
   Scenario:# 1. set default dataNode lowercase ,mysql lower_case_table_name = 0
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
	    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
	    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
	    <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
     """
     Given restart mysql in "mysql-master1" with options
       """
       /lower_case_table_names/d
       /server-id/a lower_case_table_names = 0
      """
     Given Restart dble in "dble-1"

   Scenario:# 2. set default dataNode lowercase ,mysql lower_case_table_name = 1
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
	    <dataNode dataHost="172.100.9.5" database="db1" name="dn1" />
	    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
	    <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
     """
     Given restart mysql in "mysql-master1" with options
       """
       /lower_case_table_names/d
       /server-id/a lower_case_table_names = 1
      """
     Given Restart dble in "dble-1"

   Scenario:# 3. set default dataNode uppercase ,mysql lower_case_table_name = 0
      Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
      <schema dataNode="DN1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="DN1,dn3" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="172.100.9.5" database="db1" name="DN1" />
	    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
	    <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
     """
     Given restart mysql in "mysql-master1" with options
       """
       /lower_case_table_names/d
       /server-id/a lower_case_table_names = 0
      """
     Given Restart dble in "dble-1"

   Scenario:# 4. set default dataNode uppercase ,mysql lower_case_table_name = 1
      Given delete the following xml segment
      |file        | parent          | child               |
      |schema.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataNode'}  |
      |schema.xml  |{'tag':'root'}   | {'tag':'dataHost'}  |
     Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
     """
      <schema dataNode="DN1" name="mytest" sqlMaxLimit="100">
		    <table dataNode="DN1,dn3" name="test" type="global" />
	    </schema>
	    <dataNode dataHost="172.100.9.5" database="db1" name="DN1" />
	    <dataNode dataHost="172.100.9.5" database="db2" name="dn3" />
	    <dataHost balance="0" maxCon="9" minCon="3" name="172.100.9.5" slaveThreshold="100" switchType="-1">
		    <heartbeat>select user()</heartbeat>
		    <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
		    </writeHost>
	    </dataHost>
     """
     Given restart mysql in "mysql-master1" with options
       """
       /lower_case_table_names/d
       /server-id/a lower_case_table_names = 1
      """
     Given Restart dble in "dble-1"

