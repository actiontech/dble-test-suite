# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/04/07


  @skip
Feature: test config in user.xml  ---  analysisUser


  @NORMAL
  Scenario: test analysisUser ---- add  user with illegal label, reload fail   #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana1" password="test_password" dbGroup="ha_group1" test="0"/>
    """

    Then execute admin cmd "reload @@config_all"
    """
    Attribute 'test' is not allowed to appear in element 'analysisUser'
    """


  @TRIVIAL
  Scenario: analysisUser spelling mistake, start dble fail    #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisuser name="ana1" password="test_password" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    """
    Invalid content was found starting with element 'analysisuser'. One of '{managerUser, shardingUser, rwSplitUser, analysisUser, blacklist}' is expected
    """
    Then Restart dble in "dble-1" failed for
     """
     Invalid content was found starting with element 'analysisuser'. One of '{managerUser, shardingUser, rwSplitUser, analysisUser, blacklist}' is expected
     """


  Scenario: add analysisUser user with dbGroup which does not exist, start dble fail    #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana1" password="test_password" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is The user's group[ana1.ha_group3] for analysisUser isn't configured in db.xml.
    """
    Then Restart dble in "dble-1" failed for
     """
     The user's group\[ana1.ha_group3\] for analysisUser isn't configured in db.xml.
     """


  @TRIVIAL
  Scenario: add analysisUser user with dbGroup which db.xml dbInstance database type must be CLICKHOUSE    #4

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana1" password="111111" dbGroup="ha_group3" />
    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="CLICKHOUSE"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is db json to map occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: databaseType [CLICKHOUSE]  use lowercase
    """

    ### databaseType is default
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is The group[ana1.ha_group3] all dbInstance database type must be CLICKHOUSE
    """
    ### databaseType is mysql
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="mysql"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload config failure.The reason is The group[ana1.ha_group3] all dbInstance database type must be CLICKHOUSE
    """
    ### databaseType is
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType=" "/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    databaseType [ ] not support
    """
    ### databaseType is  null
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="null"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    databaseType [null] not support
    """
    ### databaseType is abc
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="abc"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    databaseType [abc] not support
    """
    ### databaseType is -1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="-1"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    databaseType [-1] not support
    """
    ### databaseType is 9.9
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="9.9"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    databaseType [9.9] not support
    """


  @TRIVIAL
  Scenario: add analysisUser user with dbGroup which shardinguser use, start dble fail    #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana1" password="111111" dbGroup="ha_group1" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    shardingNodeDbGroup [ha_group1] define error ,all dbInstance database type must be MYSQL
    """
    Then Restart dble in "dble-1" failed for
     """
     shardingNodeDbGroup \[ha_group1\] define error ,all dbInstance database type must be MYSQL
     """


  @TRIVIAL
  Scenario: both single & multiple analysisUser user reload and do management cmd success    #6

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana1" password="111111" dbGroup="ha_group3" />
    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
     Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | ana1  | 111111 | conn_1 | False   | select 1 | success  |

    Then execute admin cmd "show @@version"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <analysisUser name="ana2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | ana2  | 111111 | conn_2 | False   | select 1 | success  |

    Then execute admin cmd "show @@version"


  @CRITICAL
  Scenario:config ip white dbInstance to analysisUser , analysisUser user not in white dbInstance access denied    #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <analysisUser name="ana1" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.253" />
    <analysisUser name="ana2" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.8" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql      | expect   |
      | ana2  | 111111 | conn_0 | True    | select 1 | success  |
      | ana1  | 111111 | conn_0 | True    | select 1 | Access denied for user 'ana1' |


  @CRITICAL
  Scenario: config "user" attr "maxCon" (front-end maxCon) greater than 0    #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <analysisUser name="ana1" password="111111" dbGroup="ha_group3" maxCon="1" />
    <analysisUser name="ana2" password="111111" dbGroup="ha_group3" maxCon="0" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql      | expect                             |
      | ana1  | 111111    | conn_0 | False    | select 1 | success                            |
      | ana1  | 111111    | new    | True     | select 1 | too many connections for this user |
      | ana1  | 111111    | new    | True     | select 1 | ana1                               |
      | ana2  | 111111    | conn_1 | False    | select 1 | success                            |
      | ana2  | 111111    | new    | False    | select 1 | success                            |
      | ana2  | 111111    | new    | False    | select 1 | success                            |


  @CRITICAL
  Scenario: config sum(all "user" attr "maxCon") > "system" property "maxCon", exceeding connection will fail    #9
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
      $a\-DmaxCon=1
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <analysisUser name="ana1" password="111111" dbGroup="ha_group3" maxCon="1" />
    <analysisUser name="ana2" password="111111" dbGroup="ha_group3" maxCon="1" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql      | expect                                 |
      | ana1  | 111111    | conn_0 | False    | select 1 | success                                |
      | ana1  | 111111    | new    | False    | select 1 | too many connections for this user     |
      | ana2  | 111111    | new    | False    | select 1 | too many connections for dble server   |


  Scenario:  config two analysisUser with the same name, reload failed    #10
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
      """
      <analysisUser name="ana1" password="111111" dbGroup="ha_group3" maxCon="1" />
      <analysisUser name="ana1" password="222222" dbGroup="ha_group3" maxCon="1" />
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      User [ana1] has already existed
      """


  Scenario:  analysisUser with the tenant   #11
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
      </dbGroup>
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <analysisUser name="ana1" password="111111" dbGroup="ha_group3" tenant="tenant1" />
      """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql         | expect   |
      | ana1:tenant1  | 111111 | conn_2 | False   | select 1    | success  |
      | ana1:tenant1  | 111111 | conn_2 | False   | show tables | success  |


  @CRITICAL
  Scenario: test 'sqlExecuteTimeout'  #12
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DfakeMySQLVersion=5.7.13
    $a -DprocessorCheckPeriod=10
    $a -DsqlExecuteTimeout=2
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.13:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse">
             <property name="timeBetweenEvictionRunsMillis">10</property>
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <analysisUser name="ana1" password="111111" dbGroup="ha_group3" maxCon="0" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose    | sql              | expect                                 |
      | ana1  | 111111    | conn_0 | false      | select sleep(3)  | reason is [sql timeout]                |


  @TRIVIAL
  Scenario: analysisUser user supporte management cmd success    #13

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DuseCostTimeStat=1
      $a -DuseThreadUsageStat=1
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <analysisUser name="ana1" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1"  />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100" >
        <heartbeat>select 1</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.13:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
        <dbInstance name="hostS1" password="111111" url="172.100.9.14:9004" user="test" maxCon="100" minCon="10" primary="false" databaseType="clickhouse"/>
    </dbGroup>
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql         | expect   |
     | ana1  | 111111 | conn_1 | False   | use default | success  |
     | ana1  | 111111 | conn_1 | False   | select 1    | success  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                     | expect       |
#########   select
      | conn_0 | False   | select @@VERSION_COMMENT                | length{(1)} |
      | conn_0 | False   | select @@SESSION.Transaction_READ_ONLY  | length{(1)} |
      | conn_0 | False   | select @@SESSION.TX_READ_ONLY           | length{(1)} |
      | conn_0 | False   | select @@max_allowed_packet             | length{(1)} |
      | conn_0 | False   | select TIMEDIFF(NOW(), UTC_TIMESTAMP()) | length{(1)} |
#########   show
      | conn_0 | False   | show @@time.current                                               | length{(1)}   |
      | conn_0 | False   | show @@time.startup                                               | length{(1)}   |
      | conn_0 | False   | show @@version                                                    | length{(1)}   |
      | conn_0 | False   | show @@server                                                     | length{(1)}   |
      | conn_0 | False   | show @@threadpool                                                 | length{(5)}   |
      | conn_0 | False   | show @@threadpool.task                                            | length{(5)}   |
      | conn_0 | False   | show @@database                                                   | length{(1)}   |
      | conn_0 | False   | show @@shardingNode                                               | length{(5)}   |
      | conn_0 | False   | show @@shardingNode where schema = "schema2"                      | length{(0)}   |
      | conn_0 | False   | show @@dbinstance                                                 | length{(4)}   |
      | conn_0 | False   | show @@dbinstance where shardingNode = "dn3"                      | length{(1)}   |
      | conn_0 | False   | show @@dbinstance.syndetail WHERE name = "hostM1"                 | length{(0)}   |
      | conn_0 | False   | show @@processor                                                  | length{(17)}  |
      | conn_0 | False   | show @@command                                                    | length{(1)}   |
      | conn_0 | False   | show @@connection                                                 | length{(2)}   |
      | conn_0 | False   | show @@cache                                                      | length{(2)}   |
      | conn_0 | False   | show @@sql.condition                                              | length{(2)}   |
      | conn_0 | False   | show @@heartbeat                                                  | length{(4)}   |
      | conn_0 | False   | show @@heartbeat.detail  where name='hostM1'                      | success       |
      | conn_0 | False   | show @@sysparam                                                   | length{(107)} |
      | conn_0 | False   | show @@white                                                      | length{(3)}   |
      | conn_0 | False   | show @@directmemory                                               | length{(1)}   |
      | conn_0 | False   | show @@command.count                                              | length{(1)}   |
      | conn_0 | False   | show @@backend.statistics                                         | length{(4)}   |
      | conn_0 | False   | show @@backend.old                                                | length{(0)}   |
      | conn_0 | False   | show @@binlog.status                                              | length{(2)}   |
      | conn_0 | False   | show @@help                                                       | length{(113)} |
      | conn_0 | False   | show @@thread_used                                                | length{(50)}  |
      | conn_0 | False   | show @@algorithm where schema='schema1' and table='sharding_4_t1' | length{(5)}   |
      | conn_0 | False   | show @@ddl                                                        | length{(0)}   |
      | conn_0 | False   | show @@reload_status                                              | length{(0)}   |
      | conn_0 | False   | show @@user                                                       | length{(3)}   |
      | conn_0 | False   | show @@user.privilege                                             | length{(1)}   |
      | conn_0 | False   | show @@questions                                                  | length{(1)}   |
#      | conn_0 | False   | show @@connection_pool                                            | length{(56)}  |
      | conn_0 | False   | show @@processlist                                                | length{(1)}   |

#########   kill
      | conn_0 | False   | kill @@connection 5,500                                           | success       |
      | conn_0 | False   | kill @@xa_session id1,id2                                         | success       |
      | conn_0 | False   | kill @@ddl_lock where schema="schema1" and table="test"           | success       |
#########   stop
      | conn_0 | False   | stop @@heartbeat ha_group3:100                                    | success       |
#########   reload
      | conn_0 | False   | reload @@config                                                   | success       |
      | conn_0 | False   | reload @@config_all                                               | success       |
      | conn_0 | False   | reload @@metadata                                                 | success       |
      | conn_0 | False   | reload @@sqlslow=1                                                | success       |
      | conn_0 | False   | reload @@query_cf                                                 | success       |
      | conn_0 | true    | release @@reload_metadata                                         | Dble not in reloading or reload status not interruptible       |

### #db.xml should be has "show slave status" in heartbeat ,but analysisUser can not configured "show slave status"
##      | conn_0 | False   | show @@dbinstance.synstatus   | length{(0)}  |


    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | ana1  | 111111 | conn_1 | False   | select 1 | success  |

#########   offline  online   ###DBLE0REQ-1701
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect  |
      | conn_0 | False   | offline            | success |
#    Then execute sql in "dble-1" in "user" mode
#      | user  | passwd | conn   | toClose | sql                | expect   |
#      | ana1  | 111111 | conn_1 | False   | select user()      | The server has been shutdown  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect  |
      | conn_0 | False   | online             | success |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | ana1  | 111111 | conn_1 | False   | select user()      | success  |
#########   dryrun
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect  |
      | conn_0 | False   | dryrun             | success  |
#########   pause && RESUME
      | conn_0 | False   | show @@pause                                                                  | success |
      | conn_0 | False   | pause @@shardingNode = 'dn1,dn2' and timeout = 10 ,queue = 10,wait_limit = 10 | success |
      | conn_0 | False   | RESUME                                                                        | success |
#########   slow_query
      | conn_0 | False   | show @@slow_query_log              | success  |
      | conn_0 | False   | disable @@slow_query_log           | success  |
      | conn_0 | False   | enable @@slow_query_log            | success  |
      | conn_0 | False   | show @@slow_query.time             | success  |
      | conn_0 | False   | reload @@slow_query.time=200       | success  |
      | conn_0 | False   | show @@slow_query.flushperiod      | success  |
      | conn_0 | False   | reload @@slow_query.flushperiod=2  | success  |
      | conn_0 | False   | show @@slow_query.flushsize        | success  |
      | conn_0 | False   | reload @@slow_query.flushsize=100  | success  |

 ### DBLE0REQ-1701
    #show @@connection.sql.status where FRONT_ID=

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | ana1  | 111111 | conn_1 | False   | select user()      | success  |
#########   database
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect  |
      | conn_2 | False   | drop database @@shardingNode ='dn1,dn2,dn3,dn4'               | success  |
      | conn_2 | False   | create database @@shardingNode ='dn1,dn2,dn3,dn4'             | success  |
#########   metadata
      | conn_2 | False   | check @@metadata                | success  |
      | conn_2 | False   | check full @@metadata           | success  |
      | conn_2 | False   | check @@global                  | success  |
#########   alert
      | conn_2 | False   | show @@alert                | success  |
      | conn_2 | False   | disable @@alert             | success  |
      | conn_2 | False   | enable @@alert              | success  |

#########   dbGroup @@disable
      | conn_2 | False   | dbGroup @@disable name='ha_group3'                | success  |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect                                                    |
      | ana1  | 111111 | conn_1 | False   | select user()      | the dbGroup[ha_group3] doesn't contain active dbInstance  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect   |
      | conn_2 | False   | dbGroup @@switch name='ha_group3' master='hostS1'             | success  |
      | conn_2 | False   | dbGroup @@enable name='ha_group3'                             | success  |
      | conn_2 | False   | dbGroup @@events                                              | success  |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | ana1  | 111111 | conn_1 | False   | select user()      | success  |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
     <dbInstance name=\"hostM1\" url=\"172.100.9.13:9004\" password=\"111111\" user=\"test\" maxCon=\"100\" minCon=\"10\" primary=\"false\" databaseType=\"clickhouse\"/>
     <dbInstance name=\"hostS1\" url=\"172.100.9.14:9004\" password=\"111111\" user=\"test\" maxCon=\"100\" minCon=\"10\" primary=\"true\" databaseType=\"clickhouse\"/>
    """

#########   fresh conn
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                | expect   |
      | conn_2 | False   | fresh conn where dbGroup ='ha_group3'                              | success  |
      | conn_2 | False   | fresh conn where dbGroup ='ha_group3' and dbInstance ='hostM1'     | success  |
#########   cap_client_found_rows
      | conn_2 | False   | show @@cap_client_found_rows                    | success  |
      | conn_2 | False   | enable @@cap_client_found_rows                  | success  |
      | conn_2 | False   | disable @@cap_client_found_rows                 | success  |
#########   general_log
      | conn_2 | False   | show @@general_log                    | success  |
      | conn_2 | False   | disable @@general_log                 | success  |
      | conn_2 | False   | enable @@general_log                 |  success  |
#########   statistic 这一期先简单通过，具体case需要去对应的feature补充
      | conn_2 | False   | show @@statistic                     | success  |
      | conn_2 | False   | disable @@statistic                  | success  |
      | conn_2 | False   | enable @@statistic                   | success  |
      | conn_2 | False   | reload @@statistic_table_size = 100  | success  |
      | conn_2 | False   | reload @@samplingRate=100            | success  |
      | conn_2 | False   | show @@statistic_queue.usage         | success  |
      | conn_2 | False   | drop @@statistic_queue.usage         | success  |
      | conn_2 | False   | start @@statistic_queue_monitor      | success  |
      | conn_2 | False   | stop @@statistic_queue_monitor       | success  |
#########   flow_control
      | conn_2 | False   | flow_control @@show                          | length{(0)}   |
      | conn_2 | False   | flow_control @@list                          | length{(0)}   |
      | conn_2 | False   | flow_control @@set enableFlowControl = true  | success       |
      | conn_2 | False   | flow_control @@show                          | length{(5)}   |
      | conn_2 | False   | flow_control @@list                          | length{(44)}  |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | ana1  | 111111 | conn_1 | False   | select user()      | success  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect        |
 ####1700
      | conn_2 | False   | select * from dble_information.dble_flow_control where connection_info like "%9004%"                          | length{(21)}  |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | ana1  | 111111 | conn_1 | False   | select user()      | success  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect        |
      | conn_2 | False   | select * from dble_information.dble_flow_control where connection_info like "%9004%"                          | length{(21)}  |
      | conn_2 | False   | flow_control @@set enableFlowControl = false | success       |
      | conn_2 | False   | flow_control @@show                          | length{(0)}   |
      | conn_2 | False   | flow_control @@list                          | length{(0)}   |
####DBLE0REQ-1700
      | conn_0 | False   | show @@backend where port= 9004          | length{(21)}  |
      | conn_0 | False   | show @@session            | length{(0)}  |
      | conn_0 | False   | show @@session.xa         | length{(0)}  |


#### 没有统计到分析用户的sql ####DBLE0REQ-1701
#    Given execute sql "50" times in "dble-1" at concurrent
#      | user  | passwd | sql             |
#      | ana1  | 111111 | select 1        |
#    Given execute sql "20" times in "dble-1" at concurrent
#      | user  | passwd | sql             |
#      | ana1  | 111111 | select 1        |
#    Then execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                     | expect       |
#      | conn_0 | False   | show @@connection.sql        | length{(1)}  |
#      | conn_0 | False   | show @@sql        | length{(1)}  |
#      | conn_0 | False   | show @@sql.high            | length{(1)}  |
#      | conn_0 | False   | show @@sql.slow           | length{(1)}  |
#      | conn_0 | False   | show @@sql.large           | length{(1)}  |
#      | conn_0 | False   | show @@sql.sum          | length{(1)}  |
#      | conn_0 | False   | show @@sql.sum.user          | length{(1)}  |
#      | conn_0 | False   | show @@sql.sum.table           | length{(1)}  |
#      | conn_0 | False   | show @@connection.coun          | length{(1)}  |
#      | conn_0 | False   | reload @@user_stat            | length{(1)}  | 重置前面命令的状态 Reset show @@sql  @@sql.sum @@sql.slow  @@sql.high  @@sql.large  @@sql.resultset  success




