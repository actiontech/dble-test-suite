# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2021/02/24
Feature: test connection pool

  @NORMAL
  Scenario: connection validation test #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="11" minCon="5" primary="true" readWeight="1"  id="xx1">
             <property name="connectionTimeout">abc</property>
             <property name="connectionHeartbeatTimeout">30</property>
             <property name="testOnCreate">-1</property>
             <property name="testOnBorrow">4</property>
             <property name="testOnReturn">string</property>
             <property name="testWhileIdle">string</property>
             <property name="timeBetweenEvictionRunsMillis">30000</property>
             <property name="evictorShutdownTimeoutMillis">20000</property>
             <property name="idleTimeout">150000</property>
             <property name="heartbeatPeriodMillis">20000</property>
        </dbInstance>
     </dbGroup>
     """
    Then Restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    property [[] connectionTimeout []] '\''abc'\'' data type should be long
    property [[] testOnBorrow []] '\''4'\'' data type should be boolean
    property [[] testOnCreate []] '\''-1'\'' data type should be boolean
    property [[] testOnReturn []] '\''string'\'' data type should be boolean
    property [[] testWhileIdle []] '\''string'\'' data type should be boolean
    """

    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "reload config: load all xml info start" in host "dble-1"
    """
    property [[] connectionTimeout []] '\''abc'\'' data type should be long
    property [[] testOnBorrow []] '\''4'\'' data type should be boolean
    property [[] testOnCreate []] '\''-1'\'' data type should be boolean
    property [[] testOnReturn []] '\''string'\'' data type should be boolean
    property [[] testWhileIdle []] '\''string'\'' data type should be boolean
    """

  @NORMAL @restore_network
  Scenario: test connection param "testOnBorrow"  #2
     """
    {'restore_network':'mysql-master1'}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="5" primary="true">
             <property name="testOnBorrow">true</property>
             <property name="connectionHeartbeatTimeout">2000</property>
             <property name="timeBetweenEvictionRunsMillis">180000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))  | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                  | success                    | schema1 |
      | conn_1 | False   | begin                                                      | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                             | success                    | schema1 |
      | conn_2 | False   | begin                                                      | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                             | success                    | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                                             | db               |
      | conn_0 | True    | select * from backend_connections where state='IDLE' and used_for_heartbeat='false' and db_instance_name='M1'    | dble_information |
    Then get index:"0" column value of "select local_port from dble_information.backend_connections where db_instance_name='M1' and used_for_heartbeat='false' and state='IDLE'" named as "local_port_1"
    #simulate the rest connection's network was broken
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutConnection.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /ping/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutConnection.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_3 | True    | select * from sharding_4_t1 where id=2          | schema1 |
    Then check btrace "BtraceAboutConnection.java" output in "dble-1" with "1" times
    """
    sending ping signal
    """
    Then execute oscmd in "mysql-master1" by parameter from resultset "local_port_1"
    """
    iptables -A INPUT -p tcp --dport {0} -j DROP
    """
    #sleep 2s wait to exceed connectionHeartbeatTimeout
    Given sleep "2" seconds
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    ERROR
    """
    Given stop btrace script "BtraceAboutConnection.java" in "dble-1"
    Given destroy btrace threads list
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_B"
      | conn   | toClose | sql                                                                                                                             | db                 |
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false' and db_instance_name='M1'    | dble_information |
    #create a new connection to continue executing sql
    Then check resultsets "idle_connection_B" including resultset "idle_connection_A" in following columns
      | column                      | column_index |
      | backend_conn_id            | 0           |
      | remote_processlist_id     | 5           |
    Given execute sql "3" times in "dble-1" at concurrent
      | sql                             | db      |
      | select * from sharding_4_t1 | schema1 |
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    2	2
    """
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"

  @NORMAL @btrace @restore_network
  Scenario: test connection param "testOnReturn"  #3
    """
    {'restore_network':'mysql-master1'}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="5" primary="true">
             <property name="testOnReturn">true</property>
             <property name="connectionHeartbeatTimeout">2000</property>
             <property name="timeBetweenEvictionRunsMillis">180000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))  | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                  | success                    | schema1 |
      | conn_1 | False   | begin                                                      | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                             | success                    | schema1 |
      | conn_2 | False   | begin                                                      | success                    | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                             | success                    | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                                            | db               |
      | conn_0 | True    | select * from backend_connections where state='idle' and used_for_heartbeat='false' and db_instance_name='M1'   | dble_information |
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutConnection.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /ping/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutConnection.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_3 | True    | insert into sharding_4_t1 values(4,4)           | schema1 |
    Then check btrace "BtraceAboutConnection.java" output in "dble-1" with "1" times
    """
    sending ping signal
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_B"
      | conn   | toClose | sql                                                                                                         | db               |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and db_instance_name='M1'   | dble_information |
    #simulate the rest connection's network was broken
    Then get index:"0" column value of "select local_port from dble_information.backend_connections where db_instance_name='M1' and used_for_heartbeat='false' and sql not in('SELECT * FROM sharding_4_t1 LIMIT 100')" named as "local_port_1"
    Then execute oscmd in "mysql-master1" by parameter from resultset "local_port_1"
    """
    iptables -A INPUT -p tcp --dport {0} -j DROP
    """
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    ERROR
    """
    Given stop btrace script "BtraceAboutConnection.java" in "dble-1"
    Given destroy btrace threads list
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect                    | db      |
      | conn_0 | True    | select * from sharding_4_t1                | has{((2,'2'),(4,'4'),)} | schema1 |
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"

  @NORMAL @btrace @restore_network
  Scenario: test connection param "testOnCreate"  #4
    """
    {'restore_network':'mysql-master1'}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="3" primary="true">
             <property name="testOnCreate">true</property>
             <property name="connectionHeartbeatTimeout">2000</property>
             <property name="timeBetweenEvictionRunsMillis">180000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))    | success     | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                  | success     | schema1 |
      | conn_1 | False   | begin                                                  | success     | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                            | success     | schema1 |
      | conn_2 | False   | begin                                                  | success     | schema1 |
      | conn_2 | False   | select * from sharding_4_t1                            | success     | schema1 |
    #simulate the rest connection's network was broken
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutConnection.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /ping/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(5000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutConnection.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                  | db      |
      | conn_3 | True    | insert into sharding_4_t1 values(4,4)           | schema1 |
    Then check btrace "BtraceAboutConnection.java" output in "dble-1" with "1" times
    """
    sending ping signal
    """
    #simulate the rest connection's network was broken
    Then get index:"0" column value of "select local_port from dble_information.backend_connections where db_instance_name='M1' and used_for_heartbeat='false' and state='IN CREATION OR OUT OF POOL'" named as "local_port_1"
    Then execute oscmd in "mysql-master1" by parameter from resultset "local_port_1"
    """
    iptables -A INPUT -p tcp --dport {0} -j DROP
    """
    #sleep 5s to wait btrace hang over
    Given sleep "5" seconds
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    ERROR
    """
   Given stop btrace script "BtraceAboutConnection.java" in "dble-1"
   Given destroy btrace threads list
   #create a new connection to execute sql and then release
   Given execute single sql in "dble-1" in "admin" mode and save resultset in "idle_connection_A"
      | conn   | toClose | sql                                                                                                                                      | expect        |db              |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'         | length{(1)} | dble_information  |
   Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect                    | db      |
      | conn_0 | True    | select * from sharding_4_t1                | has{((2,'2'),(4,'4'),)} | schema1 |
   Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
   Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"

  @NORMAL
  Scenario: test connection param "testWhileIdle"  #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="10" minCon="5" primary="true" readWeight="1" id="dbInstance1">
             <property name="testWhileIdle">true</property>
             <property name="timeBetweenEvictionRunsMillis">5000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                     | success                    | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int,name varchar(20))  | success                    | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,2)                  | success                    | schema1 |
      | conn_1 | False   | begin                                                      | success                    | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                             | success                    | schema1 |
    Given record current dble log line number in "log_linenu"
    #sleep timeBetweenEvictionRunsMillis seconds to check idle connections
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
     """
     db instance\[M1\] stats (total=5, active=2, idle=3, idleTest=0 waiting=0)
     """

  @NAOMAL @restore_mysql_service
  #DBLE0REQ-940

      @skip
#    DBLE0REQ-1028
  Scenario: test connection param "connectionTimeout"  #6
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="10" minCon="3" primary="true" id="dbInstance1">
             <property name="testOnBorrow">true</property>
             <property name="connectionTimeout">4000</property>
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="timeBetweenEvictionRunsMillis">180000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                           | success | schema1 |
      | conn_0 | True    | create table sharding_4_t1(id int,name varchar(20))        | success | schema1 |
    Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
    Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"
    Given update file content "./assets/BtraceAboutConnection.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(10L)/
    /ping/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(15000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceAboutConnection.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                                     | db      |
      | conn_3 | True    | insert into sharding_4_t1 values(4,4)                          | schema1 |
#      | conn_0 | True    | create table if not exists nosharding1(id int,name varchar(10)) | schema1 |
    Given stop mysql in host "mysql-master1"
    #sleep 5s to wait btrace hang over
    Given sleep "5" seconds
    #    DBLE0REQ-1028
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    """
    Connection is not available, request timed out after
    """
   Given stop btrace script "BtraceAboutConnection.java" in "dble-1"
   Given destroy btrace threads list
   Given delete file "/opt/dble/BtraceAboutConnection.java" on "dble-1"
   Given delete file "/opt/dble/BtraceAboutConnection.java.log" on "dble-1"

  @CRITICAL @restore_global_setting
  Scenario: test reuse connection  #7
     """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="20" minCon="10" primary="true">
             <property name="heartbeatPeriodMillis">180000</property>
             <property name="timeBetweenEvictionRunsMillis">180000</property>
        </dbInstance>
     </dbGroup>
     """
    Then execute admin cmd "reload @@config_all"
    #1.context is consistent, and then reuse the same connection
    Then execute sql in "mysql-master1"
      | sql                        | expect  |
      | set global general_log=off | success |
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /tmp/general.log
    """
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                              | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                           | success | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,name varchar(20))        | success | schema1 |
      | conn_0 | True    | insert into sharding_4_t1 values(2,'2'),(4,'4')             | success | schema1 |
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                            |
      | conn_0 | False   | set global log_output=file                     |
      | conn_0 | False   | set global general_log_file='/tmp/general.log' |
      | conn_0 | True    | set global general_log=on                      |
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect           | db      |
      | conn_0 | True    | select * from sharding_4_t1 where id=2       | has{((2,'2'),)} | schema1 |
      | conn_0 | True    | select * from sharding_4_t1 where id=2       | has{((2,'2'),)} | schema1 |
    Then get result of oscmd named "rs_A" in "mysql-master1"
    """
    grep -i 'select \* from sharding_4_t1 where id=2' /tmp/general.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_A" value is "1"
    #2.context is inconsistent, and then reuse the same connection
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | expect           | db      |
      | conn_1 | True    | select * from sharding_4_t1 where id=4       | has{((4,'4'),)} | schema1 |
    Then get result of oscmd named "rs_B" in "mysql-master1"
    """
    grep -i 'select \* from sharding_4_t1 where' /tmp/general.log |awk '{print $2}'|wc -l
    """
    Then check result "rs_B" value is "3"
    Then get result of oscmd named "rs_C" in "mysql-master1"
    """
    grep -i 'select \* from sharding_4_t1 where' /tmp/general.log |awk '{print $2}'|uniq|wc -l
    """
    Then check result "rs_C" value is "1"
    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                        | expect  |
      | conn_0 | True    | set global general_log=off | success |
    Given execute oscmd in "mysql-master1"
    """
    rm -rf /tmp/general.log
    """






