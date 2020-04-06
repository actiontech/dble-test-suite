# -*- coding=utf-8 -*-
# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/7
# 2.19.11.0#dble-7843
Feature: use template to generate configuration file, check function is normal

  Scenario: overwrite dble configuration by configuration templates
      #1.overwrite configuration by template, and modifying mysql node ip, dble can start normally
      #2.create databases by admin commands "create database"
      #3.create different types of tables successfully
      #4.table type is displayed correctly
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/schema_template.xml /opt/dble/conf/schema.xml
    """
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/rule_template.xml /opt/dble/conf/rule.xml
    """
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/server_template.xml /opt/dble/conf/server.xml
    """
    Given update file content "{install_dir}/dble/conf/schema.xml" in "dble-1" with sed cmds
    """
    s/ip1:3306/172.100.9.5:3306/
    s/ip2:3306/172.100.9.2:3306/
    s/ip4:3306/172.100.9.6:3306/
    s/ip5:3306/172.100.9.3:3306/
    s/your_user/test/
    s/your_psw/111111/
    """
    Given update file content "{install_dir}/dble/conf/server.xml" in "dble-1" with sed cmds
    """
    s/user name="root"/user name="test"/
    s/user name="man1"/user name="root"/
    s/password">[0-9]\{6\}/password">111111/g
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect  |
      | conn_0 | True    | create database @@dataNode='dn1,dn2,dn3,dn4' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect                                                                         | db     |
      | conn_0 | True    | drop table if exists tb_hash_string | success                                                                        | testdb |
      | conn_0 | True    | drop table if exists tb_global2     | success                                                                        | testdb |
      | conn_0 | True    | create table tb_hash_string(id int) | success                                                                        | testdb |
      | conn_0 | True    | create table tb_global2(id int)     | success                                                                        | testdb |
      | conn_0 | True    | show all tables                     | hasStr{(('tb_global2', 'GLOBAL TABLE'), ('tb_hash_string', 'SHARDING TABLE'))} | testdb |