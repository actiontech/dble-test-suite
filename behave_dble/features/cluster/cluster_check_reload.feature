# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: because 3.20.07 version change, the cluster function changes ,from doc: https://github.com/actiontech/dble-docs-cn/blob/master/2.Function/2.08_cluster.md
  # reload   db.xml  user.xml  sharding.xml
  ######case points:
  #  1.sequenceHandlerType=1, change config success
  #  2.sequenceHandlerType=2, change config success
  #  3.sequenceHandlerType=2, change config failed
  #  4.sequenceHandlerType=2, query btrace create lock


  @skip_restart
  Scenario: set cluster.cnf sequenceHandlerType=1 and change xml success then reload on admin mode   #1
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      $a sequenceHandlerType=1
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-2" with sed cmds
      """
      $a sequenceHandlerType=1
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-3" with sed cmds
      """
      $a sequenceHandlerType=1
      """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    Then check following text exist "Y" in file "/opt/dble/conf/cluster.cnf" in host "dble-1"
      """
      sequenceHandlerType=1
      """
    Then check following text exist "Y" in file "/opt/dble/conf/cluster.cnf" in host "dble-2"
      """
      sequenceHandlerType=1
      """
    Then check following text exist "Y" in file "/opt/dble/conf/cluster.cnf" in host "dble-3"
      """
      sequenceHandlerType=1
      """
    #case change sharding/user/db.xml and sequence_db_conf.properties, reload config
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema2" shardingNode="dn1" sqlMaxLimit="101" >
          <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM3" url="172.100.9.5:3306" password="111111" user="test" maxCon="107" minCon="10" disabled="false" primary="true">
         </dbInstance>
       </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    When Add some data in "sequence_db_conf.properties"
    """
    `schema1`.`test_auto`=dn1
    """
    Then execute admin cmd "reload @@config"
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM3" url="172.100.9.5:3306" password="111111" user="test" maxCon="107" minCon="10" disabled="false" primary="true">
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/sequence_db_conf.properties" in host "dble-1"
      """
      `schema1`.`test_auto`=dn1
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM3" url="172.100.9.5:3306" password="111111" user="test" maxCon="107" minCon="10" disabled="false" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-2"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/sequence_db_conf.properties" in host "dble-2"
      """
      `schema1`.`test_auto`=dn1
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM3" url="172.100.9.5:3306" password="111111" user="test" maxCon="107" minCon="10" disabled="false" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-3"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/sequence_db_conf.properties" in host "dble-3"
      """
      `schema1`.`test_auto`=dn1
      """
    #check on dble-1 dble-2 dble-3 data currect
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists sharding2               | success | schema2 |
      | conn_1 | true    | create table sharding2 (id int,name char(5)) | success | schema2 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_2 | False   | insert into sharding2 values (1,1),(2,null) | success     | schema2 |
      | conn_2 | true    | select * from sharding2                     | length{(2)} | schema2 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_1"
      | conn   | toClose | sql                             | db      |
      | conn_3 | true    | explain select * from sharding2 | schema2 |
    Then check resultset "Res_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                           |
      | dn1             | BASE SQL   | SELECT * FROM sharding2 LIMIT 101   |
      | dn2             | BASE SQL   | SELECT * FROM sharding2 LIMIT 101   |
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding2" on "dble-1"
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding2" on "dble-2"
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding2" on "dble-3"

    #change config on dble-2
    Given update file content "/opt/dble/conf/sharding.xml" in "dble-2" with sed cmds
    """
     s/sqlMaxLimit="101"/sqlMaxLimit="1001"/g
    """
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                  | expect    |
      | conn_21 | true    | reload @@config_all  | success   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_2"
      | conn   | toClose | sql                             | db      |
      | conn_1 | true    | explain select * from sharding2 | schema2 |
    Then check resultset "Res_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1             | BASE SQL   | SELECT * FROM sharding2 LIMIT 1001   |
      | dn2             | BASE SQL   | SELECT * FROM sharding2 LIMIT 1001   |


  @skip_restart
  Scenario: set cluster.cnf sequenceHandlerType=2 and change xml success then reload on admin mode   #2
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      /sequenceHandlerType/d
      $a sequenceHandlerType=2
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-2" with sed cmds
      """
      /sequenceHandlerType/d
      $a sequenceHandlerType=2
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-3" with sed cmds
      """
      /sequenceHandlerType/d
      $a sequenceHandlerType=2
      """
    Given Restart dble in "dble-1" success
    Given Restart dble in "dble-2" success
    Given Restart dble in "dble-3" success
    #case sequenceHandlerType default is 2
    #case change xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn2"  sqlMaxLimit="10" >
          <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
        </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="108" minCon="1" disabled="false" primary="true">
         </dbInstance>
       </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    Then execute admin cmd "reload @@config_all"
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="108" minCon="1" disabled="false" primary="true">
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="108" minCon="1" disabled="false" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-2"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="108" minCon="1" disabled="false" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-3"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check on dble-1 dble-2 dble-3 data currect
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists sharding3               | success | schema3 |
      | conn_1 | true    | create table sharding3 (id int,name char(5)) | success | schema3 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_2 | False   | insert into sharding3 values (1,1),(2,null) | success     | schema3 |
      | conn_2 | true    | select * from sharding3                     | length{(2)} | schema3 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_3"
      | conn   | toClose | sql                             | db      |
      | conn_3 | true    | explain select * from sharding3 | schema3 |
    Then check resultset "Res_3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                          |
      | dn1             | BASE SQL   | SELECT * FROM sharding3 LIMIT 10   |
      | dn2             | BASE SQL   | SELECT * FROM sharding3 LIMIT 10   |

    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding3" on "dble-1"
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding3" on "dble-2"
    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding3" on "dble-3"
    #case change config on dble-3
    Given update file content "/opt/dble/conf/sharding.xml" in "dble-3" with sed cmds
    """
     s/sqlMaxLimit="10"/sqlMaxLimit="71"/g
    """
    Then execute sql in "dble-3" in "admin" mode
      | conn    | toClose | sql                  | expect    |
      | conn_31 | true    | reload @@config_all  | success   |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_4"
      | conn   | toClose | sql                             | db      |
      | conn_2 | true    | explain select * from sharding3 | schema3 |
    Then check resultset "Res_4" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                          |
      | dn1             | BASE SQL   | SELECT * FROM sharding3 LIMIT 71   |
      | dn2             | BASE SQL   | SELECT * FROM sharding3 LIMIT 71   |


  @skip_restart
  Scenario: set cluster.cnf sequenceHandlerType=2 and change xml failed then reload on admin mode #3
    #case change config uncorrnect
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn2"  sqlMaxLimit="10" >
          <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-three" shardingColumn="id"/>
        </schema>
      """
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                 | db                 |
      | conn_1 | true    | reload @@config     | dble_information   |
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    #case change config corrnect
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn2"  sqlMaxLimit="10" >
          <shardingTable name="sharding3" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
        </schema>
      """
    Then execute admin cmd "reload @@config"
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
      """
    #case change config uncorrnect
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="1.2" name="ha_group1" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="108" minCon="1" disabled="false" primary="true">
         </dbInstance>
       </dbGroup>
      """
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                 | db                 |
      | conn_1 | true    | reload @@config     | dble_information   |
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode="1.2" name="ha_group1" delayThreshold="100">
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      """
    Then execute sql in "dble-3" in "admin" mode
      | sql             | expect      |
      | reload @@config | success     |
     #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      """


  @btrace
  Scenario: set cluster.cnf sequenceHandlerType=1 and change xml on btrace,lock is exists   #4

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn2"  sqlMaxLimit="10" >
          <shardingTable name="sharding4" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
        </schema>
      """
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(100L)/
      /delayBeforeDeleteReloadLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(60000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql               | db               |
      | conn_1 | True    | reload @@config   | dble_information |
    Then check btrace "BtraceClusterDelay.java" output in "dble-1"
       """
       get into delayBeforeDeleteReloadLock
       """
    Then execute admin cmd  in "dble-2" at background
      | conn   | toClose | sql               | db               |
      | conn_2 | True    | reload @@config   | dble_information |
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      Other instance is reloading, please try again later.
      """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-2"
      """
      acquire ZkDistributeLock failed
      KeeperErrorCode = NodeExists for /dble/cluster-1/lock/confChange.lock
      """
    Given sleep "50" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given delete file "/tmp/dble_admin_query.log" on "dble-2"
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding4" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding4" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding4" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | true    | drop table if exists sharding2               | success | schema2 |
      | conn_1 | true    | drop table if exists sharding3               | success | schema3 |