# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/10/27
Feature: #test show @@heartbeat DBLE0REQ-167


@restore_mysql_service @restore_network
  Scenario: use show @@heartbeat in 9066 to check rs_code #1
    """
    {'restore_mysql_service':{'mysql-slave1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
    {'restore_network':'mysql-master2'}
    {'restore_network':'mysql-slave1'}
    """
# set balance=0 ,one slave disabled="true"
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
       <heartbeat>select 1</heartbeat>
       <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test">
       </writeHost>
    </dataHost>

    <dataHost balance="2" maxCon="1000" minCon="10" name="ha_group2" slaveThreshold="100" >
       <heartbeat errorRetryCount="0" timeout="5">select user()</heartbeat>
       <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
          <readHost host="hostS1" url="172.100.9.6:3307" password="111111" user="test"/>
          <readHost host="hostS2" url="172.100.9.6:3308" password="111111" user="test" disabled="true"/>
       </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
    <system>
        <property name="dataNodeHeartbeatPeriod">5000</property>
    </system>
    """
    Given Restart dble in "dble-1" success
#case one slave is disable then check RS_CODE is "init",one slave is enable then check RS_CODE is "ok"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "11"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "11" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6 | STOP-9 |
      | hostM1 | 172.100.9.5 | 3306   | 1         | 0         | false  |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 5000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | 1         | 5000      | false  |
      | hostS2 | 172.100.9.6 | 3308   | 0         | 5000      | true   |
#case one slave is down ,check master RS_CODE is "ok" and slave RS_CODE is "error"
    Given stop mysql in host "mysql-slave1"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "12"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "12" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6 | STOP-9 |
      | hostM1 | 172.100.9.5 | 3306   | 1         | 0         | false  |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 5000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | -1        | 5000      | false  |
      | hostS2 | 172.100.9.6 | 3308   | 0         | 5000      | true   |
    Given start mysql in host "mysql-slave1"
#because heartbeat timeout is set to 5 seconds,so wait 5 seconds to check slave RS_CODE is "ok"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "13"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "13" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6 | STOP-9 |
      | hostM1 | 172.100.9.5 | 3306   | 1         | 0         | false  |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 5000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | 1         | 5000      | false  |
      | hostS2 | 172.100.9.6 | 3308   | 0         | 5000      | true   |
    #case one slave set iptables to check slave RS_CODE is "timeout"
    Given execute oscmd in "mysql-slave1"
      """
      iptables -A INPUT -s 172.100.9.1 -p tcp --dport 3307 -j DROP
      iptables -A OUTPUT -d 172.100.9.1 -p tcp --dport 3307 -j DROP
      """
    Given execute oscmd in "mysql-slave1"
    """
    iptables -L
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                                                                                                   | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM1', '172.100.9.5', 3306, 1}, hasStr{'hostM2', '172.100.9.6', 3306, 1}, hasStr{'hostS1', '172.100.9.6', 3307, -2}, hasStr{'hostS2', '172.100.9.6', 3308, 0}, | 60      |
    Given execute oscmd in "mysql-slave1"
    """
    iptables -F
    """
    Given execute oscmd in "mysql-slave1"
    """
    iptables -L
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                                                                                                  | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM1', '172.100.9.5', 3306, 1}, hasStr{'hostM2', '172.100.9.6', 3306, 1}, hasStr{'hostS1', '172.100.9.6', 3307, 1}, hasStr{'hostS2', '172.100.9.6', 3308, 0}, | 60      |


# change heartbeat errorRetryCount and timeout to set connection retry and check slave RS_CODE is "ok"
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" name="ha_group1" slaveThreshold="100" maxCon="1000" minCon="10">
        <heartbeat>select 1</heartbeat>
        <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test"/>
    </dataHost>

    <dataHost balance="2" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
        <heartbeat errorRetryCount="2" timeout="10">show slave status</heartbeat>
        <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
          <readHost host="hostS1" password="111111" url="172.100.9.6:3307" user="test" />
        </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-slave1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "21"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
#check slave is "error" and RETRY is equal errorRetryCount=2 DBLE0REQ-633
    Then check resultset "21" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6  | STOP-9 |
      | hostM1 | 172.100.9.5 | 3306   | 1         | 0          | false  |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 10000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | -1        | 10000      | false  |
    Given start mysql in host "mysql-slave1"
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "22"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "22" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6  | STOP-9 |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 10000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | 1         | 10000      | false  |

# case 3:add new slave and down old slave,check salve RS_CODE
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="2" name="ha_group2" slaveThreshold="100" maxCon="1000" minCon="10">
      <heartbeat errorRetryCount="0" timeout="10">show slave status</heartbeat>
      <writeHost host="hostM2" password="111111" url="172.100.9.6:3306" user="test">
        <readHost host="hostS1" password="111111" url="172.100.9.6:3307" user="test" />
        <readHost host="hostS2" password="111111" url="172.100.9.6:3308" user="test" />
      </writeHost>
    </dataHost>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-slave1"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "31"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "31" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6 | STOP-9 |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 10000     | false  |
      | hostS1 | 172.100.9.6 | 3307   | -1        | 10000     | false  |
      | hostS2 | 172.100.9.6 | 3308   | 1         | 10000     | false  |
    Given start mysql in host "mysql-slave1"
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "32"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "32" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6  | STOP-9 |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 10000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | 1         | 10000      | false  |
      | hostS2 | 172.100.9.6 | 3308   | 1         | 10000      | false  |

# case 4 :set master down to check RS_CODE
    Given stop mysql in host "mysql-master2"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "41"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "41" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6 | STOP-9 |
      | hostM2 | 172.100.9.6 | 3306   | -1        | 10000     | false  |
      | hostS1 | 172.100.9.6 | 3307   | 1         | 10000     | false  |
      | hostS2 | 172.100.9.6 | 3308   | 1         | 10000     | false  |
    Given start mysql in host "mysql-master2"
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "42"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "42" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | TIMEOUT-6  | STOP-9 |
      | hostM2 | 172.100.9.6 | 3306   | 1         | 10000      | false  |
      | hostS1 | 172.100.9.6 | 3307   | 1         | 10000      | false  |
      | hostS2 | 172.100.9.6 | 3308   | 1         | 10000      | false  |
    #case set master iptables to check master RS_CODE is "timeout"
    Given execute oscmd in "mysql-master2"
      """
       iptables -A INPUT -s 172.100.9.1 -p tcp --dport 3306 -j DROP
       iptables -A OUTPUT -d 172.100.9.1 -p tcp --dport 3306 -j DROP
      """
    Given execute oscmd in "mysql-master2"
    """
    iptables -L
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                                                        | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, -2}, hasStr{'hostS1', '172.100.9.6', 3307, 1}, hasStr{'hostS2', '172.100.9.6', 3308, 1} | 60      |
    Given execute oscmd in "mysql-master2"
    """
    iptables -L
    """
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given execute oscmd in "mysql-master2"
    """
    iptables -L
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                                                      | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 1}, hasStr{'hostS1', '172.100.9.6', 3307, 1}, hasStr{'hostS2', '172.100.9.6', 3308, 1 | 60      |
    Then execute admin cmd "reload @@config"
