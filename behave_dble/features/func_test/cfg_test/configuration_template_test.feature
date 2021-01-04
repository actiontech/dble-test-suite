# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
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
    \cp -f /opt/dble/conf/bootstrap_template.cnf /opt/dble/conf/bootstrap.cnf
    """
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/cluster_template.cnf /opt/dble/conf/cluster.cnf
    """
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/user_template.xml /opt/dble/conf/user.xml
    """
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/sharding_template.xml /opt/dble/conf/sharding.xml
    """
    Given execute oscmd in "dble-1"
    """
    \cp -f /opt/dble/conf/db_template.xml /opt/dble/conf/db.xml
    """
    Given update file content "{install_dir}/dble/conf/db.xml" in "dble-1" with sed cmds
    """
    s/ip1:3306/172.100.9.5:3306/
    s/ip2:3306/172.100.9.6:3306/
    s/ip3:3306/172.100.9.2:3306/
    s/ip4:3306/172.100.9.3:3306/
    s/your_user/test/g
    s/your_psw/111111/g
    """
    Given update file content "{install_dir}/dble/conf/user.xml" in "dble-1" with sed cmds
    """
    s/shardingUser name="root"/shardingUser name="test"/
    s/managerUser name="man1"/managerUser name="root"/
    s/\<password="[0-9]\{6\}"/password="111111"/g
    """
    Then Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                          | expect  |
      | conn_0 | True    | create database @@shardingNode='dn$1-6' | success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect                                                                         | db     |
#      | conn_0 | True    | source /opt/dble/template_table.sql | success                                                                        | testdb |
      | conn_0 | True    | drop table if exists tb_hash_string | success                                                                        | testdb |
      | conn_0 | True    | drop table if exists tb_global2     | success                                                                        | testdb |
      | conn_0 | True    | create table tb_hash_string(id int) | success                                                                        | testdb |
      | conn_0 | True    | create table tb_global2(id int)     | success                                                                        | testdb |
     #for issue http://10.186.18.11/jira/browse/DBLE0REQ-328
     # | conn_0 | True    | show all tables                     | hasStr{(('tb_global2', 'GLOBAL TABLE'), ('tb_hash_string', 'SHARDING TABLE'))} | testdb |