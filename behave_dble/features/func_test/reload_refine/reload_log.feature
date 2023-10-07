# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/09/26

# DBLE0REQ-1929
Feature: check reload log
  
  Scenario: check reload log #1

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_1 | false   | drop table if exists test           | success | schema1 |
      | conn_1 | false   | drop table if exists sharding_2_t1  | success | schema1 |
      | conn_1 | false   | drop table if exists sharding_4_t1  | success | schema1 |
    Given delete all backend mysql tables
    
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" url="172.100.9.6:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10">
        </dbInstance>
     </dbGroup>
    """

    # add slave host dry run
    Then execute admin cmd "dryrun"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
    """
    \[dry-run\] start load all xml info
    \[dry-run\] test connection from backend start
    \[dry-run\] check dble and mysql version start
    \[dry-run\] check and get system variables from backend start
    \[dry-run\] get variables from backend start
    \[dry-run\] check user start
    \[dry-run\] check delay detection start
    \[dry-run\] end ...
    """

    # add slave host reload
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
    """
    \[RL\]\[NONE\] added configLock
    \[RL\]\[0-SELF_RELOAD\] _____________________reload start________0__RELOAD_ALL
    \[RL\]\[0-SELF_RELOAD\] load config start \[local xml\]
    \[RL\]\[0-SELF_RELOAD\] load config end
    \[RL\]\[0-SELF_RELOAD\] compare changes start
    \[RL\]\[0-SELF_RELOAD\] change items :\[ChangeItem{type=ADD, item=dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\]
    \[RL\]\[0-SELF_RELOAD\] compare changes end
    \[RL\]\[0-SELF_RELOAD\] test connection start
    \[RL\]\[0-SELF_RELOAD\] test connection dbInstance:dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],is connect:true,schemaList:\[\(dn2, db1\), \(dn4, db2\)\]
    \[RL\]\[0-SELF_RELOAD\] test connection end
    \[RL\]\[0-SELF_RELOAD\] check and get system variables from random node start
    \[RL\]\[0-SELF_RELOAD\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],result:KeyVariables.*
    \[RL\]\[0-SELF_RELOAD\] get system variables :show variables
    \[RL\]\[0-SELF_RELOAD\] check and get system variables from random node end
    \[RL\]\[0-SELF_RELOAD\] skip recycle old active backend connections
    \[RL\]\[0-SELF_RELOAD\] selfChecking0 ...
    \[RL\]\[0-SELF_RELOAD\] apply new config start
    \[RL\]\[0-SELF_RELOAD\] calcDiffForMetaData ...
    \[RL\]\[0-SELF_RELOAD\] added metaLock
    \[RL\]\[0-SELF_RELOAD\] checkUser ...
    \[RL\]\[0-SELF_RELOAD\] init new dbGroup start
    \[RL\]\[0-SELF_RELOAD\] start heartbeat
    \[RL\]\[0-SELF_RELOAD\] init new dbGroup end
    \[RL\]\[0-SELF_RELOAD\] config the transformation ...
    \[RL\]\[0-SELF_RELOAD\] ha config init ...
    \[RL\]\[0-SELF_RELOAD\] reloadMetaData start
    \[RL\]\[0-SELF_RELOAD\] metadata will delete Tables:'schema1test','schema1sharding_2_t1','schema1sharding_4_t1'
    \[RL\]\[0-SELF_RELOAD\] metadata finished for deleted tables
    \[RL\]\[0-SELF_RELOAD\] metadata will reload Tables:'schema1test','schema1sharding_2_t1','schema1sharding_4_t1'
    \[RL\]\[0-META_RELOAD\] _____________________meta reload start________0__RELOAD_ALL
    \[RL\]\[0-META_RELOAD\] Meta reload schema1
    \[RL\]\[0-META_RELOAD\] sharding filter schema1test,sharding_2_t1,sharding_4_t1
    \[RL\]\[0-META_RELOAD\] try to execute show tables in \[schema1\] default shardingNode: dn5
    \[RL\]\[0-META_RELOAD\] try to execute show tables in \[schema1\] config table's shardingNode: dn1,dn3,dn2,dn4
    \[RL\]\[0-META_RELOAD\] the Node dn1 has no exist table,count down
    \[RL\]\[0-META_RELOAD\] the Node dn3 has no exist table,count down
    \[RL\]\[0-META_RELOAD\] the Node dn2 has no exist table,count down
    \[RL\]\[0-META_RELOAD\] the Node dn4 has no exist table,count down
    \[RL\]\[0-META_RELOAD\] explicit tables in schema\[schema1\]
    \[RL\]\[0-META_RELOAD\] schema\[schema1\] loading metadata is completed
    \[RL\]\[0-META_RELOAD\] no table exist in schema schema1,count down
    \[RL\]\[0-META_RELOAD\] metadata finished for changes of schemas and tables
    \[RL\]\[0-META_RELOAD\] reloadMetaData end
    \[RL\]\[0-META_RELOAD\] released metaLock
    \[RL\]\[0-META_RELOAD\] apply new config end
    \[RL\]\[0-META_RELOAD\] skip recycle old active backend connections
    \[RL\]\[0-META_RELOAD\] released configLock
    \[RL\]\[0-NOT_RELOADING\] _____________________reload finished___________0__RELOAD_ALL
    """

    # update rwSplitMode=3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" url="172.100.9.6:3306" user="test" password="111111" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10">
        </dbInstance>
     </dbGroup>
    """
    Given record current dble log line number in "log_line_num1"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1" retry "5" times
    """
    \[RL\]\[NONE\] added configLock
    \[RL\]\[1-SELF_RELOAD\] _____________________reload start________1__RELOAD_ALL
    \[RL\]\[1-SELF_RELOAD\] load config start \[local xml\]
    \[RL\]\[1-SELF_RELOAD\] load config end
    \[RL\]\[1-SELF_RELOAD\] compare changes start
    \[RL\]\[1-SELF_RELOAD\] change items :\[ChangeItem{type=UPDATE, item=PhysicalDbGroup{groupName='ha_group2', dbGroupConfig=DbGroupConfig{name='ha_group2', rwSplitMode=3
    \[RL\]\[1-SELF_RELOAD\] compare changes end
    \[RL\]\[1-SELF_RELOAD\] test connection start
    \[RL\]\[1-SELF_RELOAD\] test connection end
    \[RL\]\[1-SELF_RELOAD\] check and get system variables from random node start
    \[RL\]\[1-SELF_RELOAD\] get system variables :show variables
    \[RL\]\[1-SELF_RELOAD\] check and get system variables from random node end
    \[RL\]\[1-SELF_RELOAD\] skip recycle old active backend connections
    \[RL\]\[1-SELF_RELOAD\] selfChecking0 ...
    \[RL\]\[1-SELF_RELOAD\] apply new config start
    \[RL\]\[1-SELF_RELOAD\] calcDiffForMetaData ...
    \[RL\]\[1-SELF_RELOAD\] added metaLock
    \[RL\]\[1-SELF_RELOAD\] checkUser ...
    \[RL\]\[1-SELF_RELOAD\] init new dbGroup start
    \[RL\]\[1-SELF_RELOAD\] start connection pool :dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, init read instance
    \[RL\]\[1-SELF_RELOAD\] init new dbGroup end
    \[RL\]\[1-SELF_RELOAD\] config the transformation ...
    \[RL\]\[1-SELF_RELOAD\] ha config init ...
    \[RL\]\[1-SELF_RELOAD\] reloadMetaData start
    \[RL\]\[1-SELF_RELOAD\] metadata will delete Tables:'schema1test','schema1sharding_2_t1','schema1sharding_4_t1'
    \[RL\]\[1-SELF_RELOAD\] metadata finished for deleted tables
    \[RL\]\[1-SELF_RELOAD\] metadata will reload Tables:'schema1test','schema1sharding_2_t1','schema1sharding_4_t1'
    \[RL\]\[1-META_RELOAD\] _____________________meta reload start________1__RELOAD_ALL
    \[RL\]\[1-META_RELOAD\] Meta reload schema1
    \[RL\]\[1-META_RELOAD\] sharding filter schema1test,sharding_2_t1,sharding_4_t1
    \[RL\]\[1-META_RELOAD\] try to execute show tables in \[schema1\] default shardingNode: dn5
    \[RL\]\[1-META_RELOAD\] try to execute show tables in \[schema1\] config table's shardingNode: dn1,dn3,dn2,dn4
    \[RL\]\[1-META_RELOAD\] the Node dn1 has no exist table,count down
    \[RL\]\[1-META_RELOAD\] the Node dn3 has no exist table,count down
    \[RL\]\[1-META_RELOAD\] the Node dn2 has no exist table,count down
    \[RL\]\[1-META_RELOAD\] the Node dn4 has no exist table,count down
    \[RL\]\[1-META_RELOAD\] explicit tables in schema\[schema1\]
    \[RL\]\[1-META_RELOAD\] schema\[schema1\] loading metadata is completed
    \[RL\]\[1-META_RELOAD\] no table exist in schema schema1,count down
    \[RL\]\[1-META_RELOAD\] metadata finished for changes of schemas and tables
    \[RL\]\[1-META_RELOAD\] reloadMetaData end
    \[RL\]\[1-META_RELOAD\] released metaLock
    \[RL\]\[1-META_RELOAD\] apply new config end
    \[RL\]\[1-META_RELOAD\] skip recycle old active backend connections
    \[RL\]\[1-META_RELOAD\] released configLock
    \[RL\]\[1-NOT_RELOADING\] _____________________reload finished___________1__RELOAD_ALL
    """

    # dbGroup @@disable
    Given record current dble log line number in "log_line_num2"
    Then execute admin cmd "dbGroup @@disable name='ha_group2'"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1" retry "5" times
    """
    \[HA\] added configLock
    \[HA\] id = 0 start of Ha event type =LOCAL_COMMAND command = @@disable name='ha_group2' stage = LOCAL_CHANGE
    \[HA\] added dbGroupLock
    \[HA\] start to update the local file with sync flag true
    \[HA\] get into writeDirectly process
    \[HA\] try to writeDirectly DbGroups into local file
    \[HA\] released dbGroupLock
    \[HA\] id = 0 end of Ha event type =LOCAL_COMMAND command = @@disable name='ha_group2' stage = LOCAL_CHANGE finish type = \"success\"
    \[HA\] released configLock
    \[RL\]\[1-NOT_RELOADING\] stop heartbeat :dbInstance\[name=hostM2,disabled=true,maxCon=1000,minCon=10\],reason:ha command disable dbInstance
    \[RL\]\[1-NOT_RELOADING\] stop delayDetection :dbInstance\[name=hostM2,disabled=true,maxCon=1000,minCon=10\],reason:ha command disable dbInstance
    \[RL\]\[1-NOT_RELOADING\] stop connection pool :dbInstance\[name=hostM2,disabled=true,maxCon=1000,minCon=10\],reason:ha command disable dbInstance,is close front:false
    \[RL\]\[1-NOT_RELOADING\] stop heartbeat :dbInstance\[name=hostS1,disabled=true,maxCon=1000,minCon=10\],reason:ha command disable dbInstance
    \[RL\]\[1-NOT_RELOADING\] stop delayDetection :dbInstance\[name=hostS1,disabled=true,maxCon=1000,minCon=10\],reason:ha command disable dbInstance
    \[RL\]\[1-NOT_RELOADING\] stop connection pool :dbInstance\[name=hostS1,disabled=true,maxCon=1000,minCon=10\],reason:ha command disable dbInstance,is close front:false
    """

    # dbGroup @@switch
    Given record current dble log line number in "log_line_num3"
    Then execute admin cmd "dbGroup @@switch name='ha_group2' master='hostS1'"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num3" in host "dble-1" retry "5" times
    """
    \[HA\] added configLock
    \[HA\] id = 1 start of Ha event type =LOCAL_COMMAND command = @@switch name='ha_group2' master='hostS1' stage = LOCAL_CHANGE
    \[HA\] added dbGroupLock
    \[HA\] start to update the local file with sync flag true
    \[HA\] get into writeDirectly process
    \[HA\] try to writeDirectly DbGroups into local file
    \[HA\] released dbGroupLock
    \[HA\] id = 1 end of Ha event type =LOCAL_COMMAND command = @@switch name='ha_group2' master='hostS1' stage = LOCAL_CHANGE finish type = \"success\"
    \[HA\] released configLock
    """

    # dbGroup @@enable
    Given record current dble log line number in "log_line_num4"
    Then execute admin cmd "dbGroup @@enable name='ha_group2'"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num4" in host "dble-1" retry "5" times
    """
    \[HA\] added configLock
    \[HA\] id = 2 start of Ha event type =LOCAL_COMMAND command = @@enable name='ha_group2' stage = LOCAL_CHANGE
    \[HA\] added dbGroupLock
    \[HA\] start to update the local file with sync flag true
    \[HA\] get into writeDirectly process
    \[HA\] try to writeDirectly DbGroups into local file
    \[HA\] released dbGroupLock
    \[HA\] id = 2 end of Ha event type =LOCAL_COMMAND command = @@enable name='ha_group2' stage = LOCAL_CHANGE finish type = \"success\"
    \[HA\] released configLock
    \[RL\]\[1-NOT_RELOADING\] start connection pool :dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\],reason:execute manager cmd of enable
    \[RL\]\[1-NOT_RELOADING\] start connection pool :dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],reason:execute manager cmd of enable
    \[RL\]\[1-NOT_RELOADING\] start heartbeat
    \[RL\]\[1-NOT_RELOADING\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\]
    \[RL\]\[1-NOT_RELOADING\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\]
    """

    # insert dble_db_group
    Given record current dble log line number in "log_line_num5"
    Then execute admin cmd "insert into dble_information.dble_db_group set `name`='ha_group3',`heartbeat_stmt`='select 1',`heartbeat_timeout`='0',`heartbeat_retry`='0',`rw_split_mode`='0',`delay_threshold`='-1',`disable_ha`='false'"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num5" in host "dble-1" retry "5" times
    """
    \[RL\]\[NONE\] added configLock
    \[RL\]\[2-SELF_RELOAD\] _____________________reload start________2__MANAGER_INSERT:dble_db_group
    \[RL\]\[2-SELF_RELOAD\] load config start \[memory\]
    \[RL\]\[2-SELF_RELOAD\] memory to Users is :{\"user\":\[{\"type\":\"ManagerUser\".*,{\"type\":\"ShardingUser\".*
    \[RL\]\[2-SELF_RELOAD\] load config end
    \[RL\]\[2-SELF_RELOAD\] compare changes start
    \[RL\]\[2-SELF_RELOAD\] change items :\[ChangeItem{type=UPDATE
    \[RL\]\[2-SELF_RELOAD\] compare changes end
    \[RL\]\[2-SELF_RELOAD\] test connection start
    \[RL\]\[2-SELF_RELOAD\] test connection end
    \[RL\]\[2-SELF_RELOAD\] check and get system variables from random node start
    \[RL\]\[2-SELF_RELOAD\] get system variables :show variables
    \[RL\]\[2-SELF_RELOAD\] check and get system variables from random node end
    \[RL\]\[2-SELF_RELOAD\] skip recycle old active backend connections
    \[RL\]\[2-SELF_RELOAD\] selfChecking0 ...
    \[RL\]\[2-SELF_RELOAD\] apply new config start
    \[RL\]\[2-SELF_RELOAD\] calcDiffForMetaData ...
    \[RL\]\[2-SELF_RELOAD\] added metaLock
    \[RL\]\[2-SELF_RELOAD\] checkUser ...
    \[RL\]\[2-SELF_RELOAD\] init new dbGroup start
    \[RL\]\[2-SELF_RELOAD\] init new dbGroup end
    \[RL\]\[2-SELF_RELOAD\] config the transformation ...
    \[RL\]\[2-SELF_RELOAD\] ha config init ...
    \[RL\]\[2-SELF_RELOAD\] reloadMetaData start
    \[RL\]\[2-SELF_RELOAD\] metadata will delete Tables:'schema1test','schema1sharding_2_t1','schema1sharding_4_t1'
    \[RL\]\[2-SELF_RELOAD\] metadata finished for deleted tables
    \[RL\]\[2-SELF_RELOAD\] metadata will reload Tables:'schema1test','schema1sharding_2_t1','schema1sharding_4_t1'
    \[RL\]\[2-META_RELOAD\] _____________________meta reload start________2__MANAGER_INSERT
    \[RL\]\[2-META_RELOAD\] Meta reload schema1
    \[RL\]\[2-META_RELOAD\] sharding filter schema1test,sharding_2_t1,sharding_4_t1
    \[RL\]\[2-META_RELOAD\] try to execute show tables in \[schema1\] default shardingNode: dn5
    \[RL\]\[2-META_RELOAD\] try to execute show tables in \[schema1\] config table's shardingNode: dn1,dn3,dn2,dn4
    \[RL\]\[2-META_RELOAD\] the Node dn1 has no exist table,count down
    \[RL\]\[2-META_RELOAD\] the Node dn3 has no exist table,count down
    \[RL\]\[2-META_RELOAD\] the Node dn2 has no exist table,count down
    \[RL\]\[2-META_RELOAD\] the Node dn4 has no exist table,count down
    \[RL\]\[2-META_RELOAD\] explicit tables in schema\[schema1\]
    \[RL\]\[2-META_RELOAD\] schema\[schema1\] loading metadata is completed
    \[RL\]\[2-META_RELOAD\] no table exist in schema schema1,count down
    \[RL\]\[2-META_RELOAD\] metadata finished for changes of schemas and tables
    \[RL\]\[2-META_RELOAD\] reloadMetaData end
    \[RL\]\[2-META_RELOAD\] released metaLock
    \[RL\]\[2-META_RELOAD\] apply new config end
    \[RL\]\[2-META_RELOAD\] skip recycle old active backend connections
    \[RL\]\[2-META_RELOAD\] clean temp config ...
    \[RL\]\[2-META_RELOAD\] sync json to local ...
    \[RL\]\[2-META_RELOAD\] released configLock
    \[RL\]\[2-NOT_RELOADING\] _____________________reload finished___________2__MANAGER_INSERT:dble_db_group
    """

    # insert dble_db_instance
    Given record current dble log line number in "log_line_num6"
    Then execute admin cmd "insert into dble_information.dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostM3','ha_group3','172.100.9.4',3306,'test','111111','false','true',10,100)"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num6" in host "dble-1" retry "5" times
    """
    \[RL\]\[NONE\] added configLock
    \[RL\]\[3-SELF_RELOAD\] _____________________reload start________3__MANAGER_INSERT:dble_db_instance
    \[RL\]\[3-SELF_RELOAD\] load config start \[memory\]
    \[RL\]\[3-SELF_RELOAD\] memory to Users is
    \[RL\]\[3-SELF_RELOAD\] load config end
    \[RL\]\[3-SELF_RELOAD\] compare changes start
    \[RL\]\[3-SELF_RELOAD\] change items :\[ChangeItem{type=ADD, item=PhysicalDbGroup{groupName='ha_group3'
    \[RL\]\[3-SELF_RELOAD\] compare changes end
    \[RL\]\[3-SELF_RELOAD\] test connection start
    \[RL\]\[3-SELF_RELOAD\] test connection dbInstance:dbInstance\[name=hostM3,disabled=false,maxCon=100,minCon=10\],is connect:true,schemaList:null
    \[RL\]\[3-SELF_RELOAD\] test connection end
    \[RL\]\[3-SELF_RELOAD\] check and get system variables from random node start
    \[RL\]\[3-SELF_RELOAD\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostM3,disabled=false,maxCon=100,minCon=10\]
    \[RL\]\[3-SELF_RELOAD\] get system variables :show variables
    \[RL\]\[3-SELF_RELOAD\] check and get system variables from random node end
    \[RL\]\[3-SELF_RELOAD\] skip recycle old active backend connections
    \[RL\]\[3-SELF_RELOAD\] selfChecking0 ...
    \[RL\]\[3-SELF_RELOAD\] apply new config start
    \[RL\]\[3-SELF_RELOAD\] calcDiffForMetaData ...
    \[RL\]\[3-SELF_RELOAD\] added metaLock
    \[RL\]\[3-SELF_RELOAD\] checkUser ...
    \[RL\]\[3-SELF_RELOAD\] init new dbGroup start
    \[RL\]\[3-SELF_RELOAD\] init new group :PhysicalDbGroup{groupName='ha_group3'.*,reason:reload config
    \[RL\]\[3-SELF_RELOAD\] start heartbeat
    \[RL\]\[3-SELF_RELOAD\] init new dbGroup end
    \[RL\]\[3-SELF_RELOAD\] config the transformation ...
    \[RL\]\[3-SELF_RELOAD\] ha config init ...
    \[RL\]\[3-SELF_RELOAD\] reloadMetaData start
    \[RL\]\[3-SELF_RELOAD\] reloadMetaData end
    \[RL\]\[3-SELF_RELOAD\] released metaLock
    \[RL\]\[3-SELF_RELOAD\] apply new config end
    \[RL\]\[3-SELF_RELOAD\] skip recycle old active backend connections
    \[RL\]\[3-SELF_RELOAD\] clean temp config ...
    \[RL\]\[3-SELF_RELOAD\] sync json to local ...
    \[RL\]\[3-SELF_RELOAD\] released configLock
    \[RL\]\[3-NOT_RELOADING\] _____________________reload finished___________3__MANAGER_INSERT:dble_db_instance
    """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect  | db      |
      | conn_1 | false   | create table sharding_2_t1(id int, name varchar(10))  | success | schema1 |
    # reload @@metadata
    Given record current dble log line number in "log_line_num7"
    Then execute admin cmd "reload @@metadata"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num7" in host "dble-1" retry "5" times
    """
    \[RL\]\[4-META_RELOAD\] _____________________meta reload start________4__RELOAD_META
    \[RL\]\[4-META_RELOAD\] Meta reload schema1
    \[RL\]\[4-META_RELOAD\] try to execute show tables in \[schema1\] default shardingNode: dn5
    \[RL\]\[4-META_RELOAD\] try to execute show tables in \[schema1\] config table's shardingNode: dn1,dn3,dn2,dn4
    \[RL\]\[4-META_RELOAD\] the Node dn3 has no exist table,count down
    \[RL\]\[4-META_RELOAD\] the Node dn4 has no exist table,count down
    \[RL\]\[4-META_RELOAD\] try to execute show create tables in \[schema1\] config table's shardingNode: dn1,dn2
    \[RL\]\[4-META_RELOAD\] dbInstance is alive start sqljob for shardingNode:dn1
    \[RL\]\[4-META_RELOAD\] dbInstance is alive start sqljob for shardingNode:dn2
    \[RL\]\[4-META_RELOAD\] connectionAcquired on connection MySQLResponseService
    \[RL\]\[4-META_RELOAD\] Finish MultiTablesMetaJob with result false on connection
    \[RL\]\[4-META_RELOAD\] shardingNode normally count down:dn1 for schema schema1
    \[RL\]\[4-META_RELOAD\] shardingNode normally count down:dn2 for schema schema1
    \[RL\]\[4-META_RELOAD\] explicit tables in schema\[schema1\]
    \[RL\]\[4-META_RELOAD\] schema\[schema1\] loading metadata is completed
    \[RL\]\[4-META_RELOAD\] released configLock
    \[RL\]\[4-META_RELOAD\] released metaLock
    """

    # reload @@config_all -r
    Given record current dble log line number in "log_line_num8"
    Then execute admin cmd "reload @@config_all -r"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num8" in host "dble-1" retry "5" times
    """
    \[RL\]\[NONE\] added configLock
    \[RL\]\[5-SELF_RELOAD\] _____________________reload start________5__RELOAD_ALL
    \[RL\]\[5-SELF_RELOAD\] load config start \[local xml\]
    \[RL\]\[5-SELF_RELOAD\] load config end
    \[RL\]\[5-SELF_RELOAD\] compare changes start
    \[RL\]\[5-SELF_RELOAD\] change items :\[\]
    \[RL\]\[5-SELF_RELOAD\] compare changes end
    \[RL\]\[5-SELF_RELOAD\] test connection start
    \[RL\]\[5-SELF_RELOAD\] test connection dbInstance:dbInstance\[name=hostM1,disabled=false,maxCon=1000,minCon=10\],is connect:true,schemaList:\[\(dn3, db2\), \(dn5, db3\), \(dn1, db1\)\]
    \[RL\]\[5-SELF_RELOAD\] test connection dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\],is connect:true,schemaList:\[\(dn2, db1\), \(dn4, db2\)\]
    \[RL\]\[5-SELF_RELOAD\] test connection dbInstance:dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],is connect:true,schemaList:\[\(dn2, db1\), \(dn4, db2\)\]
    \[RL\]\[5-SELF_RELOAD\] test connection dbInstance:dbInstance\[name=hostM3,disabled=false,maxCon=100,minCon=10\],is connect:true,schemaList:null
    \[RL\]\[5-SELF_RELOAD\] test connection end
    \[RL\]\[5-SELF_RELOAD\] check and get system variables from random node start
    \[RL\]\[5-SELF_RELOAD\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostM1,disabled=false,maxCon=1000,minCon=10\]
    \[RL\]\[5-SELF_RELOAD\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\]
    \[RL\]\[5-SELF_RELOAD\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\]
    \[RL\]\[5-SELF_RELOAD\] get key variables :select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log,dbInstance:dbInstance\[name=hostM3,disabled=false,maxCon=100,minCon=10\]
    \[RL\]\[5-SELF_RELOAD\] get system variables :show variables
    \[RL\]\[5-SELF_RELOAD\] check and get system variables from random node end
    \[RL\]\[5-SELF_RELOAD\] skip recycle old active backend connections
    \[RL\]\[5-SELF_RELOAD\] selfChecking0 ...
    \[RL\]\[5-SELF_RELOAD\] apply new config start
    \[RL\]\[5-SELF_RELOAD\] calcDiffForMetaData ...
    \[RL\]\[5-SELF_RELOAD\] added metaLock
    \[RL\]\[5-SELF_RELOAD\] checkUser ...
    \[RL\]\[5-SELF_RELOAD\] init new dbGroup start
    \[RL\]\[5-SELF_RELOAD\] recycle old group. old active backend conn will be close
    \[RL\]\[5-SELF_RELOAD\] recycle old group :PhysicalDbGroup{groupName='ha_group1'.*,reason:reload config, recycle old group,is close front:false
    \[RL\]\[5-SELF_RELOAD\] stop heartbeat :dbInstance\[name=hostM1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop delayDetection :dbInstance\[name=hostM1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop connection pool :dbInstance\[name=hostM1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group,is close front:false
    \[RL\]\[5-SELF_RELOAD\] recycle old group. old active backend conn will be close
    \[RL\]\[5-SELF_RELOAD\] recycle old group :PhysicalDbGroup{groupName='ha_group2'.*,reason:reload config, recycle old group,is close front:false
    \[RL\]\[5-SELF_RELOAD\] stop heartbeat :dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop delayDetection :dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop connection pool :dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group,is close front:false
    \[RL\]\[5-SELF_RELOAD\] stop heartbeat :dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop delayDetection :dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop connection pool :dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],reason:reload config, recycle old group,is close front:false
    \[RL\]\[5-SELF_RELOAD\] recycle old group. old active backend conn will be close
    \[RL\]\[5-SELF_RELOAD\] recycle old group :PhysicalDbGroup{groupName='ha_group3'.*,reason:reload config, recycle old group,is close front:false
    \[RL\]\[5-SELF_RELOAD\] stop heartbeat :dbInstance\[name=hostM3,disabled=false,maxCon=100,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] stop delayDetection :dbInstance\[name=hostM3,disabled=false,maxCon=100,minCon=10\],reason:reload config, recycle old group
    \[RL\]\[5-SELF_RELOAD\] init new group :PhysicalDbGroup{groupName='ha_group1'.*,reason:reload config
    \[RL\]\[5-SELF_RELOAD\] start connection pool :dbInstance\[name=hostM1,disabled=false,maxCon=1000,minCon=10\],reason:reload config
    \[RL\]\[5-SELF_RELOAD\] start heartbeat :com.actiontech.dble.backend.heartbeat.MySQLHeartbeat
    \[RL\]\[5-SELF_RELOAD\] init new group :PhysicalDbGroup{groupName='ha_group2'.*,reason:reload config
    \[RL\]\[5-SELF_RELOAD\] start connection pool :dbInstance\[name=hostM2,disabled=false,maxCon=1000,minCon=10\],reason:reload config
    \[RL\]\[5-SELF_RELOAD\] start connection pool :dbInstance\[name=hostS1,disabled=false,maxCon=1000,minCon=10\],reason:reload config
    \[RL\]\[5-SELF_RELOAD\] init new group :PhysicalDbGroup{groupName='ha_group3'.*,reason:reload config
    \[RL\]\[5-SELF_RELOAD\] init new dbGroup end
    \[RL\]\[5-SELF_RELOAD\] config the transformation ...
    \[RL\]\[5-SELF_RELOAD\] ha config init ...
    \[RL\]\[5-SELF_RELOAD\] reloadMetaData start
    \[RL\]\[5-SELF_RELOAD\] metadata will delete schema:schema1
    \[RL\]\[5-SELF_RELOAD\] metadata finished for deleted schemas
    \[RL\]\[5-SELF_RELOAD\] metadata will reload schema:schema1
    \[RL\]\[5-META_RELOAD\] _____________________meta reload start________5__RELOAD_ALL
    \[RL\]\[5-META_RELOAD\] Meta reload schema1
    \[RL\]\[5-META_RELOAD\] sharding filter schema1
    \[RL\]\[5-META_RELOAD\] try to execute show tables in \[schema1\] default shardingNode: dn5
    \[RL\]\[5-META_RELOAD\] try to execute show tables in \[schema1\] config table's shardingNode: dn1,dn3,dn2,dn4
    \[RL\]\[5-META_RELOAD\] the Node dn3 has no exist table,count down
    \[RL\]\[5-META_RELOAD\] the Node dn4 has no exist table,count down
    \[RL\]\[5-META_RELOAD\] try to execute show create tables in \[schema1\] config table's shardingNode: dn1,dn2
    \[RL\]\[5-META_RELOAD\] dbInstance is alive start sqljob for shardingNode:dn1
    \[RL\]\[5-META_RELOAD\] dbInstance is alive start sqljob for shardingNode:dn2
    \[RL\]\[5-META_RELOAD\] shardingNode normally count down:dn1 for schema schema1
    \[RL\]\[5-META_RELOAD\] shardingNode normally count down:dn2 for schema schema1
    \[RL\]\[5-META_RELOAD\] explicit tables in schema\[schema1\]
    \[RL\]\[5-META_RELOAD\] schema\[schema1\] loading metadata is completed
    \[RL\]\[5-META_RELOAD\] metadata finished for changes of schemas and tables
    \[RL\]\[5-META_RELOAD\] reloadMetaData end
    \[RL\]\[5-META_RELOAD\] released metaLock
    \[RL\]\[5-META_RELOAD\] apply new config end
    \[RL\]\[5-META_RELOAD\] skip recycle old active backend connections
    \[RL\]\[5-META_RELOAD\] released configLock
    \[RL\]\[5-NOT_RELOADING\] _____________________reload finished___________5__RELOAD_ALL
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect  | db      |
      | conn_1 | true    | drop table if exists sharding_2_t1  | success | schema1 |