# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/8/16
# heartbeat中新增参数keepAlive，当心跳超过keepAlive时间未响应，将会关闭心跳连接，重新建立连接来进行心跳的任务

Feature: check keepAlive

  #DBLE0REQ-1495
  @restore_network
  Scenario: check keepAlive in heartbeat #1
    """
    {'restore_network':'mysql-master2'}
    """
    # case 1: keepAlive default value is 60s
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 3,2     |
    # 在 mysql-master2上创建一个连接，确保后面执行iptables -F之后，此连接能正常恢复
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose  | sql      | expect  | db  |
      | conn_1 | false    | select 1 | success | db1 |
    Given execute oscmd in "mysql-master2"
    """
    iptables -A INPUT -p tcp --dport 3306 -j DROP
    iptables -A OUTPUT -p tcp --dport 3306 -j DROP
    """
    Given check remote "3306" in "mysql-master2" connected "N"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                        | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'timeout'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | False   | select * from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_1"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Given record current dble log line number in "log_num_1"

    # case 1.1: sleep more than keepAlive
    Given sleep "60" seconds
    #print log and mysqlId change
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_1" in host "dble-1" retry "5,2" times
    """
      \[heartbeat\]connect timeout,the connection may be unreachable for a long time due to TCP retransmission
    """
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given check remote "3306" in "mysql-master2" connected "Y"
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose  | sql      | expect  | timeout |
      | conn_1 | false    | select 1 | success | 6       |
    # 先检查是否新建了心跳连接，再检查心跳是否恢复正常
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | False   | select * from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_2"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Then check resultsets "heartbeat_conn_2" does not including resultset "heartbeat_conn_1" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0  | false   | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |

    # case 1.2: add iptables less than keepAlive
    Given execute oscmd in "mysql-master2"
    """
    iptables -A INPUT -p tcp --dport 3306 -j DROP
    iptables -A OUTPUT -p tcp --dport 3306 -j DROP
    """
    Given check remote "3306" in "mysql-master2" connected "N"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                        | db               | timeout |
      | conn_0  | false   | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'timeout'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given check remote "3306" in "mysql-master2" connected "Y"
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose  | sql      | expect  | timeout |
      | conn_1 | false    | select 1 | success | 6       |
    # 先检查检查心跳恢复正常，再检查心跳连接未发生变化
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0  | false   | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 30,2    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | False   | select * from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_3"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Then check resultsets "heartbeat_conn_3" including resultset "heartbeat_conn_2" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |

    # case 2: keepAlive value is 30s
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat keepAlive="30">select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0  | false   | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 3,2     |
    Given execute oscmd in "mysql-master2"
    """
    iptables -A INPUT -p tcp --dport 3306 -j DROP
    iptables -A OUTPUT -p tcp --dport 3306 -j DROP
    """
    Given check remote "3306" in "mysql-master2" connected "N"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql             | expect                                                                                        | db               | timeout |
      | conn_0 | false   | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'timeout'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | False   | select * from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_4"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Given record current dble log line number in "log_num_3"

    # case 2.1: sleep more than keepAlive
    Given sleep "30" seconds
    #print log and mysqlId change
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_3" in host "dble-1" retry "5,2" times
    """
      \[heartbeat\]connect timeout,the connection may be unreachable for a long time due to TCP retransmission
    """
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given check remote "3306" in "mysql-master2" connected "Y"
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose  | sql      | expect  | timeout |
      | conn_1 | false    | select 1 | success | 6       |
    # 先检查新建了心跳连接，再检查心跳恢复正常
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | True    | select * from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_5"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Then check resultsets "heartbeat_conn_4" does not including resultset "heartbeat_conn_5" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |

    # case 2.2: add iptables less than keepAlive
    Given execute oscmd in "mysql-master2"
    """
    iptables -A INPUT -p tcp --dport 3306 -j DROP
    iptables -A OUTPUT -p tcp --dport 3306 -j DROP
    """
    Given check remote "3306" in "mysql-master2" connected "N"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                        | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'timeout'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given check remote "3306" in "mysql-master2" connected "Y"
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose  | sql      | expect  | timeout |
      | conn_1 | false    | select 1 | success | 6       |
    # 先检查心跳恢复正常，再检查心跳连接未发生变化
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 15,2    |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | True    | select * from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_6"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Then check resultsets "heartbeat_conn_6" including resultset "heartbeat_conn_5" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |

    # case 3: keepAlive value is 0s
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat keepAlive="0">select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0  | false   | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 3,2     |
    Given execute oscmd in "mysql-master2"
    """
    iptables -A INPUT -p tcp --dport 3306 -j DROP
    iptables -A OUTPUT -p tcp --dport 3306 -j DROP
    """
    Given check remote "3306" in "mysql-master2" connected "N"
    #先获取心跳连接，再check心跳状态
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | True    | select * from dble_information.backend_connections where used_for_heartbeat='true' and db_instance_name='hostM2' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_7"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                        | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'timeout'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |
    Given record current dble log line number in "log_num_5"
    #print log and mysqlId change
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_5" in host "dble-1" retry "5,2" times
    """
      \[heartbeat\]connect timeout,the connection may be unreachable for a long time due to TCP retransmission
    """
    Given execute oscmd in "mysql-master2"
    """
    iptables -F
    """
    Given check remote "3306" in "mysql-master2" connected "Y"
    Given execute sql in "mysql-master2" in "mysql" mode
      | conn   | toClose  | sql      | expect  | timeout |
      | conn_1 | false    | select 1 | success | 6       |
    # 先检查新建了心跳连接，再检查心跳恢复正常
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                              | expect      | timeout |
      | conn_0 | True    | select * from dble_information.backend_connections where used_for_heartbeat='true' and db_instance_name='hostM2' | length{(1)} | 3,2     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "heartbeat_conn_8"
      | conn   | toClose | sql                                                                                                                                  |
      | conn_0 | false   | select remote_processlist_id from dble_information.backend_connections where db_instance_name='hostM2' and used_for_heartbeat='true' |
    Then check resultsets "heartbeat_conn_7" does not including resultset "heartbeat_conn_8" in following columns
      | column                | column_index |
      | remote_processlist_id | 0            |
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                                                                   | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'ok'}, hasStr{'hostM1', '172.100.9.5', 3306, 'ok'} | dble_information | 6,2     |

    # case 4: keepAlive value is -1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat keepAlive="-1">select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        <property name="heartbeatPeriodMillis">3000</property>
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure.The reason is dbGroup ha_group2 keepAlive should be greater than 0!
    """

  #DBLE0REQ-1371
  Scenario: check heartbeat connection - dbInstance has only one heartbeat connection #2
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect  |
      | conn_0 | False   | dbGroup @@disable name='ha_group1' instance='hostM1'                | success |
      | conn_0 | False   | fresh conn forced where dbGroup='ha_group1' and dbInstance='hostM1' | success |
      | conn_0 | False   | dbGroup @@enable name='ha_group1' instance='hostM1'                 | success |
      | conn_0 | False   | reload @@config_all                                                 | success |
      | conn_0 | False   | reload @@config_all -fr                                             | success |
      | conn_0 | True    | select * from dble_information.backend_connections where used_for_heartbeat='true' and db_instance_name='hostM1' | length{(1)} |
    Given sleep "60" seconds
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    setTimeout
    """