# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2023/05/11

Feature: show @@connection.sql  show @@connection.sql.status where FRONT_ID= ?;
  1.show @@connection.sql   描述：当前活动session的前端的SQL信息
  2.show @@connection.sql.status where FRONT_ID= ?;  此功能需要开启慢⽇志才有效，当对应的连接当前query已经执⾏完毕时，执⾏此命令的结果与 trace 功能相同。 如果query正在执⾏，本结果将试图展⽰query执⾏到哪⼀个步骤了


  Scenario: show @@connection.sql
    ###配置所有的用户 管理端用户  分库分表用户 读写分离用户  分析用户
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
       """
       <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
       </dbGroup>

       <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
          <heartbeat>select 1</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.10:9004" user="test" maxCon="100" minCon="10" primary="true" databaseType="clickhouse"/>
       </dbGroup>
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <shardingUser name="test1" password="111111" schemas="schema1"/>
       <shardingUser name="test2" password="111111" schemas="schema1" tenant="ten1"/>
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Then execute admin cmd "reload @@config"

    ##ddl  dml
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | db      | expect  |
      | conn_0 | False    | drop table if exists test                     | schema1 | success |
      | conn_0 | False    | create table test(id int,k varchar(1500))     | schema1 | success |
      | conn_0 | False    | insert into test value (1, repeat('a', 1100)) | schema1 | success |
    ###包含管理端和8066上一个session的最后一条sql
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@connection.sql     | length{(2)}       | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "sql_1" has lines with following column values
      | USER-2 | SCHEMA-3 | SQL-6                                         | STAGE-7            |
      | root   |          | show @@connection.sql                         | Manager connection |
      | test   | schema1  | insert into test value (1, repeat('a', 1100)) | Finished           |

      ###新开一个8066  多语句下发 和 9066 session
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | db      | expect  |
      | conn_2 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,k varchar(1500))                        | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_3 | False   | show @@connection.sql     | length{(4)}       | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "sql_1" has lines with following column values
      | USER-2 | SCHEMA-3 | SQL-6                                              | STAGE-7            |
      | root   |          | show @@connection.sql                              | Manager connection |
      | test   | schema1  | insert into test value (1, repeat('a', 1100))      | Finished           |
      | test   | schema1  | create table sharding_4_t1(id int,k varchar(1500)) | Finished           |

    ## 多语句事务下发 没换session
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                  | db      | expect  |
      | conn_2 | False   | begin;insert into test values (6,6);begin;delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp))     | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@connection.sql     | length{(4)}       | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "sql_1" has lines with following column values
      | USER-2 | SCHEMA-3 | SQL-6                                              | STAGE-7            |
      | root   |          | show @@connection.sql                              | Manager connection |
      | test   | schema1  | insert into test value (1, repeat('a', 1100))      | Finished           |
      | test   | schema1  | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp))| Finished           |

    ## 错误的语句 换session 加user
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                  | db      | expect                                      |
      | test1 | 111111 | new    | False   | use schema66                         | schema1 | Unknown database 'schema66'                 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@connection.sql     | length{(5)}       | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "sql_1" has lines with following column values
      | USER-2 | SCHEMA-3 | SQL-6                                              | STAGE-7            |
      | root   |          | show @@connection.sql                              | Manager connection |
      | test   | schema1  | insert into test value (1, repeat('a', 1100))      | Finished           |
      | test   | schema1  | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp))| Finished           |
      | test1  | schema1  | use schema66      | Finished           |

    ### 加上其他user  session不关闭
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_31 | false   | select 1  | success |
      | test1      | 111111 | conn_32 | false   | select 2  | success |
      | test2:ten1 | 111111 | conn_33 | false   | select 21 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@connection.sql     | length{(8)}       | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "sql_1" has lines with following column values
      | USER-2 | SCHEMA-3 | SQL-6                                              | STAGE-7            |
      | root   |          | show @@connection.sql                              | Manager connection |
      | test   | schema1  | insert into test value (1, repeat('a', 1100))      | Finished           |
      | test   | schema1  | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp))| Finished           |
      | test1  | schema1  | use schema66      | Finished           |
      | test   | None     | select 1          | Finished           |
      | test1  | None     | select 2          | Finished           |
      | test2:ten1   | None     | select 21          | Finished           |

    ###session关闭
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_31 | true    | select 5  | success |
      | test1      | 111111 | conn_32 | true    | select 6  | success |
      | test2:ten1 | 111111 | conn_33 | true    | select 7  | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@connection.sql     | length{(5)}       | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_1"
      | conn   | toClose | sql                   |
      | conn_1 | False   | show @@connection.sql |
    Then check resultset "sql_1" has lines with following column values
      | USER-2 | SCHEMA-3 | SQL-6                                              | STAGE-7            |
      | root   |          | show @@connection.sql                              | Manager connection |
      | test   | schema1  | insert into test value (1, repeat('a', 1100))      | Finished           |
      | test   | schema1  | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp))| Finished           |
      | test1  | schema1  | use schema66      | Finished           |




  @TRIVIAL @auto_retry
  Scenario: query execute time <1ms #1
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | db       |
      | conn_0 | False    | select sleep(0.0001)   | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_A"
      | conn   | toClose  | sql                   |
      | conn_1 | False    | show @@connection.sql |
    Then removal result set "conn_rs_A" contains "@@connection" part
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_B"
      | conn   | toClose  | sql                   |
      | conn_2 | False    | show @@connection.sql |
    Then removal result set "conn_rs_B" contains "@@connection" part
    Then check resultsets "conn_rs_A" and "conn_rs_B" are same in following columns
      | column              | column_index |
      | START_TIME          | 5            |
      | EXECUTE_TIME        | 6            |
      | SQL                 | 7            |

  @TRIVIAL  @auto_retry
  Scenario: query execute time >1ms #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | db       |
      | conn_0 | False    | select sleep(0.0001)   | schema1  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_C"
      | conn   | toClose  | sql                   |
      | conn_1 | False    | show @@connection.sql |
    Then removal result set "conn_rs_C" contains "@@connection" part
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_D"
      | conn   | toClose  | sql                   |
      | conn_2 | False    | show @@connection.sql |
    Then removal result set "conn_rs_D" contains "@@connection" part
    Then check resultsets "conn_rs_C" and "conn_rs_D" are same in following columns
      | column              | column_index |
      | START_TIME          | 5              |
      | EXECUTE_TIME        | 6              |
      | SQL                 | 7              |

  @TRIVIAL  @auto_retry
  Scenario: multiple session with multiple query display #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | db       |
      | conn_0 | False    | select sleep(1)        | schema1  |
      | conn_1 | False    | select sleep(0.1)      | schema1   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_E"
      | conn   | toClose  | sql                   |
      | conn_3 | False    | show @@connection.sql |
    Then removal result set "conn_rs_E" contains "@@connection" part
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "conn_rs_F"
      | conn   | toClose  | sql                   |
      | conn_4 | False    | show @@connection.sql |
    Then removal result set "conn_rs_F" contains "@@connection" part
    Then check resultsets "conn_rs_E" and "conn_rs_F" are same in following columns
      | column              | column_index |
      | START_TIME          | 5              |
      | EXECUTE_TIME        | 6              |
      | SQL                 | 7              |