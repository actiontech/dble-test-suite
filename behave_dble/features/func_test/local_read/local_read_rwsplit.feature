# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/10/27

Feature: check dbDistrict and dbDataCenter

  Scenario: bootstrap.cnf and db.xml only set district #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    $a -Ddistrict=Shanghai
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    # case 1: set rwSplitMode=0, master read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Guangzhou" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then restart dble in "dble-1" success

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"
    Given turn on general log in "mysql-slave2"

    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                                                                   | db  | expect  |
       | rwS1  | 111111 | conn_1 | false   | drop table if exists table_1                                          | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | create table table_1 (id int, name varchar(100), age int)             | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | insert into table_1 values (1,'name1',18),(2, 'name2',20),(3,'name3',30),(4,'name4',19) | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | select sleep(2)                                                       | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | select name from table_1                                              | db1 | has{(('name1',),('name2',),('name3',),('name4',))} |
       | rwS1  | 111111 | conn_1 | false   | show tables                                                           | db1 | success |
       | rwS1  | 111111 | conn_1 | true    | select @@server_id                                                    | db1 | has{((3306,),)} |
    Then check general log in host "mysql-master2" has "select name from table_1"
    Then check general log in host "mysql-slave1" has not "select name from table_1"
    Then check general log in host "mysql-slave2" has not "select name from table_1"
    Then check general log in host "mysql-master2" has "show tables"
    Then check general log in host "mysql-slave1" has not "show tables"
    Then check general log in host "mysql-slave2" has not "show tables"
    Then check general log in host "mysql-master2" has "select @@server_id"
    Then check general log in host "mysql-slave1" has not "select @@server_id"
    Then check general log in host "mysql-slave2" has not "select @@server_id"

    # case 2: set rwSplitMode=1, hostS1 dbDistrict=Shanghai readWeight=0, hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" readWeight="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                        | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id from table_1     | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "select id from table_1"
    Then check general log in host "mysql-slave1" has "select id from table_1"
    Then check general log in host "mysql-slave2" has not "select id from table_1"

    # case 3: set rwSplitMode=1, hostS1 dbDistrict=Shanghai disable=true, hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                     | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select age from table_1 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "select age from table_1"
    Then check general log in host "mysql-slave1" has not "select age from table_1"
    Then check general log in host "mysql-slave2" has "select age from table_1"

    # case 4: set rwSplitMode=1, hostS1 dbDistrict=Shanghai and hostS2 dbDistrict=Beijing both disable=true, return error
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" disabled="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                         | db  | expect                                                    |
       | rwS1  | 111111 | conn_1 | true    | select id,name from table_1 | db1 | the dbGroup[ha_group3] doesn't contain active dbInstance. |
    Then check general log in host "mysql-master2" has not "select id,name from table_1"
    Then check general log in host "mysql-slave1" has not "select id,name from table_1"
    Then check general log in host "mysql-slave2" has not "select id,name from table_1"

    # case 5: set rwSplitMode=1, hostM2 dbDistrict=Shanghai, hostS1 and hostS2 dbDistrict=Beijing, hostS1 or hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                        | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id,age from table_1 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "select id,age from table_1"

    # case 6: set rwSplitMode=2, hostS1 and hostS2 dbDistrict=Beijing, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                             | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id,name,age from table_1 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has "select id,name,age from table_1"
    Then check general log in host "mysql-slave1" has not "select id,name,age from table_1"
    Then check general log in host "mysql-slave2" has not "select id,name,age from table_1"

    # case 7: set rwSplitMode=2, hostS2 dbDistrict=Beijing, hostM2 or hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                                        | db  | expect                   |
       | rwS1  | 111111 | conn_1 | true    | select id,name,age from table_1 where id=1 | db1 | has{(((1,'name1',18),))} |
    Then check general log in host "mysql-slave2" has not "select id,name,age from table_1 where id=1"

    # case 8: hint case
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                                                                       | db  | expect                |
       | rwS1  | 111111 | conn_1 | false   | /* master */select name,age from table_1 where id=2                       | db1 | has{(('name2', 20),)} |
       | rwS1  | 111111 | conn_1 | false   | /* uproxy_dest:172.100.9.6:3306 */select name,age from table_1 where id=3 | db1 | has{(('name3', 30),)} |
       | rwS1  | 111111 | conn_1 | false   | /*!dble:db_type=master*/ select name,age from table_1 where id=4          | db1 | has{(('name4', 19),)} |
       | rwS1  | 111111 | conn_1 | false   | /*!dble:db_instance_url=172.100.9.6:3306*/ select count(0) from table_1   | db1 | has{((4,),)}          |
       | rwS1  | 111111 | conn_1 | true    | drop table if exists table_1                                              | db1 | success               |
    Then check general log in host "mysql-master2" has "select name,age from table_1 where id=2"
    Then check general log in host "mysql-master2" has "select name,age from table_1 where id=3"
    Then check general log in host "mysql-master2" has "select name,age from table_1 where id=4"
    Then check general log in host "mysql-master2" has "select count(0) from table_1"

    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"
    Given turn off general log in "mysql-slave2"


  Scenario: bootstrap.cnf and db.xml only set dataCenter, local read is not enabled #2
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-Ddistrict/d
    /-DdataCenter/d
    $a -DdataCenter=Xuhui
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    # set rwSplitMode=1, hostS1 dbDataCenter=Xuhui readWeight=0, hostS2 read, local read is not enabled
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
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
       | user  | passwd | conn   | toClose | sql                                                                   | db  | expect  |
       | rwS1  | 111111 | conn_1 | false   | drop table if exists table_2                                          | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | create table table_2 (id int, name varchar(100), age int)             | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | insert into table_2 values (1,'name1',18),(2, 'name2',20)             | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | select sleep(2)                                                       | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | select * from table_2                                                 | db1 | length{(2)} |
  Then check general log in host "mysql-master2" has not "select sleep(2)"
  Then check general log in host "mysql-master2" has not "select \* from table_2"
  Then check general log in host "mysql-slave1" has not "select sleep(2)"
  Then check general log in host "mysql-slave1" has not "select \* from table_2"
    Then check general log in host "mysql-slave2" has "select sleep(2)"
    Then check general log in host "mysql-slave2" has "select \* from table_2"

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
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <managerUser name="root" password="111111"/>
    <shardingUser name="test" password="111111" schemas="schema1"/>
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    # case 1: set rwSplitMode=0, master read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100">
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
       | user  | passwd | conn   | toClose | sql                                                                   | db  | expect  |
       | rwS1  | 111111 | conn_1 | false   | drop table if exists table_3                                          | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | create table table_3 (id int, name varchar(100), age int)             | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | insert into table_3 values (1,'name1',18),(2, 'name2',20),(3,'name3',30),(4,'name4',19) | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | select sleep(2)                                                       | db1 | success |
       | rwS1  | 111111 | conn_1 | false   | select name from table_3                                              | db1 | has{(('name1',),('name2',),('name3',),('name4',))} |
       | rwS1  | 111111 | conn_1 | false   | show tables                                                           | db1 | success |
       | rwS1  | 111111 | conn_1 | true    | select @@server_id                                                    | db1 | has{((3306,),)} |

    Then check general log in host "mysql-master2" has "select name from table_3"
    Then check general log in host "mysql-slave1" has not "select name from table_3"
    Then check general log in host "mysql-slave2" has not "select name from table_3"
    Then check general log in host "mysql-master2" has "show tables"
    Then check general log in host "mysql-slave1" has not "show tables"
    Then check general log in host "mysql-slave2" has not "show tables"
    Then check general log in host "mysql-master2" has "select @@server_id"
    Then check general log in host "mysql-slave1" has not "select @@server_id"
    Then check general log in host "mysql-slave2" has not "select @@server_id"

    # case 2: set rwSplitMode=1, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui readWeight=0, hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" readWeight="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                        | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id from table_3     | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "select id from table_3"
    Then check general log in host "mysql-slave1" has "select id from table_3"
    Then check general log in host "mysql-slave2" has not "select id from table_3"

    # case 3: set rwSplitMode=1, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui readWeight=0, hostS2 dbDistrict=Shanghai readWeight=10, hostS1 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" readWeight="0" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" readWeight="10" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                     | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select age from table_3 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "select age from table_3"
    Then check general log in host "mysql-slave1" has "select age from table_3"
    Then check general log in host "mysql-slave2" has not "select age from table_3"

    # case 4: set rwSplitMode=1, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui disable=true, hostS2 dbDistrict=Beijing, hostM2 dbDistrict=Shanghai dbDataCenter=Xuhui, hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                                    | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select age from table_3 where age > 18 | db1 | length{(3)} |
    Then check general log in host "mysql-master2" has not "select age from table_3 where age > 18"
    Then check general log in host "mysql-slave1" has not "select age from table_3 where age > 18"
    Then check general log in host "mysql-slave2" has "select age from table_3 where age > 18"

    # case 5: set rwSplitMode=1, hostS1 and hostS2 dbDistrict=Shanghai dbDataCenter=Xuhui disable=true, return error
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                         | db  | expect                                                    |
       | rwS1  | 111111 | conn_1 | true    | select id,name from table_3 | db1 | the dbGroup[ha_group3] doesn't contain active dbInstance. |
    Then check general log in host "mysql-master2" has not "select id,name from table_3"
    Then check general log in host "mysql-slave1" has not "select id,name from table_3"
    Then check general log in host "mysql-slave2" has not "select id,name from table_3"

    # case 6: set rwSplitMode=1, hostS1 and hostS2 dbDistrict=Beijing dbDataCenter=Xuhui, hostS1 or hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="1" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                        | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id,age from table_3 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has not "select id,age from table_3"

    # case 7: set rwSplitMode=2, hostS1 and hostS2 dbDistrict=Shanghai dbDataCenter=Pudong, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                             | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id,name,age from table_3 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has "select id,name,age from table_3"
    Then check general log in host "mysql-slave1" has not "select id,name,age from table_3"
    Then check general log in host "mysql-slave2" has not "select id,name,age from table_3"

    # case 8: set rwSplitMode=2, hostS1 dbDistrict=Shanghai dbDataCenter=Xuhui disabled=true, hostS2 dbDistrict=Shanghai dbDataCenter=Pudong, hostM2 dbDistrict=Beijing dbDataCenter=Xuhui, hostS2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Xuhui" disabled="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Shanghai" dbDataCenter="Pudong" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                                            | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select id,name,age from table_3 where age > 20 | db1 | length{(1)} |
    Then check general log in host "mysql-master2" has not "select id,name,age from table_3 where age > 20"
    Then check general log in host "mysql-slave1" has not "select id,name,age from table_3 where age > 20"
    Then check general log in host "mysql-slave2" has "select id,name,age from table_3 where age > 20"

    # case 9: set rwSplitMode=2, hostS1 and hostS2 dbDistrict=Beijing dbDataCenter=Xuhui, hostM2 dbDistrict=Shanghai dbDataCenter=Pudong, hostM2 read
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group3" delayThreshold="100">
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="20" primary="true" dbDistrict="Shanghai" dbDataCenter="Pudong" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3308" user="test" maxCon="100" minCon="20" primary="false" dbDistrict="Beijing" dbDataCenter="Xuhui" />
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                          | db  | expect      |
       | rwS1  | 111111 | conn_1 | true    | select name,age from table_3 | db1 | length{(4)} |
    Then check general log in host "mysql-master2" has "select name,age from table_3"
    Then check general log in host "mysql-slave1" has not "select name,age from table_3"
    Then check general log in host "mysql-slave2" has not "select name,age from table_3"

    # case 10: hint case
    Given execute sql in "dble-1" in "user" mode
       | user  | passwd | conn   | toClose | sql                                                                       | db  | expect                |
       | rwS1  | 111111 | conn_1 | false   | /* master */select name,age from table_3 where id=2                       | db1 | has{(('name2', 20),)} |
       | rwS1  | 111111 | conn_1 | false   | /* uproxy_dest:172.100.9.6:3306 */select name,age from table_3 where id=3 | db1 | has{(('name3', 30),)} |
       | rwS1  | 111111 | conn_1 | false   | /*!dble:db_type=master*/ select name,age from table_3 where id=4          | db1 | has{(('name4', 19),)} |
       | rwS1  | 111111 | conn_1 | false   | /*!dble:db_instance_url=172.100.9.6:3306*/ select count(0) from table_3   | db1 | has{((4,),)}          |
       | rwS1  | 111111 | conn_1 | true    | drop table if exists table_3                                              | db1 | success               |
    Then check general log in host "mysql-master2" has "select name,age from table_3 where id=2"
    Then check general log in host "mysql-master2" has "select name,age from table_3 where id=3"
    Then check general log in host "mysql-master2" has "select name,age from table_3 where id=4"
    Then check general log in host "mysql-master2" has "select count(0) from table_3"

    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"
    Given turn off general log in "mysql-slave2"