# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/25

Feature: check txIsolation supports tx_/transaction_ variables

  @restore_mysql_service
  Scenario: writeHost mysql < 8.0, readHost mysql >= 8.0 #1
  """
    {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}, 'mysql8-slave1':{'start_mysql':1}}}
  """
# check isolation、autocommit
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql8-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

# check ddl, transaction, xa
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_2 | False   | commit                                                  | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((2,'2'), (1,'1'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | delete from sharding_4_t1 where id=1 | success                                   | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | False   | select * from sharding_4_t1 | has{((2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_2 | False   | commit                      | success                          | schema1 |
      | conn_2 | False   | set xa=on                   | success                          | schema1 |
      | conn_2 | False   | delete from sharding_4_t1   | success                          | schema1 |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1          | length{(0)} | schema1 |
      | conn_3 | True    | commit                               | success     | schema1 |

# check @@session.transaction_read_only
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect                                               | db      |
      | conn_4 | False   | set @@session.transaction_read_only=1                   | success                                              | schema1 |
      | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | Cannot execute statement in a READ ONLY transaction. | schema1 |
      | conn_4 | False   | set @@session.transaction_read_only=0                   | success                                              | schema1 |
      | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success                                              | schema1 |
      | conn_4 | True    | commit                                                  | success                                              | schema1 |

# stop, start writeHost
    Given stop mysql in host "mysql-master2"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.6:3306[]] setError
    """
    Given start mysql in host "mysql-master2"
    Given sleep "40" seconds
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_5 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.6:3306[]] setOK
    """

# stop, start readHost
    Given stop mysql in host "mysql8-slave1"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.11:3306[]] setError
    """
    Given start mysql in host "mysql8-slave1"
    Given sleep "40" seconds
    Then execute sql in "mysql8-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_6 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.11:3306[]] setOK
    """

  @restore_mysql_service
  Scenario: writeHost mysql >= 8.0, readHost mysql < 8.0 #2
  """
    {'restore_mysql_service':{'mysql8-master2':{'start_mysql':1}, 'mysql-slave1':{'start_mysql':1}}}
  """
# check isolation、autocommit
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success
    Then execute sql in "mysql8-master2"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

# check ddl, transaction, xa
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_2 | False   | commit                                                  | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((2,'2'), (1,'1'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | delete from sharding_4_t1 where id=1 | success                                   | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | False   | select * from sharding_4_t1 | has{((2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_2 | False   | commit                      | success                          | schema1 |
      | conn_2 | False   | set xa=on                   | success                          | schema1 |
      | conn_2 | False   | delete from sharding_4_t1   | success                          | schema1 |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1          | length{(0)} | schema1 |
      | conn_3 | True    | commit                               | success     | schema1 |

# check @@session.transaction_read_only
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect                                               | db      |
      | conn_4 | False   | set @@session.transaction_read_only=1                   | success                                              | schema1 |
      | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | Cannot execute statement in a READ ONLY transaction. | schema1 |
      | conn_4 | False   | set @@session.transaction_read_only=0                   | success                                              | schema1 |
      | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success                                              | schema1 |
      | conn_4 | True    | commit                                                  | success                                              | schema1 |

# stop, start writeHost
    Given stop mysql in host "mysql8-master2"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.10:3306[]] setError
    """
    Given start mysql in host "mysql8-master2"
    Given sleep "40" seconds
    Then execute sql in "mysql8-master2"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_5 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.10:3306[]] setOK
    """

# stop, start readHost
    Given stop mysql in host "mysql-slave1"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.2:3306[]] setError
    """
    Given start mysql in host "mysql-slave1"
    Given sleep "40" seconds
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_6 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.2:3306[]] setOK
    """


  @restore_mysql_service
  Scenario: writeHost and readHost mysql >= 8.0 #3
  """
    {'restore_mysql_service':{'mysql8-master2':{'start_mysql':1}, 'mysql8-slave1':{'start_mysql':1}}}
  """
# check isolation、autocommit
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.9:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>

    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.10:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.11:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success
    Then execute sql in "mysql8-master2"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql8-slave1"
      | conn   | toClose | sql                                                                                | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

# check ddl, transaction, xa
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_2 | False   | commit                                                  | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((2,'2'), (1,'1'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | delete from sharding_4_t1 where id=1 | success                                   | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | False   | select * from sharding_4_t1 | has{((2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_2 | False   | commit                      | success                          | schema1 |
      | conn_2 | False   | set xa=on                   | success                          | schema1 |
      | conn_2 | False   | delete from sharding_4_t1   | success                          | schema1 |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1          | length{(0)} | schema1 |
      | conn_3 | True    | commit                               | success     | schema1 |

# check @@session.transaction_read_only
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                     | expect                                               | db      |
    | conn_4 | False   | set @@session.transaction_read_only=1                   | success                                              | schema1 |
    | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | Cannot execute statement in a READ ONLY transaction. | schema1 |
    | conn_4 | False   | set @@session.transaction_read_only=0                   | success                                              | schema1 |
    | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success                                              | schema1 |
    | conn_4 | True    | commit                                                  | success                                              | schema1 |

# stop, start writeHost
    Given stop mysql in host "mysql8-master2"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.10:3306[]] setError
    """
    Given start mysql in host "mysql8-master2"
    Given sleep "40" seconds
    Then execute sql in "mysql8-master2"
    | conn   | toClose | sql                                                                                | expect                                |
    | conn_5 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.10:3306[]] setOK
    """

# stop, start readHost
    Given stop mysql in host "mysql8-slave1"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.11:3306[]] setError
    """
    Given start mysql in host "mysql8-slave1"
    Given sleep "40" seconds
    Then execute sql in "mysql8-slave1"
    | conn   | toClose | sql                                                                                | expect                                |
    | conn_6 | True    | select @@lower_case_table_names,@@autocommit, @@transaction_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.11:3306[]] setOK
    """


  @restore_mysql_service
  Scenario: writeHost and readHost mysql < 8.0 #4
  """
    {'restore_mysql_service':{'mysql-master2':{'start_mysql':1}, 'mysql-slave1':{'start_mysql':1}}}
  """
# check isolation、autocommit
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
        <dbInstance name="hostS1" password="111111" url="172.100.9.2:3306" user="test" maxCon="1000" minCon="10">
        </dbInstance>
    </dbGroup>
    """
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DtxIsolation/d
    /-Dautocommit/d
    $a -Dautocommit=0
    $a -DtxIsolation=1
    """
    Then restart dble in "dble-1" success
    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_0 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                                                                       | expect                                |
      | conn_1 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |

# check ddl, transaction, xa
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                     | expect  | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1                      | success | schema1 |
      | conn_2 | False   | create table sharding_4_t1(id int,name varchar(20))     | success | schema1 |
      | conn_2 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success | schema1 |
      | conn_2 | False   | commit                                                  | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect                                    | db      |
      | conn_3 | False   | select * from sharding_4_t1          | has{((2,'2'), (1,'1'), (4,'4'), (3,'3'))} | schema1 |
      | conn_3 | False   | delete from sharding_4_t1 where id=1 | success                                   | schema1 |
      | conn_3 | False   | commit                               | success                                   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                         | expect                           | db      |
      | conn_2 | False   | select * from sharding_4_t1 | has{((2,'2'), (4,'4'), (3,'3'))} | schema1 |
      | conn_2 | False   | commit                      | success                          | schema1 |
      | conn_2 | False   | set xa=on                   | success                          | schema1 |
      | conn_2 | False   | delete from sharding_4_t1   | success                          | schema1 |
      | conn_2 | True    | commit                      | success                          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1          | length{(0)} | schema1 |
      | conn_3 | True    | commit                               | success     | schema1 |

# check @@session.transaction_read_only
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                     | expect                                               | db      |
    | conn_4 | False   | set @@session.transaction_read_only=1                   | success                                              | schema1 |
    | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | Cannot execute statement in a READ ONLY transaction. | schema1 |
    | conn_4 | False   | set @@session.transaction_read_only=0                   | success                                              | schema1 |
    | conn_4 | False   | insert into sharding_4_t1 values(1,1),(2,2),(3,3),(4,4) | success                                              | schema1 |
    | conn_4 | True    | commit                                                  | success                                              | schema1 |

# stop, start writeHost
    Given stop mysql in host "mysql-master2"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.6:3306[]] setError
    """
    Given start mysql in host "mysql-master2"
    Given sleep "40" seconds
    Then execute sql in "mysql-master2"
    | conn   | toClose | sql                                                                       | expect                                |
    | conn_5 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.6:3306[]] setOK
    """

# stop, start readHost
    Given stop mysql in host "mysql-slave1"
    Given sleep "40" seconds
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.2:3306[]] setError
    """
    Given start mysql in host "mysql-slave1"
    Given sleep "40" seconds
    Then execute sql in "mysql-slave1"
    | conn   | toClose | sql                                                                       | expect                                |
    | conn_6 | True    | select @@lower_case_table_names,@@autocommit, @@tx_isolation, @@read_only | has{((0, 0, 'READ-UNCOMMITTED', 0),)} |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    heartbeat to [[]172.100.9.2:3306[]] setOK
    """