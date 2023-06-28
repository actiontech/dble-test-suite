# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/21

# for DBLE0REQ-189
@use.with_mysql_version=8.0
Feature: check mysql 8.0 authentication plugin

  @restore_mysql_config
  Scenario: check mysql 8.0 default authentication plugin #1
  """
    {'restore_mysql_config':{'mysql-master1':{'default_authentication_plugin':'mysql_native_password'}}}
  """

   # create user test1 use mysql 8.0 default authentication plugin
    Given update config of mysql "8.0.18" in "single" type in "mysql-master1" with sed cmds
    """
    /default_authentication_plugin/d
    """
    Given restart mysql in "mysql-master1"

    Then execute sql in "mysql-master1"
    | user | passwd | conn   | toClose | sql                                                   | expect                                                            | db    |
    | test | 111111 | conn_0 | False   | show variables like '%default_authentication_plugin%' | has{(('default_authentication_plugin','caching_sha2_password'),)} | mysql |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test1`@`%`                       | success                                                           | mysql |
    | test | 111111 | conn_0 | False   | CREATE USER `test1`@`%` IDENTIFIED BY '111111'        | success                                                           | mysql |
    | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test1`@`%` WITH GRANT OPTION     | success                                                           | mysql |
    | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                                                           | mysql |
    | test | 111111 | conn_0 | True    | SELECT user,host,plugin from user where user='test1'  | has{(('test1', '%', 'caching_sha2_password'),)}                   | mysql |

# connect dble use caching_sha2_password user
    Given delete the following xml segment
      | file         | parent         | child                   |
      | schema.xml   | {'tag':'root'} | {'tag':'dataNode'}      |
      | schema.xml   | {'tag':'root'} | {'tag':'dataHost'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn2" />
    <dataNode dataHost="ha_group1" database="db3" name="dn3" />
    <dataNode dataHost="ha_group1" database="db4" name="dn4" />
    <dataNode dataHost="ha_group1" database="db5" name="dn5" />

    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test1">
      </writeHost>
    </dataHost>
    """
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="fakeMySQLVersion">8.0.21</property>
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
    Given update config of mysql "8.0.18" in "single" type in "mysql-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql-master1"

  @restore_mysql_config
  Scenario: check mysql 8.0 mysql_native_password authentication plugin #2
  """
    {'restore_mysql_config':{'mysql-master1':{'default_authentication_plugin':'mysql_native_password'}}}
  """
# update mysql 8.0 default_authentication_plugin=mysql_native_password
    Given update config of mysql "8.0.18" in "single" type in "mysql-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql-master1"

    Then execute sql in "mysql-master1"
    | user | passwd | conn   | toClose | sql                                                   | expect                                                             | db    |
    | test | 111111 | conn_0 | False   | show variables like '%default_authentication_plugin%' | has{(('default_authentication_plugin', 'mysql_native_password'),)} | mysql |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test2`@`%`                       | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | CREATE USER `test2`@`%` IDENTIFIED BY '111111'        | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test2`@`%` WITH GRANT OPTION     | success                                                            | mysql |
    | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                                                            | mysql |
    | test | 111111 | conn_0 | True    | SELECT user,host,plugin from user where user='test2'  | has{(('test2', '%', 'mysql_native_password'),)}                    | mysql |

    Given delete the following xml segment
      | file         | parent         | child                   |
      | schema.xml   | {'tag':'root'} | {'tag':'dataNode'}      |
      | schema.xml   | {'tag':'root'} | {'tag':'dataHost'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn2" />
    <dataNode dataHost="ha_group1" database="db3" name="dn3" />
    <dataNode dataHost="ha_group1" database="db4" name="dn4" />
    <dataNode dataHost="ha_group1" database="db5" name="dn5" />

    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test2">
      </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_1 | False   | drop table if exists test | success | schema1 |
    | conn_1 | False   | create table test(id int) | success | schema1 |
    | conn_1 | True    | drop table if exists test | success | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test1">
      </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
    | conn   | toClose | sql                       | expect  | db      |
    | conn_2 | False   | drop table if exists test | success | schema1 |
    | conn_2 | False   | create table test(id int) | success | schema1 |
    | conn_2 | True    | drop table if exists test | success | schema1 |

    Then execute sql in "mysql-master1"
    | user | passwd | conn   | toClose | sql                             | expect |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS 'test1'@'%' | success |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS 'test2'@'%' | success |

  # reset mysql 8.0 default_authentication_plugin to default
    Given update config of mysql "8.0.18" in "single" type in "mysql-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = mysql_native_password
    """
    Given restart mysql in "mysql-master1"

  @restore_mysql_config
  Scenario: check mysql 8.0 sha256_password Authentication Plugin #3
  """
    {'restore_mysql_config':{'mysql-master1':{'default_authentication_plugin':'mysql_native_password'}}}
  """
# update mysql 8.0 default_authentication_plugin=sha256_password
    Given update config of mysql "8.0.18" in "single" type in "mysql-master1" with sed cmds
    """
    /default_authentication_plugin/d
    /server-id/a default_authentication_plugin = sha256_password
    """
    Given restart mysql in "mysql-master1"

    Then execute sql in "mysql-master1"
    | user | passwd | conn   | toClose | sql                                                   | expect                                                       | db    |
    | test | 111111 | conn_0 | False   | show variables like '%default_authentication_plugin%' | has{(('default_authentication_plugin', 'sha256_password'),)} | mysql |
    | test | 111111 | conn_0 | False   | DROP USER IF EXISTS `test3`@`%`                       | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | CREATE USER `test3`@`%` IDENTIFIED BY '111111'        | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | GRANT ALL ON *.* TO `test3`@`%` WITH GRANT OPTION     | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | FLUSH PRIVILEGES                                      | success                                                      | mysql |
    | test | 111111 | conn_0 | False   | SELECT user,host,plugin from user where user='test3'  | has{(('test3', '%', 'sha256_password'),)}                    | mysql |

    Given delete the following xml segment
      | file         | parent         | child                   |
      | schema.xml   | {'tag':'root'} | {'tag':'dataNode'}      |
      | schema.xml   | {'tag':'root'} | {'tag':'dataHost'}      |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <dataNode dataHost="ha_group1" database="db1" name="dn1" />
    <dataNode dataHost="ha_group1" database="db2" name="dn2" />
    <dataNode dataHost="ha_group1" database="db3" name="dn3" />
    <dataNode dataHost="ha_group1" database="db4" name="dn4" />
    <dataNode dataHost="ha_group1" database="db5" name="dn5" />

    <dataHost balance="0" maxCon="1000" minCon="10" name="ha_group1" slaveThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <writeHost host="hostM1" password="111111" url="172.100.9.5:3306" user="test3">
      </writeHost>
    </dataHost>
    """
    Then restart dble in "dble-1" failed for
    """
    Can't get variables from all dbGroups
    """

    Then execute sql in "mysql-master1"
    | user | passwd | conn   | toClose | sql                             | expect  |
    | test | 111111 | conn_0 | True    | DROP USER IF EXISTS 'test3'@'%' | success |