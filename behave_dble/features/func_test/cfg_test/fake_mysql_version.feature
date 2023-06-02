# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/15

# for DBLE0REQ-189 and DBLE0REQ-2051
Feature: test fakeMySQLVersion

  @restore_mysql_service
  Scenario: shardingUser - check fakeMySQLVersion #1
  """
    {'restore_mysql_service':{'mysql-slave1':{'start_mysql':1}}}
  """

# case 1: fakeMySQLVersion is 5.7.19, backend mysql version is 5.7.25 / 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.19
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="10000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    # check restart dble
    Then restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.5 port = 3306
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3306
     """

    # check dryrun
    Given record current dble log line number in "log_line_num1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="10000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then execute admin cmd "dryrun"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.5 port = 3306
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3306
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.4 port = 3306
     """

    # check reload
    Given record current dble log line number in "log_line_num2"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.4 port = 3306
     """

    # check add db_instance
    Given record current dble log line number in "log_line_num3"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                         | expect  | db               |
      | conn_0 | True    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostS2','ha_group2','172.100.9.6',3307,'test','111111','false','false',1,99)  | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num3" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    # check heartbeat from error to ok
    Given stop mysql in host "mysql-slave1"
    Then restart dble in "dble-1" success
    Given record current dble log line number in "log_line_num4"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostS2', '172.100.9.6', 3307, 'error'} | dble_information | 5,2     |
    Given start mysql in host "mysql-slave1"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                      | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostS2', '172.100.9.6', 3307, 'ok'} | dble_information | 5,2     |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num4" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                      | expect           | db      | timeout |
    | conn_1 | False   | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |
    | conn_1 | False   | create table sharding_2_t1(id int, name varchar(10))                     | success          | schema1 |         |
    | conn_1 | False   | create table test(id int, code int)                                      | success          | schema1 |         |
    | conn_1 | False   | insert into sharding_2_t1 values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')      | success          | schema1 |         |
    | conn_1 | False   | insert into test(id, code) values(1, 1),(2, 3),(3, 3),(4, 2)             | success          | schema1 |         |
    | conn_1 | False   | select * from sharding_2_t1                                              | length{(4)}      | schema1 | 20      |
    | conn_1 | False   | update sharding_2_t1 set name='aa' where id=1                            | success          | schema1 |         |
    | conn_1 | False   | /*!dble:db_type=master*/select * from sharding_2_t1 where id=1           | has{((1,'aa'),)} | schema1 | 20      |
    | conn_1 | False   | /*#dble:db_type=slave*/select * from sharding_2_t1 where id=1            | has{((1,'aa'),)} | schema1 | 20      |
    | conn_1 | False   | begin                                                                    | success          | schema1 |         |
    | conn_1 | False   | update test set code=10 where id=1                                       | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 20      |
    | conn_1 | False   | commit                                                                   | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 20      |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a,test b where a.id=b.id         | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 20  |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a join test b on a.id=b.id       | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 20  |
    | conn_1 | False   | delete from sharding_2_t1; delete from test                              | success          | schema1 |         |
    | conn_1 | False   | select count(0) from sharding_2_t1                                       | success          | schema1 |         |
    | conn_1 | False   | select count(0) from test                                                | success          | schema1 |         |
    | conn_1 | True    | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |

# case 2: fakeMySQLVersion is 5.7.20, backend mysql version is 5.7.25 / 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.20
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                      | expect           | db      | timeout |
    | conn_1 | False   | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |
    | conn_1 | False   | create table sharding_2_t1(id int, name varchar(10))                     | success          | schema1 |         |
    | conn_1 | False   | create table test(id int, code int)                                      | success          | schema1 |         |
    | conn_1 | False   | insert into sharding_2_t1 values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')      | success          | schema1 |         |
    | conn_1 | False   | insert into test(id, code) values(1, 1),(2, 3),(3, 3),(4, 2)             | success          | schema1 |         |
    | conn_1 | False   | select * from sharding_2_t1                                              | length{(4)}      | schema1 | 5       |
    | conn_1 | False   | update sharding_2_t1 set name='aa' where id=1                            | success          | schema1 |         |
    | conn_1 | False   | /*!dble:db_type=master*/select * from sharding_2_t1 where id=1           | has{((1,'aa'),)} | schema1 | 5       |
    | conn_1 | False   | /*#dble:db_type=slave*/select * from sharding_2_t1 where id=1            | has{((1,'aa'),)} | schema1 | 5       |
    | conn_1 | False   | begin                                                                    | success          | schema1 |         |
    | conn_1 | False   | update test set code=10 where id=1                                       | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 5       |
    | conn_1 | False   | commit                                                                   | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 5       |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a,test b where a.id=b.id         | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 5   |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a join test b on a.id=b.id       | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 5   |
    | conn_1 | False   | delete from sharding_2_t1; delete from test                              | success          | schema1 |         |
    | conn_1 | False   | select count(0) from sharding_2_t1                                       | success          | schema1 |         |
    | conn_1 | False   | select count(0) from test                                                | success          | schema1 |         |
    | conn_1 | True    | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |

  @use.with_mysql_version=5.7
  Scenario: shardingUser - check fakeMySQLVersion backend use mysql 5.7 #2
    # case 1: fakeMySQLVersion is 8.0.0, backend mysql version is 5.7.25, dble restart fail
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.2
    """
    Then restart dble in "dble-1" failed for
    """
    this dbInstance\[=172.100.9.5:3306\]'s version\[=5.7.25-log\] cannot be lower than the dble version\[=8.0.2\],pls check the backend MYSQL node.
    """

    # case 2: fakeMySQLVersion is 8.0.3, backend mysql version is 5.7.25, dble restart fail
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.3
    """
    Then restart dble in "dble-1" failed for
    """
    this dbInstance\[=172.100.9.5:3306\]'s version\[=5.7.25-log\] cannot be lower than the dble version\[=8.0.3\],pls check the backend MYSQL node.
    """

  @use.with_mysql_version=8.0
  Scenario: shardingUser - check fakeMySQLVersion backend use mysql 8.0 #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="10000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """

    # case 1: fakeMySQLVersion is 8.0.0, backend mysql version is 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.2
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                      | expect           | db      | timeout |
    | conn_1 | False   | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |
    | conn_1 | False   | create table sharding_2_t1(id int, name varchar(10))                     | success          | schema1 |         |
    | conn_1 | False   | create table test(id int, code int)                                      | success          | schema1 |         |
    | conn_1 | False   | insert into sharding_2_t1 values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')      | success          | schema1 |         |
    | conn_1 | False   | insert into test(id, code) values(1, 1),(2, 3),(3, 3),(4, 2)             | success          | schema1 |         |
    | conn_1 | False   | select * from sharding_2_t1                                              | length{(4)}      | schema1 | 5       |
    | conn_1 | False   | update sharding_2_t1 set name='aa' where id=1                            | success          | schema1 |         |
    | conn_1 | False   | /*!dble:db_type=master*/select * from sharding_2_t1 where id=1           | has{((1,'aa'),)} | schema1 | 5       |
    | conn_1 | False   | /*#dble:db_type=slave*/select * from sharding_2_t1 where id=1            | has{((1,'aa'),)} | schema1 | 5       |
    | conn_1 | False   | begin                                                                    | success          | schema1 |         |
    | conn_1 | False   | update test set code=10 where id=1                                       | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 5       |
    | conn_1 | False   | commit                                                                   | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 5       |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a,test b where a.id=b.id         | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 5   |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a join test b on a.id=b.id       | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 5   |
    | conn_1 | False   | delete from sharding_2_t1; delete from test                              | success          | schema1 |         |
    | conn_1 | False   | select count(0) from sharding_2_t1                                       | success          | schema1 |         |
    | conn_1 | False   | select count(0) from test                                                | success          | schema1 |         |
    | conn_1 | True    | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |

    # case 2: fakeMySQLVersion is 8.0.3, backend mysql version is 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.3
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                                                                      | expect           | db      | timeout |
    | conn_1 | False   | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |
    | conn_1 | False   | create table sharding_2_t1(id int, name varchar(10))                     | success          | schema1 |         |
    | conn_1 | False   | create table test(id int, code int)                                      | success          | schema1 |         |
    | conn_1 | False   | insert into sharding_2_t1 values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')      | success          | schema1 |         |
    | conn_1 | False   | insert into test(id, code) values(1, 1),(2, 3),(3, 3),(4, 2)             | success          | schema1 |         |
    | conn_1 | False   | select * from sharding_2_t1                                              | length{(4)}      | schema1 | 5       |
    | conn_1 | False   | update sharding_2_t1 set name='aa' where id=1                            | success          | schema1 |         |
    | conn_1 | False   | /*!dble:db_type=master*/select * from sharding_2_t1 where id=1           | has{((1,'aa'),)} | schema1 | 5       |
    | conn_1 | False   | /*#dble:db_type=slave*/select * from sharding_2_t1 where id=1            | has{((1,'aa'),)} | schema1 | 5       |
    | conn_1 | False   | begin                                                                    | success          | schema1 |         |
    | conn_1 | False   | update test set code=10 where id=1                                       | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 5       |
    | conn_1 | False   | commit                                                                   | success          | schema1 |         |
    | conn_1 | False   | select * from test where id=1                                            | has{((1,10),)}   | schema1 | 5       |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a,test b where a.id=b.id         | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 5   |
    | conn_1 | False   | select a.name,b.code from sharding_2_t1 a join test b on a.id=b.id       | has{(('aa',10),('b',3),('c',3),('d',2))} | schema1 | 5   |
    | conn_1 | False   | delete from sharding_2_t1; delete from test                              | success          | schema1 |         |
    | conn_1 | False   | select count(0) from sharding_2_t1                                       | success          | schema1 |         |
    | conn_1 | False   | select count(0) from test                                                | success          | schema1 |         |
    | conn_1 | True    | drop table if exists sharding_2_t1; drop table if exists test            | success          | schema1 |         |

  @use.with_mysql_version=5.7
  @restore_mysql_service
  Scenario: rwSplitUser - check fakeMySQLVersion backend use mysql 5.7 #4
    """
    {'restore_mysql_service':{'mysql-slave1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
    """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |

    # case 1: fakeMySQLVersion is 5.7.19, backend mysql version is 5.7.25
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.19
    """
    Then restart dble in "dble-1" success

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """

    # check dryrun
    Then execute admin cmd "dryrun" get the following output
    """
    hasStr{check dble and mysql version exception: the dble version[=5.7.19] and MYSQL[172.100.9.6:3306] version[=5.7.25-log] not match, Please check the version.}
    """

    # check reload @@config_all
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure, The reason is the dble version[=5.7.19] and MYSQL[172.100.9.6:3306] version[=5.7.25-log] not match, Please check the version.
    """

    # check insert rwSplitUser
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                     | expect  | db               |
      | conn_0 | true    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rwS2','111111','false','100','ha_group2') | Insert failure.The reason is the dble version[=5.7.19] and MYSQL[172.100.9.6:3306] version[=5.7.25-log] not match, Please check the version. | dble_information |

    # check heartbeat from error to ok
    Given stop mysql in host "mysql-master2"
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_1 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'error'} | dble_information | 5,2     |
    Given start mysql in host "mysql-master2"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_1 | true     | show @@heartbeat | hasStr{the dble version[=5.7.19] and MYSQL[172.100.9.6:3306] version[=5.7.25-log] not match, Please check the version.} | dble_information | 5,2     |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     the dble version\[=5.7.19\] and MYSQL\[172.100.9.6:3306\] version\[=5.7.25-log\] not match, Please check the version., set heartbeat Error
     """

    # check restart
    Then restart dble in "dble-1" failed for
    """
    the dble version\[=5.7.19\] and MYSQL\[172.100.9.6:3306\] version\[=5.7.25-log\] not match, Please check the version.
    """

    # case 2: fakeMySQLVersion is 5.7.20, backend mysql version is 5.7.25
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.20
    """

    # check restart dble
    Then restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3306
     """

    # check dryrun
    Given record current dble log line number in "log_line_num1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
        <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="10000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Then execute admin cmd "dryrun"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3306
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    # check reload
    Given record current dble log line number in "log_line_num2"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    # check add db_instance
    Given record current dble log line number in "log_line_num3"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                         | expect  | db               |
      | conn_0 | True    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostS2','ha_group2','172.100.9.6',3308,'test','111111','false','false',1,99)  | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num3" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3308
     """

    # check heartbeat from error to ok
    Given stop mysql in host "mysql-slave1"
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostS1', '172.100.9.6', 3307, 'error'} | dble_information | 5,2     |
    Given start mysql in host "mysql-slave1"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_0 | true     | show @@heartbeat | hasStr{'hostS1', '172.100.9.6', 3307, 'ok'}    | dble_information | 5,2     |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    Given execute sql in "dble-1" in "user" mode
    | user | passwd | conn   | toClose | sql                                                                      | expect           | db  | timeout |
    | rwS1 | 111111 | conn_0 | False   | drop table if exists table_01;drop table if exists table_02              | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | create table table_01(id int, name varchar(10))                          | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | create table table_02(id int, code int)                                  | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | insert into table_01 values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')           | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | insert into table_02(id, code) values(1, 1),(2, 3),(3, 3),(4, 2)         | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select * from table_01                                                   | length{(4)}      | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | update table_01 set name='aa' where id=1                                 | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | /*!dble:db_type=master*/select * from table_01 where id=1                | has{((1,'aa'),)} | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | /*#dble:db_type=slave*/select * from table_01 where id=1                 | has{((1,'aa'),)} | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | begin                                                                    | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | update table_02 set code=10 where id=1                                   | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select * from table_02 where id=1                                        | has{((1,10),)}   | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | commit                                                                   | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select * from table_02 where id=1                                        | has{((1,10),)}   | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | select a.name,b.code from table_01 a,table_02 b where a.id=b.id          | has{(('aa',10),('b',3),('c',3),('d',2))} | db1 | 5   |
    | rwS1 | 111111 | conn_0 | False   | select a.name,b.code from table_01 a join table_02 b on a.id=b.id        | has{(('aa',10),('b',3),('c',3),('d',2))} | db1 | 5   |
    | rwS1 | 111111 | conn_0 | False   | delete from table_01;delete from table_02                                | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select count(0) from db1.table_01;select count(0) from db1.table_02      | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | True    | drop table if exists table_01;drop table if exists table_02              | success          | db1 |         |

    # case 3: fakeMySQLVersion is 8.0.2, backend mysql version is 5.7.25
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.2
    """
    Then restart dble in "dble-1" failed for
    """
    the dble version\[=8.0.2\] and MYSQL\[172.100.9.6:3306\] version\[=5.7.25-log\] not match, Please check the version.
    """

    # case 4: fakeMySQLVersion is 8.0.3, backend mysql version is 5.7.25, remove select @@query_cache_size, @@query_cache_type
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.3
    """
    Then restart dble in "dble-1" failed for
    """
    the dble version\[=8.0.3\] and MYSQL\[172.100.9.6:3306\] version\[=5.7.25-log\] not match, Please check the version.
    """


  @use.with_mysql_version=8.0
  @restore_mysql_service
  Scenario: rwSplitUser - check fakeMySQLVersion backend use mysql 8.0 #5
  """
  {'restore_mysql_service':{'mysql-slave1':{'start_mysql':1},'mysql-master2':{'start_mysql':1}}}
  """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
      | user.xml     | {'tag':'root'} | {'tag':'shardingUser'} |

    # case 1: fakeMySQLVersion is 8.0.2, backend mysql version is 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.2
    """
    Then restart dble in "dble-1" success

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group2" />
    """

    # check dryrun
    Then execute admin cmd "dryrun" get the following output
    """
    hasStr{check dble and mysql version exception: the dble version[=8.0.2] and MYSQL[172.100.9.6:3306] version[=8.0.18] not match, Please check the version.}
    """

    # check reload @@config_all
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure, The reason is the dble version[=8.0.2] and MYSQL[172.100.9.6:3306] version[=8.0.18] not match, Please check the version.
    """

    # check insert rwSplitUser
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                     | expect  | db               |
      | conn_0 | true    | insert into dble_rw_split_entry(username,password_encrypt,encrypt_configured,max_conn_count,db_group) value ('rwS2','111111','false','100','ha_group2') | Insert failure.The reason is the dble version[=8.0.2] and MYSQL[172.100.9.6:3306] version[=8.0.18] not match, Please check the version. | dble_information |

    # check heartbeat from error to ok
    Given stop mysql in host "mysql-master2"
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_1 | false    | show @@heartbeat | hasStr{'hostM2', '172.100.9.6', 3306, 'error'} | dble_information | 5,2     |
    Given start mysql in host "mysql-master2"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_1 | true     | show @@heartbeat | hasStr{the dble version[=8.0.2] and MYSQL[172.100.9.6:3306] version[=8.0.18] not match, Please check the version.} | dble_information | 5,2     |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     the dble version\[=8.0.2\] and MYSQL\[172.100.9.6:3306\] version\[=8.0.18\] not match, Please check the version., set heartbeat Error
     """

    # check restart
    Then restart dble in "dble-1" failed for
    """
    the dble version\[=8.0.2\] and MYSQL\[172.100.9.6:3306\] version\[=8.0.18\] not match, Please check the version.
    """

    # case 2: fakeMySQLVersion is 8.0.3, backend mysql version is 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.3
    """

    # check restart dble
    Then restart dble in "dble-1" success
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3306
     """

    # check dryrun
    Given record current dble log line number in "log_line_num1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
        <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="10000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.6:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Then execute admin cmd "dryrun"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num1" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3306
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    # check reload
    Given record current dble log line number in "log_line_num2"
    Then execute admin cmd "reload @@config_all"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num2" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    # check add db_instance
    Given record current dble log line number in "log_line_num3"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                                                                                                                         | expect  | db               |
      | conn_0 | True    | insert into dble_db_instance (name,db_group,addr,port,user,password_encrypt,encrypt_configured,primary,min_conn_count,max_conn_count) value ('hostS2','ha_group2','172.100.9.6',3308,'test','111111','false','false',1,99)  | success | dble_information |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_line_num3" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3308
     """

    # check heartbeat from error to ok
    Given stop mysql in host "mysql-slave1"
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_0 | false    | show @@heartbeat | hasStr{'hostS1', '172.100.9.6', 3307, 'error'} | dble_information | 5,2     |
    Given start mysql in host "mysql-slave1"
    Given execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect                                         | db               | timeout |
      | conn_0 | true     | show @@heartbeat | hasStr{'hostS1', '172.100.9.6', 3307, 'ok'}    | dble_information | 5,2     |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1" retry "5" times
     """
     select @@lower_case_table_names,@@autocommit,@@read_only,@@max_allowed_packet,@@transaction_isolation,@@version,@@back_log.* host = 172.100.9.6 port = 3307
     """

    Given execute sql in "dble-1" in "user" mode
    | user | passwd | conn   | toClose | sql                                                                      | expect           | db  | timeout |
    | rwS1 | 111111 | conn_0 | False   | drop table if exists table_01;drop table if exists table_02              | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | create table table_01(id int, name varchar(10))                          | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | create table table_02(id int, code int)                                  | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | insert into table_01 values(1, 'a'),(2, 'b'),(3, 'c'),(4, 'd')           | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | insert into table_02(id, code) values(1, 1),(2, 3),(3, 3),(4, 2)         | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select * from table_01                                                   | length{(4)}      | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | update table_01 set name='aa' where id=1                                 | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | /*!dble:db_type=master*/select * from table_01 where id=1                | has{((1,'aa'),)} | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | /*#dble:db_type=slave*/select * from table_01 where id=1                 | has{((1,'aa'),)} | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | begin                                                                    | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | update table_02 set code=10 where id=1                                   | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select * from table_02 where id=1                                        | has{((1,10),)}   | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | commit                                                                   | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select * from table_02 where id=1                                        | has{((1,10),)}   | db1 | 5       |
    | rwS1 | 111111 | conn_0 | False   | select a.name,b.code from table_01 a,table_02 b where a.id=b.id          | has{(('aa',10),('b',3),('c',3),('d',2))} | db1 | 5   |
    | rwS1 | 111111 | conn_0 | False   | select a.name,b.code from table_01 a join table_02 b on a.id=b.id        | has{(('aa',10),('b',3),('c',3),('d',2))} | db1 | 5   |
    | rwS1 | 111111 | conn_0 | False   | delete from table_01;delete from table_02                                | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | False   | select count(0) from db1.table_01;select count(0) from db1.table_02      | success          | db1 |         |
    | rwS1 | 111111 | conn_0 | True    | drop table if exists table_01;drop table if exists table_02              | success          | db1 |         |

    # case 3: fakeMySQLVersion is 5.7.19, backend mysql version is 8.0.18
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.19
    """
    Then restart dble in "dble-1" failed for
    """
    the dble version\[=5.7.19\] and MYSQL\[172.100.9.6:3306\] version\[=8.0.18\] not match, Please check the version.
    """

    # case 4: fakeMySQLVersion is 5.7.20, backend mysql version is 8.0.18, remove select @@query_cache_size, @@query_cache_type
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=5.7.20
    """
    Then restart dble in "dble-1" failed for
    """
    the dble version\[=5.7.20\] and MYSQL\[172.100.9.6:3306\] version\[=8.0.18\] not match, Please check the version.
    """