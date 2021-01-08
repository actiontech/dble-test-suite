# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/21

# for DBLE0REQ-189
Feature: check mysql 8.0 authentication plugin

  @restore_mysql_service
  Scenario: check mysql 8.0 default authentication plugin #1
  """
    {'restore_mysql_service':{'mysql8-master1':{'start_mysql':1}}}
  """

# create use test1 use mysql 8.0 default authentication plugin
    Given update file content "/etc/my.cnf" in "mysql8-master1" with sed cmds
    """
    /default_authentication_plugin/d
    """
    Given restart mysql in "mysql8-master1"

    Then execute sql in "mysql8-master1"
    | user | passwd | conn   | toClose | sql                                                   | expect                                                            | db    |
    | test | 111111 | conn_0 | False   | show variables like '%default_authentication_plugin%' | has{(('default_authentication_plugin','caching_sha2_password'),)} | mysql |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test1`@`%`                       | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | CREATE USER `test1`@`%` IDENTIFIED BY '111111'        | success                                                           | mysql |
    | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test1`@`%` WITH GRANT OPTION     | success                                                           | mysql |
    | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                                                           | mysql |
    | test | 111111 | conn_0 | True    | SELECT user,host,plugin from user where user='test1'  | has{(('test1', '%', 'caching_sha2_password'),)}                   | mysql |

# connect dble use caching_sha2_password user
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test1" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a\-DfakeMySQLVersion=8.0.21
    """
    Then restart dble in "dble-1" success

    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_1 | False   | drop table if exists test | success | schema1 |
    | conn_1 | False   | create table test(id int) | success | schema1 |
    | conn_1 | True    | drop table if exists test | success | schema1 |

    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_2 | False   | drop table if exists test | success | schema1 |
    | conn_2 | False   | create table test(id int) | success | schema1 |
    | conn_2 | True    | drop table if exists test | success | schema1 |

# reset mysql 8.0 default_authentication_plugin to default
    Given update file content "/etc/my.cnf" in "mysql8-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql8-master1"

  @restore_mysql_service
  Scenario: check mysql 8.0 mysql_native_password authentication plugin #2
  """
    {'restore_mysql_service':{'mysql8-master1':{'start_mysql':1}}}
  """
# update mysql 8.0 default_authentication_plugin=mysql_native_password
    Given update file content "/etc/my.cnf" in "mysql8-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql8-master1"

    Then execute sql in "mysql8-master1"
    | user | passwd | conn   | toClose | sql                                                   | expect                                                             | db    |
    | test | 111111 | conn_0 | False   | show variables like '%default_authentication_plugin%' | has{(('default_authentication_plugin', 'mysql_native_password'),)} | mysql |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test2`@`%`                       | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | CREATE USER `test2`@`%` IDENTIFIED BY '111111'        | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test2`@`%` WITH GRANT OPTION     | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                                                            | mysql |
    | test | 111111 | conn_0 | True    | SELECT user,host,plugin from user where user='test2'  | has{(('test2', '%', 'mysql_native_password'),)}                    | mysql |

    Given delete the following xml segment
    | file         | parent         | child                  |
    | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test2" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
    """

    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_1 | False   | drop table if exists test | success | schema1 |
    | conn_1 | False   | create table test(id int) | success | schema1 |
    | conn_1 | True    | drop table if exists test | success | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test1" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_2 | False   | drop table if exists test | success | schema1 |
    | conn_2 | False   | create table test(id int) | success | schema1 |
    | conn_2 | True    | drop table if exists test | success | schema1 |

# dble only has mysql5.7 backend
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_3 | False   | drop table if exists test | success | schema1 |
    | conn_3 | False   | create table test(id int) | success | schema1 |
    | conn_3 | True    | drop table if exists test | success | schema1 |

# dble have mysql5.7 and mysql8.0 backend
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.9:3306" user="test1" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
    """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_4 | False   | drop table if exists test | success | schema1 |
    | conn_4 | False   | create table test(id int) | success | schema1 |
    | conn_4 | True    | drop table if exists test | success | schema1 |

    Then execute sql in "mysql8-master1"
    | user | passwd | conn   | toClose | sql                             | expect |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS 'test1'@'%' | success |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS 'test2'@'%' | success |

  # reset mysql 8.0 default_authentication_plugin to default
    Given update file content "/etc/my.cnf" in "mysql8-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql8-master1"

  @restore_mysql_service
  Scenario: check mysql 8.0 sha256_password Authentication Plugin #3
  """
    {'restore_mysql_service':{'mysql8-master1':{'start_mysql':1}}}
  """
# update mysql 8.0 default_authentication_plugin=sha256_password
    Given update file content "/etc/my.cnf" in "mysql8-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = sha256_password
    """
    Given restart mysql in "mysql8-master1"

    Then execute sql in "mysql8-master1"
    | user | passwd | conn   | toClose | sql                                                   | expect                                                       | db    |
    | test | 111111 | conn_0 | False   | show variables like '%default_authentication_plugin%' | has{(('default_authentication_plugin', 'sha256_password'),)} | mysql |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test3`@`%`                       | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | CREATE USER `test3`@`%` IDENTIFIED BY '111111'        | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test3`@`%` WITH GRANT OPTION     | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | SELECT user,host,plugin from user where user='test3'  | has{(('test3', '%', 'sha256_password'),)}                    | mysql |

    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.9:3306" user="test3" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group1" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
    """
    Then restart dble in "dble-1" failed for
    """
    Can't get variables from shardingNode
    """

    Then execute sql in "mysql8-master1"
    | user | passwd | conn   | toClose | sql                             | expect  |
    | test | 111111 | conn_0 | True    | DROP USER IF EXISTS 'test3'@'%' | success |

# dble have mysql5.7 and mysql8.0 backend, mysql8.0 connect user is test1
    Given delete the following xml segment
      | file         | parent         | child                  |
      | db.xml       | {'tag':'root'} | {'tag':'dbGroup'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.9:3306" user="test1" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db4" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db5" name="dn5" />
    """
    Then restart dble in "dble-1" success

    Given execute linux command in "dble-1" and contains exception "ha_group2.hostM2 - Connection is not available"
    """
    mysql -P{node:client_port} -u{node:client_user} -e "drop table if exists schema1.test"
    """

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    support the password plugin sha256_password,please check the default auth Plugin
    """

# reset mysql 8.0 default_authentication_plugin to default
    Given update file content "/etc/my.cnf" in "mysql8-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql8-master1"

