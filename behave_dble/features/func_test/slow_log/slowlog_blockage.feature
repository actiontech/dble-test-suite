# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/5/12

Feature: slowlog_blockage
  ###form DBLE0REQ-2228

  @skip_restart
  Scenario: 因慢日志过多阻塞导致创建链接和心跳失败
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-Dprocessors=/d
      /-DprocessorExecutor=/d
      $a -Dprocessors=2
      $a -DprocessorExecutor=2
      $a -DbackendProcessorExecutor=2
      $a -DsqlSlowTime=1
      $a -DenableSlowLog=1
      $a -DsqlSlowTime=1
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="100" minCon="4" primary="true">
            <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
      </dbGroup>

      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="4" primary="true">
            <property name="heartbeatPeriodMillis">2000</property>
        </dbInstance>
      </dbGroup>
      """
    Given Restart dble in "dble-1" success

     ###两个事务，占用掉4跟链接
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect      | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                         | success     | schema1 |
      | conn_3 | False   | create table sharding_4_t1(id int,name varchar(20))        | success     | schema1 |
      | conn_3 | False   | insert into sharding_4_t1 values(2,2),(4,4),(1,1),(3,3)    | success     | schema1 |

    Then connect "dble-1" to insert "1000" of data for "sharding_4_t1"
     ###两个事务，占用掉4跟链接
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect                     | db      |
      | conn_1 | False   | begin;select * from sharding_4_t1                          | success                    | schema1 |
      | conn_2 | False   | begin;select * from sharding_4_t1                          | success                    | schema1 |
    ### 这个桩是模拟慢日志写满阈值，导致backendBusinessExecutor阻塞
    Given prepare a thread run btrace script "BtraceAboutslow.java" in "dble-1"
    ##新建链接会hang住
    Then execute "user" cmd  in "dble-1" at background
      | conn    | toClose | sql                           | db        |
      | conn_11 | false   | select * from sharding_4_t1   | schema1   |
    Then check btrace "BtraceAboutslow.java" output in "dble-1"
      """
      get into putSlowQueryLog
      """
    Given sleep "5" seconds
    Then get result of oscmd named "A" in "dble-1"
      """
      jstack `jps | grep WrapperSimpleApp | awk '{print $1}'` | grep 'backendBusinessExecutor' | wc -l
      """
    Then check result "A" value is "2"
    #创建链接hang住的  这一步还没有适用的ci自动化  需要手动执行
#    Then execute "user" cmd  in "dble-1" at background
#      | conn    | toClose | sql                                       | db        |
#      | conn_21 | false   | select * from sharding_4_t1 limit 10000   | schema1   |
#    Then execute "user" cmd  in "dble-1" at background
#      | conn    | toClose | sql                                       | db        |
#      | conn_22 | false   | select * from sharding_4_t1 limit 10000   | schema1   |
#    Then execute "user" cmd  in "dble-1" at background
#      | conn    | toClose | sql                                       | db        |
#      | conn_23 | false   | select * from sharding_4_t1 limit 10000   | schema1   |

    Given execute "user" sql "1000" times in "dble-1" at background concurrent "100"

      | sql                                     | db      |
      | select * from sharding_4_t1 limit 10000 | schema1 |


    ####找到心跳的那根连接 去mysql kill
    Given execute linux command in "dble-1" and save result in "dble_idle_connections"
      """
      mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -Ddble_information -e "select remote_processlist_id from backend_connections where used_for_heartbeat='true' and db_instance_name='hostM1' "
      """
    Given kill mysql conns in "mysql-master1" in "dble_idle_connections"
    #由于kill连接和查询间隔太快，会偶发查询的时候还没kill完成，会查多余预期条数的连接。改成重试查询kill完成了
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                         | expect        | db                |timeout|
      | new    | false   | select remote_processlist_id from backend_connections where used_for_heartbeat='true'       | length{(1)}   | dble_information  | 10,0.5|
      | new    | false   | show @@heartbeat | hasStr{'error'} | dble_information | 30,1     |



#    #    Then execute sql in "dble-1" in "admin" mode
#      | sql                                                               | expect        | db |
#      | select * from backend_connections where used_for_heartbeat='true' | length{(1)} | dble_information|


#    Given execute sql "10000" times in "dble-1" at concurrent
#      | sql                                         | db      |
#      | select * from sharding_4_t1 limit 10000 | schema1 |


#    Given execute sql in "dble-1" in "admin" mode
#    | conn   | toClose  | sql              | expect                                         | db               | timeout |
#    | conn_1 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3307, 'error'} | dble_information | 6,2     |



