# Created by yexiaoli at 2018/11/5
Feature:check if schema.xml in which writeHost contains "weight" push success in cluster after execute "reload @@config_all"
#github issue #793

  @CRITICAL @skip_restart
  Scenario: set parameter "weight" for writeHost in cluster, then reload #1
       Given delete the following xml segment
        |file         | parent         | child               |
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
                 <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test" weight="3">
                    <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test" weight="3"/>
                    <readHost host="hostM3" url="172.100.9.3:3306" password="111111" user="test" weight="3"/>
                  </writeHost>
              </dataHost>
      """
      Then execute admin cmd "reload @@config_all"
      Given sleep "2" seconds
      Then check following " " exist in file "/opt/dble/conf/schema.xml" in "dble-2"
      """
      weight="3"
     """
      Then check following " " exist in file "/opt/dble/conf/schema.xml" in "dble-3"
      """
      weight="3"
      """
