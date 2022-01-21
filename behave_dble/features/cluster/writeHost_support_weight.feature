# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2018/11/5
Feature:check if sharding.xml in which writeHost contains "weight" push success in cluster after execute "reload @@config_all"
#github issue #793

  @CRITICAL @skip_restart
  Scenario: set parameter "readWeight" for writeHost in cluster, then reload #1
       Given delete the following xml segment
        |file         | parent         | child               |
        |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
        |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
        |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
       Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
       """
              <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
                  <shardingTable shardingNode="dn1,dn2,dn3,dn4" name="test" function="hash-four" shardingColumn="id"/>
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
     <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true" readWeight="3"/>
     <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="9" minCon="3" readWeight="3"/>
     <dbInstance name="hostM3" password="111111" url="172.100.9.3:3306" user="test" maxCon="9" minCon="3" readWeight="3"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
      Given sleep "2" seconds
      Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      readWeight="3"
     """
      Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      readWeight="3"
      """
