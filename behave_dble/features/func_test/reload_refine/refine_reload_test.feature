# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by mayingle at 2022/10/25

Feature: refine reload of DBLE0REQ-1793
    @NORMAL
  Scenario: we can exec insert/update/delete on a dbGroup with no dbInstance in it #1
    # 测试1：添加新的dbGroup
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect              | db               |
      | conn_0 | False   | select * from dble_db_group                       | length{(2)}         | dble_information |
      | conn_0 | False   | insert into dble_information.dble_db_group set `name`='mysql-tg',`heartbeat_stmt`='show slave status',`heartbeat_timeout`='0',`heartbeat_retry`='0',`rw_split_mode`='1',`delay_threshold`='-1',`disable_ha`='false' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#1_1"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_db_group       | dble_information |
    Then check resultset "refine_reload#1_1" has lines with following column values
      | name-0   | heartbeat_stmt-1 | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()    | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select user()    | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
      | mysql-tg | show slave status| 0                  | 0                | 60                    | 1              |        -1        |  -1                  | None           |   false    |     false |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect              | db               |
      | conn_0 | False   | select * from dble_db_group                       | length{(3)}         | dble_information |
    # 测试2 变更active=false状态的dbGroup相关参数值
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect              | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set heartbeat_stmt='select user()',heartbeat_timeout='10',heartbeat_retry='2',heartbeat_keep_alive='30',rw_split_mode='3',delay_threshold='12',disable_ha='true' where name='mysql-tg' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#1_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_db_group       | dble_information |
    Then check resultset "refine_reload#1_2" has lines with following column values
      | name-0   | heartbeat_stmt-1 | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()    | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select user()    | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
      | mysql-tg | select user()    | 10                 | 2                | 30                    | 3              |        12        |  -1                  | None           |   true     |     false |
    # 测试3 变更active=false状态的dbGroup相关参数值
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect              | db               |
      | conn_0 | False   | select * from dble_db_group                       | length{(3)}         | dble_information |
      | conn_0 | False   | delete from dble_db_group where name='mysql-tg'   | success             | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#1_3"
      | conn   | toClose | sql                               | db               |
      | conn_0 | True    | select * from dble_db_group       | dble_information |
    Then check resultset "refine_reload#1_3" has lines with following column values
      | name-0   | heartbeat_stmt-1 | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()    | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select user()    | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |

    @CRITICAL
  Scenario: Comprehensive test of active/inactive dbGroup with 0/!0 values of rwSplitMode #2
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="host4M" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="2" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
        <heartbeat>select @@read_only</heartbeat>
        <dbInstance name="host6M" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="2" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"

    # 测试1：dbGroup被引用，且rwSplitMode为0的情况下，dbGroup内新增从实例，从实例只新增心跳连接，并不会初始化连接池,以ha_group1为测试对象 非空dbGroup内新增dbInstance
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                      | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                | expect  | db               |
      | conn_0 | False   | insert into dble_information.dble_db_instance set `name`='host4S',`db_group`='ha_group1',`addr`='172.100.9.4',`port`='3307',`user`='test',`password_encrypt`='111111',`encrypt_configured`='false',`primary`='false',`disabled`='false',`min_conn_count`='2',`max_conn_count`='10'| success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance\[name=host4S
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] start connection pool :dbInstance\[name=host4S
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host4S\" url=\"172.100.9.4:3307\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"false\">
            <property name=\"connectionTimeout\">30000</property>
            <property name=\"connectionHeartbeatTimeout\">20</property>
            <property name=\"testOnCreate\">false</property>
            <property name=\"testOnBorrow\">false</property>
            <property name=\"testOnReturn\">false</property>
            <property name=\"testWhileIdle\">false</property>
            <property name=\"timeBetweenEvictionRunsMillis\">30000</property>
            <property name=\"evictorShutdownTimeoutMillis\">10000</property>
            <property name=\"idleTimeout\">600000</property>
            <property name=\"heartbeatPeriodMillis\">10000</property>
            <property name=\"flowHighLevel\">4194304</property>
            <property name=\"flowLowLevel\">262144</property>
        </dbInstance>
      """

    # 测试2 dbGroup被引用，且rwSplitMode不为0的情况下，dbGroup内新增从实例，从实例会新增心跳连接，并初始化业务连接池 rwSplitMode=1 非空dbGroup内新增dbInstance
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db               |
      | conn_0 | False   | insert into dble_information.dble_db_instance set `name`='host6S1',`db_group`='ha_group2',`addr`='172.100.9.6',`port`='3307',`user`='test',`password_encrypt`='111111',`encrypt_configured`='false',`primary`='false',`disabled`='false',`min_conn_count`='2',`max_conn_count`='10'| success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance\[name=host6S1
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                      | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host6S1\" url=\"172.100.9.6:3307\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"false\">
            <property name=\"connectionTimeout\">30000</property>
            <property name=\"connectionHeartbeatTimeout\">20</property>
            <property name=\"testOnCreate\">false</property>
            <property name=\"testOnBorrow\">false</property>
            <property name=\"testOnReturn\">false</property>
            <property name=\"testWhileIdle\">false</property>
            <property name=\"timeBetweenEvictionRunsMillis\">30000</property>
            <property name=\"evictorShutdownTimeoutMillis\">10000</property>
            <property name=\"idleTimeout\">600000</property>
            <property name=\"heartbeatPeriodMillis\">10000</property>
            <property name=\"flowHighLevel\">4194304</property>
            <property name=\"flowLowLevel\">262144</property>
        </dbInstance>
      """

    # 测试3 dbInstance从引用→未被引用    #删除user.xml中的sharding用户，使dbInstance从引用→未被引用，所有dbInstance的连接池都会被回收，心跳保留
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Then execute admin cmd "reload @@config_all"
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4S
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |

    # 测试4 rwSplitMode值为不同值时，dbGroup未被引用→被引用：    #- rwSplitMode=0时，仅主实例新建连接池  #dble_rw_split_entry的insert
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db               |
      | conn_0 | False   | insert into dble_information.dble_rw_split_entry set `username`='S1',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='600',`db_group`='ha_group1'| success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4S
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """

    # 测试5 rwSplitMode值为不同值时，dbGroup未被引用→被引用：    #- rwSplitMode=1时，主从实例均会新建连接池  #dble_rw_split_entry的insert
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false' | equal{((0,),)}  | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db               |
      | conn_0 | False   | insert into dble_information.dble_rw_split_entry set `username`='S2',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='600',`db_group`='ha_group2'| success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host6M
    SELF_RELOAD] start connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='true' | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S2\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group2\"/>
      """

    # 测试6 dbGroup被引用的状态下，rwSplitMode调整时：从0→非0；从非0→0
    #rwSplitMode调整从0→非0（本测试为从0→2），从实例需要初始化连接池
    #rwSplitMode调整从非0→0（本测试为从1→0），从实例的连接池需要被回收
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                   | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'                                | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'                                | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false'                               | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false'                               | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and db_instance_name='host6S1' and used_for_heartbeat='false'| hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and db_instance_name='host6M'  and used_for_heartbeat='false'| hasnot{((0,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='2' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)}| dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"2\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # 调整ha_group2的rwSplitMode=0，（rwSplitMode：1→0）组内的MySQL从dbInstance会回收连接池
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                    | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'                                | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'                                | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false'                               | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false'                               | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and db_instance_name='host6S1' and used_for_heartbeat='false'| hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and db_instance_name='host6M' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='0' where `name`='ha_group2' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | hasnot{((0,),)}| dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='true' | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((0,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"0\" name=\"ha_group2\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """

    # 测试7 rwSplitMode=2时，dbGroup被引用→不被引用 dbGroup未被引用→被引用；
    #此时ha_group1的rwSplitMode=2，拿它作为测试对象：
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)}  | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                       | expect  | db               |
      | conn_0 | False   | delete from dble_rw_split_entry where username='S1'       | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """
    # 把用户S1添加回来，
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((0,),)}  | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db               |
      | conn_0 | False   | insert into dble_information.dble_rw_split_entry set `username`='S1',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='10',`db_group`='ha_group1'| success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    SELF_RELOAD] start connection pool :dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4S
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)}| dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"10\" dbGroup=\"ha_group1\"/>
      """

  # 测试8：dbGroup被引用的状态下，rwSplitMode调整时：从0→非0；从非0→0
  #rwSplitMode调整从0→非0（本测试为从2→0），从实例的连接池需要被回收
  #rwSplitMode调整从非0→0（本测试为从0→3），从实例需要初始化连接池
    # ha_group2 的 rwSplitMode调整从非0→0（本测试为从0→3）
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                   | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'                                | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'                                | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false'                               | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false'                               | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((0,),)}  | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)}  | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='3' where `name`='ha_group2' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"3\" name=\"ha_group2\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # ha_group1 的rwSplitMode调整从0→非0（本测试为从2→0）
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)}| dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='0' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)}| dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"0\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """

     # 测试9：dbGroup被引用的状态下，rwSplitMode调整时：从0→非0；从非0→0 rwSplitMode=3时，dbGroup被引用→不被引用 dbGroup未被引用→被引用；
     #此时ha_group2的rwSplitMode=3，拿它作为测试对象：
     # delete/insert   dble_rw_split_entry
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                    | expect  | db               |
      | conn_0 | False   | delete from dble_rw_split_entry where username='S2'    | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S2\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group2\"/>
      """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((0,),)} | dble_information |
    # 为ha_group2这个未被引用的dbGroup添加用户S2，使ha_group2由被不引用→被引用；组内由于rwSplitMode=3，组内主从dbInstance都会新建连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                   | expect  | db               |
      | conn_0 | False   | insert into dble_information.dble_rw_split_entry set `username`='S2',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='600',`db_group`='ha_group2' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host6M
    SELF_RELOAD] start connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S2\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group2\"/>
      """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |

    # 测试10：dbGroup被引用的状态下，rwSplitMode调整时：从0→非0；从非0→0
    #rwSplitMode调整从0→非0（本测试为从0→1），从实例需要初始化连接池
    #rwSplitMode调整从非0→0（本测试为从3→0），从实例的连接池需要被回收
    # 以ha_group1为测试对象     rwSplitMode调整从0→非0（本测试为从0→1）
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | hasnot{((0,),)}| dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='1' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                      | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |
    # 调整ha_group2的rwSplitMode=0，（rwSplitMode：3→0）组内的MySQL从dbInstance会回收连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                     | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='0' where `name`='ha_group2' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6S1
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6M
    """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"0\" name=\"ha_group2\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((0,),)} | dble_information |

    @NORMAL
  Scenario: when we change the sql of heartbeat_stmt the connection of heartbeat should be reconnected #3
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2"  primary="false"/>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select @@read_only</heartbeat>
        <dbInstance name="host6M" url="172.100.9.6:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host6S1" url="172.100.9.6:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
     <rwSplitUser name="S2" password="123" usingDecrypt="false" maxCon="600" dbGroup="ha_group2"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试1：变更心跳sql：select user()  →  show slave status  使用ha_group1作为测试对象
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_1"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_db_group       | dble_information |
    Then check resultset "refine_reload#3_1" has lines with following column values
      | name-0   | heartbeat_stmt-1    | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()       | 0                  | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only  | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4M_heartbeat_1"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4M_other_1"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4S_heartbeat_1"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4S_other_1"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | dble_information |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                    | expect         | db               |
      | conn_0 | False   | select * from dble_db_group                                                                            | length{(2)}    | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true' | equal{((2,),)} | dble_information |
      | conn_0 | False   | UPDATE dble_db_group set `heartbeat_stmt`='show slave status' where `name`='ha_group1'                 | success        | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_2"
      | conn   | toClose | sql                               | db               |
      | conn_0 | False   | select * from dble_db_group       | dble_information |
    Then check resultset "refine_reload#3_2" has lines with following column values
      | name-0   | heartbeat_stmt-1   | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| show slave status  | 0                  | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only | 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
           <heartbeat timeout=\"0\" errorRetryCount=\"1\" keepAlive=\"60\">show slave status</heartbeat>
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4M_heartbeat_2"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4M_other_2"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4S_heartbeat_2"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#3_test1_ha_group1_4S_other_2"
      | sql                                                                                                                  | db               |
      | select remote_processlist_id from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | dble_information |
    Then check resultsets "refine_reload#3_test1_ha_group1_4M_heartbeat_1" does not including resultset "refine_reload#3_test1_ha_group1_4M_heartbeat_2" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |
    Then check resultsets "refine_reload#3_test1_ha_group1_4S_heartbeat_1" does not including resultset "refine_reload#3_test1_ha_group1_4S_heartbeat_2" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |
    Then check resultsets "refine_reload#3_test1_ha_group1_4M_other_1" including resultset "refine_reload#3_test1_ha_group1_4M_other_2" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |
    Then check resultsets "refine_reload#3_test1_ha_group1_4S_other_1" including resultset "refine_reload#3_test1_ha_group1_4S_other_2" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |

    @NORMAL
  Scenario: when we change the value of heartbeat_timeout, the heartbeat connection should be rebuild #4
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select @@read_only</heartbeat>
        <dbInstance name="host6M" url="172.100.9.6:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host6S1" url="172.100.9.6:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
     <rwSplitUser name="S2" password="123" usingDecrypt="false" maxCon="600" dbGroup="ha_group2"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试1：变更心跳sql：select user()  →  show slave status  使用ha_group1作为测试对象
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#4_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#4_1" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                          | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `heartbeat_timeout`='100' where `name`='ha_group1' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#4_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#4_2" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 100                | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
           <heartbeat timeout=\"100\" errorRetryCount=\"1\" keepAlive=\"60\">select user\(\)</heartbeat>
      """

    @NORMAL
  Scenario: when we change the value of heartbeat_retry, the heartbeat connection should be rebuild #5
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select @@read_only</heartbeat>
        <dbInstance name="host6M" url="172.100.9.6:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host6S1" url="172.100.9.6:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
     <rwSplitUser name="S2" password="123" usingDecrypt="false" maxCon="600" dbGroup="ha_group2"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试：变更心跳heartbeat_retry数值  使用ha_group1作为测试对象
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#5_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#5_1" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `heartbeat_retry`=2 where `name`='ha_group1' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#5_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#5_2" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 2                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |

    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
           <heartbeat timeout=\"0\" errorRetryCount=\"2\" keepAlive=\"60\">select user\(\)</heartbeat>
      """

    @NORMAL
  Scenario: when we change the value of keepAlive, the heartbeat connection should be rebuild #6
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select @@read_only</heartbeat>
        <dbInstance name="host6M" url="172.100.9.6:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host6S1" url="172.100.9.6:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
     <rwSplitUser name="S2" password="123" usingDecrypt="false" maxCon="600" dbGroup="ha_group2"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试：变更心跳keepAlive数值  使用ha_group1作为测试对象
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#6_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#6_1" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                          | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `heartbeat_keep_alive`=50 where `name`='ha_group1' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#6_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#6_2" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 1                | 50                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |

    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
           <heartbeat timeout=\"0\" errorRetryCount=\"1\" keepAlive=\"50\">select user\(\)</heartbeat>
      """

    @NORMAL
  Scenario: when we change the value of delay_threshold,disable_ha,rw_split_mode(!0 → !0) the heartbeat_connection & connection_pools will not be rebuild #7
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select @@read_only</heartbeat>
        <dbInstance name="host6M" url="172.100.9.6:3306" password="111111" user="test" maxCon="100" minCon="2" primary="true"/>
        <dbInstance name="host6S1" url="172.100.9.6:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
     <rwSplitUser name="S2" password="123" usingDecrypt="false" maxCon="600" dbGroup="ha_group2"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试：变更心跳keepAlive数值  使用ha_group1作为测试对象
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#7_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#7_1" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 1                | 60                    | 1              |        100       |  -1                  | null           |   false    |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                              | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`=3,`delay_threshold`='12',`disable_ha`='true' where `name`='ha_group1' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#7_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | True    | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#7_2" has lines with following column values
      | name-0   | heartbeat_stmt-1  | heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select user()     | 0                  | 1                | 60                    | 3              |        12        |  -1                  | null           |   true     |     true  |
      | ha_group2| select @@read_only| 0                  | 1                | 60                    | 0              |        100       |  -1                  | null           |   false    |     true  |

    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"3\" name=\"ha_group1\" delayThreshold=\"12\" disableHA=\"true\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
           <heartbeat timeout=\"0\" errorRetryCount=\"1\" keepAlive=\"60\">select user\(\)</heartbeat>
      """

    @CRITICAL
  Scenario: when we add/delete dbInstance in a new created dbGroup #8
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                        | expect         | db               |
      | conn_0 | False   | select * from dble_db_group                | length{(0)}    | dble_information |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db               |
      | conn_0 | False   | insert into dble_db_group set `name`='ha_group1',`heartbeat_stmt`='select 1',`heartbeat_timeout`='0',`heartbeat_retry`='0',`rw_split_mode`='1',`delay_threshold`='-1',`disable_ha`='false' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#8_1"
      | conn   | toClose | sql                           | db               |
      | conn_0 | False   | select * from dble_db_group   | dble_information |
     # issue wait for fixed
    Then check resultset "refine_reload#8_1" has lines with following column values
      | name-0   | heartbeat_stmt-1| heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select 1        | 0                  | 0                | 60                    | 1              |        -1        |  -1                  | None           |   false    |     false |
  # 测试0  通过添加1M1S 的dbGroup,  ha_group2，reload后生效rwSplitMode=3  没有被引用，只新增心跳，没有新增连接池
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" disableHA="false">
          <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">show slave status</heartbeat>
          <dbInstance name="host6M" url="172.100.9.6:3306" password="111111" user="test" maxCon="10" minCon="2" primary="true"/>
          <dbInstance name="host6S1" url="172.100.9.6:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
       </dbGroup>
      """
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                           | expect         | db               |
      | conn_0 | False   | reload @@config_all                           | success        | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
      """
      SELF_RELOAD] test connection dbInstance:dbInstance\[name=host6M
      SELF_RELOAD] test connection dbInstance:dbInstance\[name=host6S1
      SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6M
      SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host6S1
      get system variables :show variables,dbInstance
      SELF_RELOAD] start heartbeat :
      """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       SELF_RELOAD] start connection pool :dbInstance
       SELF_RELOAD] stop connection pool :dbInstance
       SELF_RELOAD] stop heartbeat :
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |

  # 测试1：新建的空dbGroup新增首个dbInstance(rwSplitMode=1)，由于未被rwSplitUser引用，新建的主从实例都不会创建连接池，只会新建心跳
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                              | expect  | db               |
      | conn_0 | False   | insert into dble_db_instance set `name`='host4M',`db_group`='ha_group1',`addr`='172.100.9.4',`port`='3306',`user`='test',`password_encrypt`='111111',`encrypt_configured`='false',`primary`='true',`disabled`='false',`min_conn_count`='2',`max_conn_count`='10' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#8_2"
      | conn   | toClose | sql                           | db               |
      | conn_0 | False   | select * from dble_db_group   | dble_information |
    Then check resultset "refine_reload#8_2" has lines with following column values
      | name-0   | heartbeat_stmt-1| heartbeat_timeout-2| heartbeat_retry-3| heartbeat_keep_alive-4| rw_split_mode-5| delay_threshold-6| delay_period_millis-7|delay_database-8|disable_ha-9| active-10 |
      | ha_group1| select 1        | 0                  | 0                | 60                    | 1              |        -1        |  -1                  | null           |   false    |     true  |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"-1\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
          <heartbeat timeout=\"0\" errorRetryCount=\"0\" keepAlive=\"60\">select 1</heartbeat>
          <dbInstance name=\"host4M\" url=\"172.100.9.4:3306\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"true\">
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
     # add slave
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                               | expect  | db               |
      | conn_0 | False   | insert into dble_db_instance set `name`='host4S',`db_group`='ha_group1',`addr`='172.100.9.4',`port`='3307',`user`='test',`password_encrypt`='111111',`encrypt_configured`='false',`primary`='false',`disabled`='false',`min_conn_count`='2',`max_conn_count`='10' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
      """
      SELF_RELOAD] test connection dbInstance:dbInstance\[name=host4S
      SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4S
      get system variables :show variables,dbInstance
      SELF_RELOAD] start heartbeat :
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
      """
      SELF_RELOAD] stop heartbeat :
      SELF_RELOAD] start connection pool :dbInstance
      SELF_RELOAD] stop connection pool :dbInstance
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"-1\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
          <heartbeat timeout=\"0\" errorRetryCount=\"0\" keepAlive=\"60\">select 1</heartbeat>
          <dbInstance name=\"host4S\" url=\"172.100.9.4:3307\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"false\">
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='true'  | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |

  # 测试2（6个小case） 未被引用状态下rwSplitMode的调整：
     # ha_group1   1 → 0 → 2 → 0 → 1
     # ha_group2   3 → 0 → 3
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='0' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"0\" name=\"ha_group1\" delayThreshold=\"-1\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # 2 调整ha_group1的rwSplitMode=2，（rwSplitMode：0→2）组内的MySQL从dbInstance会回收连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='2' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"2\" name=\"ha_group1\" delayThreshold=\"-1\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # 3 调整ha_group1的rwSplitMode=0，（rwSplitMode：2→0）组内的MySQL从dbInstance会回收连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='0' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"0\" name=\"ha_group1\" delayThreshold=\"-1\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # 4 调整ha_group1的rwSplitMode=0，（rwSplitMode：2→0）组内的MySQL从dbInstance会回收连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='1' where `name`='ha_group1' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"1\" name=\"ha_group1\" delayThreshold=\"-1\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # 5 调整ha_group2的rwSplitMode=0，（rwSplitMode：3→0）组内的MySQL从dbInstance会回收连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='0' where `name`='ha_group2' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"0\" name=\"ha_group2\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """
    # 6 调整ha_group2的rwSplitMode=3，（rwSplitMode：0→3）组内的MySQL从dbInstance会回收连接池
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                    | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_group set `rw_split_mode`='3' where `name`='ha_group2' | success | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((4,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode=\"3\" name=\"ha_group2\" delayThreshold=\"100\" disableHA=\"false\" delayPeriodMillis=\"-1\" delayDatabase=\"null\">
      """

  # 测试3：为dbGroup(rwSplitMode=1)添加 1个到2个rwSplitUser
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect          | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1' and used_for_heartbeat='false' | equal{((0,),)}  | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db               |
      | conn_0 | True    | insert into dble_rw_split_entry set `username`='S1',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='600',`db_group`='ha_group1'| success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    SELF_RELOAD] start connection pool :dbInstance\[name=host4S
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """
   # 为ha_group1 添加第二个rwSplitUser  S2
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db               |
      | conn_0 | True    | insert into dble_rw_split_entry set `username`='S2',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='600',`db_group`='ha_group1' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
       <rwSplitUser name=\"S2\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """

   # 为ha_group2添加一个rwSplitUser，使ha_group2 状态变化 不被引用 → 被引用
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db               |
      | conn_0 | True    | insert into dble_rw_split_entry set `username`='S3',`password_encrypt`='123',`encrypt_configured`='false',`conn_attr_key`=null,`conn_attr_value`=null,`max_conn_count`='600',`db_group`='ha_group2'| success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance\[name=host6M
    SELF_RELOAD] start connection pool :dbInstance\[name=host6S1
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='true' | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((2,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
       <rwSplitUser name=\"S2\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
       <rwSplitUser name=\"S3\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group2\"/>
      """

  # 测试4：删除 引用dbGroup的rwSplitUser (删除从多到一，dbGroup内dbInstance的心跳连接池不会受影响)
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect  | db               |
      | conn_0 | False   | delete from dble_rw_split_entry where username='S2'                        | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S2\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
       <rwSplitUser name=\"S3\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group2\"/>
      """

  #  测试5：删除rwSplitMode=1的dbGroup 中的从实例（心跳和连接池的变化）
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                             | expect         | db               |
      | conn_0 | False   | select count(*) from dble_db_instance where db_group='ha_group1'| equal{((2,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                             | expect         | db               |
      | conn_0 | False   | delete from dble_db_instance where name='host4S'                | success        | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4S
    SELF_RELOAD] stop heartbeat :
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    SELF_RELOAD] start heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from dble_db_instance where name='host4S'                                               | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S'                                | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host4S\" url=\"172.100.9.4:3307\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"false\">
      """

  #  测试6：删除被引用的dbGroup 中的唯一一个主实例实例（因为dbGroup被引用，所以删除会失败）
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                             | expect         | db               |
      | conn_0 | False   | select count(*) from dble_db_instance where db_group='ha_group1'| equal{((1,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                             | expect              | db               |
      | conn_0 | False   | delete from dble_db_instance where name='host4M'                | Delete failure.The reason is The user's group[S1.ha_group1] for rwSplit isn't configured in db.xml. | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    get system variables :show variables,dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from dble_db_instance where db_group='ha_group1'                                        | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((2,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host4M\" url=\"172.100.9.4:3306\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"true\">
      """

  #  测试7：删除 引用dbGroup的rwSplitUser (删除从一到零，dbGroup内dbInstance的心跳不会受影响，但连接池会被回收)
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect  | db               |
      | conn_0 | False   | delete from dble_rw_split_entry where username='S3'                        | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host6S1
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='true' | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host6S1' and used_for_heartbeat='false'| equal{((0,),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S3\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group2\"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """
  #  删除S1
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect  | db               |
      | conn_0 | False   | delete from dble_rw_split_entry where username='S1'                        | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    """
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4M' and used_for_heartbeat='true'  | equal{((1,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='true'  | equal{((0,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_instance_name='host4S' and used_for_heartbeat='false' | equal{((0,),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
       <rwSplitUser name=\"S1\" password=\"123\" usingDecrypt=\"false\" maxCon=\"600\" dbGroup=\"ha_group1\"/>
      """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from backend_connections                                                                | equal{((3,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where used_for_heartbeat='true'                                | equal{((3,),)} | dble_information |
      | conn_0 | False   | select count(*) from backend_connections where db_group_name='ha_group1'                                | equal{((1,),)} | dble_information |
      | conn_0 | True    | select count(*) from backend_connections where db_group_name='ha_group2'                                | equal{((2,),)} | dble_information |

  # 测试8：删除rwSplitMode=1的dbGroup(没有被引用) 中的唯一一个主实例实例（心跳和连接池的变化）
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                             | expect         | db               |
      | conn_0 | False   | select count(*) from dble_db_instance where db_group='ha_group1'| equal{((1,),)} | dble_information |
    Given record current dble log line number in "log_linenu"
    When execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                             | expect         | db               |
      | conn_0 | False   | delete from dble_db_instance where name='host4M'                | success        | dble_information |
    # todo heartbeat logs should change into some other reasonable styles
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    get system variables :show variables,dbInstance
    SELF_RELOAD] stop heartbeat :
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    SELF_RELOAD] start heartbeat :
    """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                     | expect         | db               |
      | conn_0 | False   | select count(*) from dble_db_instance where db_group='ha_group1'                                        | equal{((0,),)} | dble_information |
      | conn_0 | False   | select count(*) from dble_db_group where name='ha_group1'                                               | equal{((0,),)} | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host4M\" url=\"172.100.9.4:3306\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" readWeight=\"0\" primary=\"true\">
      """

    @CRITICAL
  Scenario: when we change the attributes of dbInstance, some of attributes would cause rebuilding of heartbeat_connection & connection_pools #9
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="10" minCon="2" primary="true"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试1：变更addr   使用ha_group1作为测试对象
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                  | db               | expect                                                       |
      | conn_0 | True    | select name,db_group,addr,port,user from dble_db_instance where db_group='ha_group1' | dble_information | has{(('host4M', 'ha_group1', '172.100.9.4', 3306, 'test'),)} |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                      | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_instance set `addr`='172.100.9.6' where `name`='host4M'  | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                  | db               | expect                                                       |
      | conn_0 | True    | select name,db_group,addr,port,user from dble_db_instance where db_group='ha_group1' | dble_information | has{(('host4M', 'ha_group1', '172.100.9.6', 3306, 'test'),)} |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host4M\" url=\"172.100.9.6:3306\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" id=\"host4M\" readWeight=\"0\" primary=\"true\">
      """
    # 测试2：变更port   使用ha_group1作为测试对象
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                              | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_instance set `port`='3307' where `name`='host4M' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    SELF_RELOAD] stop connection pool :dbInstance
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#9_3"
      | conn   | toClose | sql                                                                                  | db               | expect                                                       |
      | conn_0 | True    | select name,db_group,addr,port,user from dble_db_instance where db_group='ha_group1' | dble_information | has{(('host4M', 'ha_group1', '172.100.9.6', 3307, 'test'),)} |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name=\"host4M\" url=\"172.100.9.6:3307\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" usingDecrypt=\"false\" disabled=\"false\" id=\"host4M\" readWeight=\"0\" primary=\"true\">
      """
    # 测试3：变更user，password_encrypt，encrypt_configured
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="10" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 添加user
    Then execute sql in "mysql"
      | user | passwd | conn   | toClose | sql                                                   | expect                 | db    |
      | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test1`@`%`                       | success                | mysql |
      | test | 111111 | conn_0 | False   | CREATE USER `test1`@`%` IDENTIFIED BY '123456'        | success                | mysql |
      | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test1`@`%` WITH GRANT OPTION     | success                | mysql |
      | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                | mysql |
      | test | 111111 | conn_0 | True    | SELECT user,host from user where user='test1'         | has{(('test1', '%'),)} | mysql |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                         | db               | expect                                                                |
      | conn_0 | True    | select name,db_group,addr,port,user,encrypt_configured from dble_db_instance where db_group='ha_group1' and `name`='host4M' | dble_information | has{(('host4M', 'ha_group1', '172.100.9.4', 3306, 'test', 'false'),)} |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                        | expect  | db               |
      | conn_0 | False   | UPDATE dble_information.dble_db_instance set `user`='test1',`password_encrypt`='123456',`encrypt_configured`='false' where `name`='host4M' | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance\[name=host4M
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=host4M
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance\[name=host4M
    SELF_RELOAD] stop connection pool :dbInstance\[name=host4M
    """
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                      | db               | expect                                                        |
      | conn_0 | True    | select name,db_group,addr,port,user from dble_db_instance where db_group='ha_group1' and `name`='host4M' | dble_information | has{(('host4M', 'ha_group1', '172.100.9.4', 3306, 'test1'),)} |
    # drop user
    Then execute sql in "mysql"
      | user | passwd | conn   | toClose | sql                             | expect                 | db    |
      | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test1`@`%` | success                | mysql |

    @NORMAL
  Scenario: when we change the attributes of dbInstance which not support change by sql #10
    # test env prepare
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" disableHA="false">
        <heartbeat timeout="0" errorRetryCount="1" keepAlive="60">select user()</heartbeat>
        <dbInstance name="host4M" url="172.100.9.4:3306" password="111111" user="test" maxCon="10" minCon="2" primary="true"/>
        <dbInstance name="host4S" url="172.100.9.4:3307" password="111111" user="test" maxCon="10" minCon="2" primary="false"/>
     </dbGroup>
    """
    Given delete the following xml segment
      | file         | parent         | child                   |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="S1" password="123" usingDecrypt="false" maxCon="10" dbGroup="ha_group1"/>
    """
    Then execute admin cmd "reload @@config_all"
    # 测试1：变更name   使用ha_group1作为测试对象
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#10_1"
      | conn   | toClose | sql                                                                                  | db               |
      | conn_0 | True    | select name,db_group,addr,port,user from dble_db_instance where db_group='ha_group1' | dble_information |
    Then check resultset "refine_reload#10_1" has lines with following column values
      | name-0   | db_group-1   | addr-2        | port-3  | user-4  |
      | host4M   | ha_group1    | 172.100.9.4   | 3306    | test    |
      | host4S   | ha_group1    | 172.100.9.4   | 3307    | test    |
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                           | expect                                                              | db               |
      | conn_0 | False   | UPDATE dble_db_instance set `name`='hostMtest10_1' where `addr`='172.100.9.4' and port='3306' | Primary column 'name' can not be update, please use delete & insert | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbInstance name=\"hostMtest10_1\" url=\"172.100.9.4:3306\" password=\"111111\" user=\"test\" maxCon=\"10\" minCon=\"2\" primary=\"true\"/>
      """
        # 测试2：变更db_group  使用ha_group1作为测试对象
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                           | expect                                                                  | db               |
      | conn_0 | False   | UPDATE dble_db_instance set `db_group`='group10_2' where `addr`='172.100.9.4' | Primary column 'db_group' can not be update, please use delete & insert | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
       <dbGroup rwSplitMode=\"1\" name=\"group10_2\" delayThreshold=\"100\" disableHA=\"false\">
      """
    # 测试3：变更active_conn_count等只读的参数  使用ha_group1作为测试对象
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                            |  expect                                     | db               |
      | conn_0 | False   | UPDATE dble_db_instance set `active_conn_count`='5' where `name`='host4M'      | Column 'active_conn_count' is not writable | dble_information |
    # idle_conn_count
      | conn_0 | False   | UPDATE dble_db_instance set `idle_conn_count`='5' where `name`='host4M'        | Column 'idle_conn_count' is not writable | dble_information |
    # read_conn_request
      | conn_0 | False   | UPDATE dble_db_instance set `read_conn_request`='5' where `name`='host4M'      | Column 'read_conn_request' is not writable | dble_information |
    # write_conn_request
      | conn_0 | False   | UPDATE dble_db_instance set `write_conn_request`='5' where `name`='host4M'     | Column 'write_conn_request' is not writable | dble_information |
    # last_heartbeat_ack_timestamp
      | conn_0 | False   | UPDATE dble_db_instance set `last_heartbeat_ack_timestamp`='2022-11-14 15:49:09' where `name`='host4M' | Column 'last_heartbeat_ack_timestamp' is not writable | dble_information |
    # last_heartbeat_ack
      | conn_0 | False   | UPDATE dble_db_instance set `last_heartbeat_ack`='test' where `name`='host4M'  | Column 'last_heartbeat_ack' is not writable | dble_information |
    # heartbeat_status
      | conn_0 | False   | UPDATE dble_db_instance set `heartbeat_status`='test' where `name`='host4M'    | Column 'heartbeat_status' is not writable | dble_information |
    # heartbeat_failure_in_last_5min
      | conn_0 | False   | UPDATE dble_db_instance set `heartbeat_failure_in_last_5min`='5' where `name`='host4M' | Column 'heartbeat_failure_in_last_5min' is not writable | dble_information |
    # encrypt_configured
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#10_test_1"
      | sql                                                                   | db               |
      | select encrypt_configured from dble_db_instance where name='host4M'   | dble_information |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                            | expect              | db               |
      | conn_0 | False   | UPDATE dble_db_instance set `encrypt_configured`='true' where `name`='host4M'  | Update failure.The reason is db json to map occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: host host4M,user test password need to decrypt, but failed ! | dble_information |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "refine_reload#10_test_2"
      | sql                                                                   | db               |
      | select encrypt_configured from dble_db_instance where name='host4M'   | dble_information |
    Then check resultsets "refine_reload#10_test_1" including resultset "refine_reload#10_test_2" in following columns
      | column                | column_index |
      | encrypt_configured    | 0            |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    SELF_RELOAD] test connection dbInstance:dbInstance
    SELF_RELOAD] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version,@@back_log,dbInstance:dbInstance
    get system variables :show variables,dbInstance
    SELF_RELOAD] start heartbeat :
    SELF_RELOAD] stop heartbeat :
    SELF_RELOAD] start connection pool :dbInstance
    SELF_RELOAD] stop connection pool :dbInstance
    """