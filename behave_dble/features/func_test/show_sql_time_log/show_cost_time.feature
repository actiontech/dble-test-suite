# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2023/05/11

Feature: show @@cost_time;
  ## 这个命令的前提是 useCostTimeStat  maxCostStatSize  costSamplePercent 参数开启
  ## 描述：查询query耗时统计的结果,需要在bootstrap.cnf中开启useCostTimeStat选项之后才会有统计结果
  ## OVER_ALL: 总耗时
  ## FRONT_PREPARE: 前端连接以及dble中的耗时
  ## BACKEND_EXECUTE: 后端连接执行耗时

  Scenario: show @@cost_time   #1
    ##查看各参数的默认值
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                        | expect                           | db               |
      | conn_0 | False   | select variable_value from dble_variables where variable_name in ('useCostTimeStat','maxCostStatSize','costSamplePercent') | has{(('0',), ('100',), ('1%',))} | dble_information |
      | conn_0 | False   | show @@cost_time  | length{(0)} | dble_information |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect      | db      |
      | conn_1 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(20))      | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect      |
      | conn_0 | False   | show @@cost_time  | length{(0)} |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect      | db      |
      | conn_1 | False   | insert into sharding_4_t1 values(1,'test1'),(2,'test2'),(3,'test3'),(4,'test4'),(5,'test5')      | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect      |
      | conn_0 | true    | show @@cost_time  | length{(0)} |

    ### 开启必要的参数
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      $a\-DuseCostTimeStat=1
      $a\-DmaxCostStatSize=10000
      $a\-DcostSamplePercent=100
      """
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

    Then Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                                        | expect                                | db               |
      | conn_0 | False   | select variable_value from dble_variables where variable_name in ('useCostTimeStat','maxCostStatSize','costSamplePercent') | has{(('1',), ('10000',), ('100%',))}  | dble_information |
      | conn_0 | False   | show @@cost_time  | length{(0)} | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                         | expect      | db      |
      | conn_2 | False   | drop table if exists sharding_4_t1;create table sharding_4_t1(id int,name varchar(20))      | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect      | timeout |
      | conn_0 | False   | show @@cost_time  | length{(2)} | 10,3    |
    ### 连续执行show @@  结果一致
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "compare_1"
      | conn   | toClose  | sql              |
      | conn_0 | False    | show @@cost_time |
    Given sleep "2" seconds
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "compare_2"
      | conn   | toClose  | sql              |
      | conn_0 | False    | show @@cost_time |
    Then check resultsets "compare_1" and "compare_2" are same in following columns
      | column              | column_index |
      | OVER_ALL(µs)        | 0              |
      | FRONT_PREPARE       | 1              |
      | BACKEND_EXECUTE     | 2              |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                   | expect      | db      |
      | conn_2 | False   | insert into sharding_4_t1 values (1,'test1'),(2,'test2'),(3,'test3'),(4,'test4')      | success     | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect      | timeout |
      | conn_0 | False   | show @@cost_time  | length{(3)} | 10,3    |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect      | db      |
      | conn_2 | False   | select * from sharding_4_t1      | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect      | timeout |
      | conn_0 | False   | show @@cost_time  | length{(4)} | 10,3    |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect      | db      |
      | conn_2 | true    | select * from sharding_4_t1 where id = 1      | success     | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect      | timeout |
      | conn_0 | False   | show @@cost_time  | length{(5)} | 10,3    |

    ###错误的语句+select + show + set
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                  | db      | expect                                      |
      | test1 | 111111 | conn_3  | False   | use schema66                         | schema1 | Unknown database 'schema66'                 |
      | test1 | 111111 | conn_3  | False   | select * from test100                | schema1 | Table 'db3.test100' doesn't exist           |
      | test1 | 111111 | conn_3  | False   | select user()                        | schema1 | success                                     |
      | test1 | 111111 | conn_3  | False   | show tables                          | schema1 | success                                     |
      | test1 | 111111 | conn_3  | False   | set @@trace=1                        | schema1 | success                                     |
      | test1 | 111111 | conn_3  | False   | select @@trace                       | schema1 | success                                     |
      | test1 | 111111 | conn_3  | true    | select 1                             | schema1 | success                                     |
    ###
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect       | timeout |
      | conn_0 | False   | show @@cost_time  | length{(8)}  | 10,3    |

    ###事务未结束
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn    | toClose | sql                                                       | db      | expect                  |
      | test1 | 111111 | conn_3  | False   | begin;insert into sharding_4_t1 values (6,'test1')        | schema1 | success                 |
      | test1 | 111111 | conn_3  | False   | select * from sharding_4_t1                               | schema1 | success                 |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect       | timeout |
      | conn_0 | False   | show @@cost_time  | length{(10)} | 10,3    |

    ###不记录除了分库分表用户外的用户执行的sql
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd    | conn    | toClose  | sql      | expect   |
      | rw1   | 111111    | conn_11 | true     | select 1 | success  |
      | ana1  | 111111    | conn_12 | true     | select 1 | success  |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql               | expect       | timeout |
      | conn_0 | true    | show @@cost_time  | length{(10)} | 10,3    |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"

      ###dble重启清空记录的结果
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                  | expect             |
      | conn_0 | False   | show @@cost_time     | length{(0)}        |

    Then execute sql in "dble-1" in "user" mode
      | user         | passwd    | conn    | toClose  | sql      | expect   |
      | test2:ten1   | 111111    | conn_11 | true     | select 1 | success  |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect       | timeout |
      | conn_0 | False   | show @@cost_time      | length{(1)}  | 10,3    |
      | conn_0 | False   | show @@cost_time true | Unsupported statement  |      |

    Given execute sql "2050" times in "dble-1" at concurrent 1000
      | sql              | db      |
      | select 3         | schema1 |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect          | timeout |
      | conn_0 | False   | show @@cost_time      | length{(2051)}  | 10,3    |

    ##load data 会被记录
    Given execute oscmd in "dble-1"
      """
      echo -e '1,1\n2,2\n3,3\n4,4\n5,5\n6,a\n7,7\n8,8\n9,9\n10,10\n11,11\n12,12\n13,13' > /opt/dble/data.txt
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                     | expect       | db      |
      | new    | False   | load data infile '/opt/dble/data.txt' into table sharding_4_t1 character SET 'utf8' fields terminated by ',' lines terminated by '\n'   | success      | schema1 |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                   | expect          | timeout |
      | conn_0 | False   | show @@cost_time      | length{(2052)}  | 10,3    |

    Then check "NullPointerException|caught err|unknown error|setError" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"