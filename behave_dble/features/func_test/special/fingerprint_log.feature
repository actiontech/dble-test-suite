# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/10/27

# DBLE0REQ-1284
Feature: check fingerprint log
  # fingerprint example: /*#timestamp=xxxx from=xxxx reason=xxxx*/

  Scenario: check fingerprint on manager side #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
       <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="1000" >
          <heartbeat>show slave status</heartbeat>
           <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
           <dbInstance name="hostS2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" />
       </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given record current dble log line number in "log_line"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                     | expect                | db               |
      | conn_1 | False   | select * from session_connections                                       | success               | dble_information |
      | conn_1 | False   | insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha) value ('ha_group5', 'select user()', 0, 1, 1, 100, 'false') | success | dble_information |
      | conn_1 | False   | update dble_db_group set rw_split_mode=3 where name="ha_group5"         | success               | dble_information |
      | conn_1 | False   | delete from dble_db_group where name="ha_group5"                        | success               | dble_information |
      | conn_1 | False   | show @@config                                                           | Unsupported statement | dble_information |
      | conn_1 | False   | aaa @@config                                                            | Unsupported statement | dble_information |
      | conn_1 | False   | show @@heartbeat                                                        | success               | dble_information |
      | conn_1 | False   | check @@metadata                                                        | success               | dble_information |
      | conn_1 | False   | reload @@config                                                         | success               | dble_information |
      | conn_1 | False   | stop @@heartbeat ha_group2:3                                            | success               | dble_information |
      | conn_1 | False   | flow_control @@list                                                     | success               | dble_information |
      | conn_1 | False   | flow_control @@show                                                     | success               | dble_information |
      | conn_1 | False   | flow_control @@set enableFlowControl=false                              | success               | dble_information |
      | conn_1 | False   | dryrun                                                                  | success               | dble_information |
      | conn_1 | False   | fresh conn where dbGroup='ha_group1'                                    | success               | dble_information |
      | conn_1 | False   | drop database @@shardingNode="dn5"                                      | success               | dble_information |
      | conn_1 | False   | create database @@shardingNode="dn5"                                    | success               | dble_information |
      | conn_1 | False   | enable @@slow_query_log                                                 | success               | dble_information |
      | conn_1 | False   | disable @@slow_query_log                                                | success               | dble_information |
      | conn_1 | False   | enable @@general_log                                                    | success               | dble_information |
      | conn_1 | False   | disable @@general_log                                                   | success               | dble_information |
      | conn_1 | False   | reload @@general_log_file="general/test.log"                            | success               | dble_information |
      | conn_1 | False   | offline                                                                 | success               | dble_information |
      | conn_1 | False   | online                                                                  | success               | dble_information |
      | conn_1 | False   | pause @@shardingNode='dn1,dn2' and timeout=10,queue=10,wait_limit=10    | success               | dble_information |
      | conn_1 | False   | resume                                                                  | success               | dble_information |
      | conn_1 | False   | reload @@metadata                                                       | success               | dble_information |
      | conn_1 | False   | dbGroup @@disable name='ha_group1'                                      | success               | dble_information |
      | conn_1 | False   | dbGroup @@enable name='ha_group1'                                       | success               | dble_information |
      | conn_1 | False   | dbGroup @@switch name='ha_group2' master='hostS2'                       | success               | dble_information |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line" in host "dble-1"
    """
    select * from session_connections
    show @@heartbeat
    check @@metadata
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line" in host "dble-1" retry "5" times
    """
    INFO.*execute manager cmd from .*172.100.9.8.*insert into dble_db_group\(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha\)
    INFO.*execute manager cmd from .*172.100.9.8.*update dble_db_group set rw_split_mode=3 where name=\"ha_group5\"
    INFO.*execute manager cmd from .*172.100.9.8.*delete from dble_db_group where name=\"ha_group5\"
    WARN.*Unsupported show:show @@config
    INFO.*execute manager cmd from .*172.100.9.8.*aaa @@config
    INFO.*execute manager cmd from .*172.100.9.8.*reload @@config
    INFO.*execute manager cmd from .*172.100.9.8.*stop @@heartbeat ha_group2:3
    INFO.*execute manager cmd from .*172.100.9.8.*flow_control @@list
    INFO.*execute manager cmd from .*172.100.9.8.*flow_control @@show
    INFO.*execute manager cmd from .*172.100.9.8.*flow_control @@set enableFlowControl=false
    INFO.*execute manager cmd from .*172.100.9.8.*dryrun
    INFO.*execute manager cmd from .*172.100.9.8.*fresh conn where dbGroup='ha_group1'
    INFO.*execute manager cmd from .*172.100.9.8.*drop database @@shardingNode=\"dn5\"
    INFO.*execute manager cmd from .*172.100.9.8.*create database @@shardingNode=\"dn5\"
    INFO.*execute manager cmd from .*172.100.9.8.*enable @@slow_query_log
    INFO.*execute manager cmd from .*172.100.9.8.*disable @@slow_query_log
    INFO.*execute manager cmd from .*172.100.9.8.*enable @@general_log
    INFO.*execute manager cmd from .*172.100.9.8.*disable @@general_log
    INFO.*execute manager cmd from .*172.100.9.8.*reload @@general_log_file=\"general/test.log\"
    INFO.*execute manager cmd from .*172.100.9.8.*offline
    INFO.*execute manager cmd from .*172.100.9.8.*online
    INFO.*execute manager cmd from .*172.100.9.8.*pause @@shardingNode='dn1,dn2' and timeout=10,queue=10,wait_limit=10
    INFO.*execute manager cmd from .*172.100.9.8.*resume
    INFO.*execute manager cmd from .*172.100.9.8.*reload @@metadata
    INFO.*execute manager cmd from .*172.100.9.8.*dbGroup @@disable name='ha_group1'
    INFO.*execute manager cmd from .*172.100.9.8.*dbGroup @@enable name='ha_group1'
    INFO.*execute manager cmd from .*172.100.9.8.*dbGroup @@switch name='ha_group2' master='hostS2'
    """
    Given record current dble log line number in "log_line"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                          | expect                | db               |
      | conn_1 | False   | /*# key=1 */select * from session_connections                                | success               | dble_information |
      | conn_1 | False   | /*# insert=dble_db_group*/insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha) value ('ha_group5', 'select user()', 0, 1, 1, 100, 'false') | success | dble_information |
      | conn_1 | False   | /*#update=dble_db_group*/update dble_db_group set rw_split_mode=3 where name="ha_group5" | success   | dble_information |
      | conn_1 | False   | /*#delete=dble_db_group */delete from dble_db_group where name="ha_group5"   | success               | dble_information |
      | conn_1 | False   | /*# show=config */show @@config                                              | Unsupported statement | dble_information |
      | conn_1 | False   | /*# aaa=config */ aaa @@config                                               | Unsupported statement | dble_information |
      | conn_1 | False   | /*# show=heartbeat */ show @@heartbeat                                       | success               | dble_information |
      | conn_1 | False   | /*# reload=config */ reload @@config                                         | success               | dble_information |
      | conn_1 | False   | /*# stop=heartbeat */stop @@heartbeat ha_group2:3                            | success               | dble_information |
      | conn_1 | False   | /*# flow_control=list and test_key=test_value ab=cd */flow_control @@list    | success               | dble_information |
      | conn_1 | False   | /*# flow_control=show */flow_control @@show                                  | success               | dble_information |
      | conn_1 | False   | /*# flow_control=set */flow_control @@set enableFlowControl=false            | success               | dble_information |
      | conn_1 | False   | /*# dryrun=1 2=test ab=@cd key=#value */dryrun                               | success               | dble_information |
      | conn_1 | False   | /*# fresh=conn & dbGroup=ha_group1 */fresh conn where dbGroup = 'ha_group1'  | success               | dble_information |
      | conn_1 | False   | /*# drop=database */drop database @@shardingNode ="dn5"                      | success               | dble_information |
      | conn_1 | False   | /*# create=database */ create database @@shardingNode="dn5"                  | success               | dble_information |
      | conn_1 | False   | /*# enable=slow_query_log */enable @@slow_query_log                          | success               | dble_information |
      | conn_1 | False   | /*# disable=slow_query_log */disable @@slow_query_log                        | success               | dble_information |
      | conn_1 | False   | /*# enable=@general_log */enable @@general_log                               | success               | dble_information |
      | conn_1 | False   | /*# disable=@@general_log */disable @@general_log                            | success               | dble_information |
      | conn_1 | False   | /*# reload=general_log_file */reload @@general_log_file="general/test.log"   | success               | dble_information |
      | conn_1 | False   | /*# 1=offline */offline                                                      | success               | dble_information |
      | conn_1 | False   | /*# 2=online */online                                                        | success               | dble_information |
      | conn_1 | False   | /*# pause=shardingNode */pause @@shardingNode='dn1,dn2' and timeout=10,queue=10,wait_limit=10 | success | dble_information |
      | conn_1 | False   | /*# resume=true */resume                                                     | success               | dble_information |
      | conn_1 | False   | /*# reload = metadata */reload @@metadata                                    | success               | dble_information |
      | conn_1 | False   | /*# dbGroup=disable */dbGroup @@disable name='ha_group1'                     | success               | dble_information |
      | conn_1 | False   | /*# dbGroup=enable */dbGroup @@enable name='ha_group1'                       | success               | dble_information |
      | conn_1 | False   | /*# dbGroup=switch */dbGroup @@switch name='ha_group2' master='hostM2'       | success               | dble_information |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_line" in host "dble-1"
    """
    select * from session_connections
    show @@heartbeat
    """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line" in host "dble-1" retry "5" times
    """
    INFO.*execute manager cmd from .*172.100.9.8.*insert into dble_db_group\(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha\) value
    INFO.*execute manager cmd from .*172.100.9.8.*/\*#update=dble_db_group\*/update dble_db_group set rw_split_mode=3 where name=\"ha_group5\"
    INFO.*execute manager cmd from .*172.100.9.8.*/\*#delete=dble_db_group \*/delete from dble_db_group where name=\"ha_group5\"
    WARN.*Unsupported show:/\*# show=config \*/show @@config
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# aaa=config \*/ aaa @@config
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# reload=config \*/ reload @@config
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# stop=heartbeat \*/stop @@heartbeat ha_group2:3
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# flow_control=list and test_key=test_value ab=cd \*/flow_control @@list
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# flow_control=show \*/flow_control @@show
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# flow_control=set \*/flow_control @@set enableFlowControl=false
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# dryrun=1 2=test ab=@cd key=#value \*/dryrun
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# fresh=conn & dbGroup=ha_group1 \*/fresh conn where dbGroup =
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# drop=database \*/drop database @@shardingNode =\"dn5\"
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# create=database \*/ create database @@shardingNode=\"dn5\"
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# enable=slow_query_log \*/enable @@slow_query_log
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# disable=slow_query_log \*/disable @@slow_query_log
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# enable=@general_log \*/enable @@general_log
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# disable=@@general_log \*/disable @@general_log
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# reload=general_log_file \*/reload @@general_log_file=\"general/test.log\"
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# 1=offline \*/offline
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# 2=online \*/online
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# pause=shardingNode \*/pause @@shardingNode='dn1,dn2' and timeout=10,queue=10,wait_limit=10
    INFO.*execute manager cmd from .*172.100.9.8.*/*\# resume=true \*/resume
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# reload = metadata \*/reload @@metadata
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# dbGroup=disable \*/dbGroup @@disable name='ha_group1'
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# dbGroup=enable \*/dbGroup @@enable name='ha_group1'
    INFO.*execute manager cmd from .*172.100.9.8.*/\*# dbGroup=switch \*/dbGroup @@switch name='ha_group2' master='hostM2'
    """

  @restore_global_setting
  Scenario: check fingerprint on client side #2
    """
    {'restore_global_setting':{'mysql-master2':{'general_log':0},'mysql-master1':{'general_log':0},'mysql-slave1':{'general_log':0}}}
    """
    Given delete all backend mysql tables
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DinstanceName/d
    $a -DinstanceName=instance-test
    """
    Then restart dble in "dble-1" success
    Given turn on general log in "mysql-master1"
    Given turn on general log in "mysql-slave1"
    Given turn on general log in "mysql-master2"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="1000" delayPeriodMillis="1000" delayDatabase="delay_test">
    <heartbeat>show slave status</heartbeat>
    <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
      <property name="heartbeatPeriodMillis">2000</property>
    </dbInstance>
    <dbInstance name="hostS2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" />
    </dbGroup>
    """
    Given record current dble log line number in "log_linenu"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1" retry "5" times
    """
    from=instance-test reason=one time job\*/show databases to con
    from=instance-test reason=one time job\*/select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@.*_isolation,@@version
    from=instance-test reason=one time job\*/show variables to con
    """
    Given record current dble log line number in "log_linenu1"
    Then execute admin cmd "reload @@metadata"
    Then check the time interval of following key after line "log_linenu1" in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                                                             | interval_times | percent |
      | from=instance-test reason=sql job\*/show full tables where Table_type =                         | 15             | 1       |
    Given record current dble log line number in "log_linenu2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                             | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(10))                             | success | schema1 |
      | conn_1 | False   | create index id_index on sharding_4_t1(id)                                      | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values(1,"name1"),(2,"name2"),(3,"name3"),(4,"name4") | success | schema1 |
      | conn_1 | False   | update sharding_4_t1 set name="33" where id=3                                   | success | schema1 |
      | conn_1 | False   | delete from sharding_4_t1                                                       | success | schema1 |
      | conn_1 | False   | drop index id_index on sharding_4_t1                                            | success | schema1 |
      | conn_1 | False   | create view test_view as select * from sharding_4_t1                            | success | schema1 |
      | conn_1 | False   | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_1 | False   | select * from test_view                                                         | success | schema1 |
      | conn_1 | False   | drop view test_view                                                             | success | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu2" in host "dble-1"
      """
      \*/drop table if exists sharding_4_t1
      \*/create table sharding_4_t1(id int,name varchar(10))
      \*/create index id_index on sharding_4_t1(id)
      \*/insert into sharding_4_t1 values(1,\"name1\"),(2,\"name2\"),(3,\"name3\"),(4,\"name4\")
      \*/update sharding_4_t1 set name=\"33\" where id=3
      \*/delete from sharding_4_t1
      \*/drop index id_index on sharding_4_t1
      \*/create view test_view as select * from sharding_4_t1
      \*/select * from sharding_4_t1
      \*/select * from test_view
      \*/drop view test_view
      """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu1" in host "dble-1" retry "2,2" times
    """
    heartbeat to [[]172.100.9.6:3306[]] setOK
    """
    Then check general log in host "mysql-master2" has "from=instance-test reason=heartbeat\*/show slave status" occured ">0" times
    Then check general log in host "mysql-slave1" has "from=instance-test reason=heartbeat\*/show slave status" occured ">0" times
    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-master1"
    Given turn off general log in "mysql-slave1"