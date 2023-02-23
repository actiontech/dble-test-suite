# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/6
@skip
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
        <dbInstance name="slave1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-master2"
    Then check following "not" exist in dir "/opt/dble/logs" in "dble-1"
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
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "reload @@config_all -r" get the following output
      """
      Reload Failure, The reason is com.actiontech.dble.config.util.ConfigException: SelfCheck### there are some dbInstance connection failed, pls check these dbInstance:{dbInstance[ha_group2.hostM2]}
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
    #等待custom_mysql_ha程序启动并打印日志
    Given sleep "1" seconds
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


  @restore_mysql_service @skip
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
        <dbInstance name="slave1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Given Restart dble in "dble-1" success

    Given stop mysql in host "mysql-master2"
#    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql                      | expect            |timeout｜
      | show @@custom_mysql_ha   | has{(('1',),)}    |10,1   ｜
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      DbInstance 172.100.9.6:3306 in ha_group2 is not alive!
      Get dbGroups from db.xml file.
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"hostM2\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\" maxCon=\"1000\" minCon=\"10\" primary=\"false\"\/>
      <dbInstance name=\"slave1\" url=\"172.100.9.6:3307\" password=\"111111\" user=\"test\" maxCon=\"1000\" minCon=\"10\" primary=\"true\"\/>
      """

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect      | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1    | success     | schema1 |
      | conn_1 | True    | create table sharding_4_t1 (id int)   | success     | schema1 |

    Given start mysql in host "mysql-master2"

    # mysql user usingDecrypt values true
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" usingDecrypt="true" password="NxbH9imEoi3INzkFiiSvGbfXOCzN4COTL0vJdyUZyiEW4+lGFgRagpXDeg/7yzVhRkv4jfxuRTRiux7I3iRDOg==" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" usingDecrypt="true" url="172.100.9.6:3307" user="test" password="cDswIroIVCCGE376ivg0JtCq22RAqdiMkVzHmiJRtP3S1gb8OsSbA58MjqzGR3cvt4oCBv1B2Z/PpnKAU5wQlQ==" maxCon="1000" minCon="10"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-master2"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"hostM2\" url=\"172.100.9.6:3306\" password=\"NxbH9imEoi3INzkFiiSvGbfXOCzN4COTL0vJdyUZyiEW4\+lGFgRagpXDeg\/7yzVhRkv4jfxuRTRiux7I3iRDOg==\" user=\"test\" maxCon=\"1000\" minCon=\"10\" usingDecrypt=\"true\" primary=\"false\"\/>
      <dbInstance name=\"slave1\" url=\"172.100.9.6:3307\" password=\"cDswIroIVCCGE376ivg0JtCq22RAqdiMkVzHmiJRtP3S1gb8OsSbA58MjqzGR3cvt4oCBv1B2Z\/PpnKAU5wQlQ==\" user=\"test\" maxCon=\"1000\" minCon=\"10\" usingDecrypt=\"true\" primary=\"true\"\/>
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
        <dbInstance name="slave1" url="172.100.9.6:3308" user="test" password="111111" maxCon="1000" minCon="10"/>
    </dbGroup>

     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="false"/>
        <dbInstance name="slave2" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10" primary="true"/>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "admin" mode
      | sql                         | expect            |
      | enable @@custom_mysql_ha    | success           |
      | show @@custom_mysql_ha      | has{(('1',),)}    |

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      | db      |
      | conn_1 | False   | drop table if exists test    | success     | schema1 |
      | conn_1 | False   | create table test (id int)   | success     | schema1 |
      | conn_1 | False   | insert into test values (1)  | success     | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1    | success     | schema1 |
      | conn_1 | True    | drop table if exists test             | success     | schema1 |


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
        <dbInstance name="slave1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10"/>
        <dbInstance name="slave2" url="172.100.9.6:3308" user="test" password="111111" maxCon="1000" minCon="10"/>
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
      <dbInstance name=\"hostM2\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\" maxCon=\"1000\" minCon=\"10\" primary=\"false\"/>
      """
    Given start mysql in host "mysql-master2"
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"hostM2\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\" maxCon=\"1000\" minCon=\"10\" primary=\"false\"/>
      """


  Scenario: don't use "disable/enable", can change mysql master and active idle DBLE0REQ-816   #5
    # rwSplitMode="0"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
       <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" >
            <property name="timeBetweenEvictionRunsMillis">3000</property>
            <property name="idleTimeout">1000</property>
       </dbInstance>
       <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="1000" minCon="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'true',0,10,'false'),('hostS1', 3307,'false',0,0,'false') ,('hostS2', 3308,'false',0,0,'false'))}     |3,1    |

##### change msater to  hostS1  172.100.9.6:3307
    Given change the primary instance of mysql group named "group2" to "mysql-slave1"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS1'"
    Given sleep "4" seconds
      #timeBetweenEvictionRunsMillis is 3s,so hostS1 and hostM2(former master) idle_conn_count is 10
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'false',0,10,'false'),('hostS1', 3307,'true',0,10,'false') ,('hostS2', 3308,'false',0,0,'false'))}    |3,1    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      | db      |
      | conn_1 | False   | drop table if exists test    | success     | schema1 |
      | conn_1 | False   | create table test (id int)   | success     | schema1 |
      | conn_1 | true    | insert into test values (1)  | success     | schema1 |

##### change msater to  mysql-master2
    Given change the primary instance of mysql group named "group2" to "mysql-master2"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostM2'"

    # rwSplitMode="1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true">
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
       <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3" />
       <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="10" minCon="3" >
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -r"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'true',0,3,'false'),('hostS1', 3307,'false',0,3,'false') ,('hostS2', 3308,'false',0,3,'false'))}      |3,1    |
##### change msater to  hostS2
    Given change the primary instance of mysql group named "group2" to "mysql-slave2"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS2'"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'false',0,3,'false'),('hostS1', 3307,'false',0,3,'false') ,('hostS2', 3308,'true',0,3,'false'))}      |3,1    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      | db      |
      | conn_1 | False   | drop table if exists test    | success     | schema1 |
      | conn_1 | False   | create table test (id int)   | success     | schema1 |
      | conn_1 | true    | insert into test values (1)  | success     | schema1 |


##### change msater to  mysql-master2
    Given change the primary instance of mysql group named "group2" to "mysql-master2"
    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostM2'"

    # rwSplitMode="2"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true">
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
       <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3" />
       <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="10" minCon="3" >
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -r"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'true',0,3,'false'),('hostS1', 3307,'false',0,3,'false') ,('hostS2', 3308,'false',0,3,'false'))}      |3,1    |
##### change msater to  hostS2
    Given change the primary instance of mysql group named "group2" to "mysql-slave2"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS2'"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'false',0,3,'false'),('hostS1', 3307,'false',0,3,'false') ,('hostS2', 3308,'true',0,3,'false'))}      |3,1    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      | db      |
      | conn_1 | False   | drop table if exists test    | success     | schema1 |
      | conn_1 | False   | create table test (id int)   | success     | schema1 |
      | conn_1 | true    | insert into test values (1)  | success     | schema1 |

    Given change the primary instance of mysql group named "group2" to "mysql-master2"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostM2'"

    # rwSplitMode="3"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
       <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="10" minCon="3" primary="true">
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
       <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="10" minCon="3" />
       <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="10" minCon="3" >
           <property name="timeBetweenEvictionRunsMillis">3000</property>
           <property name="idleTimeout">1000</property>
       </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -r"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'true',0,3,'false'),('hostS1', 3307,'false',0,3,'false') ,('hostS2', 3308,'false',0,3,'false'))}      |3,1    |

    Given change the primary instance of mysql group named "group2" to "mysql-slave2"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS2'"
    Given sleep "4" seconds
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                      | db               |expect                                                                                                                     |timeout|
      | conn_0 | False   | select name,port,primary,active_conn_count,idle_conn_count,disabled from dble_db_instance where db_group='ha_group2'     | dble_information |has{(('hostM2', 3306,'false',0,3,'false'),('hostS1', 3307,'false',0,3,'false') ,('hostS2', 3308,'true',0,3,'false'))}      |3,1    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                          | expect      | db      |
      | conn_1 | False   | drop table if exists test    | success     | schema1 |
      | conn_1 | False   | create table test (id int)   | success     | schema1 |
      | conn_1 | False   | insert into test values (1)  | success     | schema1 |
      | conn_1 | true    | drop table if exists test    | success     | schema1 |


  Scenario: in autotest ,Need to manually kill the python3 process #6
    Given change the primary instance of mysql group named "group2" to "mysql-master2"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostM2'"

    Given execute linux command in "dble-1"
      """
      ps -ef | grep python3 |grep -v grep | awk '{print $2}' | xargs -r kill -9
      """