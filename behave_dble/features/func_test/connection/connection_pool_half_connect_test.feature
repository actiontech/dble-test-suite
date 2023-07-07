# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2023/06/05

Feature: half-connect test, DBLE0REQ-1716(只影响第三次握手)

  @CRITICAL @restore_network @restart_mysql
  Scenario: 测试dble关闭半连接的功能, dble内部keepalive生效关闭连接之后再关闭防火墙，前端持续hang  #1
    """
    {'restore_network':'mysql-master1'}
    {'restart_mysql':'mysql-master1'}
    """
    Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema name="schema1" sqlMaxLimit="100">
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id" />
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="6" primary="true">
              <property name="connectionTimeout">100000</property>
              <property name="heartbeatPeriodMillis">10800000</property>
              <property name="timeBetweenEvictionRunsMillis">10800000</property>
          </dbInstance>
      </dbGroup>
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DxaIdCheckPeriod=-1
    $a\-DidleTimeout=10800000
    $a\-DtcpKeepIdle=10
    $a\-DtcpKeepInterval=7
    $a\-DtcpKeepCount=3
    """
    Then Restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_1" is more then expect value "6" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                     | success                    | schema1 |
      | conn_1 | False   | create table sharding_2_t1(id int,name varchar(20))    | success                    | schema1 |
      | conn_1 | True    | insert into sharding_2_t1 values (1,'Bob'),(2,'Joe')   | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_2_t1                            | success                    | schema1 |
      | conn_3 | False   | begin                                                  | success                    | schema1 |
      | conn_3 | False   | select * from sharding_2_t1                            | success                    | schema1 |
      | conn_4 | False   | begin                                                  | success                    | schema1 |
      | conn_4 | False   | select * from sharding_2_t1                            | success                    | schema1 |
    #在MySQL服务器端设置防火墙，拦截TCP第三次握手的ACK报文
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -p tcp --tcp-flag ack ack --dport 3306 -j DROP
    """
    #执行语句，制造新建连接的场景
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose   | sql                                     |  db      |
      | conn_5 | true      | select * from sharding_2_t1 where id=1  |  schema1 |
    #按照dble当前的配置,大约第三次握手包重试到第4次会进入dble的keepAlive机制，所以大概等待31s日志中检测连接被关闭
    Given sleep "31" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
    """
     mysqlId 0 close for reason java.io.IOException: Connection timed out
     mysqlId 0 close for reason create fail
    """
    Given execute oscmd in "mysql-master1"
    """
     iptables -F
    """
    #此时查询结果不会返回，因为后端连接被关闭，前端无感知，前端会持续hang直到100s后获取连接超时前端才会返回报错
    Given sleep "70" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1" retry "5" times
    """
    Connection is not available, request timed out after
    """
    #此时查询结果不会返回，因为后端连接被关闭，前端无感知，前端会持续hang
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1" retry "5" times
    """
    1	Bob
    """
    #对于已建立的连接，由于加了防火墙，mysql收不到dble发送的关闭连接的命令，防止连接残留，所以此处重启mysql关闭连接，使用@restart_mysql标签重启mysql。

  @CRITICAL @restore_network
  Scenario: 测试dble关闭半连接的功能, dble内部keepalive生效关闭连接之前关闭防火墙，前端返回正确的结果  #2
    """
    {'restore_network':'mysql-master1'}
    """
    Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema name="schema1" sqlMaxLimit="100">
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id" />
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat keepAlive="1000">select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="6" primary="true">
              <property name="connectionTimeout">900000</property>
              <property name="heartbeatPeriodMillis">10800000</property>
              <property name="timeBetweenEvictionRunsMillis">10800000</property>
          </dbInstance>
      </dbGroup>
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DxaIdCheckPeriod=-1
    $a\-DidleTimeout=10800000
    $a\-DtcpKeepIdle=10
    $a\-DtcpKeepInterval=60
    $a\-DtcpKeepCount=3
    """
    Then Restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_1" is more then expect value "6" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                     | success                    | schema1 |
      | conn_1 | False   | create table sharding_2_t1(id int,name varchar(20))    | success                    | schema1 |
      | conn_1 | True    | insert into sharding_2_t1 values (1,'Bob'),(2,'Joe')   | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_2_t1                            | success                    | schema1 |
      | conn_3 | False   | begin                                                  | success                    | schema1 |
      | conn_3 | False   | select * from sharding_2_t1                            | success                    | schema1 |
      | conn_4 | False   | begin                                                  | success                    | schema1 |
      | conn_4 | False   | select * from sharding_2_t1                            | success                    | schema1 |
    #在MySQL服务器端设置防火墙，拦截TCP第三次握手的ACK报文
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -p tcp --tcp-flag ack ack --dport 3306 -j DROP
    """
    #执行语句，制造新建连接的场景
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose   | sql                                     |  db      |
      | conn_5 | true      | select * from sharding_2_t1 where id=1  |  schema1 |
    #按照dble当前的配置,大约第三次握手包重试到第4次后会进入dble的keepAlive机制，所以10s~210S期间连接不会被关闭
    Given sleep "11" seconds
    Given execute oscmd in "mysql-master1"
    """
     iptables -F
    """
    #去除防火墙后，等到下次tcp层面包重传会执行成功
    Given sleep "5" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1" retry "5" times
    """
    1	Bob
    """
    #从始至终，日志中未有连接被关闭的信息
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
    """
     mysqlId 0 close for reason java.io.IOException: Connection timed out
     mysqlId 0 close for reason create fail
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_2 | True    | commit                                                 | success                    | schema1 |
      | conn_3 | True    | commit                                                 | success                    | schema1 |
      | conn_4 | True    | commit                                                 | success                    | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                         | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and state='idle' and remote_addr='172.100.9.5'           |  length{(7)}  | dble_information  |


  @CRITICAL @restore_network @restart_mysql
  Scenario: 测试dble关闭半连接的功能，dble内部的keepalive比心跳的keepalive的大，心跳连接触发keepalive参数逻辑，其他链接走keepalive机制  #3
    """
    {'restore_network':'mysql-master1'}
    {'restart_mysql':'mysql-master1'}
    """
    Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema name="schema1" sqlMaxLimit="100">
          <shardingTable name="sharding_2_t1" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id" />
      </schema>

      <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
      <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
          <heartbeat keepAlive="10">select user()</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="6" primary="true">
              <property name="connectionTimeout">80000</property>
              <property name="heartbeatPeriodMillis">10000</property>
              <property name="timeBetweenEvictionRunsMillis">10800000</property>
          </dbInstance>
      </dbGroup>
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DxaIdCheckPeriod=-1
    $a\-DidleTimeout=10800000
    $a\-DtcpKeepIdle=40
    $a\-DtcpKeepInterval=5
    $a\-DtcpKeepCount=3
    """
    Then Restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                      | expect        | db                |
      | conn_0 | True    | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_1" is more then expect value "6" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect                     | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                     | success                    | schema1 |
      | conn_1 | False   | create table sharding_2_t1(id int,name varchar(20))    | success                    | schema1 |
      | conn_1 | True    | insert into sharding_2_t1 values (1,'Bob'),(2,'Joe')   | success                    | schema1 |
      | conn_2 | False   | begin                                                  | success                    | schema1 |
      | conn_2 | False   | select * from sharding_2_t1                            | success                    | schema1 |
      | conn_3 | False   | begin                                                  | success                    | schema1 |
      | conn_3 | False   | select * from sharding_2_t1                            | success                    | schema1 |
      | conn_4 | False   | begin                                                  | success                    | schema1 |
      | conn_4 | False   | select * from sharding_2_t1                            | success                    | schema1 |
    #在MySQL服务器端设置防火墙，拦截TCP第三次握手的ACK报文
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -p tcp --tcp-flag ack ack --dport 3306 -j DROP
    """
    #记录日志的行号
    Given record current dble log line number in "log_line_num"
    #执行语句，制造新建连接的场景
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose   | sql                                     |  db      |
      | conn_5 | true      | select * from sharding_2_t1 where id=1  |  schema1 |
    Given sleep "30" seconds
    #进入下一个心跳周期，心跳超过keepalive参数10s，会用新连接发送心跳
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num" in host "dble-1" retry "5" times
    """
     do heartbeat
    """
    #此时其他连接未被关闭
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
     mysqlId 0 close for reason java.io.IOException: Connection timed out
     mysqlId 0 close for reason create fail
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                        | expect        | db                |
      | conn_0 | True    | select * from backend_connections where used_for_heartbeat='false' and remote_addr='172.100.9.5'           |  length{(6)}  | dble_information  |
    Given sleep "25" seconds
    #此时，所有连接被关闭，包括重试的心跳连接
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
    """
     mysqlId 0 close for reason java.io.IOException: Connection timed out
     mysqlId 0 close for reason create fail
    """
    Given execute oscmd in "mysql-master1"
    """
     iptables -F
    """
    #使用@restart_mysql标签重启mysql


  @CRITICAL @restore_network @restart_mysql
  Scenario: 读写分离用户，测试dble关闭半连接的功能, dble内部keepalive生效关闭连接之后再关闭防火墙，前端持续hang  #4
    """
    {'restore_network':'mysql-master1'}
    {'restart_mysql':'mysql-master1'}
    """
    Given delete the following xml segment
        | file          | parent           | child                   |
        | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}        |
        | sharding.xml  | {'tag':'root'}   | {'tag':'shardingNode'}  |
        | db.xml        | {'tag':'root'}   | {'tag':'dbGroup'}       |
        | user.xml        |{'tag':'root'}   | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM2" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="3" primary="true">
              <property name="connectionTimeout">100000</property>
              <property name="heartbeatPeriodMillis">10800000</property>
              <property name="timeBetweenEvictionRunsMillis">10800000</property>
          </dbInstance>
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" maxCon="0"/>
      """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DxaIdCheckPeriod=-1
    $a\-DidleTimeout=10800000
    $a\-DtcpKeepIdle=10
    $a\-DtcpKeepInterval=7
    $a\-DtcpKeepCount=3
    """
    Then Restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "rs_1"
      | conn   | toClose| sql                                                                                                                                      | expect        | db                |
      | conn_0 | True   | select remote_processlist_id from backend_connections where state='idle' and used_for_heartbeat='false' and remote_addr='172.100.9.5'    | success       | dble_information  |
    Then kill the redundant connections if "rs_1" is more then expect value "3" in "mysql-master1"
    Then execute sql in "dble-1" in "user" mode
     |user | conn   | toClose | sql                                                    | expect                     | db      |
     |rwS1 | conn_1 | False   | drop table if exists sharding_2_t1                     | success                    | db1     |
     |rwS1 | conn_1 | False   | create table sharding_2_t1(id int,name varchar(20))    | success                    | db1     |
     |rwS1 | conn_1 | True    | insert into sharding_2_t1 values (1,'Bob'),(2,'Joe')   | success                    | db1     |
     |rwS1 | conn_2 | False   | begin                                                  | success                    | db1     |
     |rwS1 | conn_2 | False   | select * from sharding_2_t1                            | success                    | db1     |
     |rwS1 | conn_3 | False   | begin                                                  | success                    | db1     |
     |rwS1 | conn_3 | False   | select * from sharding_2_t1                            | success                    | db1     |
     |rwS1 | conn_4 | False   | begin                                                  | success                    | db1     |
     |rwS1 | conn_4 | False   | select * from sharding_2_t1                            | success                    | db1     |
    #在MySQL服务器端设置防火墙，拦截TCP第三次握手的ACK报文
    Given execute oscmd in "mysql-master1"
    """
    iptables -A INPUT -p tcp --tcp-flag ack ack --dport 3306 -j DROP
    """
    #执行语句，制造新建连接的场景
    Then execute "user" cmd  in "dble-1" at background
      |user | conn   | toClose   | sql                                     |  db      |
      |rwS1 | conn_5 | true      | select * from sharding_2_t1 where id=1  |  d1      |
    #按照dble当前的配置,大约第三次握手包重试到第4次会进入dble的keepAlive机制，所以大概等待31s日志中检测连接被关闭
    Given sleep "31" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
    """
     mysqlId 0 close for reason java.io.IOException: Connection timed out
     mysqlId 0 close for reason create fail
    """
    Given execute oscmd in "mysql-master1"
    """
     iptables -F
    """
    #此时查询结果不会返回，因为后端连接被关闭，前端无感知，前端会持续hang
    Then check following text exist "N" in file "/opt/dble/logs/dble_user_query.log" in host "dble-1" retry "5" times
    """
    1	Bob
    """
    #使用@restart_mysql标签重启mysql



