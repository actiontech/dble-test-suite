# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2023/05/11

Feature: show @@sql XXX
#  1.show @@sql  描述：展示每个用户近期执行完的1024条sql语句，每隔5s清理多余数据  重置：show @@sql true
#  2.show @@sql.high  描述：展示每个用户近期执行高频的1024条sql语句，每隔5s清理多余数据   重置：show @@sql.high true
#  5.show @@sql.sum  描述：展⽰⽤⼾的sql执⾏情况, 是否带.user结果是⼀样的.带参数true，表⽰查询结束后清空已经缓存的结果  重置：show @@sql.sum true
#  6.show @@sql.sum.user  等同于 show @@sql.sum    重置：sshow @@sql.sum.user true
#  7.show @@sql.sum.table 描述：展⽰各个表的读写情况   重置：show @@sql.sum.table true
#
#  3.show @@sql.slow  描述：展⽰执⾏时间超过给定阈值(默认100毫秒，可通过reload修改)的sql(默认10条，可以通过设置系统参数sqlRecordCount修改，多余的每5秒清理⼀次）   重置：show @@sql.slow true
#  4.show @@sql.resultset 描述：展⽰结果集⼤⼩超过某个阈值(默认512K，可以通过maxResultSet配置) 的sql，结果集统计信息
#
#  8.show @@sql.large 描述：展⽰各个⽤⼾的结果集超过10000⾏的sql(容量为10,多的会被定时清理，清理周期5秒)  重置 ：show @@sql.large true
#  9.show @@sql.condition 描述：查询条件统计，需要配合reload @@query_cf 使⽤，前者设置了table&column后，运⾏此语句后展⽰sql查询条件统计信息.（最多100000条，超出后不再统计）

  ####reload @@user_stat  描述：重置⽤⼾状态统计结果。影响的命令  show @@sql;show @@sql.sum;show @@sql.slow;show @@sql.high;show @@sql.large;show @@sql.resultset
  ##todo mysqldump 的sql


  Scenario: show @@sql && show @@sql.high  && show @@sql.sum  && show @@sql.sum.user && show @@sql.sum.table  #1

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
      | conn_0 | False    | insert into test value (2, repeat('b', 1500)) | schema1 | success |
      | conn_0 | False    | insert into test value (3, repeat('c', 100))  | schema1 | success |
      | conn_0 | False    | update test set k="c" where id=3              | schema1 | success |
      | conn_0 | False    | select * from test                            | schema1 | success |
      | conn_0 | False    | select * from test order by id limit 1        | schema1 | success |
      | conn_0 | False    | select * from test where id=2                 | schema1 | success |
      | conn_0 | False    | delete from test where id=1                   | schema1 | success |
      | conn_0 | True     | alter table test drop column k                | schema1 | success |
    ### case 1: drop create alter 没有被记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql           | length{(8)}    | 10      |
      | conn_1 | False   | show @@sql.high      | length{(6)}    |         |
      | conn_1 | False   | show @@sql.sum       | length{(1)}    |         |
      | conn_1 | False   | show @@sql.sum.user  | hasStr{'test'} |         |
      | conn_1 | False   | show @@sql.sum.table | hasStr{'test'} |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql1"
      | sql        |
      | show @@sql |
    Then check resultset "sql1" has lines with following column values
      | USER-1 | SQL-4                                         |
      | test   | delete from test where id=1                   |
      | test   | SELECT * FROM test WHERE id = 2 LIMIT 100     |
      | test   | select * from test order by id limit 1        |
      | test   | SELECT * FROM test LIMIT 100                  |
      | test   | update test set k="c" where id=3              |
      | test   | insert into test value (3, repeat('c', 100))  |
      | test   | insert into test value (2, repeat('b', 1500)) |
      | test   | insert into test value (1, repeat('a', 1100)) |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high1"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high1" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                     |
      | test   | 1           | DELETE FROM test WHERE id = ?             |
      | test   | 1           | UPDATE test SET k = ? WHERE id = ?        |
      | test   | 1           | SELECT * FROM test LIMIT ?                |
      | test   | 3           | INSERT INTO test VALUES (?, repeat(?, ?)) |
      | test   | 1           | SELECT * FROM test ORDER BY id LIMIT ?    |
      | test   | 1           | SELECT * FROM test WHERE id = ? LIMIT ?   |

   ### case 2: 多语句
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | db      | expect  |
      | conn_2 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,k varchar(1500))                        | schema1 | success |
      | conn_2 | False   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b',1100)) | schema1 | success |
      | conn_2 | true    | update sharding_4_t1 set k="c" where id=3;alter table sharding_4_t1 drop column k                            | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                 | timeout |
      | conn_1 | False   | show @@sql           | length{(11)}                           | 10      |
      | conn_1 | False   | show @@sql.high      | length{(8)}                            |         |
      | conn_1 | False   | show @@sql.sum       | length{(1)}                            |         |
      | conn_1 | False   | show @@sql.sum.user  | hasStr{'test'}                         |         |
      | conn_1 | False   | show @@sql.sum.table | hasStr{'test'},hasStr{'sharding_4_t1'} |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql2"
      | sql        |
      | show @@sql |
    Then check resultset "sql2" has lines with following column values
      | USER-1 | SQL-4                                                   |
      | test   | INSERT INTO sharding_4_t1 VALUES (1, repeat('a', 1100)) |
      | test   | insert into sharding_4_t1 value (2, repeat('b',1100))   |
      | test   | UPDATE sharding_4_t1 SET k = 'c' WHERE id = 3           |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high2"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high2" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                     |
      | test   | 1           | DELETE FROM test WHERE id = ?             |
      | test   | 1           | UPDATE test SET k = ? WHERE id = ?        |
      | test   | 1           | SELECT * FROM test LIMIT ?                |
      | test   | 3           | INSERT INTO test VALUES (?, repeat(?, ?)) |
      | test   | 1           | SELECT * FROM test ORDER BY id LIMIT ?    |
      | test   | 1           | SELECT * FROM test WHERE id = ? LIMIT ?   |
      | test   | 1           | UPDATE sharding_4_t1 SET k = ? WHERE id = ? |
      | test   | 2           | INSERT INTO sharding_4_t1 VALUES (?, repeat(?, ?)) |

    ### case 3:事务+复杂语句+其他shardinguser+hint
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                               | db      | expect  |
      | test1 | 111111 | conn_3 | False   | begin;select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id =1                                                  | schema1 | success |
      | test1 | 111111 | conn_3 | False   | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1;commit                                                                     | schema1 | success |
      | test1 | 111111 | conn_3 | False   | start transaction;delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp));rollback | schema1 | success |
      | test1 | 111111 | conn_3 | False   | set autocommit=0;insert into test values (4)                                                                                      | schema1 | success |
      | test1 | 111111 | conn_3 | False   | set autocommit=1;insert into test values (5)                                                                                      | schema1 | success |
      | test1 | 111111 | conn_3 | False   | begin;insert into test values (6);begin;insert into test values (7);rollback;                                                     | schema1 | success |
      | test1 | 111111 | conn_3 | true    | select * from test                                                                                                                | schema1 | success |

   #### begin rollback set autocommit 等不记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                            | timeout |
      | conn_1 | False   | show @@sql           | length{(19)}                                                                      | 10      |
      | conn_1 | False   | show @@sql.high      | length{(13)}                                                                      |         |
      | conn_1 | False   | show @@sql.sum       | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.user  | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.table | hasStr{'test'},hasStr{'sharding_4_t1'},hasStr{'sharding_4_t1 a'},hasStr{'test b'} |         |


    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql3"
      | sql        |
      | show @@sql |
    Then check resultset "sql3" has lines with following column values
      | USER-1 | SQL-4                                                                                                 |
      | test1  | SELECT * FROM test LIMIT 100                                                                          |
      | test1  | insert into test values (5)                                                                           |
      | test1  | insert into test values (4)                                                                           |
      | test1  | DELETE FROM sharding_4_t1 WHERE id IN ( SELECT id FROM ( SELECT id FROM test ORDER BY id DESC ) tmp ) |
      | test1  | select * from sharding_4_t1                                                                           |
      | test1  | select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id =1                            |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high3"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high3" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                                                                                 |
      | test   | 1           | DELETE FROM test WHERE id = ?                                                                         |
      | test   | 1           | UPDATE test SET k = ? WHERE id = ?                                                                    |
      | test   | 1           | SELECT * FROM test LIMIT ?                                                                            |
      | test   | 1           | UPDATE sharding_4_t1 SET k = ? WHERE id = ?                                                           |
      | test   | 3           | INSERT INTO test VALUES (?, repeat(?, ?))                                                             |
      | test   | 2           | INSERT INTO sharding_4_t1 VALUES (?, repeat(?, ?))                                                    |
      | test   | 1           | SELECT * FROM test ORDER BY id LIMIT ?                                                                |
      | test   | 1           | SELECT * FROM test WHERE id = ? LIMIT ?                                                               |
      | test1  | 1           | DELETE FROM sharding_4_t1 WHERE id IN ( SELECT id FROM ( SELECT id FROM test ORDER BY id DESC ) tmp ) |
      | test1  | 1           | SELECT * FROM test LIMIT ?                                                                            |
#      | test1  | 1           | SELECT * FROM sharding_4_t1 a \tINNER JOIN test b ON a.id = b.id WHERE a.id = ?                       |
      | test1  | 1           | select * from sharding_4_t1                                                                           |
      | test1  | 4           | INSERT INTO test VALUES (?)                                                                           |


    ### case 4:错误的语句+select + show + set + view
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                  | db      | expect                                      |
      | test1 | 111111 | new    | False   | use schema66                         | schema1 | Unknown database 'schema66'                 |
      | test1 | 111111 | new    | False   | select * from test100                | schema1 | Table 'db3.test100' doesn't exist           |
      | test1 | 111111 | new    | False   | select user()                        | schema1 | success                                     |
      | test1 | 111111 | new    | False   | show tables                          | schema1 | success                                     |
      | test1 | 111111 | new    | False   | set @@trace=1                        | schema1 | success                                     |
      | test1 | 111111 | new    | False   | select @@trace                       | schema1 | success                                     |
      | test1 | 111111 | new    | False   | select 1                             | schema1 | success                                     |
      | test1 | 111111 | new    | False   | drop view if exists schema1.view_test         | schema1 | success                            |
      | test1 | 111111 | new    | False   | create view view_test as select * from test   | schema1 | success                            |

    ###不记录错误语句+select + show + set + view,简单的select 1 记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                            | timeout |
      | conn_1 | False   | show @@sql           | length{(20)}                                                                      | 10      |
      | conn_1 | False   | show @@sql.high      | length{(14)}                                                                      |         |
      | conn_1 | False   | show @@sql.sum       | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.user  | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.table | hasStr{'test'},hasStr{'sharding_4_t1'},hasStr{'sharding_4_t1 a'},hasStr{'test b'} |         |


   ### case 5:load data语句不记录
    Given execute oscmd in "dble-1"
      """
      echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,a\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                     | expect       | db      |
      | new    | False   | load data infile '/opt/dble/data.txt' into table sharding_4_t1 character SET 'utf8' fields terminated by ',' lines terminated by '\n'   | success      | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                            | timeout |
      | conn_1 | False   | show @@sql           | length{(20)}                                                                      | 10      |
      | conn_1 | False   | show @@sql.high      | length{(14)}                                                                      |         |
      | conn_1 | False   | show @@sql.sum       | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.user  | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.table | hasStr{'test'},hasStr{'sharding_4_t1'},hasStr{'sharding_4_t1 a'},hasStr{'test b'} |         |


    ### case 6:不记录除了分库分表用户外的用户执行的sql
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql      | expect   |
      | rw1   | 111111    | conn_11 | true     | select 1 | success  |
      | ana1  | 111111    | conn_12 | true     | select 1 | success  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                            | timeout |
      | conn_1 | False   | show @@sql           | length{(20)}                                                                      | 10      |
      | conn_1 | False   | show @@sql.high      | length{(14)}                                                                      |         |
      | conn_1 | False   | show @@sql.sum       | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.user  | length{(2)}                                                                       |         |
      | conn_1 | False   | show @@sql.sum.table | hasStr{'test'},hasStr{'sharding_4_t1'},hasStr{'sharding_4_t1 a'},hasStr{'test b'} |         |


     ### case 7: show @@sql xxx true 会重置清空数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect      | timeout |
      | conn_1 | False   | show @@sql true           | success     |         |
      | conn_1 | False   | show @@sql                | length{(0)} | 10      |
      | conn_1 | False   | show @@sql.high true      | success     |         |
      | conn_1 | False   | show @@sql.high           | length{(0)} | 10      |
      | conn_1 | False   | show @@sql.sum true       | success     |         |
      | conn_1 | False   | show @@sql.sum            | length{(0)} | 10      |
      | conn_1 | False   | show @@sql.sum.user true  | success     |         |
      | conn_1 | False   | show @@sql.sum.user       | length{(0)} | 10      |
      | conn_1 | False   | show @@sql.sum.table true | success     |         |
      | conn_1 | true    | show @@sql.sum.table      | length{(0)} | 10      |

    ### case 8: 一个sql执行多次 加上租户信息
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_11 | true    | select 1  | success |
      | test1      | 111111 | conn_12 | true    | select 2  | success |
      | test2:ten1 | 111111 | conn_11 | true    | select 21 | success |
    ### 按用户的id重新计算的  所以show @@sql.high 虽然类型都一样 但是用户不一样 所以还是有3个
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect      | timeout |
      | conn_1 | False   | show @@sql           | length{(3)} | 10      |
      | conn_1 | False   | show @@sql.high      | length{(3)} |         |
      | conn_1 | False   | show @@sql.sum       | length{(3)} |         |
      | conn_1 | False   | show @@sql.sum.user  | length{(3)} |         |
      | conn_1 | False   | show @@sql.sum.table | length{(0)} |         |


    Given execute sql "1050" times in "dble-1" at concurrent 1000
      | sql              | db      |
      | select 3         | schema1 |
    ###这边是1024+1 （每个用户1024）
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql           | length{(1026)} | 10      |
      | conn_1 | False   | show @@sql.high      | length{(3)}    |         |
      | conn_1 | False   | show @@sql.sum       | length{(3)}    |         |
      | conn_1 | False   | show @@sql.sum.user  | length{(3)}    |         |
      | conn_1 | False   | show @@sql.sum.table | length{(0)}    |         |

     ### case 9：reload @@user_stat 会重置清空数据，
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd    | conn    | toClose  | sql      | expect   |
      | test   | 111111    | conn_11 | true     | select 1 | success  |
      | test1  | 111111    | conn_12 | true     | select 2 | success  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql           | length{(1027)} | 10      |
      | conn_1 | False   | reload @@user_stat   | success        |         |
      | conn_1 | true    | show @@sql           | length{(0)}    | 10      |
      | conn_1 | False   | show @@sql.high      | length{(0)}    | 10      |
#      | conn_1 | False   | show @@sql.sum       | length{(0)}    | 10      |
#      | conn_1 | False   | show @@sql.sum.user  | length{(0)}    | 10      |
      | conn_1 | true    | show @@sql.sum.table | length{(0)}    | 10      |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  @skip
    #coz DBLE0REQ-2107
  Scenario: show @@sql.slow   #2
    ##sqlRecordCount 慢查询记录阈值
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
    ###case 1 ：这个慢sql 依赖的开关是 useSqlStat和 reload @@sqlslow=t;调整时间 和slow_log不一致
    Then execute admin cmd "reload @@sqlslow=0"
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_11 | true    | select 1  | success |
      | test1      | 111111 | conn_12 | true    | select 2  | success |
      | test2:ten1 | 111111 | conn_21 | true    | select 21 | success |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect      | timeout |
      | conn_1 | False   | show @@sql           | length{(3)} | 10      |
      | conn_1 | False   | show @@sql.slow      | length{(1)} | 10      |


    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test  | 111111 | conn_11 | false   | drop table if exists test;create table test(id int,name varchar(1500))                                        | success | schema1 |
      | test  | 111111 | conn_11 | false   | insert into test value (1, repeat('a', 1100));insert into test value (2, repeat('b', 1500))                   | success | schema1 |
      | test  | 111111 | conn_11 | false   | select * from test                                                                                            | success | schema1 |

      | test1 | 111111 | conn_12 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(1500))                      | success | schema1 |
      | test1 | 111111 | conn_12 | false   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b', 1500)) | success | schema1 |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1                                                                                   | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect      | timeout |
      | conn_1 | true    | show @@sql.slow      | length{(1)} |         |


    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DsqlRecordCount=100
      """
    Then restart dble in "dble-1" success
    Then execute admin cmd "reload @@sqlslow=0"
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_31 | true    | select 1  | success |
      | test1      | 111111 | conn_32 | true    | select 2  | success |
      | test2:ten1 | 111111 | conn_33 | true    | select 21 | success |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect      | timeout |
      | conn_1 | False   | show @@sql           | length{(3)} | 10      |
      | conn_1 | False   | show @@sql.slow      | length{(1)} | 10      |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"



  Scenario: show @@sql.resultset  #3
    ###可以通过 maxResultSet 配置
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
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                               | db      | expect  |
      | conn_0 | False   | drop table if exists test                         | schema1 | success |
      | conn_0 | False   | create table test(id int,k longblob)              | schema1 | success |
      | conn_0 | False   | insert into test value (1, repeat('a', 1100))     | schema1 | success |
      | conn_0 | False   | insert into test value (2, repeat('b', 1500))     | schema1 | success |
      | conn_0 | False   | insert into test value (3, repeat('c', 100))      | schema1 | success |
      | conn_0 | False   | insert into test value (4, repeat('d', 512*1024)) | schema1 | success |
      | conn_0 | False   | select * from test where id = 1                   | schema1 | success |
      | conn_0 | False   | select * from test where id = 2                   | schema1 | success |
      | conn_0 | False   | select * from test where id = 3                   | schema1 | success |
      | conn_0 | true    | select * from test where id = 4                   | schema1 | success |
   ### case 1：因为maxResultSet 默认512 所以记录一条
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | true    | show @@sql.resultset      | length{(1)}    | 10       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset1"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset1" has lines with following column values
      | ID-0 | USER-1 | FREQUENCY-2 | SQL-3                                   | RESULTSET_SIZE-4 |
      | 1    | test   | 1           | SELECT * FROM test WHERE id = ? LIMIT ? | 524401           |

    ###更改 maxResultSet 的值
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DmaxResultSet=1
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_31 | true    | select 1  | success |
      | test1      | 111111 | conn_32 | true    | select 2  | success |
      | test2:ten1 | 111111 | conn_33 | true    | select 21 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | true    | show @@sql.resultset      | length{(3)}    | 10       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset2"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset2" has lines with following column values
      | USER-1     | FREQUENCY-2 | SQL-3    | RESULTSET_SIZE-4 |
      | test       | 1           | SELECT ? | 56               |
      | test1      | 1           | SELECT ? | 56               |
      | test2:ten1 | 1           | SELECT ? | 58               |

     ### case 2: 多语句，也是单语句拆分记录 ddl不记录
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | db      | expect  |
      | conn_2 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,k varchar(1500))                        | schema1 | success |
      | conn_2 | False   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b',1100)) | schema1 | success |
      | conn_2 | true    | update sharding_4_t1 set k="c" where id=3;alter table sharding_4_t1 drop column k                            | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | true    | show @@sql.resultset      | length{(5)}    | 10       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset3"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset3" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-3                                              | RESULTSET_SIZE-4 |
      | test   | 1           | UPDATE sharding_4_t1 SET k = ? WHERE id = ?        | 52               |
      | test   | 2           | INSERT INTO sharding_4_t1 VALUES (?, repeat(?, ?)) | 11               |

    ### case 3:事务+复杂语句+其他shardinguser+hint  begin rollback set autocommit 等不记录
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                               | db      | expect  |
      | test1 | 111111 | conn_3 | False   | begin;select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id =1                                                  | schema1 | success |
      | test1 | 111111 | conn_3 | False   | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1;commit                                                                     | schema1 | success |
      | test1 | 111111 | conn_3 | False   | start transaction;delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp));rollback | schema1 | success |
      | test1 | 111111 | conn_3 | False   | set autocommit=0;insert into test values (4,'aaaa')                                                                               | schema1 | success |
      | test1 | 111111 | conn_3 | False   | set autocommit=1;insert into test values (5,'bbbb')                                                                               | schema1 | success |
      | test1 | 111111 | conn_3 | False   | begin;insert into test values (6,'aaaa');begin;insert into test values (7,'aaaa');rollback;                                       | schema1 | success |
      | test1 | 111111 | conn_3 | true    | select * from test                                                                                                                | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | true    | show @@sql.resultset      | length{(10)}    | 10       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset4"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset4" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-3                                                                                                 | RESULTSET_SIZE-4 |
      | test1  | 1           | DELETE FROM sharding_4_t1 WHERE id IN ( SELECT id FROM ( SELECT id FROM test ORDER BY id DESC ) tmp ) | 44               |
      | test1  | 1           | SELECT * FROM test LIMIT ?                                                                            | 527159           |
#      | test1  | 1           | SELECT * FROM sharding_4_t1 a         INNER JOIN test b ON a.id = b.id WHERE a.id = ?                 | 1255             |
      | test1  | 4           | INSERT INTO test VALUES (?, ?)                                                                        | 44               |
      | test1  | 1           | select * from sharding_4_t1                                                                           | 82               |

    ### case 4:错误的语句+select + show + set 不记录
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                  | db      | expect                                      |
      | test1 | 111111 | new    | False   | use schema66                         | schema1 | Unknown database 'schema66'                 |
      | test1 | 111111 | new    | False   | select * from test100                | schema1 | Table 'db3.test100' doesn't exist           |
      | test1 | 111111 | new    | False   | select user()                        | schema1 | success                                     |
      | test1 | 111111 | new    | False   | show tables                          | schema1 | success                                     |
      | test1 | 111111 | new    | False   | set @@trace=1                        | schema1 | success                                     |
      | test1 | 111111 | new    | False   | select @@trace                       | schema1 | success                                     |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | false   | show @@sql.resultset      | length{(10)}   | 10       |

   ### case 5:load data语句不记录
    Given execute oscmd in "dble-1"
      """
      echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,a\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                     | expect       | db      |
      | new    | False   | load data infile '/opt/dble/data.txt' into table sharding_4_t1 character SET 'utf8' fields terminated by ',' lines terminated by '\n'   | success      | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | false   | show @@sql.resultset      | length{(10)}   | 10       |

    ### case 6:不记录除了分库分表用户外的用户执行的sql
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql      | expect   |
      | rw1   | 111111    | conn_11 | true     | select 1 | success  |
      | ana1  | 111111    | conn_12 | true     | select 1 | success  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | false   | show @@sql.resultset      | length{(10)}   | 10       |

    ### case 7：验证 FREQUENCY 参数
    Given execute sql "1050" times in "dble-1" at concurrent 1000
      | sql              | db      |
      | select 3         | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect         | timeout |
      | conn_1 | false   | show @@sql.resultset      | length{(10)}   | 10       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset5"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset5" has lines with following column values
      | USER-1     | FREQUENCY-2 | SQL-3    | RESULTSET_SIZE-4 |
      | test       | 1051        | SELECT ? | 56               |

     ### case 8: show @@sql xxx true 不会重置清空数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                 | expect      | timeout |
      | conn_1 | False   | show @@sql.resultset true           | success     |         |
      | conn_1 | false   | show @@sql.resultset                | length{(10)}| 10      |
     ### case 9: reload @@user_stat 会重置清空数据
      | conn_1 | False   | reload @@user_stat                  | success     |          |
      | conn_1 | false   | show @@sql.resultset                | length{(0)} | 10       |
    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"



  Scenario: show @@sql.large  #4
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

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect      | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                         | success     | schema1 |
      | conn_3 | False   | create table sharding_4_t1(id int,name varchar(20))        | success     | schema1 |
      | conn_3 | False   | drop table if exists test                                  | success     | schema1 |
      | conn_3 | False   | create table test(id int,name varchar(20))                 | success     | schema1 |
      | conn_3 | False   | drop table if exists test1                                 | success     | schema1 |
      | conn_3 | False   | create table test1(id int,name varchar(20))                | success     | schema1 |
    ### case 1: dml不会被记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.large     | length{(0)}    | 10      |

    ### case 2: 制造select结果返回大于1万行的数据
    Then connect "dble-1" to insert "10001" of data for "sharding_4_t1"
    Then connect "dble-1" to insert "15000" of data for "test"
    Then connect "dble-1" to insert "20000" of data for "test1"

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1 limit 100000   | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.large     | length{(1)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_large1"
      | sql              |
      | show @@sql.large |
    Then check resultset "sql_large1" has lines with following column values
      | USER-0 | ROWS-1 | SQL-4                                    |
      | test   | 10001  | SELECT * FROM sharding_4_t1 LIMIT 100000 |

    ### case 2: 多语句下发
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                        | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1 where id>0 limit 100000;select id from sharding_4_t1 where id>0 limit 100000   | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.large     | length{(3)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_large2"
      | sql              |
      | show @@sql.large |
    Then check resultset "sql_large2" has lines with following column values
      | USER-0 | ROWS-1 | SQL-4                                                  |
      | test   | 10001  | SELECT * FROM sharding_4_t1 LIMIT 100000               |
      | test   | 10001  | SELECT id FROM sharding_4_t1 WHERE id > 0 LIMIT 100000 |
      | test   | 10001  | SELECT * FROM sharding_4_t1 WHERE id > 0 LIMIT 100000  |

    ### case 3:事务+复杂语句+其他shardinguser+hint  begin rollback set autocommit 等不记录
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                               | db          | expect  |
      | test1 | 111111 | conn_3 | False   | begin;select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id > 0 limit 100000                                    | schema1     | success |
      | test1 | 111111 | conn_3 | False   | /*!dble:shardingNode=dn1*/ select name from test limit 100000;commit                                                              | schema1     | success |
      | test1 | 111111 | conn_3 | False   | start transaction;delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp));rollback | schema1     | success |
      | test1 | 111111 | conn_3 | False   | set autocommit=0;select * from test limit 100000                                                                                  | schema1     | success |
      | test1 | 111111 | conn_3 | False   | set autocommit=1;select * from test1 limit 100000                                                                                 | schema1     | success |
      | test1 | 111111 | conn_3 | true    | select * from test order by id limit 100000                                                                                       | schema1      | success |
    ###这边应该有issue： user没有区分
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.large     | length{(8)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_large2"
      | sql              |
      | show @@sql.large |
    Then check resultset "sql_large2" has lines with following column values
      | USER-0 | ROWS-1 | SQL-4                                                                                    |
      | test   | 20000  | select * from test1 limit 100000                                                         |
      | test   | 15000  | select * from test order by id limit 100000                                              |
      | test   | 15000  | select * from test limit 100000                                                          |
      | test   | 15000  | select name from test limit 100000                                                       |
      | test   | 10001  | select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id > 0 limit 100000 |
      | test   | 10001  | SELECT * FROM sharding_4_t1 LIMIT 100000                                                 |
      | test   | 10001  | SELECT id FROM sharding_4_t1 WHERE id > 0 LIMIT 100000                                   |
      | test   | 10001  | SELECT * FROM sharding_4_t1 WHERE id > 0 LIMIT 100000                                    |


     Then execute sql in "dble-1" in "user" mode
      | user       | conn   | toClose | sql                                                                                                  | expect      | db      |
      | test2:ten1 | conn_3 | False   | select * from test where id>0 limit 100000;select id from test1 where id>0 limit 100000              | success     | schema1 |
      | test2:ten1 | conn_3 | False   | select id,name from test where id>0 limit 100000;select name,id from test1 where id>0 limit 100000   | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | conn_1 | False   | show @@sql.large     | length{(12)}    | 10      |


#    ### case 4:不记录除了分库分表用户外的用户执行的sql
#    Then execute sql in "dble-1" in "user" mode
#      | user  | passwd    | conn    | toClose  | sql                                                                              | expect   | db|
#      | rw1   | 111111    | conn_11 | true     | drop table if exists table1;create table sharding_4_t1(id int,name varchar(20))  | success  | db1|
#    Then connect "dble-1" to insert "10001" of data for "table1"
#    Then execute sql in "dble-1" in "user" mode
#      | user  | passwd    | conn    | toClose  | sql                                                                              | expect   | db|
#      | rw1   | 111111    | conn_11 | true     | select * from  table1 limit 1  | success  | db1|



     ### case : show @@sql xxx true 会重置清空数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                             | expect      | timeout |
      | conn_1 | False   | show @@sql.large true           | success     |         |
      | conn_1 | false   | show @@sql.large                | length{(0)} | 10      |

     ### case : reload @@user_stat 会重置清空数据
    Then connect "dble-1" to insert "10001" of data for "sharding_4_t1"
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1 limit 100000   | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.large     | length{(1)}    | 10      |
      | conn_1 | False   | reload @@user_stat   | success        |         |
      | conn_1 | false   | show @@sql.large     | length{(0)}    | 10      |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"



  Scenario: show @@sql.condition  #5
    ##reload @@query_cf=table&column;
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

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                        | expect      | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1                         | success     | schema1 |
      | conn_3 | False   | create table sharding_4_t1(id int,name varchar(20))        | success     | schema1 |
      | conn_3 | False   | drop table if exists test                                  | success     | schema1 |
      | conn_3 | False   | create table test(id int,name varchar(20))                 | success     | schema1 |
      | conn_3 | False   | drop table if exists test1                                 | success     | schema1 |
      | conn_3 | False   | create table test1(id int,name varchar(20))                | success     | schema1 |

    ### case : 没有设置reload @@query_cf=table&column; show @@sql.condition为2条null数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(2)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition1" has lines with following column values
      | ID-0 | KEY-1                | VALUE-2 | COUNT-3 |
      | 1    | null.null.valuekey   | size    | 0       |
      | 2    | null.null.valuecount | total   | 0       |

    Then connect "dble-1" to insert "100001" of data for "sharding_4_t1"
    Then connect "dble-1" to insert "150" of data for "test"
    ### case 1: 设置reload @@query_cf=table&column; show @@sql.condition为2条null数据
    Then execute admin cmd "reload @@query_cf=sharding_4_t1&id"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_3 | False   | select id from sharding_4_t1 where id=1     | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(3)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition1" has lines with following column values
      | KEY-1                       | VALUE-2 | COUNT-3 |
      | sharding_4_t1.id            | 1       |     1 |
      | sharding_4_t1.id.valuekey   | size    |     1 |
      | sharding_4_t1.id.valuecount | total   |     1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                         | expect      | db      |
      | conn_3 | False   | select id from sharding_4_t1 where id=0     | success     | schema1 |
      | conn_3 | true    | select id from sharding_4_t1 where id=2     | success     | schema1 |

    Given execute sql "101" times in "dble-1" at concurrent
      | sql                                             | db      |
      | select id from sharding_4_t1 where id=1         | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(5)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition1" has lines with following column values
      | KEY-1                       | VALUE-2 | COUNT-3 |
      | sharding_4_t1.id            | 0       | 1       |
      | sharding_4_t1.id            | 1       | 102     |
      | sharding_4_t1.id            | 2       | 1       |
      | sharding_4_t1.id.valuekey   | size    | 3       |
      | sharding_4_t1.id.valuecount | total   | 104     |

   ##测试超过100000条 时间太久了  日常手动测试即可
#    Given execute sql "100001" times in "dble-1" at concurrent 1000
#      | sql                                        | db      |
#      | select id from sharding_4_t1 where id ={}  | schema1 |
#    Then execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                      | expect              | timeout |
#      | conn_1 | False   | show @@sql.condition     | length{(100002)}    | 10      |
#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
#      | sql                  |
#      | show @@sql.condition |
#    Then check resultset "sql_condition1" has lines with following column values
#      | KEY-1                       | VALUE-2 | COUNT-3 |
#      | sharding_4_t1.id.valuekey   | size    | 100000  |
#      | sharding_4_t1.id.valuecount | total   | 100105  |

     ### case : show @@sql xxx true 不支持
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                 | expect                    | timeout |
      | conn_1 | False   | show @@sql.condition true           | Unsupported statement     |         |
      | conn_1 | False   | reload @@query_cf                   | success                   |         |
      | conn_1 | False   | show @@sql.condition                | length{(2)}               | 10      |

    ###其他sharding用户
    Then execute admin cmd "reload @@query_cf=sharding_4_t1&name"
    Then execute sql in "dble-1" in "user" mode
      | user       | conn   | toClose | sql                                         | expect      | db      |
      | test1      | conn_3 | False   | select name from sharding_4_t1 where id=0     | success     | schema1 |
      | test2:ten1 | conn_3 | False   | select name from sharding_4_t1 where id=2     | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(2)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition1" has lines with following column values
      | KEY-1                         | VALUE-2 | COUNT-3 |
      | sharding_4_t1.name.valuekey   | size    | 0       |
      | sharding_4_t1.name.valuecount | total   | 0       |

    Then execute sql in "dble-1" in "user" mode
      | user       | conn   | toClose | sql                                             | expect      | db      |
      | test1      | conn_3 | False   | select name from sharding_4_t1 where name=0     | success     | schema1 |
      | test2:ten1 | conn_3 | False   | select name from sharding_4_t1 where name=2     | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(4)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition1" has lines with following column values
      | KEY-1                         | VALUE-2 | COUNT-3 |
      | sharding_4_t1.name            | 0       | 1       |
      | sharding_4_t1.name            | 2       | 1       |
      | sharding_4_t1.name.valuekey   | size    | 2       |
      | sharding_4_t1.name.valuecount | total   | 2       |

    ### reload其他table，原来的table清空
    Then execute admin cmd "reload @@query_cf=test&name"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(2)}    | 10      |
    Then execute sql in "dble-1" in "user" mode
      | user       | conn   | toClose | sql                                             | expect      | db      |
      | test1      | conn_3 | False   | select name from sharding_4_t1 where name=0     | success     | schema1 |
      | test2:ten1 | conn_3 | False   | select name from sharding_4_t1 where name=2     | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(2)}    | 10      |
    Then execute sql in "dble-1" in "user" mode
      | user       | conn   | toClose | sql                                    | expect      | db      |
      | test1      | conn_3 | False   | select name from test where name=0     | success     | schema1 |
      | test2:ten1 | conn_3 | False   | select name from test where name=2     | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(4)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition1"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition1" has lines with following column values
      | KEY-1                | VALUE-2 | COUNT-3 |
      | test.name            | 0       | 1       |
      | test.name            | 2       | 1       |
      | test.name.valuekey   | size    | 2       |
      | test.name.valuecount | total   | 2       |
     ### case : reload @@user_stat 不会重置清空数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | reload @@user_stat       | success        |         |
      | conn_1 | False   | show @@sql.condition     | length{(4)}    | 10      |

    ### case 6:不记录除了分库分表用户外的用户执行的sql
    Then execute admin cmd "reload @@query_cf=table1&name"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql                                                                              | expect   | db  |
      | rw1   | 111111    | conn_11 | true     | drop table if exists table1;create table table1(id int,name varchar(20))         | success  | db1 |
      | rw1   | 111111    | conn_11 | true     | select name from table1 where name=0;select name from table1 where name=1        | success  | db1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(2)}    | 10      |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"



  Scenario: dble重启数据会被清空恢复默认值   #6
    ###9066端口默认初始值 ，默认开启sql统计
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            |
      | conn_1 | False   | show @@sql                | length{(0)}       |
      | conn_1 | False   | show @@sql.high           | length{(0)}       |
      | conn_1 | False   | show @@sql.slow           | length{(0)}       |
      | conn_1 | False   | show @@sql.large          | length{(0)}       |
      | conn_1 | False   | show @@sql.resultset      | length{(0)}       |
      | conn_1 | False   | show @@sql.sum            | length{(0)}       |
      | conn_1 | False   | show @@sql.sum.user       | length{(0)}       |
      | conn_1 | False   | show @@sql.sum.table      | length{(0)}       |
      | conn_1 | true    | show @@sql.condition      | length{(2)}       |

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
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DmaxResultSet=1
      """
    Then restart dble in "dble-1" success
    Then execute admin cmd "reload @@sqlslow=0"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test  | 111111 | conn_11 | false   | drop table if exists test;create table test(id int,name longblob)                                             | success | schema1 |
      | test  | 111111 | conn_11 | false   | insert into test value (1, repeat('a', 1100));insert into test value (2, repeat('b', 512*1024))               | success | schema1 |
      | test  | 111111 | conn_11 | false   | select * from test                                                                                            | success | schema1 |

      | test1 | 111111 | conn_12 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(1500))                      | success | schema1 |
      | test1 | 111111 | conn_12 | false   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b', 1500)) | success | schema1 |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1                                                                                   | success | schema1 |
    Then connect "dble-1" to insert "10001" of data for "sharding_4_t1"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1 limit 100000                                                                      | success | schema1 |

     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@sql                | length{(8)}       | 10      |
      | conn_1 | False   | show @@sql.high           | length{(6)}       | 10      |
#      | conn_1 | False   | show @@sql.slow           | length{(1)}       | 10      |
      | conn_1 | False   | show @@sql.large          | length{(1)}       | 10      |
      | conn_1 | False   | show @@sql.resultset      | length{(6)}       | 10      |
      | conn_1 | False   | show @@sql.sum            | length{(2)}       | 10      |
      | conn_1 | False   | show @@sql.sum.user       | length{(2)}       | 10      |
      | conn_1 | False   | show @@sql.sum.table      | length{(2)}       | 10      |
      | conn_1 | true    | show @@sql.condition      | length{(2)}       | 10      |

    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            |
      | conn_1 | False   | show @@sql                | length{(0)}       |
      | conn_1 | False   | show @@sql.high           | length{(0)}       |
      | conn_1 | False   | show @@sql.slow           | length{(0)}       |
      | conn_1 | False   | show @@sql.large          | length{(0)}       |
      | conn_1 | False   | show @@sql.resultset      | length{(0)}       |
      | conn_1 | False   | show @@sql.sum            | length{(0)}       |
      | conn_1 | False   | show @@sql.sum.user       | length{(0)}       |
      | conn_1 | False   | show @@sql.sum.table      | length{(0)}       |
      | conn_1 | False   | show @@sql.condition      | length{(2)}       |


  Scenario: useSqlStat 是否启⽤SQL统计 默认启动  #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DuseSqlStat=0
      """
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
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Then restart dble in "dble-1" success
    Then execute admin cmd "reload @@sqlslow=0"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test  | 111111 | conn_11 | false   | drop table if exists test;create table test(id int,name longblob)                                             | success | schema1 |
      | test  | 111111 | conn_11 | false   | insert into test value (1, repeat('a', 1100));insert into test value (2, repeat('b', 512*1024))               | success | schema1 |
      | test  | 111111 | conn_11 | false   | select * from test                                                                                            | success | schema1 |

      | test1 | 111111 | conn_12 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(1500))                      | success | schema1 |
      | test1 | 111111 | conn_12 | false   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b', 1500)) | success | schema1 |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1                                                                                   | success | schema1 |
    Then connect "dble-1" to insert "10001" of data for "sharding_4_t1"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1 limit 100000                                                                      | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            |
      | conn_1 | False   | show @@sql                | length{(0)}       |
      | conn_1 | False   | show @@sql.high           | length{(0)}       |
      | conn_1 | False   | show @@sql.slow           | length{(0)}       |
      | conn_1 | False   | show @@sql.large          | length{(0)}       |
      | conn_1 | False   | show @@sql.resultset      | length{(0)}       |
      | conn_1 | False   | show @@sql.sum            | length{(0)}       |
      | conn_1 | False   | show @@sql.sum.user       | length{(0)}       |
      | conn_1 | False   | show @@sql.sum.table      | length{(0)}       |
      | conn_1 | False   | show @@sql.condition      | length{(2)}       |