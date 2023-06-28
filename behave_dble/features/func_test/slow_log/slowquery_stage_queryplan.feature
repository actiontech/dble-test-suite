# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2020/12/2
# DBLE0REQ-79
# 当前语句执行的各个阶段：http://10.186.18.11/confluence/pages/viewpage.action?pageId=11862867
Feature: check sql execute stage and connection query plan

  @btrace
  Scenario: check "show @@connection.sql" result add stage column #1
    Given add xml segment to node with attribute "{'tag':'system'}" in "server.xml"
    """
    <property name="processors">4</property>
    <property name="processorExecutor">4</property>
    """
    Then Restart dble in "dble-1" success
    Given execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect  | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1 | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_sql_0"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "connection_sql_0" has lines with following column values
      | user-2  | schema-3  | sql-6                                  | stage-7            |
      | root    | None      | show @@connection.sql                  | Manager connection |
      | test    | schema1   | drop table if exists sharding_4_t1     | Finished           |

# endParse(Route_Calculation)：sql解析结束，准备计算路由
# at endParse stage - ddl
     Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
     Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"
     Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
     """
     s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
     /endParse/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
     """
     Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
     Given prepare a thread execute sql "create table sharding_4_t1(id int)" with "conn_0"
     Then check btrace "BtraceSessionStage.java" output in "dble-1" with ">0" times
     """
     get into endParse
     """
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_sql_1"
       | conn   | toClose | sql                   |
       | conn_1 | False   | show @@connection.sql |
     Then check resultset "connection_sql_1" has lines with following column values
       | user-2  | schema-3  | sql-6                                  | stage-7                   |
       | root    | None      | show @@connection.sql                  | Manager connection        |
       | test    | schema1   | create table sharding_4_t1(id int)     | Route_Calculation         |
     Given stop btrace script "BtraceSessionStage.java" in "dble-1"
     Given destroy btrace threads list
     Given destroy sql threads list
     Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
     Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"

# at endParse stage - dml
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"
    Given update file content "./assets/BtraceSessionStage.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /endParse/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage.java" in "dble-1"
    Given prepare a thread execute sql "insert into sharding_4_t1 values (1),(2),(3),(4)" with "conn_0"
    Then check btrace "BtraceSessionStage.java" output in "dble-1" with ">0" times
    """
    get into endParse
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "connection_sql_1" has lines with following column values
      | user-2  | schema-3  | sql-6                                            | stage-7                   |
      | root    | None      | show @@connection.sql                            | Manager connection        |
      | test    | schema1   | insert into sharding_4_t1 values (1),(2),(3),(4) | Route_Calculation         |
    Given stop btrace script "BtraceSessionStage.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceSessionStage.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage.java.log" on "dble-1"

# setBackendResponseTime(Fetching_Result)：收到后端mysql返回的结果（指已收到一个包的返回）
# at setBackendResponseTime stage - dml
    Given delete file "/opt/dble/BtraceSessionStage1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage1.java.log" on "dble-1"
    Given update file content "./assets/BtraceSessionStage1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /setBackendResponseTime/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage1.java" in "dble-1"
    Given prepare a thread execute sql "select * from sharding_4_t1" with "conn_0"
    Then check btrace "BtraceSessionStage1.java" output in "dble-1" with ">0" times
    """
    get into setBackendResponseTime
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_sql_2"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "connection_sql_2" has lines with following column values
      | user-2  | schema-3  | sql-6                                  | stage-7            |
      | root    | None      | show @@connection.sql                  | Manager connection |
      | test    | schema1   | select * from sharding_4_t1            | Fetching_Result    |
    Given stop btrace script "BtraceSessionStage1.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceSessionStage1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage1.java.log" on "dble-1"

# at setBackendResponseTime stage - ddl
    Given delete file "/opt/dble/BtraceSessionStage1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage1.java.log" on "dble-1"
    Given update file content "./assets/BtraceSessionStage1.java" in "behave" with sed cmds
    """
    s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
    /setBackendResponseTime/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(10000L)/;/\}/!ba}
    """
    Given prepare a thread run btrace script "BtraceSessionStage1.java" in "dble-1"
    Given prepare a thread execute sql "drop table if exists sharding_4_t1" with "conn_0"
    Then check btrace "BtraceSessionStage1.java" output in "dble-1" with ">0" times
    """
    get into setBackendResponseTime
    """
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "connection_sql_2"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "connection_sql_2" has lines with following column values
      | user-2  | schema-3  | sql-6                                  | stage-7            |
      | root    | None      | show @@connection.sql                  | Manager connection |
      | test    | schema1   | drop table if exists sharding_4_t1     | Fetching_Result    |
    Given stop btrace script "BtraceSessionStage1.java" in "dble-1"
    Given destroy btrace threads list
    Given destroy sql threads list
    Given delete file "/opt/dble/BtraceSessionStage1.java" on "dble-1"
    Given delete file "/opt/dble/BtraceSessionStage1.java.log" on "dble-1"


  Scenario: check "show @@connection.sql.status where FRONT_ID=?"   ---admin #2
# case 1: use default @@slow_query_log and disable @@slow_query_log
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                        | expect                               |
      | conn_2 | False   | show @@connection.sql.status where front_id=1              | please enable @@slow_query_log first |
      | conn_2 | False   | disable @@slow_query_log                                   | success                              |
      | conn_2 | False   | show @@connection.sql.status where front_id=1              | please enable @@slow_query_log first |

# case 2: enable @@slow_query_log
# check show @@help and enable @@slow_query_log and invalid front_id
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                | expect                                                 |
      | conn_2 | False   | show @@help                                        | hasStr{show @@connection.sql.status where FRONT_ID= ?} |
      | conn_2 | False   | enable @@slow_query_log                            | success                                                |
      | conn_2 | False   | show @@connection.sql.status where front_id=-1     | The front_id -1 doesn't exist                          |
      | conn_2 | False   | show @@connection.sql.status where front_id=8888   | The front_id 8888 doesn't exist                        |
      | conn_2 | False   | show @@connection.sql.status where front_id=aaaa   | front_id must be a number                              |

# check manager front_id
    Then get index:"1" column value of "show @@connection" named as "admin_front_id"
    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "admin_front_id"
      | conn   | toClose | sql                                               | expect                                   |
      | conn_2 | False   | show @@connection.sql.status where front_id = {0} | The front_id {0} is a manager connection |

@skip
  ##coz DBLE0REQ-2188 命令的字段类型修复后
  Scenario: check "show @@connection.sql.status where FRONT_ID=?"  ---user #3
    Then execute admin cmd "enable @@slow_query_log"
      # check user front_id not execute sql
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql         | expect  |
      | conn_3 | False   | use schema1 | success |
    Then get index:"1" column value of "show @@connection" named as "user_front_id"

#    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_3"
#      | conn   | toClose | sql                                                 |
#      | conn_2 | False   | show @@connection.sql.status where front_id = {0}   |
#
#    Then check resultset "connection_sql_3" has lines with following column values
#      | OPERATION-0 | SHARDING_NODE-4 | SQL/REF-5 |
#      | Read_SQL    | -               | -         |
#      | Parse_SQL   | -               | -         |

# check front_id executed sql
# no sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect  | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                        | success | schema1 |
      | conn_3 | False   | drop table if exists test                                 | success | schema1 |
      | conn_3 | False   | drop table if exists no_sharding_t1                       | success | schema1 |
      | conn_3 | False   | create table sharding_4_t1 (id int(10),name char(10))     | success | schema1 |
      | conn_3 | False   | create table test (id int(10),name char(10))              | success | schema1 |
      | conn_3 | False   | create table no_sharding_t1 (id int(10),name char(10))    | success | schema1 |
      | conn_3 | False   | insert into no_sharding_t1 values (1,'name1'),(2,'name2') | success | schema1 |
      | conn_3 | False   | select * from no_sharding_t1                              | success | schema1 |

    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_6"
      | conn   | toClose | sql                                                 | expect      |
      | conn_2 | False   | show @@connection.sql.status where front_id = {0}   | length{(7)} |

    Then check resultset "connection_sql_6" has lines with following column values
      | OPERATION-0              | SHARDING_NODE-4 | SQL/REF-5                              |
      | Read_SQL                 | -               | -                                      |
      | Parse_SQL                | -               | -                                      |
      | Route_Calculation        | -               | -                                      |
      | Prepare_to_Push/Optimize | -               | -                                      |
      | Execute_SQL              | dn5             | SELECT * FROM no_sharding_t1 LIMIT 100 |
      | Fetch_result             | dn5             | SELECT * FROM no_sharding_t1 LIMIT 100 |
      | Write_to_Client          | -               | -                                      |

# sharding 4 table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect  | db      |
      | conn_3 | False   | select * from sharding_4_t1                              | success | schema1 |

    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_7"
      | conn   | toClose | sql                                               | expect       |
      | conn_2 | False   | show @@connection.sql.status where front_id={0}   | length{(13)} |

    Then check resultset "connection_sql_7" has lines with following column values
      | OPERATION-0              | SHARDING_NODE-4 | SQL/REF-5                             |
      | Read_SQL                 | -               | -                                     |
      | Parse_SQL                | -               | -                                     |
      | Route_Calculation        | -               | -                                     |
      | Prepare_to_Push/Optimize | -               | -                                     |
      | Execute_SQL              | dn2             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL              | dn1             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL              | dn4             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Execute_SQL              | dn3             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result             | dn2             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result             | dn1             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result             | dn4             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Fetch_result             | dn3             | SELECT * FROM sharding_4_t1 LIMIT 100 |
      | Write_to_Client          | -               | -                                     |

# sharding 4 table and where
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect  | db      |
      | conn_3 | False   | select * from sharding_4_t1 where id between 1 and 100   | success | schema1 |

    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_8"
      | conn   | toClose | sql                                               | expect       |
      | conn_2 | False   | show @@connection.sql.status where front_id={0}   | length{(13)} |

    Then check resultset "connection_sql_8" has lines with following column values
      | OPERATION-0              | SHARDING_NODE-4 | SQL/REF-5                                              |
      | Read_SQL                 | -               | -                                                      |
      | Parse_SQL                | -               | -                                                      |
      | Route_Calculation        | -               | -                                                      |
      | Prepare_to_Push/Optimize | -               | -                                                      |
      | Execute_SQL              | dn2             | select * from sharding_4_t1 where id between 1 and 100 |
      | Execute_SQL              | dn1             | select * from sharding_4_t1 where id between 1 and 100 |
      | Execute_SQL              | dn4             | select * from sharding_4_t1 where id between 1 and 100 |
      | Execute_SQL              | dn3             | select * from sharding_4_t1 where id between 1 and 100 |
      | Fetch_result             | dn2             | select * from sharding_4_t1 where id between 1 and 100 |
      | Fetch_result             | dn1             | select * from sharding_4_t1 where id between 1 and 100 |
      | Fetch_result             | dn4             | select * from sharding_4_t1 where id between 1 and 100 |
      | Fetch_result             | dn3             | select * from sharding_4_t1 where id between 1 and 100 |
      | Write_to_Client          | -               | -                                                      |

# sharding 4 table join global table and where and in and sub query and order by
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_3 | False   | select * from sharding_4_t1 join test where sharding_4_t1.id in (select id from test where id=1) order by sharding_4_t1.id desc | success | schema1 |

    Then execute the sql in "dble-1" in "admin" mode by parameter from resultset "user_front_id" and save resultset in "connection_sql_9"
      | conn   | toClose | sql                                               | expect       |
      | conn_2 | True    | show @@connection.sql.status where front_id={0}   | length{(15)} |

    Then check resultset "connection_sql_9" has lines with following column values
      | OPERATION-0              | SHARDING_NODE-4   | SQL/REF-5                                              |
      | Read_SQL                 | -                 | -                                                      |
      | Parse_SQL                | -                 | -                                                      |
      | Route_Calculation        | -                 | -                                                      |
      | Prepare_to_Push/Optimize | -                 | -                                                      |
      | Execute_SQL              | dn1_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Fetch_result             | dn1_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Execute_SQL              | dn2_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Fetch_result             | dn2_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Execute_SQL              | dn3_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Fetch_result             | dn3_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Execute_SQL              | dn4_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | Fetch_result             | dn4_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`name`,`test`.`id`,`test`.`name` from  (  `sharding_4_t1` join  `test` )  join (select  distinct `test`.`id` as `autoalias_scalar` from  `test` where `test`.`id` = 1) autoalias_test on `sharding_4_t1`.`id` = `autoalias_test`.`autoalias_scalar` where 1=1  ORDER BY `sharding_4_t1`.`id` DESC |
      | MERGE_AND_ORDER          | merge_and_order_1 | dn1_0; dn2_0; dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                    |
      | SHUFFLE_FIELD            | shuffle_field_1   | merge_and_order_1                                                                                                                                                                                                                                                                                                                             |
      | Write_to_Client          | -                 | -                                                                                                                                                                                                                                                                                                                                             |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect  | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                        | success | schema1 |
      | conn_3 | False   | drop table if exists test                                 | success | schema1 |
      | conn_3 | True    | drop table if exists no_sharding_t1                       | success | schema1 |
