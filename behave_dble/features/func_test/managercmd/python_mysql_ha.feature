# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/6


Feature: test python script "custom_mysql_ha.py" to change mysql master

  todo: add check dble.log has disable @@/dbgroup @@switch/enable @@

  @restore_mysql_service
  Scenario: when useOuterHa is true, python script does not start #1
     """
     {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
     """
    # set useOuterHa=false
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     /-DuseOuterHa/d
     $a -DuseOuterHa=true
     """
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" url="172.100.9.2:3306" user="test" password="111111" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-master2"
    Then check following "N" exist in dir "/opt/dble/logs" in "dble-1"
      """
      custom_mysql_ha.log
      """
    Then execute sql in "dble-1" in "admin" mode
      | sql                      | expect            |
      | show @@custom_mysql_ha   | has{(('0',),)}    |
    Given start mysql in host "mysql-master2"



  @restore_mysql_service
  Scenario: when useOuterHa is false, mysql not slave, can`t change mysql master ,but python script run #2
     """
     {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
     """
    # set useOuterHa=false
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     /-DuseOuterHa/d
     $a -DuseOuterHa=false
     """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Then execute admin cmd "reload @@config" get the following output
      """
      Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: SelfCheck### there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group2.hostM2]}
      """
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      Write-dbInstance 172.100.9.6:3306 in ha_group2 is not alive!
      Do not switch ha_group2 Write-dbInstance to 172.100.9.6:3306; due to canbemaster status is 0.
      Switch failed!
      """
    Given stop dble in "dble-1"
    Given start mysql in host "mysql-master2"
    Then Start dble in "dble-1"
    Then check following text exist "N" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      Write-dbInstance 172.100.9.6:3306 in ha_group2 is not alive!
      Do not switch ha_group2 Write-dbInstance to 172.100.9.6:3306; due to canbemaster status is 0.
      Switch failed!
      """
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      DbInstance 172.100.9.6:3306 in ha_group2 is normal!
      """


  @restore_mysql_service
  Scenario: when useOuterHa is false, mysql has one slave, python script can change mysql master #3
     """
     {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
     """
    # mysql user encryption,usingDecrypt default false
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     /-DuseOuterHa/d
     $a -DuseOuterHa=false
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" url="172.100.9.2:3306" user="test" password="111111" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Given Restart dble in "dble-1" success

    Given stop mysql in host "mysql-master2"
    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql                      | expect            |
      | show @@custom_mysql_ha   | has{(('1',),)}    |
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      DbInstance 172.100.9.6:3306 in ha_group2 is not alive!
      Get dbGroups from db.xml file.
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="slave1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """

      # block by issue DBLE0REQ-816
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                   | expect      | db      |
#      | conn_1 | False   | drop table if exists sharding_4_t1    | success     | schema1 |
#      | conn_1 | True    | create table sharding_4_t1 (id int)   | success     | schema1 |

    Given start mysql in host "mysql-master2"

    # mysql user usingDecrypt values true
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" usingDecrypt="true" password="NxbH9imEoi3INzkFiiSvGbfXOCzN4COTL0vJdyUZyiEW4+lGFgRagpXDeg/7yzVhRkv4jfxuRTRiux7I3iRDOg==" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" usingDecrypt="true" url="172.100.9.2:3306" user="test" password="cDswIroIVCCGE376ivg0JtCq22RAqdiMkVzHmiJRtP3S1gb8OsSbA58MjqzGR3cvt4oCBv1B2Z/PpnKAU5wQlQ==" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-master2"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="NxbH9imEoi3INzkFiiSvGbfXOCzN4COTL0vJdyUZyiEW4+lGFgRagpXDeg/7yzVhRkv4jfxuRTRiux7I3iRDOg==" user="test" maxCon="1000" minCon="10" usingDecrypt="true" primary="false"/>
      <dbInstance name="slave1" url="172.100.9.2:3306" password="cDswIroIVCCGE376ivg0JtCq22RAqdiMkVzHmiJRtP3S1gb8OsSbA58MjqzGR3cvt4oCBv1B2Z/PpnKAU5wQlQ==" user="test" maxCon="1000" minCon="10" usingDecrypt="true" primary="true"/>
      """
    Given start mysql in host "mysql-master2"

    # check stop and start python script
    Then execute sql in "dble-1" in "admin" mode
      | sql                         | expect            |
      | disable @@custom_mysql_ha   | success           |
      | show @@custom_mysql_ha      | has{(('0',),)}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" url="172.100.9.3:3306" user="test" password="111111" maxCon="1000" minCon="10"/>
    </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="false"/>
        <dbInstance name="slave2" url="172.100.9.2:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | sql                         | expect            |
      | enable @@custom_mysql_ha    | success           |
      | show @@custom_mysql_ha      | has{(('1',),)}    |

      # block by issue DBLE0REQ-816
#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                          | expect      | db      |
#      | conn_1 | False   | drop table if exists test    | success     | schema1 |
#      | conn_1 | True    | create table test (id int)   | success     | schema1 |



  @restore_mysql_service
  Scenario: when useOuterHa is false, mysql has two slave, python script can change mysql master #4
     """
     {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
     """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     /-DuseOuterHa/d
     $a -DuseOuterHa=false
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" url="172.100.9.2:3306" user="test" password="111111" maxCon="1000" minCon="10"/>
        <dbInstance name="slave2" url="172.100.9.3:3306" user="test" password="111111" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      172.100.9.6:3306 in ha_group2 is not alive!
      Get dbGroups from db.xml file.
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Given start mysql in host "mysql-master2"
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """

    @skip
  Scenario: don't use "disable/enable", can change mysql master and active idle DBLE0REQ-816   #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
       <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" />
       <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "1"
      | conn   | toClose | sql                                                                                                                      | db               |
      | conn_0 | False   | select name,db_group,addr,port,primary,active_conn_count,idle_conn_count,max_conn_count,disabled from dble_db_instance   | dble_information |
    Then check resultset "1" has lines with following column values
      | name-0 | db_group-1 | addr-2      | port-3 | primary-4 | active_conn_count-5 | idle_conn_count-6 | max_conn_count-7 | disabled-8 |
      | hostM1 | ha_group1  | 172.100.9.5 | 3306   | true      | 0                   | 10                | 1000             | false      |
      | hostM2 | ha_group2  | 172.100.9.6 | 3306   | true      | 0                   | 10                | 1000             | false      |
      | hostS1 | ha_group2  | 172.100.9.2 | 3306   | false     | 0                   | 0                 | 1000             | false      |
      | hostS2 | ha_group2  | 172.100.9.3 | 3306   | false     | 0                   | 0                 | 1000             | false      |

    Given execute linux command in "behave"
      """
      bash ./compose/docker-build-behave/ChangeMaster.sh dble-2 mysql-master2 dble-3
      """
    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS1'"
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "2"
#      | conn   | toClose | sql                                                                                                                      | db               |
#      | conn_0 | False   | select name,db_group,addr,port,primary,active_conn_count,idle_conn_count,max_conn_count,disabled from dble_db_instance   | dble_information |
#    Then check resultset "2" has lines with following column values
#      | name-0 | db_group-1 | addr-2      | port-3 | primary-4 | active_conn_count-5 | idle_conn_count-6 | max_conn_count-7 | disabled-8 |
#      | hostM1 | ha_group1  | 172.100.9.5 | 3306   | true      | 0                   | 10                | 1000             | false      |
#      | hostM2 | ha_group2  | 172.100.9.6 | 3306   | false     | 0                   | 0                 | 1000             | false      |
#      | hostS1 | ha_group2  | 172.100.9.2 | 3306   | true      | 0                   | 10                | 1000             | false      |
#      | hostS2 | ha_group2  | 172.100.9.3 | 3306   | false     | 0                   | 0                 | 1000             | false      |
#      Given sleep "30" seconds
#      #timeBetweenEvictionRunsMillis defalut is 30s
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "3"
#      | conn   | toClose | sql                                                                                                                      | db               |
#      | conn_0 | False   | select name,db_group,addr,port,primary,active_conn_count,idle_conn_count,max_conn_count,disabled from dble_db_instance   | dble_information |
#    Then check resultset "3" has lines with following column values
#      | name-0 | db_group-1 | addr-2      | port-3 | primary-4 | active_conn_count-5 | idle_conn_count-6 | max_conn_count-7 | disabled-8 |
#      | hostM1 | ha_group1  | 172.100.9.5 | 3306   | true      | 0                   | 10                | 1000             | false      |
#      | hostM2 | ha_group2  | 172.100.9.6 | 3306   | false     | 0                   | 10                | 1000             | false      |
#      | hostS1 | ha_group2  | 172.100.9.2 | 3306   | true      | 0                   | 10                | 1000             | false      |
#      | hostS2 | ha_group2  | 172.100.9.3 | 3306   | false     | 0                   | 0                 | 1000             | false      |

    Given execute linux command in "behave"
      """
      bash ./compose/docker-build-behave/ChangeMaster.sh mysql-master2 dble-2 dble-3
      """
    Then execute admin cmd "dbGroup @@switch name = 'hostS1' master = 'ha_group2'"


  Scenario: in autotest ,Need to manually kill the python3 process #6
    Given execute linux command in "dble-1"
      """
      kill -9 `ps -ef | grep python3 |grep -v grep | awk '{print $2}'`
      """