# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/04/07


Feature: test config in user.xml  ---  rwSplitUser


  @NORMAL
  Scenario: test rwSplitUser ---- add  user with illegal label, reload fail   #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="rwS1" password="test_password" dbGroup="ha_group1" test="0"/>
    """

    Then execute admin cmd "reload @@config_all"
    """
    Attribute 'test' is not allowed to appear in element 'rwSplitUser'
    """


  @TRIVIAL
  Scenario: rwSplitUser spelling mistake, start dble fail    #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitser name="rwS1" password="test_password" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    """
    Invalid content was found starting with element 'rwSplitser'. One of '{managerUser, shardingUser, rwSplitUser, analysisUser, hybridTAUser, blacklist}' is expected
    """
    Then Restart dble in "dble-1" failed for
     """
     Invalid content was found starting with element 'rwSplitser'. One of '{managerUser, shardingUser, rwSplitUser, analysisUser, hybridTAUser, blacklist}' is expected
     """


  @TRIVIAL
  Scenario: add rwSplitUser user with dbGroup which does not exist, start dble fail    #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="rwS1" password="test_password" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload Failure, The reason is The user's group[rwS1.ha_group3] for rwSplit isn't configured in db.xml.
    """
    Then Restart dble in "dble-1" failed for
     """
     The user's group\[rwS1.ha_group3\] for rwSplit isn't configured in db.xml.
     """


  @TRIVIAL
  Scenario: add rwSplitUser user with dbGroup which db.xml dbInstance database type must be mysql    #4

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """

     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload Failure, The reason is The group[rwS1.ha_group3] all dbInstance database type must be MYSQL
    """

     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" databaseType="MYSQL"/>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload Failure, The reason is db json to map occurred  parse errors, The detailed results are as follows . com.actiontech.dble.config.util.ConfigException: databaseType [MYSQL]  use lowercase
    """


  @TRIVIAL
  Scenario: add rwSplitUser user with dbGroup which shardinguser use, start dble fail    #5
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group1" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.1:3306" user="test" maxCon="1000" minCon="10" primary="true" >
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    """
    Reload Failure, The reason is The group[rwS1.ha_group1] has been used by sharding node, can't be used by rwSplit
    """


  @TRIVIAL
  Scenario: both single & multiple rwSplitUser user reload and do management cmd success    #6

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
    </dbGroup>
    """
     Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | rwS1  | 111111 | conn_1 | False   | select 1 | success  |

    Then execute admin cmd "show @@version"
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
     <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | rwS2  | 111111 | conn_2 | False   | select 1 | success  |

    Then execute admin cmd "show @@version"


  @CRITICAL
  Scenario:config ip white dbInstance to rwSplitUser , rwSplitUser user not in white dbInstance access denied    #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.253" />
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.8" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql      | expect   |
      | rwS2  | 111111 | conn_0 | True    | select 1 | success  |
      | rwS1  | 111111 | conn_0 | True    | select 1 | Access denied for user 'rwS1' |


  @CRITICAL
  Scenario: config "user" attr "maxCon" (front-end maxCon) greater than 0    #8
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="1" />
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" maxCon="0" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql      | expect                             |
      | rwS1  | 111111    | conn_0 | False    | select 1 | success                            |
      | rwS1  | 111111    | new    | True     | select 1 | too many connections for this user |
      | rwS1  | 111111    | new    | True     | select 1 | rwS1                               |
      | rwS2  | 111111    | conn_1 | False    | select 1 | success                            |
      | rwS2  | 111111    | new    | False    | select 1 | success                            |
      | rwS2  | 111111    | new    | False    | select 1 | success                            |


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
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="1" />
    <rwSplitUser name="rwS2" password="111111" dbGroup="ha_group3" maxCon="1" />
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose  | sql      | expect                                 |
      | rwS1  | 111111    | conn_0 | False    | select 1 | success                                |
      | rwS1  | 111111    | new    | False    | select 1 | too many connections for this user     |
      | rwS2  | 111111    | new    | False    | select 1 | too many connections for dble server   |


  Scenario:  config two rwSplitUser with the same name, reload failed    #10
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml" with duplicate name
      """
      <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="1" />
      <rwSplitUser name="rwS1" password="222222" dbGroup="ha_group3" maxCon="1" />
      """
    Then execute admin cmd "reload @@config_all" get the following output
      """
      User [rwS1] has already existed
      """


  Scenario:  rwSplitUser with the tenant   #11
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" tenant="tenant1" />
      """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | user          | passwd | conn   | toClose | sql            | expect   |
      | rwS1:tenant1  | 111111 | conn_2 | False   | select 1       | success  |
      | rwS1:tenant1  | 111111 | conn_2 | False   | show databases | success  |


  @CRITICAL
  Scenario: test 'sqlExecuteTimeout'  #12
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DprocessorCheckPeriod=10
    $a -DsqlExecuteTimeout=2
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" >
             <property name="timeBetweenEvictionRunsMillis">10</property>
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" maxCon="0"/>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn   | toClose    | sql              | expect                                 | timeout |
      | rwS1  | 111111    | conn_1 | false      | select sleep(3)  | reason is [sql timeout]                | 5,3     |


  @TRIVIAL
  Scenario: rwSplitUser user support management cmd success    #13

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DuseCostTimeStat=1
      $a -DuseThreadUsageStat=1
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" whiteIPs="172.100.9.8,127.0.0.1,0:0:0:0:0:0:0:1"  />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | rwS1  | 111111 | conn_1 | False   | select 1 | success  |

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
      | conn_0 | False   | show @@threadpool                                                 | length{(7)}   |
      | conn_0 | False   | show @@threadpool.task                                            | length{(7)}   |
      | conn_0 | False   | show @@database                                                   | length{(1)}   |
      | conn_0 | False   | show @@shardingNode                                               | length{(5)}   |
      | conn_0 | False   | show @@shardingNode where schema = "schema2"                      | length{(0)}   |
      | conn_0 | False   | show @@dbinstance                                                 | length{(4)}   |
      | conn_0 | False   | show @@dbinstance where shardingNode = "dn3"                      | length{(1)}   |
      | conn_0 | False   | show @@dbinstance.syndetail WHERE name = "hostM1"                 | length{(0)}   |
      | conn_0 | False   | show @@processor                                                  | success       |
      | conn_0 | False   | show @@command                                                    | length{(1)}   |
      | conn_0 | False   | show @@connection                                                 | length{(2)}   |
      # DBLE0REQ-1381
      | conn_0 | False   | show @@connection.sql                                             | length{(2)}   |
      | conn_0 | False   | show @@cache                                                      | length{(2)}   |
      | conn_0 | False   | show @@sql.condition                                              | length{(2)}   |
      | conn_0 | False   | show @@heartbeat                                                  | length{(4)}   |
      | conn_0 | False   | show @@heartbeat.detail  where name='hostM1'                      | success       |
      | conn_0 | False   | show @@sysparam                                                   | length{(140)} |
      | conn_0 | False   | show @@white                                                      | length{(3)}   |
      | conn_0 | False   | show @@directmemory                                               | length{(1)}   |
      | conn_0 | False   | show @@command.count                                              | length{(1)}   |
      | conn_0 | False   | show @@backend.statistics                                         | length{(4)}   |
      | conn_0 | False   | show @@backend.old                                                | length{(0)}   |
      | conn_0 | False   | show @@binlog.status                                              | length{(2)}   |
      | conn_0 | False   | show @@help                                                       | length{(124)} |
      | conn_0 | False   | show @@thread_used                                                | success       |
      | conn_0 | False   | show @@algorithm where schema='schema1' and table='sharding_4_t1' | length{(5)}   |
      | conn_0 | False   | show @@ddl                                                        | length{(0)}   |
      | conn_0 | False   | show @@reload_status                                              | length{(0)}   |
      | conn_0 | False   | show @@user                                                       | length{(3)}   |
      | conn_0 | False   | show @@user.privilege                                             | length{(1)}   |
      | conn_0 | False   | show @@questions                                                  | length{(1)}   |
#      | conn_0 | False   | show @@connection_pool                                            | success       |
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
      | conn_0 | False   | reload @@query_cf                                                 | success       |
      | conn_0 | true    | release @@reload_metadata                                         | Dble not in reloading or reload status not interruptible       |
      | conn_0 | False   | show @@dbinstance.synstatus                                       | success       |


    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql      | expect   |
     | rwS1  | 111111 | conn_1 | False   | select 1 | success  |

#########   offline  online #1700
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect  |
      | conn_0 | False   | offline            | success |
#    Then execute sql in "dble-1" in "user" mode
#      | user  | passwd | conn   | toClose | sql                | expect   |
#      | rwS1  | 111111 | conn_1 | False   | select user()      | The server has been shutdown  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                | expect  |
      | conn_0 | False   | online             | success |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | rwS1  | 111111 | conn_1 | False   | select user()      | success  |
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
#show @@connection.sql.status where FRONT_ID=

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | rwS1  | 111111 | conn_1 | False   | select user()      | success  |
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
      | rwS1  | 111111 | conn_1 | False   | select user()      | the dbGroup[ha_group3] doesn't contain active dbInstance  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                           | expect   |
      | conn_2 | False   | dbGroup @@switch name='ha_group3' master='hostS1'             | success  |
      | conn_2 | False   | dbGroup @@enable name='ha_group3'                             | success  |
      | conn_2 | False   | dbGroup @@events                                              | success  |
   #need to wait for the heartbeat to return to normal,due to DBLE0REQ-1847
    Given sleep "1" seconds
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | rwS1  | 111111 | conn_1 | False   | select user()      | success  |
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
    """
     <dbInstance name=\"hostM1\" url=\"172.100.9.4:3306\" password=\"111111\" user=\"test\" maxCon=\"100\" minCon=\"10\" primary=\"false\"/>
     <dbInstance name=\"hostS1\" url=\"172.100.9.4:3307\" password=\"111111\" user=\"test\" maxCon=\"100\" minCon=\"10\" primary=\"true\"/>
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
      | conn_2 | False   | flow_control @@list                          | success       |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | rwS1  | 111111 | conn_1 | False   | select user()      | success  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect        |
 ####1700
      | conn_2 | False   | select * from dble_information.dble_flow_control where connection_info like "%3307%"                          | success   |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                | expect   |
      | rwS1  | 111111 | conn_1 | False   | select user()      | success  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect        |
      | conn_2 | False   | select * from dble_information.dble_flow_control where connection_info like "%3307%"                          | success  |
      | conn_2 | False   | flow_control @@set enableFlowControl = false | success       |
      | conn_2 | False   | flow_control @@show                          | length{(0)}   |
      | conn_2 | False   | flow_control @@list                          | length{(0)}   |
####DBLE0REQ-1700
      | conn_0 | False   | show @@backend where port= 3307          | success     |
      | conn_0 | False   | show @@session            | length{(0)}  |
      | conn_0 | False   | show @@session.xa         | length{(0)}  |


  Scenario:  rwSplitUser with the prepared sql  DBLE0REQ-1065   #14
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
      """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                               | expect  | db  |
      | rwS1 | 111111 | conn_0 | False   | drop table if exists test_table                   | success | db1 |
      | rwS1 | 111111 | conn_0 | False   | create table test_table(id int, name varchar(12)) | success | db1 |
      | rwS1 | 111111 | conn_0 | False   | insert into test_table values(1,'1'),(2,'2')      | success | db1 |

    Then execute prepared sql "select * from test_table where id = %s" with params "(1);(3)" on db "db1" and user "rwS1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                               | expect  | db  |
      | rwS1 | 111111 | conn_0 | true    | drop table if exists test_table                   | success | db1 |