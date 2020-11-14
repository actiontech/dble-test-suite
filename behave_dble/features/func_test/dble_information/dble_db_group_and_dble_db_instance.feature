# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# update by quexiuping at 2020/8/26

Feature:  dble_db_group test
#@skip_restart
   Scenario:  dble_db_group table #1
  #case desc dble_db_group
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_1"
#      | conn   | toClose | sql                     | db               |
#      | conn_0 | False   | desc dble_db_group | dble_information |
#    Then check resultset "dble_db_group_1" has lines with following column values
#      | Field-0   | Type-1      | Null-2 | Key-3 | Default-4 | Extra-5 |
#| name              | varchar(64) | NO   | PRI  | None    |       |
#| heartbeat_stmt    | varchar(64) | NO   |      | None    |       |
#| heartbeat_timeout | int(11)     | YES  |      | 0       |       |
#| heartbeat_retry   | int(11)     | YES  |      | 1       |       |
#| rw_split_mode     | int(11)     | NO   |      | None    |       |
#| delay_threshold   | int(11)     | YES  |      | -1      |       |
#| disable_ha        | varchar(5)  | YES  |      | false   |       |
#| active            | varchar(5)  | YES  |      | false   |       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_2"
      | conn   | toClose | sql                         | db               |
      | conn_0 | False   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_2" has lines with following column values
      | name-0    | heartbeat_stmt-1 | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_group1 | select user()    | 0                   | 1                 | 0               | 100               | false        | true     |
      | ha_group2 | select user()    | 0                   | 1                 | 0               | 100               | false        | true     |
  #case change db.xml and reload
    Given delete the following xml segment
      | file           | parent         | child                  |
      | db.xml         | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_1" disableHA="true" >
        <heartbeat errorRetryCount="0" timeout="100">show slave status</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="2" name="ha_2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_3" delayThreshold="1000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_1" database="db3" name="dn5" />
    """
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwSplit" password="111111" dbGroup="ha_1" maxCon="20"/>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_group_3"
      | conn   | toClose | sql                         | db               |
      | conn_0 | False   | select * from dble_db_group | dble_information |
    Then check resultset "dble_db_group_3" has lines with following column values
      | name-0 | heartbeat_stmt-1  | heartbeat_timeout-2 | heartbeat_retry-3 | rw_split_mode-4 | delay_threshold-5 | disable_ha-6 | active-7 |
      | ha_1   | show slave status | 100                 | 0                 | 1               | -1                | true         | true     |
      | ha_2   | select user()     | 0                   | 1                 | 2               | 100               | false        | true     |
      | ha_3   | show slave status | 0                   | 1                 | 0               | 1000              | false        | true     |

  #case select limit/order by
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                               | expect                                                                                                                           |
      | conn_0 | False   | select * from dble_db_group limit 1                          | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'),)}                                                                 |
      | conn_0 | False   | select * from dble_db_group order by name desc limit 2       | has{(('ha_3', 'show slave status', 0, 1, 0, 1000, 'false', 'true'), ('ha_2', 'select user()', 0, 1, 2, 100, 'false', 'true'))}        |
  #case select max/min
      | conn_0 | False   | select max(delay_threshold) from dble_db_group         | has{((1000,),)}      |
      | conn_0 | False   | select min(delay_threshold) from dble_db_group         | has{((-1,),)}       |
  #case select where like
      | conn_0 | False   | select * from dble_db_group where heartbeat_stmt ='show slave status'      | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'),('ha_3', 'show slave status', 0, 1, 0, 1000, 'false', 'true'))}         |
      | conn_0 | False   | select * from dble_db_group where name like '%ha%'                         | length{(3)}                                                                                                                               |
  #case select where [sub-query]
      | conn_0 | False   | select * from dble_db_group where name in (select db_group from dble_db_instance) and rw_split_mode=0     | has{(('ha_3', 'show slave status', 0, 1, 0, 1000, 'false', 'true'))}                                                              |
      | conn_0 | False   | select * from dble_db_group where name >all (select db_group from dble_db_instance)                       | length{(0)}                                                                                                                       |
      | conn_0 | False   | select * from dble_db_group where name < any (select db_group from dble_db_instance)                      | has{(('ha_1', 'show slave status', 100, 0, 1, -1, 'true', 'true'), ('ha_2', 'select user()', 0, 1, 2, 100, 'false', 'true'))}     |
      | conn_0 | False   | select * from dble_db_group where name = any (select db_group from dble_db_instance)                      | length{(3)}                                                                                                                       |
  #case select field
#      | conn_0 | False   | select a.*,b.* from dble_db_group a inner join dble_db_instance b on a.name=b.db_group where a.heartbeat_retry = 0     |         |
#      | conn_0 | False   | select * from dble_db_group where name in (select sharding_node from dble_db_instance where name ='schema1')       |         |
#      | conn_0 | False   | select name,heartbeat_stmt from dble_db_group where rw_split_mode > 0                                             |         |




@skip_restart

   Scenario:  dble_db_instance table #2
  #case desc dble_db_instance
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_1"
      | conn   | toClose | sql                     | db               |
      | conn_0 | False   | desc dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_1" has lines with following column values
      | Field-0                           | Type-1       | Null-2 | Key-3 | Default-4 | Extra-5 |
      | name                              | varchar(64)  | NO     | PRI   | None      |         |
      | db_group                          | varchar(64)  | NO     | PRI   | None      |         |
      | addr                              | varchar(64)  | NO     |       | None      |         |
      | port                              | int(11)      | NO     |       | None      |         |
      | user                              | varchar(64)  | NO     |       | None      |         |
      | password_encrypt                  | varchar(256) | NO     |       | None      |         |
      | encrypt_configured                | varchar(5)   | YES    |       | true      |         |
      | primary                           | varchar(5)   | NO     |       | None      |         |
      | active_conn_count                 | int(11)      | YES    |       | 0         |         |
      | idle_conn_count                   | int(11)      | YES    |       | None      |         |
      | read_conn_request                 | int(11)      | YES    |       | 0         |         |
      | write_conn_request                | int(11)      | YES    |       | 0         |         |
      | disabled                          | varchar(5)   | YES    |       | false     |         |
      | last_heartbeat_ack_timestamp      | varchar(64)  | YES    |       | None      |         |
      | last_heartbeat_ack                | varchar(32)  | YES    |       | None      |         |
      | heartbeat_status                  | varchar(32)  | YES    |       | None      |         |
      | heartbeat_failure_in_last_5min    | int(11)      | YES    |       | None      |         |
      | min_conn_count                    | int(11)      | NO     |       | None      |         |
      | max_conn_count                    | int(11)      | NO     |       | None      |         |
      | read_weight                       | int(11)      | YES    |       | 0         |         |
      | id                                | varchar(64)  | YES    |       | None      |         |
#      | connection_timeout                | int(11)      | YES    |       | 30000     |         |
      | connection_heartbeat_timeout      | int(11)      | YES    |       | 20        |         |
      | test_on_create                    | varchar(64)  | YES    |       | false     |         |
      | test_on_borrow                    | varchar(64)  | YES    |       | false     |         |
      | test_on_return                    | varchar(64)  | YES    |       | false     |         |
      | test_while_idle                   | varchar(64)  | YES    |       | false     |         |
      | time_between_eviction_runs_millis | int(11)      | YES    |       | 30000     |         |
      | evictor_shutdown_timeout_millis   | int(11)      | YES    |       | 10000     |         |
      | idle_timeout                      | int(11)      | YES    |       | 600000    |         |
      | heartbeat_period_millis           | int(11)      | YES    |       | 10000     |         |
  #case change db.xml and reload
    Given delete the following xml segment
      | file           | parent         | child                  |
      | db.xml         | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true" readWeight="1"  id="xx1">
             <property name="connectionTimeout">10000</property>
             <property name="connectionHeartbeatTimeout">30</property>
             <property name="testOnCreate">true</property>
             <property name="testOnBorrow">true</property>
             <property name="testOnReturn">true</property>
             <property name="testWhileIdle">true</property>
             <property name="timeBetweenEvictionRunsMillis">30000</property>
             <property name="evictorShutdownTimeoutMillis">20000</property>
             <property name="idleTimeout">150000</property>
             <property name="heartbeatPeriodMillis">20000</property>
        </dbInstance>

        <dbInstance name="s1" password="111111" url="172.100.9.1:3306" user="test" maxCon="100" minCon="10" readWeight="2" >
             <property name="connectionTimeout">5000</property>
             <property name="connectionHeartbeatTimeout">10</property>
             <property name="testOnCreate">true</property>
             <property name="testOnBorrow">true</property>
             <property name="testOnReturn">false</property>
             <property name="testWhileIdle">true</property>
             <property name="timeBetweenEvictionRunsMillis">15000</property>
             <property name="evictorShutdownTimeoutMillis">30000</property>
             <property name="idleTimeout">200000</property>
             <property name="heartbeatPeriodMillis">15000</property>
        </dbInstance>

        <dbInstance name="s2" password="111111" url="172.100.9.2:3306" user="test" maxCon="10" minCon="3" readWeight="3" disabled="true">
             <property name="connectionTimeout">100000</property>
             <property name="connectionHeartbeatTimeout">20</property>
             <property name="testOnCreate">false</property>
             <property name="testOnBorrow">true</property>
             <property name="testOnReturn">true</property>
             <property name="testWhileIdle">false</property>
             <property name="timeBetweenEvictionRunsMillis">10000</property>
             <property name="evictorShutdownTimeoutMillis">15000</property>
             <property name="idleTimeout">300000</property>
             <property name="heartbeatPeriodMillis">50000</property>
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M2" password="MmQ1VfdjVK4VbF7z7WXQ1Zj81wN7EDHJmwwZO9MA2q5RK8rs+fT2Zjy/3XdOyutXRcSLhTqJsAQs1A1M2ww8Pw=="
             usingDecrypt="true" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_2"
      | conn   | toClose | sql                                                    | db               |
      | conn_0 | False   | select name,db_group,addr,port from dble_db_instance   | dble_information |
    Then check resultset "dble_db_instance_2" has lines with following column values
      | name-0 | db_group-1 | addr-2      | port-3 |
      | M1     | ha_group1  | 172.100.9.5 | 3306   |
      | s1     | ha_group1  | 172.100.9.1 | 3306   |
      | s2     | ha_group1  | 172.100.9.2 | 3306   |
      | M2     | ha_group2  | 172.100.9.6 | 3306   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_3"
      | conn   | toClose | sql                                                                                                        | db               |
      | conn_0 | False   | select user,encrypt_configured,disabled,read_weight,max_conn_count,min_conn_count,id from dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_3" has lines with following column values
      | user-0 | encrypt_configured-1 | disabled-2 | read_weight-3 | max_conn_count-4 | min_conn_count-5 | id-6 |
      | test   | false                | false      | 1             | 1000             | 10               | xx1  |
      | test   | false                | false      | 2             | 100              | 10               | s1   |
      | test   | false                | true       | 3             | 10               | 3                | s2   |
      | test   | true                 | false      | 0             | 1000             | 10               | M2   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_4"
      | conn   | toClose | sql                                                                                                 | db               |
      | conn_0 | False   | select active_conn_count,idle_conn_count,read_conn_request,write_conn_request from dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_4" has lines with following column values
      | active_conn_count-0 | idle_conn_count-1 | read_conn_request-2 | write_conn_request-3 |
      | 0                   | 10                | 0                   | 0                    |
      | 0                   | 0                 | 0                   | 0                    |
      | 0                   | 0                 | 0                   | 0                    |
      | 0                   | 10                | 0                   | 0                    |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_5"
      | conn   | toClose | sql                                                                                             | db               |
      | conn_0 | False   | select last_heartbeat_ack,heartbeat_status,heartbeat_failure_in_last_5min from dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_5" has lines with following column values
      | last_heartbeat_ack-0 | heartbeat_status-1 | heartbeat_failure_in_last_5min-2 |
      | ok                   | idle               | 0                                |
      | ok                   | idle               | 0                                |
      | init                 | idle               | 0                                |
      | ok                   | idle               | 0                                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_6"
      | conn   | toClose | sql                                                                                                                                                                                 | db               |
      | conn_0 | False   | select connection_timeout,connection_heartbeat_timeout,time_between_eviction_runs_millis,evictor_shutdown_timeout_millis,idle_timeout,heartbeat_period_millis from dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_6" has lines with following column values
      | connection_timeout-0 | connection_heartbeat_timeout-1 | time_between_eviction_runs_millis-2 | evictor_shutdown_timeout_millis-3 | idle_timeout-4 | heartbeat_period_millis-5 |
      | 10000                | 30                             | 30000                               | 20000                             | 150000         | 20000                     |
      | 5000                 | 10                             | 15000                               | 30000                             | 200000         | 15000                     |
      | 100000               | 20                             | 10000                               | 15000                             | 300000         | 50000                     |
      | 30000                | 20                             | 30000                               | 10000                             | 600000         | 10000                     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_7"
      | conn   | toClose | sql                                                                                      | db               |
      | conn_0 | False   | select test_on_create,test_on_borrow,test_on_return,test_on_return from dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_7" has lines with following column values
      | test_on_create-0 | test_on_borrow-1 | test_on_return-2 |
      | true             | true             | true             |
      | true             | true             | false            |
      | false            | true             | true             |
      | false            | false            | false            |

  #case select limit/order by
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                         | expect                                                                                                                           |
      | conn_0 | False   | select name,db_group from dble_db_instance  limit 1                                         | has{(('M1', 'ha_group1',),)}                        |
      | conn_0 | False   | select test_on_borrow,test_on_return from dble_db_instance order by name desc limit 2       | has{(('true', 'true',), ('true', 'false',))}        |
  #case select max/min
      | conn_0 | False   | select max(idle_timeout) from dble_db_instance         | has{((600000,),)}      |
      | conn_0 | False   | select min(idle_timeout) from dble_db_instance         | has{((150000,),)}      |
  #case select where like
      | conn_0 | False   | select name,db_group from dble_db_instance where read_weight >1                | has{(('s1', 'ha_group1',), ('s2', 'ha_group1',))}         |
      | conn_0 | False   | select name,db_group from dble_db_instance where test_on_create like '%fa%'    | has{(('s2', 'ha_group1',), ('M2', 'ha_group2',))}         |
  #case select where [sub-query]
      | conn_0 | False   | select user from dble_db_instance where name in (select name from dble_db_instance where disabled ='false')        | has{(('test',), ('test',), ('test',))}                                                              |
#      | conn_0 | False   | select user from dble_db_instance where name >all (select name from dble_db_instance where disabled ='false')     |           |
#      | conn_0 | False   | select user from dble_db_instance where name < any (select name from dble_db_instance where disabled ='false')    |           |
      | conn_0 | False   | select user from dble_db_instance where name = any (select name from dble_db_instance where disabled ='false')     |has{(('test',), ('test',), ('test',))}                                                                                                                    |
  #case select field
      | conn_0 | False   | select `primary` from dble_db_instance where name ='s1'      | has{(('false',),)}        |

  #case change mysql username
    Then execute sql in "mysql-master1"
      | conn   | toClose  | sql                                                    | expect   |
      | conn_1 | False    | GRANT ALL ON *.* TO 't1'@'%' identified by '111111'    | success  |
      | conn_1 | True     | FLUSH PRIVILEGES                                       | success  |
    Given delete the following xml segment
      | file           | parent         | child                  |
      | db.xml         | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="T1" password="111111" url="172.100.9.5:3306" user="t1" maxCon="1000" minCon="10" primary="true" readWeight="1" >
        </dbInstance>

    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="M2" password="MmQ1VfdjVK4VbF7z7WXQ1Zj81wN7EDHJmwwZO9MA2q5RK8rs+fT2Zjy/3XdOyutXRcSLhTqJsAQs1A1M2ww8Pw=="
             usingDecrypt="true" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "dble_db_instance_8"
      | conn   | toClose | sql                                             | db               |
      | conn_0 | False   | select name,db_group,user from dble_db_instance | dble_information |
    Then check resultset "dble_db_instance_8" has lines with following column values
      | name-0 | db_group-1 | user-2 |
      | M2     | ha_group2  | test   |
      | T1     | ha_group1  | t1     |
