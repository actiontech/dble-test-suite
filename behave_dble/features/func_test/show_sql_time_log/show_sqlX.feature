# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2023/05/11
  ## update 2023、06、05

Feature: show @@sql XXX
#  1.show @@sql  描述：展示每个用户近期执行完的1024条sql语句，每隔5s清理多余数据
#  2.show @@sql.high  描述：展示每个用户近期执行高频的1024条sql语句，每隔5s清理多余数据
#  3.show @@sql.slow  描述：展⽰执⾏时间超过给定阈值(默认100毫秒，可通过reload修改)的sql(默认10条，可以通过设置系统参数sqlRecordCount修改，多余的每5秒清理⼀次）
#  4.show @@sql.resultset 描述：展⽰结果集⼤⼩超过某个阈值(默认512K，可以通过maxResultSet配置) 的sql，结果集统计信息
#  8.show @@sql.large 描述：展⽰各个⽤⼾的结果集超过10000⾏的sql(容量为10,多的会被定时清理，清理周期5秒)

#  5.show @@sql.sum  描述：展⽰⽤⼾的sql执⾏情况, 是否带.user结果是⼀样的.带参数true，表⽰查询结束后清空已经缓存的结果  重置：show @@sql.sum true
#  6.show @@sql.sum.user  等同于 show @@sql.sum    重置：sshow @@sql.sum.user true
#  7.show @@sql.sum.table 描述：展⽰各个表的读写情况   重置：show @@sql.sum.table true
#  9.show @@sql.condition 描述：查询条件统计，需要配合reload @@query_cf 使⽤，前者设置了table&column后，运⾏此语句后展⽰sql查询条件统计信息.（最多100000条，超出后不再统计）
  #### reload @@user_stat  废弃

  ## change DBLE0REQ-2101

  Scenario: 新增参数enableStatisticAnalysis 校验 #1
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DenableStatisticAnalysis=99.99
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableStatisticAnalysis \] '99.99' data type should be int
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableStatisticAnalysis=99.99/-DenableStatisticAnalysis=-199/
      """
    Then restart dble in "dble-1" failed for
      """
      Property \[ enableStatisticAnalysis \] '-199' in bootstrap.cnf is illegal, you may need use the default value 0 replaced
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableStatisticAnalysis=-199/-DenableStatisticAnalysis=abc/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableStatisticAnalysis \] 'abc' data type should be int
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableStatisticAnalysis=abc/-DenableStatisticAnalysis=null/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableStatisticAnalysis \] 'null' data type should be int
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableStatisticAnalysis=null/-DenableStatisticAnalysis=/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableStatisticAnalysis \] '' data type should be int
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/-DenableStatisticAnalysis=/-DenableStatisticAnalysis=@/
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ enableStatisticAnalysis \] '@' data type should be int
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DenableStatisticAnalysis/d
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect          | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name = "enableStatisticAnalysis"           | has{(('0',),)}  | dble_information |

#    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
#      """
#      $a -DenableStatisticAnalysis=true
#      """
#    Then restart dble in "dble-1" success
#    Then execute sql in "dble-1" in "admin" mode
#      | conn   | toClose | sql                                                                                                 | expect          | db               |
#      | conn_0 | true    | select variable_value from dble_variables where variable_name = "enableStatisticAnalysis"           | has{(('1',),)}  | dble_information |



  Scenario: show @@sql.sum  && show @@sql.sum.user && show @@sql.sum.table  #2
  ##| ID   | USER | R 读的次数   | W 写的次数   | R%   | MAX 最大并发数  | NET_IN | NET_OUT | TIME_COUNT query在四个时间区间的个数分布，四个区间分别是前一天22-06 ,06-13 ,13-18，18-22   | TTL_COUNT query耗时在四个时间级别内的个数分布，分别是10毫秒内,10-200毫秒内,1秒内,超过1秒   | LAST_TIME           |
  ##| ID   | TABLE | R 读的次数   | W 写的次数   | R%   | RELATABLE 关联表的名称 | RELACOUNT 关联表的个数 | LAST_TIME           |
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
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test1" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test2" password="111111" schemas="schema1" tenant="ten1"/>
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DenableStatisticAnalysis=1
      """
    Then restart dble in "dble-1" success
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

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.sum.user  | hasStr{'test'} | 5       |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql1"
      | sql            |
      | show @@sql.sum |
    Then check resultset "sql1" has lines with following column values and has "1" lines
      | ID-0 | USER-1 | R-2 | W-3 | R%-4 | MAX-5 |
      | 1    | test   | 3   | 8   | 0.27 | 1     |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql2"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql2" has lines with following column values and has "1" lines
      | ID-0 | TABLE-1         | R-2 | W-3 | R%-4 | RELATABLE-5           | RELACOUNT-6 |
      | 1    | schema1.test    | 3   | 8   | 0.27 | schema1.test,         | 1,          |

   ### case 2: 多语句
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | db      | expect  |
      | conn_2 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,k varchar(1500))                        | schema1 | success |
      | conn_2 | False   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b',1100)) | schema1 | success |
      | conn_2 | true    | update sharding_4_t1 set k="c" where id=3;alter table sharding_4_t1 drop column k                            | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                 | timeout |
      | conn_1 | False   | show @@sql.sum       | length{(1)}                            | 5       |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql3"
      | sql                  |
      | show @@sql.sum.user  |
    Then check resultset "sql3" has lines with following column values and has "1" lines
      | ID-0 | USER-1 | R-2 | W-3  | R%-4 | MAX-5 |
      | 1    | test   | 3   | 14   | 0.18 | 1     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql4"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql4" has lines with following column values and has "2" lines
      | ID-0 | TABLE-1                  | R-2 | W-3 | R%-4 | RELATABLE-5           | RELACOUNT-6 |
      | 1    | schema1.test             | 3   | 8   | 0.27 | schema1.test,         | 1,          |
      | 2    | schema1.sharding_4_t1    | 0   | 6   | 0.00 | NULL                  | NULL        |

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
      | conn   | toClose | sql                  | expect                | timeout  |
      | conn_1 | False   | show @@sql.sum.user  | length{(2)}           | 5        |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql5"
      | sql                  |
      | show @@sql.sum.user  |
    Then check resultset "sql5" has lines with following column values and has "2" lines
      | ID-0 | USER-1 | R-2 | W-3  | R%-4 | MAX-5 |
      | 1    | test   | 3   | 14   | 0.18 | 1     |
      | 2    | test1  | 3   | 5    | 0.38 | 1     |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql6"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql6" has lines with following column values and has "2" lines
      | ID-0 | TABLE-1                  | R-2 | W-3  | R%-4 | RELATABLE-5           | RELACOUNT-6 |
      | 1    | schema1.test             | 4   | 12   | 0.25 | schema1.test,         | 1,          |
      | 2    | schema1.sharding_4_t1    | 2   | 7    | 0.22 | schema1.sharding_4_t1, schema1.test,         | 1, 2,          |

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

    ###不记录错误语句   show + set  但是view select 1 select user() 记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                            | timeout  |
      | conn_1 | False   | show @@sql.sum       | length{(2)}                                                                       | 5        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql7"
      | sql                  |
      | show @@sql.sum.user  |
    Then check resultset "sql7" has lines with following column values and has "2" lines
      | ID-0 | USER-1 | R-2 | W-3  | R%-4 | MAX-5 |
      | 1    | test   | 3   | 14   | 0.18 | 1     |
      | 2    | test1  | 7   | 7    | 0.50 | 1     |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql8"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql8" has lines with following column values and has "3" lines
      | ID-0 | TABLE-1                  | R-2 | W-3  | R%-4 | RELATABLE-5           | RELACOUNT-6 |
      | 1    | schema1.test             | 4   | 13   | 0.24 | schema1.test,         | 1,          |
      | 2    | schema1.sharding_4_t1    | 2   | 7    | 0.22 | schema1.sharding_4_t1, schema1.test,         | 1, 2,          |
      | 3    | schema1.view_test        | 0   | 1    | 0.00 | NULL         | NULL        |

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
      | conn_1 | False   | show @@sql.sum       | length{(2)}                                                                       |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql9"
      | sql                  |
      | show @@sql.sum.user  |
    Then check resultset "sql9" has lines with following column values and has "2" lines
      | ID-0 | USER-1 | R-2 | W-3  | R%-4 | MAX-5 |
      | 1    | test   | 3   | 14   | 0.18 | 1     |
      | 2    | test1  | 7   | 7    | 0.50 | 1     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql10"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql10" has lines with following column values and has "3" lines
      | ID-0 | TABLE-1                  | R-2 | W-3  | R%-4 | RELATABLE-5           | RELACOUNT-6 |
      | 1    | schema1.test             | 4   | 13   | 0.24 | schema1.test,         | 1,          |
      | 2    | schema1.sharding_4_t1    | 2   | 7    | 0.22 | schema1.sharding_4_t1, schema1.test,         | 1, 2,          |
      | 3    | schema1.view_test        | 0   | 1    | 0.00 | NULL         | NULL        |

    ### case 6:记录除了管理端用户外的用户执行的sql
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql      | expect   |
      | rw1   | 111111    | conn_11 | true     | select 1 | success  |
      | ana1  | 111111    | conn_12 | true     | select 1 | success  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                                                                            | timeout  |
      | conn_1 | False   | show @@sql.sum       | length{(4)}                                                                       | 5        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql11"
      | sql                  |
      | show @@sql.sum.user  |
    Then check resultset "sql11" has lines with following column values and has "4" lines
      | USER-1 | R-2 | W-3  | R%-4 | MAX-5 |
      | test   | 3   | 14   | 0.18 | 1     |
      | test1  | 7   | 7    | 0.50 | 1     |
      | rw1    | 1   | 0    | 1.00 | 1     |
      | ana1   | 1   | 0    | 1.00 | 1     |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql12"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql12" has lines with following column values and has "3" lines
      | ID-0 | TABLE-1                  | R-2 | W-3  | R%-4 | RELATABLE-5           | RELACOUNT-6 |
      | 1    | schema1.test             | 4   | 13   | 0.24 | schema1.test,         | 1,          |
      | 2    | schema1.sharding_4_t1    | 2   | 7    | 0.22 | schema1.sharding_4_t1, schema1.test,         | 1, 2,          |
      | 3    | schema1.view_test        | 0   | 1    | 0.00 | NULL                  | NULL        |

     ### case 7: show @@sql xxx true 会重置清空数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect      | timeout |
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
      | test2:ten1 | 111111 | conn_13 | true    | select 21 | success |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect      | timeout  |
      | conn_1 | False   | show @@sql.sum       | length{(3)} | 5        |
      | conn_1 | False   | show @@sql.sum.table | length{(0)} | 5        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql13"
      | sql                  |
      | show @@sql.sum.user  |
    Then check resultset "sql13" has lines with following column values and has "3" lines
      | USER-1       | R-2 | W-3  | R%-4 | MAX-5 |
      | test         | 1   | 0    | 1.00 | 1     |
      | test1        | 1   | 0    | 1.00 | 1     |
      | test2:ten1   | 1   | 0    | 1.00 | 1     |

    ##case 9:samplingRate对命令不影响
    Then execute admin cmd "reload @@samplingRate=0"
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                                                                                                                                                                                                                    | expect  | db      |
      | conn_21 | False   | drop table if exists test;drop table if exists sharding_2_t1;drop table if exists schema2.global2;drop table if exists schema2.sharding2;drop table if exists schema2.sing1                                                                            | success | schema1 |
      | conn_21 | False   | create table test (id int,name char(20));create table sharding_2_t1 (id int,name char(20));create table schema2.global2 (id int,name char(20));create table schema2.sharding2 (id int,name char(20));create table schema2.sing1 (id int,name char(20)) | success | schema1 |
      | conn_21 | False   | insert into test values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4');insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                                                                               | success | schema1 |
      | conn_21 | False   | insert into schema2.global2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4');insert into schema2.sharding2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                                                                | success | schema1 |
      | conn_21 | true    | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4');insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                                                                             | success | schema1 |
      | conn_21 | False   | insert into test(id, name) select id,name from schema2.global2;insert into schema2.sing1(id, name) select id,name from schema2.sing1;insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                     | success | schema1 |
      | conn_21 | False   | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1;select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                                                               | success | schema1 |
      | conn_21 | False   | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1;select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                                                                    | success | schema1 |
      | conn_21 | False   | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1);update test set name= '4' where name in (select name from schema2.global2 )                                                                         | success | schema1 |
      | conn_21 | False   | begin;update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2;begin;commit;rollback;begin;select * from schema2.sing1 as tmp                                                                                              | success | schema1 |
      | conn_21 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1                                                                                                                                 | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout  |
      | conn_1 | False   | show @@sql.sum.user  | length{(3)}    | 5        |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql14"
      | sql              |
      | show @@sql.sum   |
    Then check resultset "sql14" has lines with following column values and has "3" lines
      | USER-1       | R-2 | W-3  | R%-4 | MAX-5 |
      | test         | 6   | 23   | 0.21 | 1     |
      | test1        | 1   | 0    | 1.00 | 1     |
      | test2:ten1   | 1   | 0    | 1.00 | 1     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql15"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql15" has lines with following column values and has "5" lines
      | ID-0 | TABLE-1               | R-2 | W-3 | R%-4 | RELATABLE-5                                   | RELACOUNT-6 |
      | 1    | schema1.sharding_2_t1 | 2   | 5   | 0.29 | schema2.sharding2, schema2.sing1,             | 3, 1,       |
      | 2    | schema1.test          | 1   | 6   | 0.14 | schema1.sharding_2_t1, schema2.global2,       | 1, 3,       |
      | 3    | schema2.sing1         | 1   | 4   | 0.20 | schema2.sing1,                                | 1,          |
      | 4    | schema2.sharding2     | 0   | 5   | 0.00 | schema2.sharding2, schema1.sharding_2_t1,     | 1, 1,       |
      | 5    | schema2.global2       | 1   | 3   | 0.25 | schema1.sharding_2_t1,                        | 1,          |


    Given execute sql "1050" times in "dble-1" at concurrent 1000
     | user  | sql                                                                                             | db      |
     | test1 | begin;begin;update test set name= '4' where name in (select name from schema2.global2 )         | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout  |
      | conn_1 | False   | show @@sql.sum.user  | length{(3)}    | 5        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql16"
      | sql              |
      | show @@sql.sum   |
    Then check resultset "sql16" has lines with following column values and has "3" lines
      | USER-1       | R-2 | W-3  | R%-4 | MAX-5 |
      | test         | 6   | 23   | 0.21 | 1     |
      | test1        | 1   | 1050 | 0.00 | 1     |
      | test2:ten1   | 1   | 0    | 1.00 | 1     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql16"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql16" has lines with following column values and has "5" lines
      | TABLE-1               | R-2 | W-3    | R%-4 | RELATABLE-5                                   | RELACOUNT-6 |
      | schema1.test          | 1   | 1056   | 0.00 | schema1.sharding_2_t1, schema2.global2,       | 1, 1053,    |

    ### case 10: 读写分离用户的各种sql组合
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                     | expect  | db  |
      | rw1  | 111111 | conn_3 | False   | drop table if exists test_table;create table test_table(id int,name varchar(20),age int)                                                                | success | db1 |
      | rw1  | 111111 | conn_3 | true    | insert into test_table values (1,'1',1),(2, '2',2)                                                                                                      | success | db1 |
      | rw1  | 111111 | conn_3 | False   | begin;select * from test_table;insert into test_table values(5,'name5',5);commit                                                                        | success | db1 |

      | rw1  | 111111 | conn_4 | False   | drop table if exists test_table1                                                                                                                        | success | db2 |
      | rw1  | 111111 | conn_4 | False   | create table test_table1(id int,name varchar(20),age int);insert into test_table1 values (1,'1',1),(2, '2',2)                                           | success | db2 |
      | rw1  | 111111 | conn_4 | False   | start transaction;update test_table1 set age =33 where id=1;delete from test_table1 where id=5;update test_table1 set age =44 where id=100;begin;commit | success | db2 |

      | rw1  | 111111 | conn_3 | False   | insert into test_table(id,name,age) select id,name,age from test_table;update test_table set name='test_name' where id in (select id from db2.test_table1 )  | success | db1 |
      | rw1  | 111111 | conn_3 | False   | update test_table a,db2.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2 ;select n.id,s.name from test_table n join db2.test_table1 s on n.id=s.id    | success | db1 |
      | rw1  | 111111 | conn_3 | False   | begin;select * from test_table where age <> (select age from db2.test_table1 where id !=1)                                                                   | success | db1 |
      | rw1  | 111111 | conn_3 | False   | begin;delete test_table from test_table,db2.test_table1 where test_table.id=1 and db2.test_table1.id =1                                                      | success | db1 |
      | rw1  | 111111 | conn_3 | False   | delete from db2.test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp))                                      | success | db1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout  |
      | conn_1 | False   | show @@sql.sum.user  | length{(4)}    | 5        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql17"
      | sql              |
      | show @@sql.sum   |
    Then check resultset "sql17" has lines with following column values and has "4" lines
      | USER-1       | R-2 | W-3  | R%-4 | MAX-5 |
      | test         | 6   | 23   | 0.21 | 1     |
      | test1        | 1   | 1050 | 0.00 | 1     |
      | test2:ten1   | 1   | 0    | 1.00 | 1     |
      | rw1          | 3   | 15   | 0.17 | 1     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql18"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql18" has lines with following column values and has "7" lines
      | TABLE-1          | R-2 | W-3 | R%-4 | RELATABLE-5                         | RELACOUNT-6 |
      | db1.test_table   | 3   | 8   | 0.27 | db2.test_table1, db1.test_table,    | 5, 3,       |
      | db2.test_table1  | 0   | 7   | 0.00 | db2.test_table1, db1.test_table,    | 2, 1,       |

    ### case 11: ps协议
    Then execute prepared sql "select %s from test where id =%s" with params "(name,1);(id,3)" on db "schema1" and user "test"
    Then execute prepared sql "select %s from test_table where id =%s" with params "(name,1);(id,3)" on db "db1" and user "rw1"

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout  |
      | conn_1 | False   | show @@sql.sum.user  | length{(4)}    | 5        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql18"
      | sql              |
      | show @@sql.sum   |
    Then check resultset "sql18" has lines with following column values and has "4" lines
      | USER-1       | R-2 | W-3  | R%-4 | MAX-5 |
      | test         | 8   | 23   | 0.26 | 1     |
      | test1        | 1   | 1050 | 0.00 | 1     |
      | test2:ten1   | 1   | 0    | 1.00 | 1     |
      | rw1          | 5   | 15   | 0.25 | 1     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql19"
      | sql                  |
      | show @@sql.sum.table |
    Then check resultset "sql19" has lines with following column values and has "7" lines
      | TABLE-1          | R-2 | W-3    | R%-4 | RELATABLE-5                        | RELACOUNT-6 |
      | db1.test_table   | 5   | 8      | 0.38 | db2.test_table1, db1.test_table,   | 5, 3,          |
      | schema1.test     | 3   | 1056   | 0.00 | schema1.sharding_2_t1, schema2.global2,   | 1, 1053,     |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: show @@sql && show @@sql.high show @@sql.slow show @@sql.resultset  #3
  ##show @@sql | ID   | USER | START_TIME          | EXECUTE_TIME | SQL    |
  ## show @@sql.high | ID   | USER | FREQUENCY  sql曾被执行次数 | AVG_TIME | MAX_TIME | MIN_TIME | EXECUTE_TIME | LAST_TIME    | SQL    |
  ##show @@sql.slow | USER | START_TIME          | EXECUTE_TIME | SQL       |
  ##show @@sql.resultset | ID | USER | FREQUENCY  sql曾被执⾏次数 | SQL | RESULTSET_SIZE 结果集的⼤⼩ |
  ## 根据sql_log过滤得到
    ###配置所有的用户 管理端用户  分库分表用户 读写分离用户  分析用户
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
       """
       <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="2000" minCon="10" primary="true" />
       </dbGroup>

       <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
          <heartbeat>select 1</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.10:9004" user="test" maxCon="2000" minCon="10" primary="true" databaseType="clickhouse"/>
       </dbGroup>
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test1" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test2" password="111111" schemas="schema1" tenant="ten1"/>
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
      """
    Then execute admin cmd "reload @@config"
    Then execute admin cmd "reload @@slow_query.time=0"

    ##ddl  dml
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                           | db      | expect  |
      | conn_0 | False    | drop table if exists test                     | schema1 | success |
      | conn_0 | False    | create table test(id int,k longblob)          | schema1 | success |
      | conn_0 | False    | insert into test value (1, repeat('a', 1100)) | schema1 | success |
      | conn_0 | False    | insert into test value (2, repeat('b', 1500)) | schema1 | success |
      | conn_0 | False    | insert into test value (3, repeat('c', 524290))  | schema1 | success |
      | conn_0 | False    | update test set k="c" where id=1              | schema1 | success |
      | conn_0 | False    | select * from test                            | schema1 | success |
      | conn_0 | False    | select * from test order by id limit 1        | schema1 | success |
      | conn_0 | False    | select * from test where id=2                 | schema1 | success |
      | conn_0 | False    | delete from test where id=1                   | schema1 | success |
      | conn_0 | True     | alter table test drop column k                | schema1 | success |
    ### case 1: dml ddl 都被记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | conn_1 | False   | show @@sql           | length{(11)}    | 10      |
      | conn_1 | False   | show @@sql.high      | length{(9)}     |         |
      | conn_1 | False   | show @@sql.slow      | length{(11)}    |         |
      | conn_1 | False   | show @@sql.resultset | length{(1)}     |         |
      | conn_1 | False   | show @@sql.large     | length{(0)}     |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql1"
      | sql        |
      | show @@sql |
    Then check resultset "sql1" has lines with following column values
      | USER-1 | SQL-4                                         |
      | test   | drop table if exists test                     |
      | test   | create table test(id int,k longblob)          |
      | test   | insert into test value (1, repeat('a', 1100)) |
      | test   | insert into test value (2, repeat('b', 1500)) |
      | test   | insert into test value (3, repeat('c', 524290))  |
      | test   | update test set k="c" where id=1              |
      | test   | select * from test                            |
      | test   | select * from test order by id limit 1        |
      | test   | select * from test where id=2                 |
      | test   | delete from test where id=1                   |
      | test   | alter table test drop column k                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high1"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high1" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                           |
      | test   | 1           | ALTER TABLE test  DROP COLUMN k                 |
      | test   | 1           | CREATE TABLE test (  id int,  k longblob )      |
      | test   | 1           | DELETE FROM test WHERE id = ?                   |
      | test   | 1           | DROP TABLE IF EXISTS test                       |
      | test   | 3           | INSERT INTO test VALUES (?, repeat(?, ?))       |
      | test   | 1           | select * from test                              |
      | test   | 1           | SELECT * FROM test ORDER BY id LIMIT ?          |
      | test   | 1           | SELECT * FROM test WHERE id = ?                 |
      | test   | 1           | UPDATE test SET k = ? WHERE id = ?              |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow1"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow1" has lines with following column values
      | USER-0 | SQL-3                                         |
      | test   | drop table if exists test                     |
      | test   | create table test(id int,k longblob)          |
      | test   | insert into test value (1, repeat('a', 1100)) |
      | test   | insert into test value (2, repeat('b', 1500)) |
      | test   | insert into test value (3, repeat('c', 524290))  |
      | test   | update test set k="c" where id=1              |
      | test   | select * from test                            |
      | test   | select * from test order by id limit 1        |
      | test   | select * from test where id=2                 |
      | test   | delete from test where id=1                   |
      | test   | alter table test drop column k                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset1"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset1" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-3               | RESULTSET_SIZE-4 |
      | test   | 1           | select * from test  | 525920           |

   ### case 2: 多语句
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | db      | expect  |
      | conn_2 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,k varchar(1500))                        | schema1 | success |
      | conn_2 | False   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b',1100)) | schema1 | success |
      | conn_2 | true    | update sharding_4_t1 set k="c" where id=3;alter table sharding_4_t1 drop column k                            | schema1 | success |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect            | timeout |
      | conn_1 | False   | show @@sql           | length{(17)}      | 10      |
      | conn_1 | False   | show @@sql.high      | length{(14)}      |         |
      | conn_1 | False   | show @@sql.slow      | length{(17)}      |         |
      | conn_1 | False   | show @@sql.resultset | length{(1)}       |         |
      | conn_1 | False   | show @@sql.large     | length{(0)}       |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql2"
      | sql        |
      | show @@sql |
    Then check resultset "sql2" has lines with following column values
      | USER-1 | SQL-4                                                  |
      | test   | drop table if exists sharding_4_t1                     |
      | test   | create table sharding_4_t1(id int,k varchar(1500))     |
      | test   | insert into sharding_4_t1 value (1, repeat('a', 1100)) |
      | test   | insert into sharding_4_t1 value (2, repeat('b',1100))  |
      | test   | update sharding_4_t1 set k="c" where id=3              |
      | test   | alter table sharding_4_t1 drop column k                |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high2"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high2" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                                    |
      | test   | 1           | ALTER TABLE test  DROP COLUMN k                          |
      | test   | 1           | DELETE FROM test WHERE id = ?                            |
      | test   | 1           | DROP TABLE IF EXISTS test                                |
      | test   | 3           | INSERT INTO test VALUES (?, repeat(?, ?))                |
      | test   | 1           | select * from test                                       |
      | test   | 1           | SELECT * FROM test ORDER BY id LIMIT ?                   |
      | test   | 1           | SELECT * FROM test WHERE id = ?                          |
      | test   | 1           | UPDATE test SET k = ? WHERE id = ?                       |
      | test   | 1           | ALTER TABLE sharding_4_t1  DROP COLUMN k                 |
      | test   | 1           | CREATE TABLE sharding_4_t1 (  id int,  k varchar(1500) ) |
      | test   | 1           | DROP TABLE IF EXISTS sharding_4_t1                       |
      | test   | 2           | INSERT INTO sharding_4_t1 VALUES (?, repeat(?, ?))       |
      | test   | 1           | UPDATE sharding_4_t1 SET k = ? WHERE id = ?              |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow2"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow2" has lines with following column values
      | USER-0 | SQL-3                                                  |
      | test   | drop table if exists sharding_4_t1                     |
      | test   | create table sharding_4_t1(id int,k varchar(1500))     |
      | test   | insert into sharding_4_t1 value (1, repeat('a', 1100)) |
      | test   | insert into sharding_4_t1 value (2, repeat('b',1100))  |
      | test   | update sharding_4_t1 set k="c" where id=3              |
      | test   | alter table sharding_4_t1 drop column k                |

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
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                | timeout |
      | conn_1 | False   | show @@sql           | length{(34)}          | 10      |
      | conn_1 | False   | show @@sql.high      | length{(24)}          |         |
      | conn_1 | False   | show @@sql.slow      | length{(34)}          |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql3"
      | sql        |
      | show @@sql |
    Then check resultset "sql3" has lines with following column values
      | USER-1 | SQL-4                                                                                                  |
      | test1  | begin                                                                                                  |
      | test1  | select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id =1                             |
      | test1  | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                                                 |
      | test1  | commit                                                                                                 |
      | test1  | start transaction                                                                                      |
      | test1  | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp)) |
      | test1  | rollback                                                                                               |
      | test1  | set autocommit=0                                                                                       |
      | test1  | insert into test values (4)                                                                            |
      | test1  | set autocommit=1                                                                                       |
      | test1  | insert into test values (5)                                                                            |
      | test1  | begin                                                                                                  |
      | test1  | insert into test values (6)                                                                            |
      | test1  | begin                                                                                                  |
      | test1  | insert into test values (7)                                                                            |
      | test1  | rollback                                                                                               |
      | test1  | select * from test                                                                                     |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high3"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high3" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                                                                                  |
      | test1  | 3           | begin                                                                                                  |
      | test1  | 1           | commit                                                                                                 |
      | test1  | 1           | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp)) |
      | test1  | 4           | INSERT INTO test VALUES (?)                                                                            |
      | test1  | 2           | rollback                                                                                               |
      | test1  | 1           | SELECT * FROM sharding_4_t1                                                                            |
      | test1  | 1           | SELECT * FROM sharding_4_t1 a  INNER JOIN test b ON a.id = b.id WHERE a.id = ?                         |
      | test1  | 1           | select * from test                                                                                     |
      | test1  | 2           | SET autocommit = ?                                                                                     |
      | test1  | 1           | start transaction                                                                                      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow3"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow3" has lines with following column values
      | USER-0 | SQL-3                                                                                                  |
      | test1  | begin                                                                                                  |
      | test1  | select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id =1                             |
      | test1  | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                                                 |
      | test1  | commit                                                                                                 |
      | test1  | start transaction                                                                                      |
      | test1  | delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp)) |
      | test1  | rollback                                                                                               |
      | test1  | set autocommit=0                                                                                       |
      | test1  | insert into test values (4)                                                                            |
      | test1  | set autocommit=1                                                                                       |
      | test1  | insert into test values (5)                                                                            |
      | test1  | begin                                                                                                  |
      | test1  | insert into test values (6)                                                                            |
      | test1  | begin                                                                                                  |
      | test1  | insert into test values (7)                                                                            |
      | test1  | rollback                                                                                               |
      | test1  | select * from test                                                                                     |

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

    ###不记录错误语句  select + show + set + view select 1 记录
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect            | timeout |
      | conn_1 | False   | show @@sql           | length{(41)}      | 10      |
      | conn_1 | False   | show @@sql.high      | length{(31)}      |         |
      | conn_1 | False   | show @@sql.slow      | length{(41)}      |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql4"
      | sql        |
      | show @@sql |
    Then check resultset "sql4" has lines with following column values
      | USER-1 | SQL-4                                       |
      | test1  | select user()                               |
      | test1  | show tables                                 |
      | test1  | set @@trace=1                               |
      | test1  | select @@trace                              |
      | test1  | select 1                                    |
      | test1  | drop view if exists schema1.view_test       |
      | test1  | create view view_test as select * from test |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high4"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high4" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                       |
      | test1  | 1           | CREATE VIEW view_test AS SELECT * FROM test |
      | test1  | 1           | DROP VIEW IF EXISTS schema1.view_test       |
      | test1  | 1           | SELECT ?                                    |
      | test1  | 1           | select @@trace                              |
      | test1  | 1           | select user()                               |
      | test1  | 1           | SET @@trace = ?                             |
      | test1  | 1           | show tables                                 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow4"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow4" has lines with following column values
      | USER-0 | SQL-3                                       |
      | test1  | select user()                               |
      | test1  | show tables                                 |
      | test1  | set @@trace=1                               |
      | test1  | select @@trace                              |
      | test1  | select 1                                    |
      | test1  | drop view if exists schema1.view_test       |
      | test1  | create view view_test as select * from test |


   ### case 5:load data语句记录
    Given execute oscmd in "dble-1"
      """
      echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,a\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                     | expect       | db      |
      | new    | False   | load data infile '/opt/dble/data.txt' into table sharding_4_t1 character SET 'utf8' fields terminated by ',' lines terminated by '\n'   | success      | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                    | timeout |
      | conn_1 | False   | show @@sql           | length{(42)}              | 10      |
      | conn_1 | False   | show @@sql.high      | length{(32)}              |         |
      | conn_1 | False   | show @@sql.slow      | length{(42)}              |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql5"
      | sql        |
      | show @@sql |
    Then check resultset "sql5" has lines with following column values
      | USER-1 | SQL-4                                                                                                                                           |
      | test1  | load data infile '/opt/dble/data.txt' into table sharding_4_t1 character SET 'utf8' fields terminated by ',' lines terminated by '\n'           |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high5"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high5" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                                                                     |
      | test1  | 1           | LOAD DATA INFILE ? INTO TABLE sharding_4_t1 COLUMNS TERMINATED BY ? LINES TERMINATED BY ? |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow5"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow5" has lines with following column values
      | USER-0 | SQL-3                                                                                                                                           |
      | test1  | load data infile '/opt/dble/data.txt' into table sharding_4_t1 character SET 'utf8' fields terminated by ',' lines terminated by '\n'           |

    ### case 6:记录除了管理端用户外的用户执行的sql
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql      | expect   |
      | rw1   | 111111    | conn_11 | true     | select 1 | success  |
      | ana1  | 111111    | conn_12 | true     | select 1 | success  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                  | timeout |
      | conn_1 | False   | show @@sql           | length{(44)}            | 10      |
      | conn_1 | False   | show @@sql.high      | length{(34)}            |         |
      | conn_1 | False   | show @@sql.slow      | length{(44)}            |         |

     ### case 7: show @@sql xxx true 命令失效  清理数据是truncate sql_log
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                               | expect                | timeout |
      | conn_1 | False   | show @@sql true                   | Unsupported statement |         |
      | conn_1 | False   | show @@sql.high true              | Unsupported statement |         |
      | conn_1 | False   | show @@sql.slow true              | Unsupported statement |         |
      | conn_1 | False   | show @@sql.resultset true         | Unsupported statement |         |
      | conn_1 | False   | show @@sql.large true            | Unsupported statement |         |
      | conn_1 | False   | truncate dble_information.sql_log | success               | 10      |
      | conn_1 | False   | show @@sql.high                   | length{(0)}           | 10      |
      | conn_1 | False   | show @@sql                        | length{(0)}           |         |
      | conn_1 | False   | show @@sql.slow                   | length{(0)}           |         |
      | conn_1 | false   | show @@sql.resultset               | length{(0)}          |         |

    ### case 8: 一个sql执行多次 加上租户信息，验证默认阈值 1024
    Given execute "user" sql "1025" times in "dble-1" together use 1025 connection not close
      | user       | sql                                     | db      |
      | test2:ten1 | select * from test where id ={}         | schema1 |
    ##阈值是1024
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql           | length{(1024)} | 10      |
      | conn_1 | False   | show @@sql.high      | length{(1)}    |         |
      | conn_1 | False   | show @@sql.slow      | length{(1024)} |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high8"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high8" has lines with following column values
      | USER-1     | FREQUENCY-2 | SQL-8                           |
      | test2:ten1 | 1024        | SELECT * FROM test WHERE id = ? |

    Then execute sql in "dble-1" in "user" mode
      | user       | passwd | conn    | toClose | sql       | expect  |
      | test       | 111111 | conn_11 | true    | select 1  | success |
      | test1      | 111111 | conn_12 | true    | select 2  | success |
      | test2:ten1 | 111111 | conn_13 | true    | select 21 | success |
    ### 这个1024是根据全局txd计算的，
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql           | length{(1024)} | 10      |
      | conn_1 | true    | show @@sql.high      | length{(4)}    |         |
      | conn_1 | False   | show @@sql.slow      | length{(1024)} |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high9"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high9" has lines with following column values
      | USER-1     | FREQUENCY-2 | SQL-8                           |
      | test2:ten1 | 1021        | SELECT * FROM test WHERE id = ? |
      | test       | 1           | SELECT ?                        |
      | test1      | 1           | SELECT ?                        |
      | test2:ten1 | 1           | SELECT ?                        |

     ### case 9：reload @@user_stat and reload @@sqlslow 命令失效
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect                   |
      | conn_1 | true    | reload @@user_stat   | Unsupported statement    |
      | conn_1 | true    | reload @@sqlslow=0   | Unsupported statement    |
    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"

    ### case 10：多语句事务复杂查询 和设置慢sql时间阈值(要bootstrap.cnf更改参数需要先去bootstrap.dynamic.cnf删除参数)
    Given update file content "/opt/dble/conf/bootstrap.dynamic.cnf" in "dble-1" with sed cmds
      """
      /sqlSlowTime/d
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DsqlSlowTime=1000000
      $a -DmaxResultSet=1
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose | sql                                                                                                                                                                                                                                                    | expect  | db      |
      | conn_21 | False   | drop table if exists test;drop table if exists sharding_2_t1;drop table if exists schema2.global2;drop table if exists schema2.sharding2;drop table if exists schema2.sing1                                                                            | success | schema1 |
      | conn_21 | False   | create table test (id int,name char(20));create table sharding_2_t1 (id int,name char(20));create table schema2.global2 (id int,name char(20));create table schema2.sharding2 (id int,name char(20));create table schema2.sing1 (id int,name char(20)) | success | schema1 |
      | conn_21 | False   | insert into test values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4');insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                                                                               | success | schema1 |
      | conn_21 | False   | insert into schema2.global2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4');insert into schema2.sharding2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                                                                | success | schema1 |
      | conn_21 | true    | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4');insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                                                                             | success | schema1 |
      | conn_21 | False   | insert into test(id, name) select id,name from schema2.global2;insert into schema2.sing1(id, name) select id,name from schema2.sing1;insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                     | success | schema1 |
      | conn_21 | False   | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1;select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                                                               | success | schema1 |
      | conn_21 | False   | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1;select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                                                                    | success | schema1 |
      | conn_21 | False   | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1);update test set name= '4' where name in (select name from schema2.global2 )                                                                         | success | schema1 |
      | conn_21 | False   | begin;update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2;begin;commit;rollback;begin;select * from schema2.sing1 as tmp                                                                                              | success | schema1 |
      | conn_21 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1                                                                                                                                 | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | conn_1 | False   | show @@sql           | length{(33)}    | 10      |
      | conn_1 | False   | show @@sql.high      | length{(31)}    |         |
      | conn_1 | False   | show @@sql.slow      | length{(0)}     |         |
      | conn_1 | False   | show @@sql.resultset | length{(28)}    |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql10"
      | sql        |
      | show @@sql |
    Then check resultset "sql10" has lines with following column values
      | ID-0 | USER-1 | SQL-4                                                                                                                  |
      | 20   | test   | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                         |
      | 21   | test   | select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                              |
      | 22   | test   | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1                                |
      | 23   | test   | select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                            |
      | 24   | test   | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1)                     |
      | 25   | test   | update test set name= '4' where name in (select name from schema2.global2 )                                            |
      | 26   | test   | begin                                                                                                                  |
      | 27   | test   | update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2                                   |
      | 28   | test   | begin                                                                                                                  |
      | 29   | test   | commit                                                                                                                 |
      | 30   | test   | rollback                                                                                                               |
      | 31   | test   | begin                                                                                                                  |
      | 32   | test   | select * from schema2.sing1 as tmp                                                                                     |
      | 33   | test   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1 |
      | 1    | test   | drop table if exists test                                                                                              |
      | 2    | test   | drop table if exists sharding_2_t1                                                                                     |
      | 3    | test   | drop table if exists schema2.global2                                                                                   |
      | 4    | test   | drop table if exists schema2.sharding2                                                                                 |
      | 5    | test   | drop table if exists schema2.sing1                                                                                     |
      | 6    | test   | create table test (id int,name char(20))                                                                               |
      | 7    | test   | create table sharding_2_t1 (id int,name char(20))                                                                      |
      | 8    | test   | create table schema2.global2 (id int,name char(20))                                                                    |
      | 9    | test   | create table schema2.sharding2 (id int,name char(20))                                                                  |
      | 10   | test   | create table schema2.sing1 (id int,name char(20))                                                                      |
      | 11   | test   | insert into test values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                                |
      | 12   | test   | insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                       |
      | 13   | test   | insert into schema2.global2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                     |
      | 14   | test   | insert into schema2.sharding2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                   |
      | 15   | test   | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                       |
      | 16   | test   | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                              |
      | 17   | test   | insert into test(id, name) select id,name from schema2.global2                                                         |
      | 18   | test   | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                  |
      | 19   | test   | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                          |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high10"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high10" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                                                                                                       |
      | test   | 1           | CREATE TABLE schema2.global2 (  id int,  name char(20) )                                                                    |
      | test   | 1           | CREATE TABLE schema2.sharding2 (  id int,  name char(20) )                                                                  |
      | test   | 1           | CREATE TABLE schema2.sing1 (  id int,  name char(20) )                                                                      |
      | test   | 1           | CREATE TABLE sharding_2_t1 (  id int,  name char(20) )                                                                      |
      | test   | 1           | CREATE TABLE test (  id int,  name char(20) )                                                                               |
      | test   | 1           | DROP TABLE IF EXISTS schema2.global2                                                                                        |
      | test   | 1           | DROP TABLE IF EXISTS schema2.sharding2                                                                                      |
      | test   | 1           | DROP TABLE IF EXISTS schema2.sing1                                                                                          |
      | test   | 1           | DROP TABLE IF EXISTS sharding_2_t1                                                                                          |
      | test   | 1           | DROP TABLE IF EXISTS test                                                                                                   |
      | test   | 1           | INSERT INTO schema2.global2 VALUES (?, ?)                                                                                   |
      | test   | 1           | INSERT INTO schema2.sharding2 VALUES (?, ?)                                                                                 |
      | test   | 1           | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                               |
      | test   | 1           | INSERT INTO schema2.sing1 VALUES (?, ?)                                                                                     |
      | test   | 1           | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                       |
      | test   | 1           | INSERT INTO sharding_2_t1 VALUES (?, ?)                                                                                     |
      | test   | 1           | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                                   |
      | test   | 1           | INSERT INTO test VALUES (?, ?)                                                                                              |
      | test   | 1           | insert into test(id, name) select id,name from schema2.global2                                                              |
      | test   | 3           | begin                                                                                                                       |
      | test   | 1           | commit                                                                                                                      |
      | test   | 1           | DELETE schema1.sharding_2_t1 FROM sharding_2_t1, schema2.sharding2 WHERE sharding_2_t1.id = ?  AND schema2.sharding2.id = ? |
      | test   | 1           | rollback                                                                                                                    |
      | test   | 1           | SELECT * FROM schema2.global2 a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                               |
      | test   | 1           | select * from schema2.sing1 as tmp                                                                                          |
      | test   | 1           | SELECT * FROM sharding_2_t1 a  INNER JOIN schema2.sing1 b ON a.name = b.name WHERE a.id = ?                                 |
      | test   | 1           | SELECT * FROM sharding_2_t1 WHERE name IN (  SELECT name  FROM schema2.sharding2  WHERE id != ? )                           |
      | test   | 1           | SELECT * FROM test a  INNER JOIN sharding_2_t1 b ON a.name = b.name WHERE a.id = ?                                          |
      | test   | 1           | UPDATE sharding_2_t1 a, schema2.sharding2 b SET a.name = b.name WHERE a.id = ?  AND b.id = ?                                |
      | test   | 1           | UPDATE test SET name = ? WHERE name = (   SELECT name   FROM schema2.global2   ORDER BY id DESC   LIMIT ?  )                |
      | test   | 1           | UPDATE test SET name = ? WHERE name IN (   SELECT name   FROM schema2.global2  )                                            |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_resultset10"
      | sql                  |
      | show @@sql.resultset |
    Then check resultset "sql_resultset10" has lines with following column values
      | ID-0 | USER-1 | FREQUENCY-2 | SQL-3                                                                                                                  | RESULTSET_SIZE-4 |
      | 1    | test   | 1           | drop table if exists test                                                                                              | 44               |
      | 2    | test   | 1           | drop table if exists sharding_2_t1                                                                                     | 22               |
      | 3    | test   | 1           | drop table if exists schema2.global2                                                                                   | 44               |
      | 4    | test   | 1           | drop table if exists schema2.sharding2                                                                                 | 22               |
      | 5    | test   | 1           | drop table if exists schema2.sing1                                                                                     | 11               |
      | 6    | test   | 1           | create table test (id int,name char(20))                                                                               | 44               |
      | 7    | test   | 1           | create table sharding_2_t1 (id int,name char(20))                                                                      | 22               |
      | 8    | test   | 1           | create table schema2.global2 (id int,name char(20))                                                                    | 44               |
      | 9    | test   | 1           | create table schema2.sharding2 (id int,name char(20))                                                                  | 22               |
      | 10   | test   | 1           | create table schema2.sing1 (id int,name char(20))                                                                      | 11               |
      | 11   | test   | 1           | insert into test values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                                | 200              |
      | 12   | test   | 1           | insert into sharding_2_t1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                       | 100              |
      | 13   | test   | 1           | insert into schema2.global2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                     | 200              |
      | 14   | test   | 1           | insert into schema2.sharding2 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                   | 100              |
      | 15   | test   | 1           | insert into schema2.sing1 values (1,'name1'),(2,'name2'),(3,'name3'),(4,'name4')                                       | 50               |
      | 16   | test   | 1           | insert into sharding_2_t1(id, name) select id,name from schema2.sharding2                                              | 100              |
      | 17   | test   | 1           | insert into test(id, name) select id,name from schema2.global2                                                         | 200              |
      | 18   | test   | 1           | insert into schema2.sing1(id, name) select id,name from schema2.sing1                                                  | 50               |
      | 19   | test   | 1           | insert into schema2.sharding2(id, name) select id,name from schema2.sharding2                                          | 100              |
      | 20   | test   | 1           | select * from test a inner join sharding_2_t1 b on a.name=b.name where a.id =1                                         | 225              |
      | 21   | test   | 1           | select * from schema2.global2 a inner join sharding_2_t1 b on a.name=b.name where a.id =1                              | 199              |
      | 22   | test   | 1           | select * from sharding_2_t1 a inner join schema2.sing1 b on a.name=b.name where a.id =1                                | 235              |
      | 23   | test   | 1           | select * from sharding_2_t1 where name in (select name from schema2.sharding2 where id !=1)                            | 175              |
      | 24   | test   | 1           | update test set name= '3' where name = (select name from schema2.global2 order by id desc limit 1)                     | 208              |
      | 25   | test   | 1           | update test set name= '4' where name in (select name from schema2.global2 )                                            | 208              |
      | 27   | test   | 1           | update sharding_2_t1 a,schema2.sharding2 b set a.name=b.name where a.id=2 and b.id=2                                   | 52               |
      | 32   | test   | 1           | select * from schema2.sing1 as tmp                                                                                     | 205              |
      | 33   | test   | 1           | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding2 where sharding_2_t1.id=1 and schema2.sharding2.id =1 | 11               |

    Then execute admin cmd "reload @@slow_query.time=0"
    ### case 11: 读写分离用户的各种sql组合
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                     | expect  | db  |
      | rw1  | 111111 | conn_3 | False   | drop table if exists test_table;create table test_table(id int,name varchar(20),age int)                                                                | success | db1 |
      | rw1  | 111111 | conn_3 | true    | insert into test_table values (1,'1',1),(2, '2',2)                                                                                                      | success | db1 |
      | rw1  | 111111 | conn_3 | False   | begin;select * from test_table;insert into test_table values(5,'name5',5);commit                                                                        | success | db1 |

      | rw1  | 111111 | conn_4 | False   | drop table if exists test_table1                                                                                                                        | success | db2 |
      | rw1  | 111111 | conn_4 | False   | create table test_table1(id int,name varchar(20),age int);insert into test_table1 values (1,'1',1),(2, '2',2)                                           | success | db2 |
      | rw1  | 111111 | conn_4 | False   | start transaction;update test_table1 set age =33 where id=1;delete from test_table1 where id=5;update test_table1 set age =44 where id=100;begin;commit | success | db2 |

      | rw1  | 111111 | conn_3 | False   | insert into test_table(id,name,age) select id,name,age from test_table;update test_table set name='test_name' where id in (select id from db2.test_table1 )  | success | db1 |
      | rw1  | 111111 | conn_3 | False   | update test_table a,db2.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2 ;select n.id,s.name from test_table n join db2.test_table1 s on n.id=s.id    | success | db1 |
      | rw1  | 111111 | conn_3 | False   | begin;select * from test_table where age <> (select age from db2.test_table1 where id !=1)                                                                   | success | db1 |
      | rw1  | 111111 | conn_3 | False   | begin;delete test_table from test_table,db2.test_table1 where test_table.id=1 and db2.test_table1.id =1                                                      | success | db1 |
      | rw1  | 111111 | conn_3 | False   | delete from db2.test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp))                                      | success | db1 |

   ###这边show @@sql.slow逻辑性不强，数据会重新从sql_log过滤筛选得到
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | conn_1 | False   | show @@sql           | length{(58)}    | 10      |
      | conn_1 | False   | show @@sql.high      | length{(50)}    |         |
      | conn_1 | true    | show @@sql.slow      | length{(58)}    |         |
      | conn_1 | False   | show @@sql.resultset | length{(47)}    |         |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql11"
      | sql        |
      | show @@sql |
    Then check resultset "sql11" has lines with following column values
      | USER-1 | SQL-4                                                                                                                   |
      | rw1    | drop table if exists test_table                                                                                         |
      | rw1    | create table test_table(id int,name varchar(20),age int)                                                                |
      | rw1    | insert into test_table values (1,'1',1),(2, '2',2)                                                                      |
      | rw1    | begin                                                                                                                   |
      | rw1    | select * from test_table                                                                                                |
      | rw1    | insert into test_table values(5,'name5',5)                                                                              |
      | rw1    | commit                                                                                                                  |
      | rw1    | drop table if exists test_table1                                                                                        |
      | rw1    | create table test_table1(id int,name varchar(20),age int)                                                               |
      | rw1    | insert into test_table1 values (1,'1',1),(2, '2',2)                                                                     |
      | rw1    | start transaction                                                                                                       |
      | rw1    | update test_table1 set age =33 where id=1                                                                               |
      | rw1    | delete from test_table1 where id=5                                                                                      |
      | rw1    | update test_table1 set age =44 where id=100                                                                             |
      | rw1    | begin                                                                                                                   |
      | rw1    | commit                                                                                                                  |
      | rw1    | insert into test_table(id,name,age) select id,name,age from test_table                                                  |
      | rw1    | update test_table set name='test_name' where id in (select id from db2.test_table1 )                                    |
      | rw1    | update test_table a,db2.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2                                         |
      | rw1    | select n.id,s.name from test_table n join db2.test_table1 s on n.id=s.id                                                |
      | rw1    | begin                                                                                                                   |
      | rw1    | select * from test_table where age <> (select age from db2.test_table1 where id !=1)                                    |
      | rw1    | begin                                                                                                                   |
      | rw1    | delete test_table from test_table,db2.test_table1 where test_table.id=1 and db2.test_table1.id =1                       |
      | rw1    | delete from db2.test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high11"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high11" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                                                                                                   |
      | rw1    | 4           | begin                                                                                                                   |
      | rw1    | 2           | commit                                                                                                                  |
      | rw1    | 1           | CREATE TABLE test_table (  id int,  name varchar(20),  age int )                                                        |
      | rw1    | 1           | CREATE TABLE test_table1 (  id int,  name varchar(20),  age int )                                                       |
      | rw1    | 1           | delete from db2.test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) |
      | rw1    | 1           | DELETE FROM test_table1 WHERE id = ?                                                                                    |
      | rw1    | 1           | DELETE test_table FROM test_table, db2.test_table1 WHERE test_table.id = ?  AND db2.test_table1.id = ?                  |
      | rw1    | 1           | DROP TABLE IF EXISTS test_table                                                                                         |
      | rw1    | 1           | DROP TABLE IF EXISTS test_table1                                                                                        |
      | rw1    | 2           | INSERT INTO test_table VALUES (?, ?, ?)                                                                                 |
      | rw1    | 1           | insert into test_table(id,name,age) select id,name,age from test_table                                                  |
      | rw1    | 1           | INSERT INTO test_table1 VALUES (?, ?, ?)                                                                                |
      | rw1    | 1           | select * from test_table                                                                                                |
      | rw1    | 1           | SELECT * FROM test_table WHERE age <> (  SELECT age  FROM db2.test_table1  WHERE id != ? )                              |
      | rw1    | 1           | select n.id,s.name from test_table n join db2.test_table1 s on n.id=s.id                                                |
      | rw1    | 1           | start transaction                                                                                                       |
      | rw1    | 1           | UPDATE test_table a, db2.test_table1 b SET a.age = b.age - ? WHERE a.id = ?  AND b.id = ?                               |
      | rw1    | 1           | UPDATE test_table SET name = ? WHERE id IN (   SELECT id   FROM db2.test_table1  )                                      |
      | rw1    | 2           | UPDATE test_table1 SET age = ? WHERE id = ?                                                                             |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow11"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow11" has lines with following column values
      | USER-0 | SQL-3                                                                                                                   |
      | rw1    | drop table if exists test_table                                                                                         |
      | rw1    | create table test_table(id int,name varchar(20),age int)                                                                |
      | rw1    | insert into test_table values (1,'1',1),(2, '2',2)                                                                      |
      | rw1    | begin                                                                                                                   |
      | rw1    | select * from test_table                                                                                                |
      | rw1    | insert into test_table values(5,'name5',5)                                                                              |
      | rw1    | commit                                                                                                                  |
      | rw1    | drop table if exists test_table1                                                                                        |
      | rw1    | create table test_table1(id int,name varchar(20),age int)                                                               |
      | rw1    | insert into test_table1 values (1,'1',1),(2, '2',2)                                                                     |
      | rw1    | start transaction                                                                                                       |
      | rw1    | update test_table1 set age =33 where id=1                                                                               |
      | rw1    | delete from test_table1 where id=5                                                                                      |
      | rw1    | update test_table1 set age =44 where id=100                                                                             |
      | rw1    | begin                                                                                                                   |
      | rw1    | commit                                                                                                                  |
      | rw1    | insert into test_table(id,name,age) select id,name,age from test_table                                                  |
      | rw1    | update test_table set name='test_name' where id in (select id from db2.test_table1 )                                    |
      | rw1    | update test_table a,db2.test_table1 b set a.age=b.age-1 where a.id=2 and b.id=2                                         |
      | rw1    | select n.id,s.name from test_table n join db2.test_table1 s on n.id=s.id                                                |
      | rw1    | begin                                                                                                                   |
      | rw1    | select * from test_table where age <> (select age from db2.test_table1 where id !=1)                                    |
      | rw1    | begin                                                                                                                   |
      | rw1    | delete test_table from test_table,db2.test_table1 where test_table.id=1 and db2.test_table1.id =1                       |
      | rw1    | delete from db2.test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) |

    ### case 12: ps协议
    Then execute prepared sql "select %s from test where id =%s" with params "(name,1);(id,3)" on db "schema1" and user "test"
    Then execute prepared sql "select %s from test_table where id =%s" with params "(name,1);(id,3)" on db "db1" and user "rw1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | conn_1 | False   | show @@sql           | length{(66)}    | 10      |
      | conn_1 | true    | show @@sql.high      | length{(56)}    |         |
      | conn_1 | true    | show @@sql.slow      | length{(66)}    |         |
      | conn_1 | False   | show @@sql.resultset | length{(49)}    |         |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql12"
      | sql        |
      | show @@sql |
    Then check resultset "sql12" has lines with following column values
      | USER-1 | SQL-4                                            |
      | rw1    | SET NAMES 'utf8' COLLATE 'utf8_general_ci'       |
      | rw1    | SET @@session.autocommit = ON                    |
      | rw1    | select ? from test_table where id =?             |
      | rw1    | select ? from test_table where id =?             |
      | test   | SET NAMES 'utf8' COLLATE 'utf8_general_ci'       |
      | test   | SET @@session.autocommit = ON                    |
      | test   | select 'name' from test where id =1              |
      | test   | select 'id' from test where id =3                |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_high12"
      | sql             |
      | show @@sql.high |
    Then check resultset "sql_high12" has lines with following column values
      | USER-1 | FREQUENCY-2 | SQL-8                                |
      | rw1    | 2           | select ? from test_table where id =? |
      | test   | 2           | SELECT ? FROM test WHERE id = ?      |
      | rw1    | 1           | SET @@session.autocommit = ON        |
      | test   | 1           | SET @@session.autocommit = ON        |
      | rw1    | 1           | SET NAMES ?                          |
      | test   | 1           | SET NAMES ?                          |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_slow12"
      | sql             |
      | show @@sql.slow |
    Then check resultset "sql_slow12" has lines with following column values
      | USER-0 | SQL-3                                            |
      | rw1    | SET NAMES 'utf8' COLLATE 'utf8_general_ci'       |
      | rw1    | SET @@session.autocommit = ON                    |
      | rw1    | select ? from test_table where id =?             |
      | rw1    | select ? from test_table where id =?             |
      | test   | SET NAMES 'utf8' COLLATE 'utf8_general_ci'       |
      | test   | SET @@session.autocommit = ON                    |
      | test   | select 'name' from test where id =1              |
      | test   | select 'id' from test where id =3                |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: show @@sql.large show @@sql.condition #4
    ##| USER | ROWS | START_TIME | EXECUTE_TIME | SQL |
    ##| ID-0 | KEY-1  KEY: schema.table 最后两⾏为schema.table.valuekey 和 schema.table.valuecount      | VALUE-2 | COUNT-3 |
    ##reload @@query_cf=table&column;   ## 根据sql_log过滤得到
    ###配置所有的用户 管理端用户  分库分表用户 读写分离用户  分析用户
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
       """
       <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="2000" minCon="10" primary="true" />
       </dbGroup>

       <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
          <heartbeat>select 1</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.10:9004" user="test" maxCon="2000" minCon="10" primary="true" databaseType="clickhouse"/>
       </dbGroup>
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test1" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test2" password="111111" schemas="schema1" tenant="ten1"/>
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
      """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect      | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(20))     | success     | schema1 |
      | conn_3 | False   | drop table if exists test;create table test(id int,name varchar(20))                       | success     | schema1 |
      | conn_3 | False   | drop table if exists test1;create table test1(id int,name varchar(20))                     | success     | schema1 |

    ### case 1:分库分表用户插入10000 ⾏的数据
    Then connect "dble-1" to insert "10001" of data for "sharding_4_t1"
    Then connect "dble-1" to insert "10000" of data for "test1"
    Then connect "dble-1" to insert "15000" of data for "test"

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect      | db      |
      | conn_3 | False   | select * from sharding_4_t1 limit 100000   | success     | schema1 |
      | conn_3 | False   | select * from test1 limit 100000           | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.large         | length{(1)}    | 10      |
      | conn_1 | False   | show @@sql.condition     | length{(2)}    | 10      |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_large1"
      | sql              |
      | show @@sql.large |
    Then check resultset "sql_large1" has lines with following column values
      | USER-0 | ROWS-1 | SQL-4                                    |
      | test   | 10001  | select * from sharding_4_t1 limit 100000 |

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
      | USER-0 | ROWS-1 | SQL-4                                                   |
      | test   | 10001  | select * from sharding_4_t1 limit 100000                |
      | test   | 10001  | select * from sharding_4_t1 where id>0 limit 100000     |
      | test   | 10001  | select id from sharding_4_t1 where id>0 limit 100000    |

    ### case 3:多语句包含事务
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                               | db          | expect  |
      | test1 | 111111 | conn_4 | False   | begin;select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id > 0 limit 100000                                    | schema1     | success |
      | test1 | 111111 | conn_4 | False   | /*!dble:shardingNode=dn1*/ select name from test limit 100000;commit                                                              | schema1     | success |
      | test1 | 111111 | conn_4 | False   | start transaction;delete from sharding_4_t1 where id in ((select id from (select id from test order by id desc) as tmp));rollback | schema1     | success |
      | test1 | 111111 | conn_4 | False   | set autocommit=0;select name from test limit 100000                                                                               | schema1     | success |
      | test1 | 111111 | conn_4 | False   | set autocommit=1;select * from test1 limit 100000                                                                                 | schema1     | success |
      | test1 | 111111 | conn_4 | true    | select * from test order by id limit 100000                                                                                       | schema1      | success |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect         | timeout |
      | conn_1 | False   | show @@sql.large     | length{(7)}    | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_large2"
      | sql              |
      | show @@sql.large |
    Then check resultset "sql_large2" has lines with following column values
      | USER-0 | ROWS-1 | SQL-4                                                                                    |
      | test1   | 15000  | select * from test order by id limit 100000                                              |
      | test1   | 15000  | /*!dble:shardingNode=dn1*/ select name from test limit 100000                            |
      | test1   | 15000  | select name from test limit 100000                                                       |
      | test1   | 10001  | select * from sharding_4_t1 a inner join test b on a.id=b.id where a.id > 0 limit 100000 |
     Then execute sql in "dble-1" in "user" mode
      | user       | conn   | toClose | sql                                                                                                  | expect      | db      |
      | test2:ten1 | conn_5 | False   | select * from test where id>0 limit 100000;select id from test1 where id>0 limit 100000              | success     | schema1 |
      | test2:ten1 | conn_5 | False   | select id,name from test where id>0 limit 100000;select name,id from test1 where id>0 limit 100000   | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect          | timeout |
      | conn_1 | False   | show @@sql.large     | length{(9)}    | 10      |

     ### case 4: truncate sql_log 会重置清空数据
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect      | timeout |
      | conn_1 | False   | truncate dble_information.sql_log  | success     |         |
      | conn_1 | false   | show @@sql.large                   | length{(0)} | 10      |

    ### case 5:不记录除了管理端用户外的sql
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql                                                                       | expect   | db  |
      | rw1   | 111111    | conn_11 | false    | drop table if exists table1;create table table1(id int,name longblob)     | success  | db1 |
    Then connect "dble-1" to insert "10333" of data for "db1.table1" with user "rw1"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql                                  | expect   | db |
      | rw1   | 111111    | conn_11 | true     | select * from  table1 limit 1000000  | success  | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect      | timeout |
      | conn_1 | false   | show @@sql.large                   | length{(1)} | 10      |

    ### case 6: ps协议
    Then execute prepared sql "select %s from test where id >%s limit 1000000" with params "(name,1);(id,3)" on db "schema1" and user "test"
    Then execute prepared sql "select %s from table1 where id >%s" with params "(name,1);(id,3)" on db "db1" and user "rw1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                | expect      | timeout |
      | conn_1 | false   | show @@sql.large                   | length{(5)} | 10      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_large2"
      | sql              |
      | show @@sql.large |
    Then check resultset "sql_large2" has lines with following column values
      | USER-0 | ROWS-1 | SQL-4                                             |
      | test   | 14999  | select 'name' from test where id >1 limit 1000000 |
      | test   | 14997  | select 'id' from test where id >3 limit 1000000   |
      | rw1    | 10333  | select * from  table1 limit 1000000               |
      | rw1    | 10332  | select ? from table1 where id >?                  |
      | rw1    | 10330  | select ? from table1 where id >?                  |
    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: show @@sql.condition  #5
  ##      | ID-0 | KEY-1  KEY: schema.table 最后两⾏为schema.table.valuekey 和 schema.table.valuecount      | VALUE-2 | COUNT-3 |
    ##reload @@query_cf=table&column;
    ###配置所有的用户 管理端用户  分库分表用户 读写分离用户  分析用户
     Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
       """
       <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
          <heartbeat>select user()</heartbeat>
          <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="2000" minCon="10" primary="true" />
       </dbGroup>

       <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
          <heartbeat>select 1</heartbeat>
          <dbInstance name="hostM1" password="111111" url="172.100.9.10:9004" user="test" maxCon="2000" minCon="10" primary="true" databaseType="clickhouse"/>
       </dbGroup>
      """
     Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
       """
       <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test1" password="111111" schemas="schema1,schema2"/>
       <shardingUser name="test2" password="111111" schemas="schema1" tenant="ten1"/>
       <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
       <analysisUser name="ana1" password="111111" dbGroup="ha_group4"  />
       """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema2">
        <globalTable name="global2" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="sing1" shardingNode="dn1" />
        <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
      </schema>
      """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DenableStatisticAnalysis=1
      """
    Then restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                        | expect      | db      |
      | conn_3 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(20))     | success     | schema1 |
      | conn_3 | False   | drop table if exists test;create table test(id int,name varchar(20))                       | success     | schema1 |
      | conn_3 | False   | drop table if exists test1;create table test1(id int,name varchar(20))                     | success     | schema1 |
      | conn_3 | False   | select id from sharding_4_t1 where id=1                                                    | success     | schema1 |

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
     ### case : reload @@user_stat 不支持
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect                       | timeout |
      | conn_1 | False   | reload @@user_stat       | Unsupported statement        |         |
      | conn_1 | False   | show @@sql.condition     | length{(4)}                  | 10      |

    ### case 6:不记录除了管理端用户外的用户执行的sql
    Then execute admin cmd "reload @@query_cf=table1&name"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql                                                                              | expect   | db  |
      | rw1   | 111111    | conn_11 | true     | drop table if exists table1;create table table1(id int,name varchar(20))         | success  | db1 |
      | rw1   | 111111    | conn_11 | true     | select name from table1 where name=0;select name from table1 where name=1        | success  | db1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(4)}    | 10      |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition6"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition6" has lines with following column values
      | KEY-1                  | VALUE-2 | COUNT-3 |
      | table1.name            | 0       | 1       |
      | table1.name            | 1       | 1       |
      | table1.name.valuekey   | size    | 2       |
      | table1.name.valuecount | total   | 2       |

    ### case 7: ps协议
      ###读写分离用户的ps直接下发占位符？ 相当于没有记录
    Then execute prepared sql "select %s from table1 where name =%s" with params "(name,1);(id,3)" on db "db1" and user "rw1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(4)}    | 10      |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition7"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition7" has lines with following column values
      | KEY-1                  | VALUE-2 | COUNT-3 |
      | table1.name            | 0       | 1       |
      | table1.name            | 1       | 1       |
      | table1.name.valuekey   | size    | 2       |
      | table1.name.valuecount | total   | 2       |
     ###切换成分库分表用户
    Then execute admin cmd "reload @@query_cf=test&id"
    Then execute prepared sql "select %s from test where id =%s limit 1000000" with params "(name,1);(id,3)" on db "schema1" and user "test"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                      | expect         | timeout |
      | conn_1 | False   | show @@sql.condition     | length{(4)}    | 10      |
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_condition7"
      | sql                  |
      | show @@sql.condition |
    Then check resultset "sql_condition7" has lines with following column values
      | KEY-1              | VALUE-2 | COUNT-3 |
      | test.id            | 1       | 1       |
      | test.id            | 3       | 1       |
      | test.id.valuekey   | size    | 2       |
      | test.id.valuecount | total   | 2       |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: dble重启数据会被清空恢复默认值   #6
    ###9066端口默认初始值 ，默认开启采样率和默认DenableStatisticAnalysis=0
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
      $a -DenableStatisticAnalysis=1
      """
    Then restart dble in "dble-1" success
    Then execute admin cmd "reload @@slow_query.time=0"
    Then execute admin cmd "reload @@query_cf=sharding_4_t1&id"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test  | 111111 | conn_11 | false   | drop table if exists test;create table test(id int,name longblob)                                             | success | schema1 |
      | test  | 111111 | conn_11 | false   | insert into test value (1, repeat('a', 1100));insert into test value (2, repeat('b', 512*1024))               | success | schema1 |
      | test  | 111111 | conn_11 | false   | select * from test                                                                                            | success | schema1 |

      | test1 | 111111 | conn_12 | false   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(1500))                      | success | schema1 |
      | test1 | 111111 | conn_12 | false   | insert into sharding_4_t1 value (1, repeat('a', 1100));insert into sharding_4_t1 value (2, repeat('b', 1500)) | success | schema1 |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1 where id=1                                                                        | success | schema1 |
    Then connect "dble-1" to insert "10001" of data for "sharding_4_t1"
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                                                                           | expect  | db      |
      | test1 | 111111 | conn_12 | false   | select * from sharding_4_t1 limit 100000                                                                      | success | schema1 |

     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                       | expect            | timeout |
      | conn_1 | False   | show @@sql                | length{(12)}      | 10      |
      | conn_1 | False   | show @@sql.high           | length{(11)}      | 10      |
      | conn_1 | False   | show @@sql.slow           | length{(12)}      | 10      |
      | conn_1 | False   | show @@sql.large          | length{(1)}       | 10      |
      | conn_1 | False   | show @@sql.resultset      | length{(11)}      | 10      |
      | conn_1 | False   | show @@sql.sum            | length{(2)}       | 10      |
      | conn_1 | False   | show @@sql.sum.user       | length{(2)}       | 10      |
      | conn_1 | False   | show @@sql.sum.table      | length{(2)}       | 10      |
      | conn_1 | true    | show @@sql.condition      | length{(3)}       | 10      |

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


  Scenario: useSqlStat  sqlRecordCount clearBigSQLResultSetMapMs bufferUsagePercent 参数废弃  #7
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a -DuseSqlStat=1
      $a -DsqlRecordCount=1
      $a -DclearBigSQLResultSetMapMs=1
      $a -DbufferUsagePercent=1
      """
    Then restart dble in "dble-1" failed for
      """
      These properties in bootstrap.cnf or bootstrap.dynamic.cnf are not recognized: clearBigSQLResultSetMapMs,useSqlStat,sqlRecordCount,bufferUsagePercent
      """
    ## useSqlStat 替代的是samplingRate和enableStatisticAnalysis
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DuseSqlStat/d
      /-DsqlRecordCount/d
      /-DclearBigSQLResultSetMapMs/d
      /-DbufferUsagePercent/d
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
    Then execute admin cmd "reload @@slow_query.time=0"
    Then execute admin cmd "reload @@samplingRate=0"
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