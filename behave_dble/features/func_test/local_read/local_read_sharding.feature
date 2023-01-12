# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/10/27

Feature: check dbDistrict and dbDataCenter

  Scenario: check dbDistrict and dbDataCenter value #1
    # case 1: bootstrap.cnf and db.xml only set district
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    $a -Ddistrict=Shanghai
    /-DrwStickyTime/d
    $a -DrwStickyTime=0
    """

    # case 1.1: set rwSplitMode=0, master read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then restart dble in "dble-1" success

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given turn on general log in "mysql-slave2"

    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                                                           | db      | expect  | timeout |
       | conn_1 | false   | drop table if exists sharding_4_t1                                                            | schema1 | success |         |
       | conn_1 | false   | create table sharding_4_t1 (id int, name varchar(100), age int)                               | schema1 | success |         |
       | conn_1 | false   | insert into sharding_4_t1 values (1,'name1',18),(2, 'name2',20),(3,'name3',30),(4,'name4',19) | schema1 | success |         |
       | conn_1 | true    | select name from sharding_4_t1                                                                | schema1 | has{(('name1',),('name2',),('name3',),('name4',))} | 2        |
    Then check general log in host "mysql-master2" has "SELECT name FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave1" has not "SELECT name FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT name FROM sharding_4_t1"

    # case 2: set rwSplitMode=1, hostS1 dbDistrict=Shanghai readWeight=0, hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" readWeight="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                              | db      | expect                     |
       | conn_1 | true    | select id from sharding_4_t1     | schema1 | has{((1,),(2,),(3,),(4,))} |
    Then check general log in host "mysql-master2" has not "SELECT id FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has "SELECT id FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave2" has not "SELECT id FROM sharding_4_t1"

    # case 3: set rwSplitMode=1, hostS1 dbDistrict=Shanghai disable=true, hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                               | db      | expect      |
       | conn_1 | true    | select id,name from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "SELECT id, name FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has not "SELECT id, name FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has "SELECT id, name FROM sharding_4_t1" occured "==2" times

    # case 4: set rwSplitMode=1, hostS1 and hostS2 dbDistrict=Shanghai disable=true, return error
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                               | db      | expect                 |
       | conn_1 | true    | select id,age from sharding_4_t1  | schema1 | java.io.IOException: the dbGroup[ha_group2] doesn't contain active dbInstance. |
    Then check general log in host "mysql-master2" has not "SELECT id, age FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has not "SELECT id, age FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT id, age FROM sharding_4_t1"

 # case 5: set rwSplitMode=1, hostM2 dbDistrict=Shanghai, hostS1 and hostS2 dbDistrict=Beijing, hostS1 or hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                              | db      | expect      |
       | conn_1 | true    | select id,age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "SELECT id, age FROM sharding_4_t1"

    # case 6: set rwSplitMode=2, hostS1 and hostS2 dbDistrict=Beijing, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                   | db      | expect      |
       | conn_1 | true    | select id,name,age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has "SELECT id, name, age FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave1" has not "SELECT id, name, age FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT id, name, age FROM sharding_4_t1"

    # case 7: set rwSplitMode=3, hostS1 and hostS2 dbDistrict=Shanghai disable=true, hostM2 dbDistrict=Beijing, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Beijing" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                | db      | expect      |
       | conn_1 | true    | select name,age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has "SELECT name, age FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave1" has not "SELECT name, age FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT name, age FROM sharding_4_t1"

    # case 8: set rwSplitMode=3, hostS1 and hostS2 dbDistrict=Beijing, hostM2 dbDistrict=Shanghai, hostS1 or hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                           | db      | expect                |
       | conn_1 | true    | select name,age from sharding_4_t1 where id=1 | schema1 | has{(('name1', 18),)} |
    Then check general log in host "mysql-master2" has not "select name,age from sharding_4_t1 where id=1"

    # case 9: hint case
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                                             | db      | expect                |
       | conn_1 | false   | /* master */select name,age from sharding_4_t1 where age=20                     | schema1 | has{(('name2', 20),)} |
       | conn_1 | false   | /* uproxy_dest:172.100.9.6:3306 */select name,age from sharding_4_t1 where id=3 | schema1 | has{(('name3', 30),)} |
       | conn_1 | false   | /*!dble:db_type=master*/ select name,age from sharding_4_t1 where age=30        | schema1 | has{(('name3', 30),)} |
       | conn_1 | false   | /*!dble:shardingNode=dn2*/ select name,age from sharding_4_t1 where age=18      | schema1 | has{(('name1', 18),)} |
       | conn_1 | false   | /*!dble:db_instance_url=172.100.9.6:3306*/ select * from sharding_4_t1          | schema1 | current hint type is not supported |
       | conn_1 | true    | drop table if exists sharding_4_t1                                              | schema1 | success               |
    Then check general log in host "mysql-master2" has not "SELECT name, age FROM sharding_4_t1 WHERE age = 20"
    Then check general log in host "mysql-master2" has not "select name,age from sharding_4_t1 where id=3"
    Then check general log in host "mysql-master2" has "SELECT name, age FROM sharding_4_t1 WHERE age = 30" occured "==2" times
    Then check general log in host "mysql-master2" has not "select name,age from sharding_4_t1 where age=18"
    Then check general log in host "mysql-master2" has not "select \* from sharding_4_t1"

    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"
    Given turn off general log in "mysql-slave2"

  @auto_retry
  Scenario: bootstrap.cnf and db.xml only set dataCenter, local read is not enabled #2
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    /-DdataCenter/d
    $a -DdataCenter=Xuhui
    /-DrwStickyTime/d
    $a -DrwStickyTime=0
    """
    # set rwSplitMode=1, hostS1 dbDataCenter=Xuhui readWeight=0, hostS2 read, local read is not enabled
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDataCenter="Xuhui" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDataCenter="Pudong" readWeight="10" />
    </dbGroup>
    """
    Then restart dble in "dble-1" success

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given turn on general log in "mysql-slave2"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                                   | db      | expect  | timeout |
       | conn_1 | false   | drop table if exists sharding_4_t1                                    | schema1 | success |         |
       | conn_1 | false   | create table sharding_4_t1 (id int, name varchar(100), age int)       | schema1 | success |         |
       | conn_1 | false   | insert into sharding_4_t1 values (1,'name1',18),(2, 'name2',20)       | schema1 | success |         |
       | conn_1 | false   | select * from sharding_4_t1                                           | schema1 | length{(2)} | 2    |
    Then check general log in host "mysql-master2" has not "SELECT \* FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has not "SELECT \* FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has "SELECT \* FROM sharding_4_t1" occured "==2" times

    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"
    Given turn off general log in "mysql-slave2"

  Scenario: bootstrap.cnf and db.xml set district and dataCenter #3
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    $a -Ddistrict=Shanghai
    /-DdataCenter/d
    $a -DdataCenter=Xuhui
    /-DrwStickyTime/d
    $a -DrwStickyTime=0
    """
        
    # case 1: set rwSplitMode=0, master read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Beijing" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given turn on general log in "mysql-slave2"

    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                                         | db      | expect  | timeout |
       | conn_1 | false   | drop table if exists sharding_4_t1                                          | schema1 | success |         |
       | conn_1 | false   | create table sharding_4_t1 (id int, name varchar(100), age int)             | schema1 | success |         |
       | conn_1 | false   | insert into sharding_4_t1 values (1,'name1',18),(2, 'name2',20),(3,'name3',30),(4,'name4',19) | schema1 | success |         |
       | conn_1 | false   | select name from sharding_4_t1                                              | schema1 | has{(('name1',),('name2',),('name3',),('name4',))} | 2        |
    Then check general log in host "mysql-master2" has "SELECT name FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave1" has not "SELECT name FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT name FROM sharding_4_t1"

    # case 2: set rwSplitMode=1, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui readWeight=0, hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" readWeight="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                              | db      | expect      |
       | conn_1 | true    | select id from sharding_4_t1     | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "SELECT id FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has "SELECT id FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave2" has not "SELECT id FROM sharding_4_t1"

    # case 3: set rwSplitMode=1, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui readWeight=0, hostS2 dbDistrict=Shanghai readWeight=10, hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" readWeight="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                           | db      | expect      |
       | conn_1 | true    | select age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "SELECT age FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has "SELECT age FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave2" has not "SELECT age FROM sharding_4_t1"

    # case 4: set rwSplitMode=1, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui disable=true, hostS2 dbDistrict=Beijing, hostM2 dbDistrict=Shanghai dbDataCenter=Xuhui, hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                          | db      | expect      |
       | conn_1 | true    | select age from sharding_4_t1 where age > 18 | schema1 | length{(3)} |
    Then check general log in host "mysql-master2" has not "SELECT age FROM sharding_4_t1 WHERE age > 18"
    Then check general log in host "mysql-slave1" has not "SELECT age FROM sharding_4_t1 WHERE age > 18"
    Then check general log in host "mysql-slave2" has "SELECT age FROM sharding_4_t1 WHERE age > 18" occured "==2" times

    # case 5: set rwSplitMode=1, hostS1 and hostS2 dbDistrict=Shanghai dbDataCenter=Xuhui disable=true, return error
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                               | db      | expect                     |
       | conn_1 | true    | select id,name from sharding_4_t1 | schema1 | java.io.IOException: the dbGroup[ha_group2] doesn't contain active dbInstance. |
    Then check general log in host "mysql-master2" has not "SELECT id, name FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has not "SELECT id, name FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT id, name FROM sharding_4_t1"

    # case 6: set rwSplitMode=1, hostS1 and hostS2 dbDistrict=Beijing dbDataCenter=Xuhui, hostS1 or hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                              | db      | expect      |
       | conn_1 | true    | select id,age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "SELECT id, age FROM sharding_4_t1"

    # case 7: set rwSplitMode=2, hostS1 and hostS2 dbDistrict=Shanghai dbDataCenter=Pudong, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                   | db      | expect      |
       | conn_1 | true    | select id,name,age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has "SELECT id, name, age FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave1" has not "SELECT id, name, age FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT id, name, age FROM sharding_4_t1"

    # case 8: set rwSplitMode=2, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui disabled=true, hostS2 dbDistrict=Shanghai dbDataCenter=Pudong, hostM2 dbDistrict=Beijing dbDataCenter=Xuhui, hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                  | db      | expect      |
       | conn_1 | true    | select id,name,age from sharding_4_t1 where age > 20 | schema1 | length{(1)} |
    Then check general log in host "mysql-master2" has not "SELECT id, name, age FROM sharding_4_t1 WHERE age > 20"
    Then check general log in host "mysql-slave1" has not "SELECT id, name, age FROM sharding_4_t1 WHERE age > 20"
    Then check general log in host "mysql-slave2" has "SELECT id, name, age FROM sharding_4_t1 WHERE age > 20" occured "==2" times

    # case 9: set rwSplitMode=2, hostS1 and hostS2 dbDistrict=Beijing dbDataCenter=Xuhui, hostM2 dbDistrict=Shanghai dbDataCenter=Pudong, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Pudong" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                | db      | expect      |
       | conn_1 | true    | select name,age from sharding_4_t1 | schema1 | length{(4)} |
    Then check general log in host "mysql-master2" has "SELECT name, age FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave1" has not "SELECT name, age FROM sharding_4_t1"
    Then check general log in host "mysql-slave2" has not "SELECT name, age FROM sharding_4_t1"

    # case 10: set rwSplitMode=3, hostS1 and hostS2 dbDistrict=Shanghai dbDataCenter=Xuhui disable=true, hostM2 dbDistrict=Beijing, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Beijing" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                           | db      | expect                |
       | conn_1 | true    | select name,age from sharding_4_t1 where id=1 | schema1 | has{(('name1', 18),)} |
    Then check general log in host "mysql-master2" has "select name,age from sharding_4_t1 where id=1"
    Then check general log in host "mysql-slave1" has not "select name,age from sharding_4_t1 where id=1"
    Then check general log in host "mysql-slave2" has not "select name,age from sharding_4_t1 where id=1"

    # case 11: set rwSplitMode=3, hostS1 and hostS2 dbDistrict=Beijing dbDataCenter=Xuhui, hostM2 dbDistrict=Shanghai dbDataCenter=Pudong, hostS1 or hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Pudong" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                     | db  | expect                |
       | conn_1 | true    | select name,age from sharding_4_t1 where id=3 | schema1 | has{(('name3', 30),)} |
    Then check general log in host "mysql-master2" has not "SELECT name, age FROM sharding_4_t1 WHERE id = 3"

    # case 12: hint case
    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                                              | db      | expect      |
       | conn_1 | false   | /* master */select name,age from sharding_4_t1 where age!=20                     | schema1 | length{(3)} |
       | conn_1 | false   | /* uproxy_dest:172.100.9.6:3306 */select name,age from sharding_4_t1 where id!=3 | schema1 | length{(3)} |
       | conn_1 | false   | /*!dble:db_type=master*/ select name,age from sharding_4_t1 where age=30         | schema1 | has{(('name3', 30),)} |
       | conn_1 | false   | /*!dble:shardingNode=dn2*/ select name,age from sharding_4_t1 where age=18       | schema1 | has{(('name1', 18),)} |
       | conn_1 | false   | /*!dble:db_instance_url=172.100.9.6:3306*/ select count(0) from sharding_4_t1   | schema1 | current hint type is not supported |
       | conn_1 | true    | drop table if exists sharding_4_t1                                              | schema1 | success               |
    Then check general log in host "mysql-master2" has not "SELECT name, age FROM sharding_4_t1 WHERE age != 20"
    Then check general log in host "mysql-master2" has not "SELECT name, age FROM sharding_4_t1 WHERE id != 3"
    Then check general log in host "mysql-master2" has "SELECT name, age FROM sharding_4_t1 WHERE age = 30" occured "==2" times
    Then check general log in host "mysql-master2" has not "select name,age from sharding_4_t1 where age=18"
    Then check general log in host "mysql-master2" has not "select count(0) from sharding_4_t1"

    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"
    Given turn off general log in "mysql-slave2"

  Scenario: check rwStickyTime and local read #4
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    $a -Ddistrict=Shanghai
    /-DdataCenter/d
    $a -DdataCenter=Xuhui
    /-DrwStickyTime/d
    $a -DrwStickyTime=3000
    """

    # case 1: set rwSplitMode=1, master read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group2" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Beijing" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given turn on general log in "mysql-slave2"

    Given execute sql in "dble-1" in "user" mode
       | conn   | toClose | sql                                                                         | db      | expect  | timeout |
       | conn_1 | false   | drop table if exists sharding_4_t1                                          | schema1 | success |         |
       | conn_1 | false   | create table sharding_4_t1 (id int, name varchar(100), age int)             | schema1 | success |         |
       | conn_1 | false   | insert into sharding_4_t1 values (1,'name1',18),(2, 'name2',20),(3,'name3',30),(4,'name4',19) | schema1 | success |         |
       | conn_1 | false   | select name from sharding_4_t1                                              | schema1 | has{(('name1',),('name2',),('name3',),('name4',))} | 2      |
       | conn_1 | true    | drop table if exists sharding_4_t1                                          | schema1 | success |         |
    Then check general log in host "mysql-master2" has not "SELECT name FROM sharding_4_t1"
    Then check general log in host "mysql-slave1" has "SELECT name FROM sharding_4_t1" occured "==2" times
    Then check general log in host "mysql-slave2" has not "SELECT name FROM sharding_4_t1"
    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"
    Given turn off general log in "mysql-slave2"