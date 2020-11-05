# Copyright (C) 2016-2020 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/9/24
  Feature: change mysql's sql_mode

  @restore_mysql_config
  Scenario:  when insert sharding table without column name under the premise that sql_mode is ANSI#1
   """
   {'restore_mysql_config':{'mysql-master1':{'sql_mode':'NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES'},'mysql-master2':{'sql_mode':'NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES'}}}
   """
#case https://github.com/actiontech/dble/issues/828
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
     """
     s/sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES/sql_mode=REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI/
     """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
     """
     s/sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES/sql_mode=REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI/
     """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                              | except                                                                                                    |
      | conn_0 | true    | show variables like '%sql_mode%' | has{('sql_mode','REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,ONLY_FULL_GROUP_BY,ANSI')}        |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect       | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1                       | success      | schema1 |
      | conn_1 | False   | create table sharding_4_t1(id int, name char)            | success      | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (5,5)                   | success      | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1                       | success      | schema1 |

