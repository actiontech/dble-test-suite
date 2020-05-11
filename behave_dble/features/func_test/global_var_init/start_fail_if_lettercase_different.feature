# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# @Time    : 2020/3/13 下午12:14
# @Author  : irene-coming
Feature: dble start fail if global var lower_case_table_names are not consistent in all dataHosts
#  lower_case_table_names default value in mysql under linux is 0

  @restore_mysql_config
  Scenario: dble start fail if global var lower_case_table_names of writeHosts are not consistent in 2 dataHosts #1
    """
    {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0}}}
    """
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
#    in template config, there has 2 dataHosts, dataHost's default lower_case_table_names is 0
    Then restart dble in "dble-1" failed for
    """
    The values of lower_case_table_names for backend MySQLs are different
    """

  @restore_mysql_config
  Scenario: dble start fail if global var lower_case_table_names are not consistent between readHost and writeHost #2
    """
    {'restore_mysql_config':{'mysql-master2':{'lower_case_table_names':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" maxCon="9" minCon="3" name="ha_group2" slaveThreshold="100" >
       <heartbeat>select user()</heartbeat>
       <writeHost host="hostM1" password="111111" url="172.100.9.6:3306" user="test">
          <readHost host="hostM2" url="172.100.9.2:3306" password="111111" user="test"/>
       </writeHost>
    </dataHost>
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

  @restore_mysql_config @skip #for issue http://10.186.18.11/jira/browse/DBLE0REQ-228
  Scenario: dble reload fail if global var lower_case_table_names are not consistent between new added writehost and the old ones' #3
    """
    {'restore_mysql_config':{'mysql-master2':{'lower_case_table_names':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
        <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
        <table name="sharding_2_t1" dataNode="dn1,dn3" rule="hash-two" />
    </schema>

    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />

    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Given restart dble in "dble-1" success
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
    /lower_case_table_names/d
    /server-id/a lower_case_table_names = 1
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
        <table dataNode="dn1,dn2,dn3,dn4" name="test" type="global" />
        <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two" />
        <table name="sharding_4_t1" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
    </schema>

    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group2" database="db1" name="dn2" />
    <dataNode dataHost="ha_group1" database="db2" name="dn3" />
    <dataNode dataHost="ha_group2" database="db2" name="dn4" />
    <dataNode dataHost="ha_group1" database="db3" name="dn5" />

    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
        </writeHost>
    </dataHost>

    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    these MySQL's value is not 0 :ha_group2:hostM2
    """
    Then execute admin cmd "dryrun" get the following output
    """
    The values of lower_case_table_names for backend MySQLs are different.These MySQL's value is not 0 :ha_group2:hostM2
    """

  @restore_mysql_config
  Scenario: backend mysql heartbeat fail, restore the mysql but its lower_case_table_names are different with the running backend mysqls, then heartbeat to this backend mysql fail #4
    """
    {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="dataNodeHeartbeatPeriod">2000</property>
    </system>
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
    this dataHost\[=172.100.9.5:3306\].s lower_case is wrong, set heartbeat Error
    """

