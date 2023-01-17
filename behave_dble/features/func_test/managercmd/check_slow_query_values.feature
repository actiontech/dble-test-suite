# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wujinling at 2023/01/17

Feature: check show @@sql.slow column values are right
  Background: config for this test suites
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="-1">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                       | expect      | db        |
      | conn_1 | False   | drop table if exists sharding_4_t1                                                        | success     | schema1   |
      | conn_1 | False   | create table sharding_4_t1(id int,name varchar(15),age int)                               | success     | schema1   |
      | conn_1 | False   | insert into sharding_4_t1 values (1,'Amy',20),(2,'Bob',30),(3,'Carlos',40),(4,'John',50)  | success     | schema1   |
      | conn_1 | False   | drop table if exists test                                                                 | success     | schema1   |
      | conn_1 | False   | create table test(id int,name varchar(15),age int)                                        | success     | schema1   |
      | conn_1 | True    | insert into test values (1,'Amy',20),(2,'Vicky',36)                                       | success     | schema1   |
    Given execute sql "14" times in "dble-1" at concurrent 4
      | sql                                                     | db       |
      | insert into sharding_4_t1 select * from sharding_4_t1   | schema1  |

  @NORMAL
  Scenario: check USER and SQL in show @@sql.slow are right #1
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                   | expect           |
      | conn_0 | False   | disable @@slow_query_log              | success          |
      | conn_0 | False   | show @@slow_query_log                 | has{(('0',),)}   |
      | conn_0 | False   | show @@sql.slow true                  | success          |
      | conn_0 | True    | show @@sql.slow                       | length{(0)}      |
    Then execute sql in "dble-1" in "user" mode
      | user  | conn   | toClose | sql                                                                                       | expect      | db        |
      | test  | conn_1 | False   | drop table if exists sharding_4_t1                                                        | success     | schema1   |
      | test  | conn_1 | False   | create table sharding_4_t1(id int,name varchar(15),age int)                               | success     | schema1   |
      | test  | conn_1 | False   | insert into sharding_4_t1 values (1,'Amy',20),(2,'Bob',30),(3,'Carlos',40),(4,'John',50)  | success     | schema1   |
      | test  | conn_1 | False   | drop table if exists test                                                                 | success     | schema1   |
      | test  | conn_1 | False   | create table test(id int,name varchar(15),age int)                                        | success     | schema1   |
      | test  | conn_1 | True    | insert into test values (1,'Amy',20),(2,'Vicky',36)                                       | success     | schema1   |
    Given execute sql "14" times in "dble-1" at concurrent 4
      | user  | sql                                                     | db       |
      | test  | insert into sharding_4_t1 select * from sharding_4_t1   | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect           |
      | conn_0 | False   | enable @@slow_query_log                           | success          |
      | conn_0 | False   | show @@slow_query_log                             | has{(('1',),)}   |
      | conn_0 | False   | show @@sql.slow true                              | success          |
      | conn_0 | True    | show @@sql.slow                                   | length{(0)}      |
    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                                                                                         | expect  | db      |
     | test  | 111111 | conn_1 | False   | select * from sharding_4_t1                                                                 | success | schema1 |
     | test  | 111111 | conn_1 | False   | set autocommit =0;update sharding_4_t1 set age=100;commit                                  | success | schema1 |
     | test  | 111111 | conn_1 | True    | set autocommit =0;set xa=on;select * from sharding_4_t1 t1 join test t on t1.id=t.id;commit | success | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "slow_sql_A"
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | True    | show @@sql.slow                                   | length{(3)}  |
    Then check resultset "slow_sql_A" has lines with following column values
      | USER-0     | SQL-3                                                        |
      | test       | select * from sharding_4_t1                                  |
      | test       | UPDATE sharding_4_t1 SET age = 100                           |
      | test       | select * from sharding_4_t1 t1 join test t on t1.id=t.id     |

  @NORMAL
  Scenario: check START_TIME in show @@sql.slow is right #2
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect           |
      | conn_0 | False   | enable @@slow_query_log                           | success          |
      | conn_0 | False   | show @@slow_query_log                             | has{(('1',),)}   |
      | conn_0 | False   | show @@sql.slow true                              | success          |
      | conn_0 | False   | show @@sql.slow                                   | length{(0)}      |
      | conn_0 | False   | enable @@statistic                                | success          |
      | conn_0 | True    | reload @@samplingRate=100                         | success          |
    Then execute sql in "dble-1" in "user" mode
     | conn   | toClose | sql                                                      | expect  | db        |
     | conn_0 | False   | select * from sharding_4_t1 t1 join test t on t1.id=t.id | success | schema1   |
     | conn_0 | False   | select * from test                                       | success | schema1   |
     | conn_0 | True    | select * from sharding_4_t1                              | success | schema1   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "slow_sql_A"
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | True    | show @@sql.slow                                   | length{(2)}  |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "slow_sql_B"
      | conn   | toClose | sql                                                                                                                                                                                                                                       | expect       |
      | conn_0 | True    | select user,date_format(start_time,'%Y/%m/%d %H:%i:%S') as start_time,duration,sql_stmt from dble_information.sql_log where sql_stmt='select * from sharding_4_t1' or sql_stmt='select * from sharding_4_t1 t1 join test t on t1.id=t.id' | length{(2)}  |
    Then check resultsets "slow_sql_A" and "slow_sql_B" are same in following columns
      | column         | column_index |
      | USER           | 0            |
      | START_TIME     | 1            |

  @NORMAL @skip #trace结果和慢日志结果有误差不能等式判断
  Scenario: check EXECUTE_TIME in show @@sql.slow is right #3
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect           |
      | conn_0 | False   | enable @@slow_query_log                           | success          |
      | conn_0 | True    | show @@slow_query_log                             | has{(('1',),)}   |
    Given execute linux command in "dble-1" and save result in "slow_sql_A"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} -D schema1 -e "set trace=1;select * from sharding_4_t1;show trace" | grep Over_All | awk '{print $4}'
    """
    Given execute linux command in "dble-1" and save result in "slow_sql_B"
    """
    mysql -P{node:manager_port} -u{node:manager_user} -h{node:ip} -e "show @@sql.slow" | grep -v EXECUTE_TIME | awk '{print $4}'
    """
    Then check "slow_sql_A" equal to "slow_sql_B" in "int" mode

#    #清除slow log记录，进行下个测试点
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                   | expect           |
      | conn_0 | False   | disable @@slow_query_log              | success          |
      | conn_0 | False   | show @@slow_query_log                 | has{(('0',),)}   |
      | conn_0 | False   | show @@sql.slow true                  | success          |
      | conn_0 | True    | show @@sql.slow                       | length{(0)}      |

  @NORMAL
  Scenario: check parameter sqlRecordCount works fine: after 5 seconds the timer will just remains top ${sqlRecordCount} records #4
    Given update file content "{install_dir}/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DenableSlowLog=1
    $a -DsqlRecordCount=6
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect      | db        |
      | conn_1 | False   | select * from sharding_4_t1 t1 join test t on t1.id=t.id                           | success     | schema1   |
      | conn_1 | False   | select * from sharding_4_t1 t1 join test t on t1.id=t.id                           | success     | schema1   |
      | conn_1 | False   | select * from sharding_4_t1 t1 join test t on t1.id=t.id                           | success     | schema1   |
      | conn_1 | False   | select * from sharding_4_t1                                                        | success     | schema1   |
      | conn_1 | False   | select * from sharding_4_t1                                                        | success     | schema1   |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | True    | show @@sql.slow                                   | length{(5)}  |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect      | db        |
      | conn_1 | False   | select * from sharding_4_t1                                                        | success     | schema1   |
      | conn_1 | False   | select * from sharding_4_t1                                                        | success     | schema1   |
      | conn_1 | False   | select * from sharding_4_t1                                                        | success     | schema1   |
      | conn_1 | True    | select * from sharding_4_t1                                                        | success     | schema1   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "slow_sql_A"
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | True    | show @@sql.slow                                   | length{(9)}  |
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "slow_sql_B"
      | conn   | toClose | sql                                               | expect       |
      | conn_0 | True    | show @@sql.slow                                   | length{(9)}  |
    Then check resultsets "slow_sql_A" including resultset "slow_sql_B" in following columns
      | column         | column_index |
      | USER           | 0            |
      | START_TIME     | 1            |
      | EXECUTE_TIME   | 2            |
      | SQL            | 3            |
    Given sleep "3" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "slow_sql_C"
      | conn   | toClose | sql                                               | expect      |
      | conn_0 | True    | show @@sql.slow                                   | length{(6)} |
    Then check resultset "slow_sql_C" has lines with following column values
      | USER-0      | SQL-3                                                        |
      | test        | select * from sharding_4_t1 t1 join test t on t1.id=t.id     |
      | test        | select * from sharding_4_t1                                  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                   | expect        |
      | conn_0 | False   | show @@sql.slow                       | length{(6)}   |
      | conn_0 | False   | disable @@slow_query_log              | success       |
      | conn_0 | False   | show @@sql.slow                       | length{(6)}   |
      | conn_0 | False   | show @@sql.slow true                  | success       |
      | conn_0 | True    | show @@sql.slow                       | length{(0)}   |
