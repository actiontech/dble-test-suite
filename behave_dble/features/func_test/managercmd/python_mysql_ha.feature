# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/6
 # 3.20.07新增
Feature: test python script "custom_mysql_ha.py" to change mysql master

  todo: add check dble.log has disable @@/dataHost @@switch/enable @@

  @restore_mysql_service
  Scenario: when useOuterHa is true, python script does not start #1
     """
     {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
     """
    # set useOuterHa=true
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
     """
     <property name="useOuterHa">true</property>
    """
    Given Restart dble in "dble-1" success
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10" >
       <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="slave1" url="172.100.9.6:3307" user="test" password="111111"/>
        </writeHost>
     </dataHost>
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
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
     """
     <property name="useOuterHa">false</property>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    # 3.22.07开始，stop mysql后执行reload不会报错，因为这时配置未变更，不会测试连接有效性
    Then execute admin cmd "reload @@config_all" get the following output
      """
      Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: SelfCheck### there are some datasource connection failed, pls check these datasource:{DataHost[ha_group2.hostM2]}
      """
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      172.100.9.6:3306 in ha_group2 is not alive!
      Do not switch ha_group2 writehost to 172.100.9.6:3306;due to canbemaster status is 0.
      Switch failed!
      """
    Given stop dble in "dble-1"
    Given start mysql in host "mysql-master2"
    Then Start dble in "dble-1"
    #等待custom_mysql_ha程序启动并打印日志
    Given sleep "1" seconds
    Then check following text exist "N" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      172.100.9.6:3306 in ha_group2 is not alive!
      Do not switch ha_group2 writehost to 172.100.9.6:3306;due to canbemaster status is 0.
      Switch failed!
      """
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      Instance 172.100.9.6:3306 in ha_group2 is normal!
      """


  @restore_mysql_service
  Scenario: when useOuterHa is false, mysql has one slave, python script can change mysql master #3
     """
     {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
     """
    # mysql user encryption,usingDecrypt default false
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
     """
     <property name="useOuterHa">false</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
       <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="slave1" url="172.100.9.6:3307" user="test" password="111111"/>
        </writeHost>
     </dataHost>
    """
    Given Restart dble in "dble-1" success

    Given stop mysql in host "mysql-master2"
#    Given sleep "5" seconds
    Then execute sql in "dble-1" in "admin" mode
      | sql                      | expect            | timeout |
      | show @@custom_mysql_ha   | has{(('1',),)}    | 10,1    |
    ##python脚本判断 Write-dbInstance 和 DbInstance的时间误差问题
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      172.100.9.6:3306 in ha_group2 is not alive!
      Get hosts from schema.xml file.
      """
    Then check following text exist "Y" in file "/opt/dble/conf/schema.xml" in host "dble-1"
      """
      <readHost host=\"hostM2\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\" disabled=\"false\" id=\"hostM2\" weight=\"0\"/>
      <writeHost host=\"slave1\" url=\"172.100.9.6:3307\" password=\"111111\" user=\"test\" disabled=\"false\" id=\"slave1\" weight=\"0\">
      """

#     Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                   | expect      | db      | timeout |
#      | conn_1 | False   | drop table if exists sharding_4_t1    | success     | schema1 | 6,2     |
#      | conn_1 | True    | create table sharding_4_t1 (id int)   | success     | schema1 | 6,2     |

    Given start mysql in host "mysql-master2"

    # mysql user usingDecrypt values true
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
       <heartbeat>select user()</heartbeat>
       <writeHost host="hostM2" usingDecrypt="1" password="NxbH9imEoi3INzkFiiSvGbfXOCzN4COTL0vJdyUZyiEW4+lGFgRagpXDeg/7yzVhRkv4jfxuRTRiux7I3iRDOg==" url="172.100.9.6:3306" user="test">
       <readHost host="slave1" usingDecrypt="1" url="172.100.9.6:3307" user="test" password="cDswIroIVCCGE376ivg0JtCq22RAqdiMkVzHmiJRtP3S1gb8OsSbA58MjqzGR3cvt4oCBv1B2Z/PpnKAU5wQlQ==" />
       </writeHost>
     </dataHost>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-master2"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/conf/schema.xml" in host "dble-1"
    """
    <readHost host=\"hostM2\" url=\"172.100.9.6:3306\" password=\"NxbH9imEoi3INzkFiiSvGbfXOCzN4COTL0vJdyUZyiEW4\+lGFgRagpXDeg/7yzVhRkv4jfxuRTRiux7I3iRDOg==\" user=\"test\" usingDecrypt=\"1\" disabled=\"false\" id=\"hostM2\" weight=\"0\"/>
    <writeHost host=\"slave1\" url=\"172.100.9.6:3307\" password=\"cDswIroIVCCGE376ivg0JtCq22RAqdiMkVzHmiJRtP3S1gb8OsSbA58MjqzGR3cvt4oCBv1B2Z/PpnKAU5wQlQ==\" user=\"test\" usingDecrypt=\"1\" disabled=\"false\" id=\"slave1\" weight=\"0\">
    """
    Given start mysql in host "mysql-master2"

    # check stop and start python script
    Then execute sql in "dble-1" in "admin" mode
      | sql                         | expect            |
      | disable @@custom_mysql_ha   | success           |
      | show @@custom_mysql_ha      | has{(('0',),)}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
        <readHost host="slave1" url="172.100.9.6:3308" user="test" password="111111" />
      </writeHost>
    </dataHost>

     <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10" >
       <heartbeat>select user()</heartbeat>
       <writeHost host="slave2" url="172.100.9.6:3307" user="test" password="111111">
         <readHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test" />
       </writeHost>
     </dataHost>
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
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
     """
     <property name="useOuterHa">false</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <dataHost balance="0" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10" >
       <heartbeat>select user()</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="slave1" url="172.100.9.6:3307" user="test" password="111111" />
        <readHost host="slave2" url="172.100.9.6:3308" user="test" password="111111" />
        </writeHost>
     </dataHost>
    """
    Given Restart dble in "dble-1" success
    Given stop mysql in host "mysql-master2"
    Given sleep "2" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/custom_mysql_ha.log" in host "dble-1"
      """
      172.100.9.6:3306 in ha_group2 is not alive!
      Get hosts from schema.xml file.
      """
    Then check following text exist "Y" in file "/opt/dble/conf/schema.xml" in host "dble-1"
      """
      <readHost host=\"hostM2\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\"
      """
    Given start mysql in host "mysql-master2"
    Then check following text exist "Y" in file "/opt/dble/conf/schema.xml" in host "dble-1"
      """
      <readHost host=\"hostM2\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\"
      """


  Scenario: in autotest ,Need to manually kill the python3 process #5
    Given change the primary instance of mysql group named "group2" to "mysql-master2"

    Then execute admin cmd "dataHost @@switch name = 'ha_group2' master = 'hostM2'"

    Given execute linux command in "dble-1"
      """
      ps -ef | grep python3 |grep -v grep | awk '{print $2}' | xargs -r kill -9
      """