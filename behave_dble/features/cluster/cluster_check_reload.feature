# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: because 3.20.07 version change, the cluster function changes ,from doc: https://github.com/actiontech/dble-docs-cn/blob/master/2.Function/2.08_cluster.md
  # reload   db.xml  user.xml  sharding.xml
  ######case points:
  #  1.sequenceHandlerType=1,
  #  2.sequenceHandlerType=2


  @skip_restart
  Scenario: set cluster.cnf sequenceHandlerType=1 and change xml then reload on admin mode   #1
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
    #case change xml and reload
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema2" shardingNode="dn1"  sqlMaxLimit="101" >
          <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
       <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
         <heartbeat>select user()</heartbeat>
         <dbInstance name="hostM3" password="111111" url="172.100.9.5:3306" user="test" maxCon="107" minCon="10" disabled="false" primary="true">
         </dbInstance>
       </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then execute admin cmd "reload @@config"

    Then check following text exist "Y" in file "/opt/dble/conf/sharding.xml" in host "dble-1"
      """
      <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM3" password="111111" url="172.100.9.5:3306" user="test" maxCon="107" minCon="10" disabled="false" primary="true">
      """
    Then check following text exist "Y" in file "/opt/dble/conf/user.xml" in host "dble-1"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
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

    Then get "/dble/cluster-1/conf/sharding" on zkCli.sh for "sharding2" on dble-1

    Given update file content "/opt/dble/conf/sharding.xml" in "dble-2" with sed cmds
    """
     s/sqlMaxLimit="101"/sqlMaxLimit="1001"/g
    """
    Then execute sql in "dble-2" in "admin" mode
      | conn   | toClose | sql                  | expect    |
      | conn_0 | true    | reload @@config_all  | success   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_2"
      | conn   | toClose | sql                             | db      |
      | conn_3 | true    | explain select * from sharding2 | schema2 |
    Then check resultset "Res_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                            |
      | dn1             | BASE SQL   | SELECT * FROM sharding2 LIMIT 1001   |
      | dn2             | BASE SQL   | SELECT * FROM sharding2 LIMIT 1001   |

    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                  | expect    |
      | conn_0 | true    | rollback @@config    | success   |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_3"
      | conn   | toClose | sql                             | db      |
      | conn_3 | true    | explain select * from sharding2 | schema2 |
    Then check resultset "Res_3" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                           |
      | dn1             | BASE SQL   | SELECT * FROM sharding2 LIMIT 101   |
      | dn2             | BASE SQL   | SELECT * FROM sharding2 LIMIT 101   |
