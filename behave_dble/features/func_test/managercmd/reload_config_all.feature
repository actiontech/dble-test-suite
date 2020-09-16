# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
  #2.19.11.0#dble-7847
Feature: reload @@config_all base test, not including all cases in testlink
  reload @@config_all, which do diff and reserve in use backend conn
  reload @@config_all -f, which do diff and kill in use backend conn
  reload @@config_all -r which don't do diff, rebuild backend conn, skip in use backend conn
  reload @@config_all -s,  skip test new connections

  Background: prepare for reload @@config_all -?
    Given delete the following xml segment
      |file        | parent          | child               |
      |sharding.xml  |{'tag':'root'}   | {'tag':'schema'}    |
      |sharding.xml  |{'tag':'root'}   | {'tag':'shardingNode'}  |
      |db.xml  |{'tag':'root'}   | {'tag':'dbGroup'}  |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn1">
    <shardingTable name="test_shard" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    <shardingNode name="dn1" dbGroup="ha_group1" database="db1"/>
    <shardingNode name="dn2" dbGroup="ha_group1" database="db2"/>
    <shardingNode name="dn3" dbGroup="ha_group1" database="db3"/>
    <shardingNode name="dn4" dbGroup="ha_group1" database="db4"/>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    a/-DbackendProcessorExecutor=4
    """
    Given Restart dble in "dble-1" success

  @CRITICAL
  Scenario: reload @@config_all, eg:no dbInstance change, reload @@config_all does not rebuild backend connection pool #1
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_A"
      | sql            |
      | show @@backend |
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_B"
      | sql            |
      | show @@backend |
    Then check resultsets "backend_rs_A" and "backend_rs_B" are same in following columns
      |column               | column_index |
      |processor            | 0            |
      |BACKEND_ID           | 1            |
      |MYSQLID              | 2            |
      |HOST                 | 3            |
      |PORT                 | 4            |
      |LOACL_TCP_PORT       | 5            |
      |CLOSED               | 9            |
      |SYS_VARIABLES        | 18           |
      |USER_VARIABLES       | 19           |

  @BLOCKER @restore_mysql_service
  Scenario: reload @@config_all, eg:remove old dbInstance and add new, drop backend connection pool for old dbInstance, create new connection pool, backend conn in use will not be dropped even the dbInstance was removed, reload @@config_all -f, reload @@config_all -r, reload @@config_all -s #2
     """
    {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}}}
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_C"
      | sql            |
      | show @@backend |
    Then check resultset "backend_rs_C" has not lines with following column values
      | PORT-4      | HOST-3       |
      | 3306        | 172.100.9.5  |
    Then check resultset "backend_rs_C" has lines with following column values
      | PORT-4    | HOST-3      |
      | 3306      | 172.100.9.6 |

    #reload @@config_all, eg: backend conn in use will not be dropped even the dbInstance was removed, reload @@config_all -f, reload @@config_all -r, reload @@config_all -s
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | db      |
      | conn_0 | False    | drop table if exists test_shard               | schema1 |
      | conn_0 | False    | create table test_shard(id int)               | schema1 |
      | conn_0 | False    | begin                                         | schema1 |
      | conn_0 | False    | insert into test_shard values(1),(2),(3),(4)  | schema1 |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_D"
      | sql            |
      | show @@backend |
    Then check resultset "backend_rs_D" has lines with following column values
      | PORT-4      | HOST-3      |
      | 3306        | 172.100.9.6 |
    #2 reload @@config_all -f, kill in use backend conn, do diff
    Then execute admin cmd "reload @@config_all -f"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_E"
      | sql            |
      | show @@backend |
    Then check resultset "backend_rs_E" has not lines with following column values
      | PORT-4      | HOST-3       |
      | 3306        | 172.100.9.6  |
    Then check resultsets "backend_rs_D" including resultset "backend_rs_E" in following columns
      |column               | column_index |
      |processor            | 0            |
      |BACKEND_ID           | 1            |
      |MYSQLID              | 2            |
      |HOST                 | 3            |
      |PORT                 | 4            |
      |LOACL_TCP_PORT       | 5            |
      |CLOSED               | 9            |
      |SYS_VARIABLES        | 18           |
      |USER_VARIABLES       | 19           |
    #3 reload @@config_all -r, donot do diff, rebuild backend conn, skip in use backend conn
    Then execute admin cmd "reload @@config_all -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_F"
      | sql            |
      | show @@backend |
    Then check resultsets "backend_rs_F" does not including resultset "backend_rs_E" in following columns
      |column            | column_index |
      |BACKEND_ID        | 1     |
      |MYSQLID           | 2     |
      |HOST              | 3     |
      |PORT              | 4     |

    #4 reload @@config_all -s,  skip test new connections
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all -f -r"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_G"
      | sql            |
      | show @@backend |
    Given stop mysql in host "mysql-master2"
    Then execute admin cmd "reload @@config_all -s"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_H"
      | sql            |
      | show @@backend |
    Then check resultset "backend_rs_H" has not lines with following column values
      | PORT-4      | HOST-3       |
      | 3306        | 172.100.9.6  |
    Then check resultsets "backend_rs_G" including resultset "backend_rs_H" in following columns
      |column               | column_index |
      |processor            | 0            |
      |BACKEND_ID           | 1            |
      |MYSQLID              | 2            |
      |HOST                 | 3            |
      |PORT                 | 4            |
      |LOACL_TCP_PORT       | 5            |
      |CLOSED               | 9            |
      |SYS_VARIABLES        | 18           |
      |USER_VARIABLES       | 19           |
    Given start mysql in host "mysql-master2"
    Given sleep "30" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                   | expect     | db      |
      | conn_1 | False    | drop table if exists test_shard       | success    | schema1 |
      | conn_1 | False    | create table test_shard(id int)       | success    | schema1 |
      | conn_1 | False    | begin                                 | success    | schema1 |
      | conn_1 | False    | insert into test_shard values(1),(2),(3),(4)  | success    | schema1 |
    Then execute admin cmd "reload @@config_all -r -f -s"
    Given sleep "1" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "backend_rs_I"
      | sql            |
      | show @@backend |
    Then check resultsets "backend_rs_I" does not including resultset "backend_rs_H" in following columns
      |column            | column_index |
      |BACKEND_ID        | 1     |
      |MYSQLID           | 2     |
      |HOST              | 3     |
      |PORT              | 4     |