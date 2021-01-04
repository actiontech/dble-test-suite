# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
Feature: shardingNode's lettercase is insensitive, that should not be affected by lower_case_table_names

  @NORMAL @restore_mysql_config

  Scenario: shardingNode's lettercase is insensitive, but reference to the shardingNode name must consistent #1
   """
    {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0}}}
   """
    Given delete the following xml segment
    |file        | parent          | child               |
    |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
    |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
    |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema shardingNode="DN1" name="schema1" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="DN1,dn3" />
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="DN1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="9" minCon="3" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 0
    """
    Given Restart dble in "dble-1" success
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
       <schema shardingNode="dn1" name="schema1" sqlMaxLimit="100">
           <globalTable name="test" shardingNode="dn1,dn3" />
       </schema>
    """
    Then restart dble in "dble-1" failed for
    """
    shardingNode 'DN1' is not found
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
       <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    """
    Given Restart dble in "dble-1" success