# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/29


Feature: check txIsolation supports tx_/transaction_ variables in zk cluster

  Scenario: writeHost mysql < 8.0, readHost mysql >= 8.0 #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-2" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-3" success

    Then execute admin cmd "dryrun"
    Then execute admin cmd "reload @@config_all -r"

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    txIsolation=1
    """

    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql8-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1 | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | True    | commit                      | success                                   | schema1 |


  Scenario: writeHost mysql >= 8.0, readHost mysql < 8.0 #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-2" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-3" success

    Then execute admin cmd "dryrun"
    Then execute admin cmd "reload @@config_all -r"

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    txIsolation=1
    """

    Then execute sql in "mysql8-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1 | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | True    | commit                      | success                                   | schema1 |


  Scenario: writeHost and readHost mysql >= 8.0 #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-2" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-3" success

    Then execute admin cmd "dryrun"
    Then execute admin cmd "reload @@config_all -r"

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    txIsolation=1
    """

    Then execute sql in "mysql8-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql8-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1 | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | True    | commit                      | success                                   | schema1 |


  Scenario: writeHost and readHost mysql < 8.0 #4
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="2" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-2" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-2" success

    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-3" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-3" success

    Then execute admin cmd "dryrun"
    Then execute admin cmd "reload @@config_all -r"

    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-1"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-2"
    """
    txIsolation=1
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    autocommit=0
    """
    Then check following text exist "Y" in file "/opt/dble/conf/bootstrap.cnf" in host "dble-3"
    """
    txIsolation=1
    """

    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1 | has{((1,'1'), (2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | True    | commit                      | success                                   | schema1 |