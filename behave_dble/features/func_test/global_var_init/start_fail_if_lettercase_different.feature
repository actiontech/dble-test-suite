# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/13 下午12:14
# @Author  : irene-coming
Feature: dble start fail if global var lower_case_table_names are not consistent in all dbGroups
#  lower_case_table_names default value in mysql under linux is 0

  @restore_mysql_config
  Scenario: dble start fail if global var lower_case_table_names of dbInstance are not consistent in 2 dbGroups #1
    """
    {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0}}}
    """
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
#    in template config, there has 2 dbGroups, dbGroups's default lower_case_table_names is 0
    Then restart dble in "dble-1" failed for
    """
    The values of lower_case_table_names for backend MySQLs are different
    """

  @restore_mysql_config
  Scenario: dble start fail if global var lower_case_table_names are not consistent between dbInstance and dbInstance #2
    """
    {'restore_mysql_config':{'mysql-master2':{'lower_case_table_names':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="9" minCon="3" primary="true" readWeight="1">
        </dbInstance>
        <dbInstance name="hostM2" password="111111" url="172.100.9.2:3306" user="test" maxCon="9" minCon="3" readWeight="2">
        </dbInstance>
    </dbGroup>
    """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Then restart dble in "dble-1" failed for
    """
    The values of lower_case_table_names for backend MySQLs are different
    """

  @restore_mysql_config
  Scenario: dble reload fail if global var lower_case_table_names are not consistent between new added writehost and the old ones' #3
    """
    {'restore_mysql_config':{'mysql-master2':{'lower_case_table_names':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable shardingNode="dn1,dn2,dn3,dn4" name="test" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id"/>
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """

    Given restart dble in "dble-1" success
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable shardingNode="dn1,dn2,dn3,dn4" name="test" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
    </schema>

    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" >
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" >
        </dbInstance>
    </dbGroup>
    """
    #reload @@config_all returns failed,and failed info includes the output
    Then execute admin cmd "reload @@config_all" get the following output
    """
    these MySQL's value is not 0 :ha_group2:hostM2
    """
    #dryrun returns success,and success info includes the output
    Then execute admin cmd "dryrun" get the following output
    """
    hasStr{these MySQL's value is not 0 :ha_group2:hostM2}
    """
  @restore_mysql_config
  Scenario: backend mysql heartbeat fail, restore the mysql but its lower_case_table_names are different with the running backend mysqls, then heartbeat to this backend mysql fail #4
    """
    {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
          <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master1"
    Given update file content "/etc/my.cnf" in "mysql-master1" with sed cmds
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
#    sleep more than heartbeat time to make sure heartbeat failed
    Given sleep "3" seconds
    Given record current dble log line number in "log_linenu"
    Given start mysql in host "mysql-master1"
#    sleep more than heartbeat time to make sure heartbeat failed
    Given sleep "3" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    this dbInstance\[=172.100.9.5:3306\].s lower_case is wrong, set heartbeat Error
    """

