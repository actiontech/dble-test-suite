# Copyright (C) 2016-2022 ActionTech.
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
# set rwSplitMode=0 ,one slave disabled="true"
    Given delete the following xml segment
      | file           | parent         | child                  |
      | db.xml         | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat errorRetryCount="0" timeout="5">show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" >
        <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" disabled="true"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
#case one slave is disable then check RS_CODE is "init",one slave is enable then check RS_CODE is "ok"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "11"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "11" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10 |
      | hostM1 | 172.100.9.5 | 3306   | ok        | 0       | idle     | 0         | false  | None          |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 5000      | false  | None          |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | idle     | 5000      | false  | None          |
      | hostS2 | 172.100.9.3 | 3306   | init      | 0       | idle     | 5000      | true   | None          |
#case one slave is down ,check master RS_CODE is "ok" and slave RS_CODE is "error"
    Given stop mysql in host "mysql-slave1"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "12"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "12" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10      |
      | hostM1 | 172.100.9.5 | 3306   | ok        | 0       | idle     | 0         | false  | None               |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 5000      | false  | None               |
      | hostS1 | 172.100.9.2 | 3306   | error     | 0       | idle     | 5000      | false  | connection Error   |
      | hostS2 | 172.100.9.3 | 3306   | init      | 0       | idle     | 5000      | true   | None               |
    Given start mysql in host "mysql-slave1"
#because heartbeat timeout is set to 5 seconds,so wait 5 seconds to check slave RS_CODE is "ok"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "13"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "13" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10  |
      | hostM1 | 172.100.9.5 | 3306   | ok        | 0       | idle     | 0         | false  | None           |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 5000      | false  | None           |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | idle     | 5000      | false  | None           |
      | hostS2 | 172.100.9.3 | 3306   | init      | 0       | idle     | 5000      | true   | None           |
#case one slave set iptables to check slave RS_CODE is "time_out"
    Given execute oscmd in "mysql-slave1"
      """
      iptables -A INPUT -s 172.100.9.1 -j DROP
      iptables -A OUTPUT -d 172.100.9.1 -j DROP
      """
    Given sleep "20" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "16"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "16" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10 |
      | hostM1 | 172.100.9.5 | 3306   | ok        | 0       | 0         | false  | None          |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | 5000      | false  | None          |
      | hostS1 | 172.100.9.2 | 3306   | time_out  | 0       | 5000      | false  | None          |
      | hostS2 | 172.100.9.3 | 3306   | init      | 0       | 5000      | true   | None          |

    Given execute oscmd in "mysql-slave1"
    """
    iptables -F
    """
    Given sleep "20" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "17"
      | conn   | toClose | sql               |
      | conn_0 | true    | show @@heartbeat  |
    Then check resultset "17" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10  |
      | hostM1 | 172.100.9.5 | 3306   | ok        | 0       | 0         | false  | None           |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | 5000      | false  | None           |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | 5000      | false  | None           |
      | hostS2 | 172.100.9.3 | 3306   | init      | 0       | 5000      | true   | None           |

# change heartbeat errorRetryCount and timeout to set connection retry and check slave RS_CODE is "ok"
    Given delete the following xml segment
      | file           | parent         | child                  |
      | db.xml         | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat errorRetryCount="2" timeout="10">show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" >
        <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-slave1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "21"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
#check slave is "error" and RETRY is equal errorRetryCount=2 DBLE0REQ-633
    Then check resultset "21" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6  | STOP-9 | RS_MESSAGE-10    |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
      | hostS1 | 172.100.9.2 | 3306   | error     | 2       | idle     | 10000      | false  | connection Error |
    Given start mysql in host "mysql-slave1"
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "22"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "22" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6  | STOP-9 | RS_MESSAGE-10    |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |

# case 3:add new slave and down old slave,check salve RS_CODE
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat  errorRetryCount="0" timeout="10">show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
                <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" >
                <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
        <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" >
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given stop mysql in host "mysql-slave1"
    Given sleep "5" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "31"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "31" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10     |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 10000     | false  | None              |
      | hostS1 | 172.100.9.2 | 3306   | error     | 0       | idle     | 10000     | false  | connection Error  |
      | hostS2 | 172.100.9.3 | 3306   | ok        | 0       | idle     | 10000     | false  | None              |
    Given start mysql in host "mysql-slave1"
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "32"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "32" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6  | STOP-9 | RS_MESSAGE-10    |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
      | hostS2 | 172.100.9.3 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |

# case 4 :set master down to check RS_CODE
    Given stop mysql in host "mysql-master2"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "41"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "41" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6 | STOP-9 |
      | hostM2 | 172.100.9.6 | 3306   | error     | 0       | idle     | 10000     | false  |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | idle     | 10000     | false  |
      | hostS2 | 172.100.9.3 | 3306   | ok        | 0       | idle     | 10000     | false  |
    Given start mysql in host "mysql-master2"
    Given sleep "10" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "42"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "42" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | STATUS-5 | TIMEOUT-6  | STOP-9 | RS_MESSAGE-10    |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
      | hostS2 | 172.100.9.3 | 3306   | ok        | 0       | idle     | 10000      | false  | None             |
#case set master iptables to check master RS_CODE is "time_out"
    Given execute oscmd in "mysql-master2"
      """
       iptables -A INPUT -s 172.100.9.1 -j DROP
       iptables -A OUTPUT -d 172.100.9.1 -j DROP
      """
    Given sleep "20" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "43"
      | conn   | toClose | sql               |
      | conn_0 | false   | show @@heartbeat  |
    Then check resultset "43" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10 |
      | hostM2 | 172.100.9.6 | 3306   | time_out  | 0       | 10000     | false  | None          |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | 10000     | false  | None          |
      | hostS2 | 172.100.9.3 | 3306   | ok        | 0       | 10000     | false  | None          |
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given sleep "20" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "44"
      | conn   | toClose | sql               |
      | conn_0 | true    | show @@heartbeat  |
    Then check resultset "44" has lines with following column values
      | NAME-0 | HOST-1      | PORT-2 | RS_CODE-3 | RETRY-4 | TIMEOUT-6 | STOP-9 | RS_MESSAGE-10 |
      | hostM2 | 172.100.9.6 | 3306   | ok        | 0       | 10000     | false  | None          |
      | hostS1 | 172.100.9.2 | 3306   | ok        | 0       | 10000     | false  | None          |
      | hostS2 | 172.100.9.3 | 3306   | ok        | 0       | 10000     | false  | None          |
    Then execute admin cmd "reload @@config"
