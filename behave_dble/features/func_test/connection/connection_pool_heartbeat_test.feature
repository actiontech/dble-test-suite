# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2022/11/16

Feature: connection pool basic test - heartbeat create connections
  @CRITICAL @btrace
  Scenario: test initial connection pool: except heartbeat will not create connections  #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
             <property name="idleTimeout">300000</property>
             <property name="timeBetweenEvictionRunsMillis">10000</property>
             <property name="heartbeatPeriodMillis">1000</property>
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given delete file "/opt/dble/fillPool.java" on "dble-1"
    Given delete file "/opt/dble/fillPool.java.log" on "dble-1"
    Given record current dble log line number in "log_linenu"
    Given update file content "./assets/fillPool.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /fillPool/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "fillPool.java" in "dble-1"
    Then execute admin cmd "reload @@config_all -r"
    Then check btrace "fillPool.java" output in "dble-1" with ">0" times
    """
    get into fillPool
    """
    Given stop btrace script "fillPool.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    complexQueryWorker\] \(com.actiontech.dble.backend.pool.ConnectionPool.*\- need add
    """
     Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    \[connection-pool-evictor-thread\] \(com.actiontech.dble.backend.pool.ConnectionPool.*\- need add
    """
    # 此处的连接包含检查元数据的并发连接，reload时每个节点下发都会下发 show full tables where Table_type ='BASE TABLE'（日志中有体现），show create table（日志中没体现）
    # 检查元数据时会先检查默认节点，然后是其他节点（其他节点之间是异步的），此处有1默认节点，2个其他节点，并且reload检查元数据时创建连接和使用连接都是异步的，所以最大可能用到3*2=6根连接
    # 后面再出现连接超过最大范围值的话：1.可以考虑是issue；2.或者是reload逻辑变更其他地方也需要用到连接
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                   | expect                     | db                | timeout |
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'     | length_balance{10,0.6}     | dble_information  | 6,2     |


  @CRITICAL @restore_mysql_service
  Scenario: expect heartbeat create connections when heartbeat status changes from Error to OK #2
    """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="4" primary="true">
             <property name="idleTimeout">300000</property>
             <property name="timeBetweenEvictionRunsMillis">3600000</property>
             <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given record current dble log line number in "log_linenu"
    Given stop mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1" retry "5,1" times
    """
    heartbeat to \[ha_group1:hostM1:172.100.9.5:3306\] setError
    """
    Given start mysql in host "mysql-master1"
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1" retry "5,1" times
    """
    complexQueryWorker\] \(com.actiontech.dble.backend.pool.ConnectionPool.*\- need add
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                    | expect       | db                |
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'      | length{(4)}  | dble_information  |



  @CRITICAL @restore_network
  Scenario: expect heartbeat create connections when heartbeat status changes from Timeout to OK #3
    """
    {'restore_network':'mysql-master1'}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="4" primary="true">
             <property name="idleTimeout">300000</property>
             <property name="timeBetweenEvictionRunsMillis">3600000</property>
             <property name="heartbeatPeriodMillis">5000</property>
        </dbInstance>
    </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute linux command in "dble-1" and save result in "heartbeat_master1"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -e "select * from dble_information.backend_connections where used_for_heartbeat='true' and remote_addr='172.100.9.5'" | awk '{print $6, $NF}' | awk '{print $1}'
    """
    Given kill all backend conns in "mysql-master1" except ones in "heartbeat_master1"
    Given record current dble log line number in "log_linenu"
    Given execute oscmd in "mysql-master1"
      """
      iptables -A INPUT -s 172.100.9.1 -p tcp --dport 3306 -j DROP
      """
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1" retry "5,1" times
    """
    heartbeat to \[ha_group1:hostM1:172.100.9.5:3306\] setTimeout
    """
    Given execute oscmd in "mysql-master1"
      """
      iptables -F
      """
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    complexQueryWorker\] \(com.actiontech.dble.backend.pool.ConnectionPool.*\- need add
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                    | expect       | db                |
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'      | length{(4)}  | dble_information  |