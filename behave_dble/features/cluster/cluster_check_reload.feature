# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: test "reload @@config" in zk cluster
  #  db.xml  user.xml  sharding.xml sequence_db_conf.properties
  ######case points:
  #  1.sequenceHandlerType=1, change config success
  #  2.sequenceHandlerType=2, change config success
  #  3.sequenceHandlerType=2, change config failed
  #  4.sequenceHandlerType=2, use btrace create lock,check lock


  @skip_restart
  Scenario: set cluster.cnf sequenceHandlerType=1 and change xml success then reload on admin mode   #1
    Given stop dble cluster and zk service
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
    Given config zookeeper cluster in all dble nodes with "local zookeeper host"
    Given reset dble registered nodes in zk
    Then start dble in order
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
    #case change sharding/user/db.xml and sequence_db_conf.properties, reload config on admin mode
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
    #check on dble-1 dble-2 dble-3 data currect,query ddl/explain/dml
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists sharding2               | success | schema2 |
      | conn_1 | False   | create table sharding2 (id int,name char(5)) | success | schema2 |
      | conn_1 | true    | insert into sharding2 values (1,1),(2,null)  | success | schema2 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_2 | False   | alter table sharding2 add age int           | success     | schema2 |
      | conn_2 | False   | insert into sharding2 values (2,2,2)        | success     | schema2 |
      | conn_2 | true    | select * from sharding2                     | length{(3)} | schema2 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_1"
      | conn   | toClose | sql                             | db      |
      | conn_3 | false   | explain select * from sharding2 | schema2 |
    Then check resultset "Res_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                           |
      | dn1             | BASE SQL   | SELECT * FROM sharding2 LIMIT 101   |
      | dn2             | BASE SQL   | SELECT * FROM sharding2 LIMIT 101   |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_1a"
      | conn   | toClose | sql                                                          | db      |
      | conn_3 | true    | explain insert into sharding2 values (11,11,11),(12,12,12)   | schema2 |
    Then check resultset "Res_1a" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                 |
      | dn1             | BASE SQL   | INSERT INTO sharding2 VALUES (12, 12, 12) |
      | dn2             | BASE SQL   | INSERT INTO sharding2 VALUES (11, 11, 11) |
    #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_zk_sharding.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding2"
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/db  >/tmp/dble_zk_db.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_db.log" in host "dble-1"
      """
      "name":"hostM3"
      """
    Given execute linux command in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/user  >/tmp/dble_zk_user.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_user.log" in host "dble-2"
      """
      "schemas":"schema1,schema2","name":"test"
      """
    Given execute linux command in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sequences/common  >/tmp/dble_zk_sequences.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_sequences.log" in host "dble-2"
      """
      {"sequence_db_conf.properties":"{\\\"`schema1`.`test_auto`\\\":\\\"dn1\\\"}"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """

    #change config on dble-2,then check on dble-1 dble-3
    Given update file content "/opt/dble/conf/sharding.xml" in "dble-2" with sed cmds
    """
     s/sqlMaxLimit="101"/sqlMaxLimit="1001"/g
    """
    Then execute sql in "dble-2" in "admin" mode
      | conn    | toClose | sql                  | expect    |
      | conn_21 | true    | reload @@config_all  | success   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_2"
      | conn   | toClose | sql                                | db      |
      | conn_1 | true    | explain select * from sharding2    | schema2 |
    Then check resultset "Res_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1             | BASE SQL   | SELECT * FROM sharding2 LIMIT 1001   |
      | dn2             | BASE SQL   | SELECT * FROM sharding2 LIMIT 1001   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_2a"
      | conn   | toClose | sql                                                        | db      |
      | conn_1 | true    | explain insert into sharding2 values (13,11,11),(14,12,12) | schema2 |
    Then check resultset "Res_2a" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                 |
      | dn1             | BASE SQL   | INSERT INTO sharding2 VALUES (14, 12, 12) |
      | dn2             | BASE SQL   | INSERT INTO sharding2 VALUES (13, 11, 11) |



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
    #case change xml and reload on admin mode
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
    #check on dble-1 dble-2 dble-3 data currect,query ddl/explain/dml
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists sharding3               | success | schema3 |
      | conn_1 | False   | create table sharding3 (id int,name char(5)) | success | schema3 |
      | conn_1 | true    | insert into sharding3 values (1,1),(2,null)  | success | schema3 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_2 | False   | alter table sharding3 add age int           | success     | schema3 |
      | conn_2 | False   | insert into sharding3 values (3,3,3)        | success     | schema3 |
      | conn_2 | true    | select * from sharding3                     | length{(3)} | schema3 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_3"
      | conn   | toClose | sql                             | db      |
      | conn_3 | false   | explain select * from sharding3 | schema3 |
    Then check resultset "Res_3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                          |
      | dn1             | BASE SQL   | SELECT * FROM sharding3 LIMIT 10   |
      | dn2             | BASE SQL   | SELECT * FROM sharding3 LIMIT 10   |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_3a"
      | conn   | toClose | sql                                                        | db      |
      | conn_3 | true    | explain insert into sharding3 values (11,11,11),(12,12,12) | schema3 |
    Then check resultset "Res_3a" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                 |
      | dn2             | BASE SQL   | INSERT INTO sharding3 VALUES (12, 12, 12) |
      | dn1             | BASE SQL   | INSERT INTO sharding3 VALUES (11, 11, 11) |
    #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_zk_sharding.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding3"
      """
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/db  >/tmp/dble_zk_db.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_db.log" in host "dble-1"
      """
      "name":"hostM"
      "maxCon":108
      """
    Given execute linux command in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/user  >/tmp/dble_zk_user.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_user.log" in host "dble-2"
      """
      "schemas":"schema1,schema2,schema3","name":"test"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """

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
    #case change config on sharding.xml
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn2"  sqlMaxLimit="201" >
          <shardingTable name="sharding4" shardingNode="dn2,dn1" function="hash-three" shardingColumn="id"/>
        </schema>
      """
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                 | db                 |
      | conn_1 | true    | reload @@config     | dble_information   |
    #check config on dble-1, has "function="hash-three""
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding4" shardingNode="dn2,dn1" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-2,has "function="hash-two""
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding4" shardingNode="dn2,dn1" function="hash-three" shardingColumn="id"/>
      """
    #check config on dble-3,has "function="hash-two""
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding3" shardingNode="dn2,dn1" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding4" shardingNode="dn2,dn1" function="hash-three" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      Illegal table conf : table \[ sharding4 \] rule function \[ hash-three \] partition size : ID > table shardingNode size : 2, please make sure table shardingnode size = function partition size
      """
    #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_zk_sharding.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding4"
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding3"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """
    #case change config corrnect
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn2"  sqlMaxLimit="201" >
          <shardingTable name="sharding4" shardingNode="dn2,dn1,dn3" function="hash-three" shardingColumn="id"/>
        </schema>
      """
    Then execute admin cmd "reload @@config"
    #check config on dble-1
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
    #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_zk_sharding.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding3"
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding4"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """


    #case change db config
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="1.2" name="ha_group1" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="10086" minCon="1" disabled="false" primary="true">
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
      maxCon="10086"
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      maxCon="108"
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100">
      maxCon="108"
      """
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    #  Reload config failure.The reason is com.actiontech.dble.config.util.ConfigException: org.xml.sax.SAXParseException; lineNumber: 4; columnNumber: 70; cvc-datatype-valid.1.2.1: '1.2' is not a valid value for 'integer'.
      """
      '\''1.2'\'' is not a valid value for '\''integer'\''
      """
    #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/db  >/tmp/dble_zk_db.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_db.log" in host "dble-1"
      """
      "maxCon":108
      "rwSplitMode":0,"name":"ha_group1"
      """
    Then check following text exist "N" in file "/tmp/dble_zk_db.log" in host "dble-1"
      """
      "maxCon":10086
      "rwSplitMode":1.2
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM" url="172.100.9.5:3306" password="111111" user="test" maxCon="10086" minCon="1" disabled="false" primary="true">
         </dbInstance>
       </dbGroup>
      """
    Then execute admin cmd "reload @@config"
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100">
      maxCon="10086"
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100">
      maxCon="10086"
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbGroup rwSplitMode="1" name="ha_group1" delayThreshold="100">
      maxCon="10086"
      """
    #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/db  >/tmp/dble_zk_db.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_db.log" in host "dble-1"
      """
      "maxCon":108
      "rwSplitMode":0,"name":"ha_group1"
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_db.log" in host "dble-1"
      """
      "maxCon":10086
      "rwSplitMode":1
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """

    #case change user config
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema4444"/>
      """
    Then execute admin cmd  in "dble-1" at background
      | conn   | toClose | sql                 | db                 |
      | conn_1 | true    | reload @@config     | dble_information   |
    #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema4444"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-2"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-3"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    Given sleep "10" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-1"
    # Reload config failure.The reason is SelfCheck### User[name:test]'s schema [schema4444] is not exist!
      """
      Reload config failure
      """
    #case check on zookeeper
    Given execute linux command in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/user  >/tmp/dble_zk_user.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_user.log" in host "dble-2"
      """
      "schemas":"schema1,schema2,schema3","name":"test"
      """
    Then check following text exist "N" in file "/tmp/dble_zk_user.log" in host "dble-2"
      """
      "schemas":"schema1,schema4444","name":"test"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """

    Then execute sql in "dble-3" in "admin" mode
      | sql             | expect      |
      | reload @@config | success     |
     #check config on dble-1
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-2"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-3"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    #check on dble-1 dble-2 dble-3 data currect,query ddl/explain/dml
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists sharding4               | success | schema3 |
      | conn_1 | False   | create table sharding4 (id int,name char(5)) | success | schema3 |
      | conn_1 | true    | insert into sharding4 values (1,1),(2,null)  | success | schema3 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_2 | False   | alter table sharding4 add age int           | success     | schema3 |
      | conn_2 | False   | insert into sharding4 values (3,3,3)        | success     | schema3 |
      | conn_2 | true    | select * from sharding4                     | length{(3)} | schema3 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_5"
      | conn   | toClose | sql                             | db      |
      | conn_3 | False   | explain select * from sharding4 | schema3 |
    Then check resultset "Res_5" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                           |
      | dn1             | BASE SQL   | SELECT * FROM sharding4 LIMIT 201   |
      | dn2             | BASE SQL   | SELECT * FROM sharding4 LIMIT 201   |
      | dn3             | BASE SQL   | SELECT * FROM sharding4 LIMIT 201   |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_5a"
      | conn   | toClose | sql                                                                    | db      |
      | conn_3 | true    | explain insert into sharding4 values (11,11,11),(12,12,12),(13,13,13)  | schema3 |
    Then check resultset "Res_5a" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                           |
      | dn3             | BASE SQL   | INSERT INTO sharding4 VALUES (11, 11, 11)   |
      | dn2             | BASE SQL   | INSERT INTO sharding4 VALUES (12, 12, 12)   |
      | dn1             | BASE SQL   | INSERT INTO sharding4 VALUES (13, 13, 13)   |
    #case check on zookeeper
    Given execute linux command in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/user  >/tmp/dble_zk_user.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_user.log" in host "dble-2"
      """
      "schemas":"schema1,schema2,schema3","name":"test"
      """
    Then check following text exist "N" in file "/tmp/dble_zk_user.log" in host "dble-2"
      """
      "schemas":"schema1,schema4444","name":"test"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """


  @btrace
  Scenario: change xml ,use btrace create lock   #4

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema3" shardingNode="dn1"  sqlMaxLimit="2020" >
          <shardingTable name="sharding5" shardingNode="dn2,dn1,dn4,dn3" function="hash-four" shardingColumn="id"/>
        </schema>
      """
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayBeforeDeleteReloadLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(25000L)/;/\}/!ba}
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
    Then execute admin cmd  in "dble-3" at background
      | conn   | toClose | sql               | db               |
      | conn_3 | True    | reload @@config   | dble_information |
    Given sleep "3" seconds
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-2"
      """
      Other instance is reloading, please try again later.
      """
    Then check following text exist "Y" in file "/tmp/dble_admin_query.log" in host "dble-3"
      """
      Other instance is reloading, please try again later.
      """
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-2"
      """
      acquire ZkDistributeLock failed
      KeeperErrorCode = NodeExists for /dble/cluster-1/lock/confChange.lock
      """
     #case check on zookeeper
    Given execute linux command in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  get /dble/cluster-1/conf/sharding  >/tmp/dble_zk_sharding.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding5"
      """
    Then check following text exist "N" in file "/tmp/dble_zk_sharding.log" in host "dble-1"
      """
      "name":"sharding4"
      """
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "Y" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """
    Given sleep "22" seconds
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    #case dble-1 reload success
    Then check following text exist "N" in file "/tmp/dble_admin_query.log" in host "dble-1"
      """
      ERROR
      """
    #case dble-2,dble-3 reload success
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding5" shardingNode="dn2,dn1,dn4,dn3" function="hash-four" shardingColumn="id"/>
      """
    #check config on dble-2
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-2"
      """
      <shardingTable name="sharding5" shardingNode="dn2,dn1,dn4,dn3" function="hash-four" shardingColumn="id"/>
      """
    #check config on dble-3
    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-3"
      """
      <shardingTable name="sharding5" shardingNode="dn2,dn1,dn4,dn3" function="hash-four" shardingColumn="id"/>
      """
    #check on dble-1 dble-2 dble-3 data currect,query ddl/explain/dml
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | False   | drop table if exists sharding5               | success | schema3 |
      | conn_1 | False   | create table sharding5 (id int,name char(5)) | success | schema3 |
      | conn_1 | true    | insert into sharding5 values (1,1),(2,null)  | success | schema3 |
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_2 | False   | alter table sharding5 add age int           | success     | schema3 |
      | conn_2 | False   | insert into sharding5 values (3,3,3)        | success     | schema3 |
      | conn_2 | true    | select * from sharding5                     | length{(3)} | schema3 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_6"
      | conn   | toClose | sql                             | db      |
      | conn_3 | false   | explain select * from sharding5 | schema3 |
    Then check resultset "Res_6" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1             | BASE SQL   | SELECT * FROM sharding5 LIMIT 2020   |
      | dn2             | BASE SQL   | SELECT * FROM sharding5 LIMIT 2020   |
      | dn3             | BASE SQL   | SELECT * FROM sharding5 LIMIT 2020   |
      | dn4             | BASE SQL   | SELECT * FROM sharding5 LIMIT 2020   |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_6a"
      | conn   | toClose | sql                                                                              | db      |
      | conn_3 | true    | explain insert into sharding5 values (11,11,11),(12,12,12),(13,13,13),(14,14,14) | schema3 |
    Then check resultset "Res_6a" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                   |
      | dn3             | BASE SQL   | INSERT INTO sharding5 VALUES (11, 11, 11)   |
      | dn2             | BASE SQL   | INSERT INTO sharding5 VALUES (12, 12, 12)   |
      | dn1             | BASE SQL   | INSERT INTO sharding5 VALUES (13, 13, 13)   |
      | dn4             | BASE SQL   | INSERT INTO sharding5 VALUES (14, 14, 14)   |
     #case check on zookeeper
    Given execute linux command in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock  >/tmp/dble_zk_lock.log 2>&1 &
      """
    Then check following text exist "N" in file "/tmp/dble_zk_lock.log" in host "dble-3"
      """
      confChange.lock
      """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect  | db      |
      | conn_1 | true    | drop table if exists sharding2               | success | schema2 |
      | conn_1 | false   | drop table if exists sharding3               | success | schema3 |
      | conn_1 | false   | drop table if exists sharding4               | success | schema3 |
      | conn_1 | true    | drop table if exists sharding5               | success | schema3 |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"
    Given execute linux command in "dble-1"
    """
    rm -rf /tmp/dble_*
    """
    Given execute linux command in "dble-2"
    """
    rm -rf /tmp/dble_*
    """
    Given execute linux command in "dble-3"
    """
    rm -rf /tmp/dble_*
    """