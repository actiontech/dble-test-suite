# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/10/27

# DBLE0REQ-1284
Feature: check fingerprint log
  # fingerprint example: /*#timestamp=xxxx from=xxxx reason=xxxx*/

  Scenario: check fingerprint on manager side #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
       <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
           <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true"/>
           <dbInstance name="hostS2" password="111111" url="172.100.9.2:3307" user="test" maxCon="1000" minCon="10" />
       </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
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
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    select * from session_connections
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha)' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha)
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'update dble_db_group set rw_split_mode=3 where name="ha_group5"' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    update dble_db_group set rw_split_mode=3 where name=\"ha_group5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'delete from dble_db_group where name="ha_group5"' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    delete from dble_db_group where name=\"ha_group5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    Unsupported show:show @@config
    """
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'aaa @@config' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    aaa @@config
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    show @@heartbeat
    """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    check @@metadata
    """
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'reload @@config' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    reload @@config
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'stop @@heartbeat ha_group2:3' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    stop @@heartbeat ha_group2:3
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"

    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'flow_control @@list' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    flow_control @@list
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'flow_control @@show' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    flow_control @@show
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"

    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'flow_control @@set enableFlowControl=false' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    flow_control @@set enableFlowControl=false
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'dryrun' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    dryrun
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'fresh conn where dbGroup=' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    fresh conn where dbGroup=
    ha_group1
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'drop database @@shardingNode="dn5"' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    drop database @@shardingNode=\"dn5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'create database @@shardingNode="dn5"' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    create database @@shardingNode=\"dn5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'enable @@slow_query_log' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    enable @@slow_query_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'disable @@slow_query_log' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    disable @@slow_query_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'enable @@general_log' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    enable @@general_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'disable @@general_log' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    disable @@general_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'reload @@general_log_file="general/test.log"' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    reload @@general_log_file=\"general/test.log\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'offline' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    offline
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'online' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    online
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'pause @@shardingNode=' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    pause @@shardingNode=
    dn1,dn2
    and timeout=10,queue=10,wait_limit=10
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'resume' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    resume
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'reload @@metadata' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    reload @@metadata
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'dbGroup @@disable name=' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    dbGroup @@disable name=
    ha_group1
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'dbGroup @@enable name=' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    dbGroup @@enable name=
    ha_group1
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep 'dbGroup @@switch name=' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    dbGroup @@switch name=
    ha_group2
    master=
    hostS2
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given record current dble log line number in "log_linenu"
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
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    select * from session_connections
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# insert=dble_db_group\*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# insert=dble_db_group\*/insert into dble_db_group(name, heartbeat_stmt, heartbeat_timeout, heartbeat_retry, rw_split_mode, delay_threshold, disable_ha)
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*#update=dble_db_group\*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*#update=dble_db_group\*/update dble_db_group set rw_split_mode=3 where name=\"ha_group5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*#delete=dble_db_group \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*#delete=dble_db_group \*/delete from dble_db_group where name=\"ha_group5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# show=config \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    WARN
    Unsupported show:/\*# show=config \*/show @@config
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# aaa=config \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# aaa=config \*/ aaa @@config
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    show @@heartbeat
    """
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# reload=config \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# reload=config \*/ reload @@config
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# stop=heartbeat \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# stop=heartbeat \*/stop @@heartbeat ha_group2:3
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# flow_control=list and test_key=test_value ab=cd \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# flow_control=list and test_key=test_value ab=cd \*/flow_control @@list
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# flow_control=show \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# flow_control=show \*/flow_control @@show
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"

    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# flow_control=set \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# flow_control=set \*/flow_control @@set enableFlowControl=false
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# dryrun=1 2=test ab=@cd key=#value \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# dryrun=1 2=test ab=@cd key=#value \*/dryrun
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# fresh=conn & dbGroup=ha_group1 \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# fresh=conn & dbGroup=ha_group1 \*/fresh conn where dbGroup =
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# drop=database \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# drop=database \*/drop database @@shardingNode =\"dn5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# create=database \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# create=database \*/ create database @@shardingNode=\"dn5\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# enable=slow_query_log \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# enable=slow_query_log \*/enable @@slow_query_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# disable=slow_query_log \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# disable=slow_query_log \*/disable @@slow_query_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# enable=@general_log \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# enable=@general_log \*/enable @@general_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# disable=@@general_log \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# disable=@@general_log \*/disable @@general_log
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# reload=general_log_file \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# reload=general_log_file \*/reload @@general_log_file=\"general/test.log\"
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# 1=offline \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# 1=offline \*/offline
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# 2=online \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# 2=online \*/online
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# pause=shardingNode \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# pause=shardingNode \*/pause @@shardingNode=
    dn1,dn2
    and timeout=10,queue=10,wait_limit=10
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/*\# resume=true \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /*\# resume=true \*/resume
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# reload = metadata \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# reload = metadata \*/reload @@metadata
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# dbGroup=disable \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# dbGroup=disable \*/dbGroup @@disable name=
    ha_group1
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# dbGroup=enable \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# dbGroup=enable \*/dbGroup @@enable name=
    ha_group1
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    cat /opt/dble/logs/dble.log | grep '/\*# dbGroup=switch \*/' > /tmp/fingerprint.log
    """
    Then check following text exist "Y" in file "/tmp/fingerprint.log" in host "dble-1"
    """
    INFO
    execute manager cmd from UserName{name='root', tenant='null'}@172.100.9.8
    /\*# dbGroup=switch \*/dbGroup @@switch name=
    ha_group2
    master=
    hostM2
    """
    Given delete file "/tmp/fingerprint.log" on "dble-1"

  @restore_global_setting
  Scenario: check fingerprint on client side #2
    """
    {'restore_global_setting':{'mysql-master1':{'general_log':0}}}
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
  """
    /-DinstanceName/d
    $a -DinstanceName=instance-test
    """
    Then restart dble in "dble-1" success
    Given turn on general log in "mysql-master1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
    <heartbeat>select user()</heartbeat>
    <dbInstance name="hostM2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10" primary="true"/>
    <dbInstance name="hostS2" password="111111" url="172.100.9.2:3307" user="test" maxCon="1000" minCon="10" />
    </dbGroup>
    """
    Given record current dble log line number in "log_linenu"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
    """
    from=instance-test reason=one time job\*/show databases to con
    from=instance-test reason=one time job\*/select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@tx_isolation,@@version to con
    from=instance-test reason=one time job\*/show variables to con
    """
    Given record current dble log line number in "log_linenu"
    Then execute admin cmd "reload @@metadata"
    Then check the time interval of following key after line "log_linenu" in file "/opt/dble/logs/dble.log" in "dble-1"
      | key                                                                                         | interval_times |
      | from=instance-test reason=sql job\*/show full tables where Table_type ='BASE TABLE'  to con | 15             |
    Given record current dble log line number in "log_linenu"
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
      | conn_1 | False   | select * from test_view                                                         | success | schema1 |
      | conn_1 | False   | drop view test_view                                                             | success | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
      """
      \*/drop table if exists sharding_4_t1
      \*/create table sharding_4_t1(id int,name varchar(10))
      \*/create index id_index on sharding_4_t1(id)
      \*/insert into sharding_4_t1 values(1,\"name1\"),(2,\"name2\"),(3,\"name3\"),(4,\"name4\")
      \*/update sharding_4_t1 set name=\"33\" where id=3
      \*/delete from sharding_4_t1
      \*/drop index id_index on sharding_4_t1
      \*/create view test_view as select * from sharding_4_t1
      \*/select * from test_view
      \*/drop view test_view
      """
    Given sleep "10" seconds
    Then check general log in host "mysql-master1" has "/\*# from=instance-test reason=heartbeat\*/select user()" occured ">0" times
    Given turn off general log in "mysql-master1"