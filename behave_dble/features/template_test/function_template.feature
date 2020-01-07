# -*- coding=utf-8 -*-
# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/7

Feature: use template to generate configuration file, check function is normal

  @skip_restart
  Scenario:
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
    Given change file "schema.xml" in "dble-1" locate "install_dir" with sed cmds
    """
    s/name="testdb"/name="schema1"/
    /tb_hash_sharding_er3/d
    s/ip[1-3]:3306/172.100.9.5:3306/
    s/ip[4-5]:3306/172.100.9.6:3306/
    s/your_user/test/
    s/your_psw/111111/
    """
    Given change file "server.xml" in "dble-1" locate "install_dir" with sed cmds
    """
    s/user name="root"/user name="test"/
    s/user name="man1"/user name="root"/
    s/password">[0-9]\{6\}/password">111111/g
    s/>testdb/>schema1/g
    """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | user | passwd | conn   | toClose | sql                                          | expect  | db |
      | root | 111111 | conn_0 | True    | create database @@dataNode='dn1,dn2,dn3,dn4' | success |    |
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                 | expect  | db     |
      | test | 111111 | conn_0 | True    | drop table if exists tb_hash_string | success | schema1 |
      | test | 111111 | conn_0 | True    | drop table if exists tb_global2     | success | schema1 |
      | test | 111111 | conn_0 | True    | create table tb_hash_string(id int) | success | schema1 |
      | test | 111111 | conn_0 | True    | create table tb_global2(id int)     | success | schema1 |
    Then get resultset of user cmd "show all tables" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | Tables_in_TESTDB-0 | Table_type-1   |
      | tb_global2         | GLOBAL TABLE   |
      | tb_hash_string     | SHARDING TABLE |
