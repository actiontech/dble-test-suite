# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11

  #case DBLE0REQ-855
#  @skip
#  #todo：回归时手动跑
Feature: test "ha" in zk cluster
  ######case points:
  #  1.ClusterEnable=true && useOuterHa=true && needSyncHa=true,check "dbgroup"
  #  2.ClusterEnable=true && useOuterHa=true && needSyncHa=true,check "dbinstance"



  @skip_restart
  Scenario: prepare and when ClusterEnable=true && useOuterHa=true && needSyncHa=true, check "dbgroup"  #1
#    Given execute linux command in "behave"
#      """
#      bash ./compose/docker-build-behave/resetReplication.sh
#      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
           <globalTable name="global1" shardingNode="dn1,dn2,dn3,dn4"/>
           <globalTable name="global2" shardingNode="dn4,dn2"/>
           <globalTable name="global3" shardingNode="dn1,dn3"/>
           <shardingTable name="sharding4" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
           <shardingTable name="sharding3" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id"/>
           <shardingTable name="sharding2" shardingNode="dn1,dn3" function="hash-two" shardingColumn="id">
              <childTable name="child1" joinColumn="fid" parentColumn="id" />
           </shardingTable>
           <singleTable name="sing1" shardingNode="dn1" />
           <singleTable name="sing2" shardingNode="dn2" />
        </schema>
        <schema name="schema2" shardingNode="dn2" />
        <schema name="schema3" shardingNode="dn4">
           <shardingTable name="sharding21" shardingNode="dn2,dn4" function="hash-two" shardingColumn="id"/>
        </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
         <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
            <heartbeat>select user()</heartbeat>
             <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
             <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10" />
             <dbInstance name="hostS2" password="111111" url="172.100.9.3:3306" user="test" maxCon="1000" minCon="10" />
         </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2,schema3"/>
      """
    Then execute admin cmd "reload @@config"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DuseOuterHa=true
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
      """
      $a -DuseOuterHa=true
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
      """
      $a -DuseOuterHa=true
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-1" with sed cmds
      """
      s/needSyncHa=false/needSyncHa=true/
      s/clusterEnable=false/clusterEnable=true/
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-2" with sed cmds
      """
      s/needSyncHa=false/needSyncHa=true/
      s/clusterEnable=false/clusterEnable=true/
      """
    Given update file content "/opt/dble/conf/cluster.cnf" in "dble-3" with sed cmds
      """
      s/needSyncHa=false/needSyncHa=true/
      s/clusterEnable=false/clusterEnable=true/
      """
    Then restart dble in "dble-1" success
    Then restart dble in "dble-2" success
    Then restart dble in "dble-3" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                          | expect  | db      |
      | conn_0 | False   | drop table if exists vertical1                               | success | schema2 |
      | conn_0 | True    | create table vertical1 (id int)                              | success | schema2 |
      | conn_0 | False   | drop table if exists no_sharding2                            | success | schema3 |
      | conn_0 | False   | create table no_sharding2 (id int, name int)                 | success | schema3 |
      | conn_0 | False   | drop table if exists sharding21                              | success | schema3 |
      | conn_0 | True    | create table sharding21 (id int, name int)                   | success | schema3 |
      | conn_0 | False   | drop table if exists global1                                 | success | schema1 |
      | conn_0 | False   | drop table if exists global2                                 | success | schema1 |
      | conn_0 | False   | drop table if exists global3                                 | success | schema1 |
      | conn_0 | False   | drop table if exists sharding4                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding3                               | success | schema1 |
      | conn_0 | False   | drop table if exists sharding2                               | success | schema1 |
      | conn_0 | False   | drop table if exists child1                                  | success | schema1 |
      | conn_0 | False   | drop table if exists sing1                                   | success | schema1 |
      | conn_0 | False   | drop table if exists sing2                                   | success | schema1 |
      | conn_0 | False   | drop table if exists no_sharding1                            | success | schema1 |
      | conn_0 | False   | create table global1 (id int)                                | success | schema1 |
      | conn_0 | False   | create table global2 (id int)                                | success | schema1 |
      | conn_0 | False   | create table global3 (id int)                                | success | schema1 |
      | conn_0 | False   | create table sharding4 (id int, name int)                    | success | schema1 |
      | conn_0 | False   | create table sharding3 (id int, fid int)                     | success | schema1 |
      | conn_0 | False   | create table sharding2 (id int, fid int)                     | success | schema1 |
      | conn_0 | False   | create table child1 (fid int,name int)                       | success | schema1 |
      | conn_0 | False   | create table sing1 (id int)                                  | success | schema1 |
      | conn_0 | False   | create table sing2 (id int)                                  | success | schema1 |
      | conn_0 | True    | create table no_sharding1 (id int, name int)                 | success | schema1 |
    # case make sure data is correct on mysql
    Given sleep "2" seconds
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql             | expect             | db  |
      | conn_0 | True    | show tables     | has{('sing2')}     | db1 |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql             | expect             | db  |
      | conn_0 | True    | show tables     | has{('sing2')}     | db1 |
     Then execute sql in "mysql-slave2"
      | conn   | toClose | sql             | expect             | db  |
      | conn_0 | True    | show tables     | has{('sing2')}     | db1 |
     #case  when ClusterEnable=true && useOuterHa=true && needSyncHa=true, check "dbgroup"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_A" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | HOST       | 2            |
      | PORT       | 3            |
      | W/R        | 4            |
      | ACTIVE     | 5            |
      | SIZE       | 7            |
      | READ_LOAD  | 8            |
      | WRITE_LOAD | 9            |
      | DISABLED   | 10           |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | HOST       | 2            |
      | PORT       | 3            |
      | W/R        | 4            |
      | ACTIVE     | 5            |
      | SIZE       | 7            |
      | READ_LOAD  | 8            |
      | WRITE_LOAD | 9            |
      | DISABLED   | 10           |
    Then execute admin cmd "dbGroup @@disable name = 'ha_group2'"
    #case check disable change to "true"
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_D"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_D" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | W     | 0        | 1000   | 0           | 0            | true        |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | R     | 0        | 1000   | 0           | 0            | true        |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | R     | 0        | 1000   | 0           | 0            | true        |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_E"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_F"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_D" and "Res_E" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | HOST       | 2            |
      | PORT       | 3            |
      | W/R        | 4            |
      | ACTIVE     | 5            |
      | SIZE       | 7            |
      | READ_LOAD  | 8            |
      | WRITE_LOAD | 9            |
      | DISABLED   | 10           |
    Then check resultsets "Res_E" and "Res_F" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | HOST       | 2            |
      | PORT       | 3            |
      | W/R        | 4            |
      | ACTIVE     | 5            |
      | SIZE       | 7            |
      | READ_LOAD  | 8            |
      | WRITE_LOAD | 9            |
      | DISABLED   | 10           |
    #case if sql query route ha_group2(dn2 or dn4) will be wrong
    #case global table
    Given delete file "/tmp/dble_user_query.log" on "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                | db      |
      | conn_0 | true    | insert into global1 values (1)     | schema1 |
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    #java.io.IOException: the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status
      """
      the dbInstance\[172.100.9.6:3306\] can
      Please check the dbInstance status
      """
    Given delete file "/tmp/dble_user_query.log" on "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                | db      |
      | conn_0 | true    | insert into global2 values (2)     | schema1 |
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    #java.io.IOException: the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status
      """
      the dbInstance\[172.100.9.6:3306\] can
      Please check the dbInstance status
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect                                                                                                | db      |
      | conn_1 | False   | select * from global1          | length{(0)}                                                                                           | schema1 |
      | conn_1 | False   | select * from global2          | the dbGroup[ha_group2] doesn't contain active dbInstance.                        | schema1 |
      #case global3 donot route ha_group2(dn2 or dn4)
      | conn_1 | False   | insert into global3 values (1) | success                                                                                               | schema1 |
      | conn_1 | False   | insert into global3 values (2) | success                                                                                               | schema1 |
      | conn_1 | true    | select * from global3          | length{(2)}                                                                                           | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                      | expect                                                                                   | db      |
      | conn_2  | False   | insert into sharding2 values (1,1)       | success                                                                                  | schema1 |
      | conn_2  | False   | insert into sharding2 values (2,2)       | success                                                                                  | schema1 |
      | conn_2  | False   | select * from sharding2                  | length{(2)}                                                                              | schema1 |
      | conn_2  | False   | insert into sharding4 values (1,1)       | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_2  | False   | insert into sharding4 values (3,3)       | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_2  | False   | insert into sharding4 values (2,2)       | success                                                                                  | schema1 |
      | conn_2  | False   | insert into sharding4 values (4,4)       | success                                                                                  | schema1 |
      | conn_2  | False   | insert into sharding4 values (1,1),(2,2) | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_2  | False   | select * from sharding4                  | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema1 |
      | conn_2  | False   | select * from sharding4 where id=2       | length{(1)}                                                                              | schema1 |
      | conn_2  | False   | select * from sharding4 where id=1       | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema1 |
      | conn_2  | False   | insert into child1 values (1,1)          | success                                                                                  | schema1 |
      | conn_2  | False   | insert into child1 values (2,2)          | success                                                                                  | schema1 |
      | conn_2  | true    | select * from child1                     | length{(2)}                                                                              | schema1 |
      | conn_21 | False   | insert into sharding21 values (1,1)      | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema3 |
      | conn_21 | False   | insert into sharding21 values (2,2)      | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema3 |
      | conn_21 | true    | select * from sharding21                 | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema3 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                   | expect                                                                                   | db      |
      | conn_3  | False   | insert into sing1 values (1)          | success                                                                                  | schema1 |
      | conn_3  | False   | select * from sing1                   | length{(1)}                                                                              | schema1 |
      | conn_3  | False   | insert into sing2 values (1)          | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_3  | False   | select * from sing2                   | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema1 |
      | conn_3  | False   | insert into no_sharding1 values (1,1) | success                                                                                  | schema1 |
      | conn_3  | true    | select * from no_sharding1            | length{(1)}                                                                              | schema1 |
      | conn_31 | False   | insert into no_sharding2 values (1,1) | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema3 |
      | conn_31 | true    | select * from no_sharding2            | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema3 |
      | conn_32 | False   | show tables                           | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema2 |
      | conn_32 | False   | insert into vertical1 values (1)      | the dbInstance[172.100.9.6:3306] can't reach. Please check the dbInstance status | schema2 |
      | conn_32 | true    | select * from  vertical1              | the dbGroup[ha_group2] doesn't contain active dbInstance.           | schema2 |
    #case change master to slave1 on mysql group
    Given update file content "./compose/docker-build-behave/ChangeMaster.sh" in "behave" with sed cmds
    """
    s/grant replication slave on *.* to '\''repl'\''@'\''%'\''/grant replication slave on *.* to '\''repl'\''@'\''%'\'' identified by '\''111111'\''/
    """
    Given execute linux command in "behave"
      """
      bash ./compose/docker-build-behave/ChangeMaster.sh dble-2 mysql-master2 dble-3
      """
    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS1'"
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_1"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_1" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | 1000   | 0           | 0            | true        |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | W     | 0        | 1000   | 0           | 0            | true        |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | R     | 0        | 1000   | 0           | 0            | true        |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_2"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_3"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_1" and "Res_2" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |
    Then check resultsets "Res_2" and "Res_3" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |
    Then execute admin cmd "dbGroup @@enable name = 'ha_group2'"
    #check master had changed
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                          | expect        |
      | conn_0 | false   | show master status                           | success       |
      | conn_0 | true    | show slave status                            | hasNoStr{Yes} |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                            | expect         |
      | conn_0 | true    | show slave status                              | hasStr{Yes}    |
    Then execute sql in "mysql-slave2"
      | conn   | toClose | sql                                            | expect         |
      | conn_0 | true    | show slave status                              | hasStr{Yes}    |

    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_4"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_4" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_5"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_6"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_5" and "Res_6" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |

    #case check sql query will be success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect      | db      |
      | conn_1 | False   | insert into global1 values (1) | success     | schema1 |
      | conn_1 | False   | insert into global2 values (1) | success     | schema1 |
      | conn_1 | False   | insert into global3 values (1) | success     | schema1 |
      | conn_1 | False   | select * from global1          | length{(1)} | schema1 |
      | conn_1 | False   | select * from global2          | length{(1)} | schema1 |
      | conn_1 | true    | select * from global3          | length{(3)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                                  | expect      | db      |
      | conn_2  | False   | insert into sharding2 values (1,1),(2,2)             | success     | schema1 |
      | conn_2  | False   | select * from sharding2                              | length{(4)} | schema1 |
      | conn_2  | False   | insert into sharding4 values (1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_2  | False   | select * from sharding4                              | length{(6)} | schema1 |
      | conn_2  | False   | select * from sharding4 where id=1                   | length{(1)} | schema1 |
      | conn_2  | False   | insert into child1 values (3,3)                      | success     | schema1 |
      | conn_2  | true    | select * from child1                                 | length{(3)} | schema1 |
      | conn_21 | False   | insert into sharding21 values (1,1),(2,2)            | success     | schema3 |
      | conn_21 | true    | select * from sharding21                             | length{(2)} | schema3 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                   | expect      | db      |
      | conn_3  | False   | insert into sing1 values (1)          | success     | schema1 |
      | conn_3  | False   | select * from sing1                   | length{(2)} | schema1 |
      | conn_3  | False   | insert into sing2 values (1)          | success     | schema1 |
      | conn_3  | False   | select * from sing2                   | length{(1)} | schema1 |
      | conn_3  | False   | insert into no_sharding1 values (1,1) | success     | schema1 |
      | conn_3  | true    | select * from no_sharding1            | length{(2)} | schema1 |
      | conn_31 | False   | insert into no_sharding2 values (1,1) | success     | schema3 |
      | conn_31 | true    | select * from no_sharding2            | length{(1)} | schema3 |
      | conn_32 | False   | show tables                           | success     | schema2 |
      | conn_32 | False   | insert into vertical1 values (1)      | success     | schema2 |
      | conn_32 | true    | select * from  vertical1              | length{(1)} | schema2 |



  @skip_restart
  Scenario: when ClusterEnable=true && useOuterHa=true && needSyncHa=true ,check "dbinstance"  #2

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_A"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_A" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_B"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_C"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | HOST       | 2            |
      | PORT       | 3            |
      | W/R        | 4            |
      | ACTIVE     | 5            |
      | SIZE       | 7            |
      | READ_LOAD  | 8            |
      | WRITE_LOAD | 9            |
      | DISABLED   | 10           |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | HOST       | 2            |
      | PORT       | 3            |
      | W/R        | 4            |
      | ACTIVE     | 5            |
      | SIZE       | 7            |
      | READ_LOAD  | 8            |
      | WRITE_LOAD | 9            |
      | DISABLED   | 10           |

    Then execute admin cmd "dbGroup @@disable name = 'ha_group2' instance = 'hostS1'"
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_D"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_D" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | W     | 0        | 1000   | 0           | 0            | true        |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_E"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_F"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_D" and "Res_E" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |
    Then check resultsets "Res_E" and "Res_F" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |
    #case if route hostS1 dbInstance  ,result will be wrong
    Given delete file "/tmp/dble_user_query.log" on "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                | db      |
      | conn_0 | true    | insert into global1 values (1)     | schema1 |
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    #java.io.IOException: the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status
      """
      the dbInstance\[172.100.9.2:3306\] can
      Please check the dbInstance status
      """
    Given delete file "/tmp/dble_user_query.log" on "dble-1"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                | db      |
      | conn_0 | true    | insert into global2 values (2)     | schema1 |
    Then check following text exist "Y" in file "/tmp/dble_user_query.log" in host "dble-1"
    #java.io.IOException: the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status
      """
      the dbInstance\[172.100.9.2:3306\] can
      Please check the dbInstance status
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect      | db      |
      | conn_1 | False   | select * from global1          | length{(1)} | schema1 |
      | conn_1 | False   | select * from global2          | length{(1)} | schema1 |
      | conn_1 | False   | insert into global3 values (1) | success     | schema1 |
      | conn_1 | true    | select * from global3          | length{(4)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                      | expect                                                                                   | db      |
      | conn_2  | False   | insert into sharding2 values (1,1)       | success                                                                                  | schema1 |
      | conn_2  | False   | insert into sharding2 values (2,2)       | success                                                                                  | schema1 |
      | conn_2  | False   | select * from sharding2                  | length{(6)}                                                                              | schema1 |
      | conn_2  | False   | insert into sharding4 values (1,1)       | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_2  | False   | insert into sharding4 values (3,3)       | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_2  | False   | insert into sharding4 values (2,2)       | success                                                                                  | schema1 |
      | conn_2  | False   | insert into sharding4 values (4,4)       | success                                                                                  | schema1 |
      | conn_2  | False   | insert into sharding4 values (1,1),(2,2) | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_2  | False   | select * from sharding4                  | length{(8)}                                                                              | schema1 |
      | conn_2  | False   | select * from sharding4 where id=2       | length{(3)}                                                                              | schema1 |
      | conn_2  | False   | select * from sharding4 where id=1       | length{(1)}                                                                              | schema1 |
      | conn_2  | False   | insert into child1 values (1,1)          | success                                                                                  | schema1 |
      | conn_2  | False   | insert into child1 values (2,2)          | success                                                                                  | schema1 |
      | conn_2  | true    | select * from child1                     | length{(5)}                                                                              | schema1 |
      | conn_21 | False   | insert into sharding21 values (1,1)      | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema3 |
      | conn_21 | False   | insert into sharding21 values (2,2)      | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema3 |
      | conn_21 | true    | select * from sharding21                 | length{(2)}                                                                              | schema3 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                   | expect                                                                                   | db      |
      | conn_3  | False   | insert into sing1 values (1)          | success                                                                                  | schema1 |
      | conn_3  | False   | select * from sing1                   | length{(3)}                                                                              | schema1 |
      | conn_3  | False   | insert into sing2 values (1)          | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema1 |
      | conn_3  | False   | select * from sing2                   | length{(1)}                                                                              | schema1 |
      | conn_3  | False   | insert into no_sharding1 values (1,1) | success                                                                                  | schema1 |
      | conn_3  | true    | select * from no_sharding1            | length{(3)}                                                                              | schema1 |
      | conn_31 | False   | insert into no_sharding2 values (1,1) | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema3 |
      | conn_31 | true    | select * from no_sharding2            | length{(1)}                                                                              | schema3 |
      | conn_32 | False   | show tables                           | success                                                                                  | schema2 |
      | conn_32 | False   | insert into vertical1 values (1)      | the dbInstance[172.100.9.2:3306] can't reach. Please check the dbInstance status | schema2 |
      | conn_32 | true    | select * from  vertical1              | length{(1)}                                                                              | schema2 |
    #case change master to slave2 on mysql group
    Given execute linux command in "behave"
      """
      bash ./compose/docker-build-behave/ChangeMaster.sh dble-3 mysql-master2 dble-2
     """
    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostS2'"

    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="true"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "Res_1"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_1" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10 |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | 1000   | 0           | 0            | false       |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | R     | 0        | 1000   | 0           | 0            | true        |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | W     | 0        | 1000   | 0           | 0            | false       |
    Given execute single sql in "dble-2" in "admin" mode and save resultset in "Res_2"
      | sql               |
      | show @@dbinstance |
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_3"
      | sql               |
      | show @@dbinstance |
    Then check resultsets "Res_1" and "Res_2" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |
    Then check resultsets "Res_2" and "Res_3" are same in following columns
      | column     | column_index |
      | DB_GROUP   | 0            |
      | NAME       | 1            |
      | W/R        | 4            |
      | DISABLED   | 10           |
    Then execute admin cmd "dbGroup @@enable name = 'ha_group2'"
    #check master had changed
    Then execute sql in "mysql-slave2"
      | conn   | toClose | sql                                          | expect        |
      | conn_0 | false   | show master status                           | success       |
      | conn_0 | true    | show slave status                            | hasNoStr{Yes} |
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                            | expect         |
      | conn_0 | true    | show slave status                              | hasStr{Yes}    |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                            | expect         |
      | conn_0 | true    | show slave status                              | hasStr{Yes}    |


    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "Y" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostM2" url="172.100.9.6:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="false"/>
      <dbInstance name="hostS2" url="172.100.9.3:3306" password="111111" user="test" maxCon="1000" minCon="10" primary="true"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-1"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-2"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Then check following text exist "N" in file "/opt/dble/conf/db.xml" in host "dble-3"
      """
      <dbInstance name="hostS1" url="172.100.9.2:3306" password="111111" user="test" maxCon="1000" minCon="10" disabled="true" primary="false"/>
      """
    Given execute single sql in "dble-3" in "admin" mode and save resultset in "Res_5"
      | sql               |
      | show @@dbinstance |
    Then check resultset "Res_5" has lines with following column values
      | DB_GROUP-0 | NAME-1 | HOST-2      | PORT-3 | W/R-4 | ACTIVE-5 | SIZE-7 | READ_LOAD-8 | WRITE_LOAD-9 | DISABLED-10  |
      | ha_group1  | hostM1 | 172.100.9.5 | 3306   | W     | 0        | 1000   | 0           | 0            | false        |
      | ha_group2  | hostM2 | 172.100.9.6 | 3306   | R     | 0        | 1000   | 0           | 0            | false        |
      | ha_group2  | hostS1 | 172.100.9.2 | 3306   | R     | 0        | 1000   | 0           | 0            | false        |
      | ha_group2  | hostS2 | 172.100.9.3 | 3306   | W     | 0        | 1000   | 0           | 0            | false        |
    #case query dml sql will be success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                            | expect      | db      |
      | conn_1 | False   | insert into global1 values (1) | success     | schema1 |
      | conn_1 | False   | insert into global2 values (1) | success     | schema1 |
      | conn_1 | False   | insert into global3 values (1) | success     | schema1 |
      | conn_1 | False   | select * from global1          | length{(2)} | schema1 |
      | conn_1 | False   | select * from global2          | length{(2)} | schema1 |
      | conn_1 | true    | select * from global3          | length{(5)} | schema1 |
    Then execute sql in "dble-2" in "user" mode
      | conn    | toClose | sql                                                  | expect      | db      |
      | conn_2  | False   | insert into sharding2 values (1,1),(2,2)             | success     | schema1 |
      | conn_2  | False   | select * from sharding2                              | length{(8)} | schema1 |
      | conn_2  | False   | insert into sharding4 values (1,1),(2,2),(3,3),(4,4) | success     | schema1 |
      | conn_2  | False   | select * from sharding4                              | length{(12)}| schema1 |
      | conn_2  | False   | select * from sharding4 where id=1                   | length{(2)} | schema1 |
      | conn_2  | False   | insert into child1 values (3,3)                      | success     | schema1 |
      | conn_2  | true    | select * from child1                                 | length{(6)} | schema1 |
      | conn_21 | False   | insert into sharding21 values (1,1),(2,2)            | success     | schema3 |
      | conn_21 | true    | select * from sharding21                             | length{(4)} | schema3 |
    Then execute sql in "dble-3" in "user" mode
      | conn    | toClose | sql                                   | expect      | db      |
      | conn_3  | False   | insert into sing1 values (1)          | success     | schema1 |
      | conn_3  | False   | select * from sing1                   | length{(4)} | schema1 |
      | conn_3  | False   | insert into sing2 values (1)          | success     | schema1 |
      | conn_3  | False   | select * from sing2                   | length{(2)} | schema1 |
      | conn_3  | False   | insert into no_sharding1 values (1,1) | success     | schema1 |
      | conn_3  | true    | select * from no_sharding1            | length{(4)} | schema1 |
      | conn_31 | False   | insert into no_sharding2 values (1,1) | success     | schema3 |
      | conn_31 | true    | select * from no_sharding2            | length{(2)} | schema3 |
      | conn_32 | False   | show tables                           | success     | schema2 |
      | conn_32 | False   | insert into vertical1 values (1)      | success     | schema2 |
      | conn_32 | true    | select * from  vertical1              | length{(2)} | schema2 |



  Scenario: restore mysql binlog and clear table  #3

    Given update file content "./compose/docker-build-behave/ChangeMaster.sh" in "behave" with sed cmds
    """
    s/grant replication slave on *.* to '\''repl'\''@'\''%'\'' identified by '\''111111'\''/grant replication slave on *.* to '\''repl'\''@'\''%'\''/
    """

    Given execute linux command in "behave"
      """
      bash ./compose/docker-build-behave/resetReplication.sh
      """