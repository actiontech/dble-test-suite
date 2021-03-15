# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/3/10
#github:issues/1687

Feature: In order to calculate the route, the where condition needs to be processed


@skip
  Scenario: prepare env and update log from "debug" to "trace"

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="aid"/>
        <shardingTable name="tb_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="tb_child" joinColumn="kid" parentColumn="id"/>
        </shardingTable>
    </schema>

    <schema name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <globalTable name="global_4_t1" shardingNode="dn1,dn2,dn3,dn4" />
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                    | expect  | db      | charset |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                                                                                                                                                     | success | schema1 | utf8mb4 |
      | conn_0 | False   | drop table if exists tb_parent                                                                                                                                                                                                         | success | schema1 | utf8mb4 |
      | conn_0 | False   | drop table if exists tb_child                                                                                                                                                                                                          | success | schema1 | utf8mb4 |
      | conn_0 | False   | drop table if exists noshard_t1                                                                                                                                                                                                        | success | schema1 | utf8mb4 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2                                                                                                                                                                                             | success | schema1 | utf8mb4 |
      | conn_0 | False   | drop table if exists schema2.global_4_t1                                                                                                                                                                                               | success | schema1 | utf8mb4 |

      | conn_0 | False   | create table sharding_4_t1(id int,aid bigint primary key AUTO_INCREMENT,name char(20),age int,pad int)                                                                                                                                                               | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table tb_parent(id int,pad int,name char(20),age int)                                                                                                                                                                           | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table tb_child(id int,kid int,name char(20),age int)                                                                                                                                                                            | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table schema2.sharding_4_t2(id int,pad int,name char(20),age int)                                                                                                                                                               | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table noshard_t1(`id` int(10) unsigned NOT NULL,`t_id` int(10) unsigned NOT NULL DEFAULT '0',`name` varchar(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`t_id`))DEFAULT CHARSET=UTF8          | success | schema1 | utf8mb4 |
      | conn_0 | False   | create table schema2.global_4_t1(`id` int(10) unsigned NOT NULL,`o_id` int(10) unsigned NOT NULL DEFAULT '0',`name` varchar(120) NOT NULL DEFAULT '',`pad` int(11) NOT NULL,PRIMARY KEY (`id`),KEY `k_1` (`o_id`))DEFAULT CHARSET=UTF8 | success | schema1 | utf8mb4 |

      | conn_0 | False   | insert into sharding_4_t1 (id,name,age,pad)values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)                                                                                                                                                        | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into tb_parent values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)                                                                                                                                                                    | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into tb_child values(1,1,1,1)                                                                                                                                                                                                   | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into tb_child values(2,2,2,2)                                                                                                                                                                                                   | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into tb_child values(3,3,3,3)                                                                                                                                                                                                   | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into tb_child values(4,4,4,4)                                                                                                                                                                                                   | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into schema2.sharding_4_t2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)                                                                                                                                                        | success | schema1 | utf8mb4 |
      | conn_0 | False   | insert into noshard_t1 values(1,1,'noshard_t1中id为1',1),(2,2,'test_2',2),(3,3,'noshard_t1中id为3',4),(4,4,'$test$4',3),(5,5,'test...5',1),(6,6,'test6',6)                                                                              | success | schema1 | utf8mb4 |
      | conn_0 | true    | insert into schema2.global_4_t1 values(1,1,'global_4_t1中id为1',1),(2,2,'test_2',2),(3,3,'global_4_t1中id为3',3),(4,4,'$order$4',4),(5,5,'order...5',1),(6,6,'test6',6)                                                                 | success | schema1 | utf8mb4 |

@skip
  Scenario: "where" minimum condition #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" incrementColumn="aid"/>
        <shardingTable name="tb_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="tb_child" joinColumn="kid" parentColumn="id"/>
        </shardingTable>
    </schema>
    """
    Then execute admin cmd "reload @@config"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                    | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                                     | success     | schema1 |
      | conn_0 | False   | drop table if exists tb_parent                                                                         | success     | schema1 |
      | conn_0 | False   | drop table if exists tb_child                                                                          | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,aid bigint primary key AUTO_INCREMENT,name char(20),age int,pad int) | success     | schema1 |
      | conn_0 | False   | create table tb_parent(id int,pad int,name char(20),age int)                                           | success     | schema1 |
      | conn_0 | False   | create table tb_child(id int,kid int,name char(20),age int)                                            | success     | schema1 |
      | conn_0 | False   | insert into sharding_4_t1 (id,name,age,pad)values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)               | success     | schema1 |
      | conn_0 | False   | insert into tb_parent values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)                                    | success     | schema1 |
      | conn_0 | False   | insert into tb_child values(1,1,1,1)                                                                   | success     | schema1 |
      | conn_0 | False   | insert into tb_child values(2,2,2,2)                                                                   | success     | schema1 |
      | conn_0 | False   | insert into tb_child values(3,3,3,3)                                                                   | success     | schema1 |
      | conn_0 | False   | insert into tb_child values(4,4,4,4)                                                                   | success     | schema1 |

      # shardingcolumn don't simplified,routed 3 node
      | conn_0 | False   | explain select * from sharding_4_t1 where id=1 or id=2 or id=3                                         | length{(3)} | schema1 |

      # incrementColumn don't simplified,routed 4 node broadcast
      | conn_0 | False   | explain select * from sharding_4_t1 where aid=1 or aid=2 or aid=3                                      | length{(4)} | schema1 |

      # joinColumn don't simplified,routed 3 node
      | conn_0 | False   | explain select * from tb_child where kid=1 or kid=2 or kid=3                                           | length{(3)} | schema1 |

      # shardingcolumn or incrementColumn don't simplified,routed 4 node broadcast
      | conn_0 | False   | explain select * from sharding_4_t1 where id=1 or aid=2 or aid=3                                       | length{(4)} | schema1 |

      # routed "where id=1" 1 node
      | conn_0 | False   | explain select * from sharding_4_t1 where id=1 and 1=1                                                 | length{(1)} | schema1 |
      | conn_0 | False   | explain select * from sharding_4_t1 where id=1 and 1=0                                                 | length{(1)} | schema1 |

      # routed "where" is null  4 node broadcast
      | conn_0 | False   | explain select * from sharding_4_t1 where id=1 or 1=1                                                  | length{(4)} | schema1 |

      # routed "where id=1" 1 node
      | conn_0 | true    | explain select * from sharding_4_t1 where id=1 or 1=0                                                  | length{(1)} | schema1 |

      | conn_0 | False   | drop table if exists sharding_4_t1    | success     | schema1 |
      | conn_0 | False   | drop table if exists tb_parent        | success     | schema1 |
      | conn_0 | true    | drop table if exists tb_child         | success     | schema1 |


@skip
  Scenario: "where" function condition #2

    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/trace/g
      """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                      | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,aid int,name char(20),age int,pad int)                | success     | schema1 |
      | conn_0 | true    | insert into sharding_4_t1 values(1,1,1,1,1),(2,2,2,2,2),(3,3,3,3,3),(4,4,4,4,4)         | success     | schema1 |
      | conn_0 | False   | set @@trace=1                                                                           | success     | schema1 |
      | conn_0 | False   | select @@trace                                                                          | balance{1}  | schema1 |

    #case "between",route "where id between 1 and 3"
      | conn_0 | False   | select * from sharding_4_t1 where id between 1 and 3 and age=1                          | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                      |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where id between 1 and 3 and age=1 |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where id between 1 and 3 and age=1 |
      | Execute_SQL  | dn4             | select * from sharding_4_t1 where id between 1 and 3 and age=1 |
      | Fetch_result | dn2             | select * from sharding_4_t1 where id between 1 and 3 and age=1 |
      | Fetch_result | dn3             | select * from sharding_4_t1 where id between 1 and 3 and age=1 |
      | Fetch_result | dn4             | select * from sharding_4_t1 where id between 1 and 3 and age=1 |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id between (\"1\", \"3\"))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value between 1 and 3\]}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where id between 1 and 3 and age>1                          | length{(2)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                      |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where id between 1 and 3 and age>1 |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where id between 1 and 3 and age>1 |
      | Execute_SQL  | dn4             | select * from sharding_4_t1 where id between 1 and 3 and age>1 |
      | Fetch_result | dn2             | select * from sharding_4_t1 where id between 1 and 3 and age>1 |
      | Fetch_result | dn3             | select * from sharding_4_t1 where id between 1 and 3 and age>1 |
      | Fetch_result | dn4             | select * from sharding_4_t1 where id between 1 and 3 and age>1 |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id between (\"1\", \"3\"))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value between 1 and 3\]}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "2"
    Then check result "B" value is "2"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where id between 1 and 4 and age<=>1                        | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                        |
      | Execute_SQL  | dn1             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Execute_SQL  | dn4             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Fetch_result | dn1             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Fetch_result | dn2             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Fetch_result | dn3             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
      | Fetch_result | dn4             | select * from sharding_4_t1 where id between 1 and 4 and age<=>1 |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id between (\"1\", \"4\"))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value between 1 and 4\]}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    #case "in",route "where" is null ,broadcast
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                         | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where id in(1,2,3) or age=4     | length{(4)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                               |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Execute_SQL  | dn2             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Execute_SQL  | dn3             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Execute_SQL  | dn4             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Fetch_result | dn2             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Fetch_result | dn3             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
      | Fetch_result | dn4             | SELECT * FROM sharding_4_t1 WHERE id IN (1, 2, 3)  OR age = 4 LIMIT 100 |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(() or ((sharding_4_t1.id IN (1, 2, 3))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"


    #case "is null",route "where" is null ,broadcast
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                         | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where id is null and age=4      | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                               |
      | Execute_SQL  | dn1             | select * from sharding_4_t1 where id is null and age=4  |
      | Fetch_result | dn1             | select * from sharding_4_t1 where id is null and age=4  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id IS NULL)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=null\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"


    #case "and",associate irrelevant conditions (delete irrelevant conditions)
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                            | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where id=1 and age=1 and name=2    | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                    |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where id=1 and age=1 and name=2  |
      | Fetch_result | dn2             | select * from sharding_4_t1 where id=1 and age=1 and name=2  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where age=1 and name=2    | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                         |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Execute_SQL  | dn2             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Execute_SQL  | dn3             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Execute_SQL  | dn4             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Fetch_result | dn2             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Fetch_result | dn3             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
      | Fetch_result | dn4             | SELECT * FROM sharding_4_t1 WHERE age = 1  AND name = 2 LIMIT 100 |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "2"

    #case "or",irrelevant conditions (as long as there are irrelevant conditions, the whole is set as irrelevant conditions)
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where age=1 or name=2     | length{(2)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                         |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Execute_SQL  | dn2             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Execute_SQL  | dn3             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Execute_SQL  | dn4             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn2             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn3             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn4             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR name = 2 LIMIT 100  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(() or ())}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "C" in "dble-1"
    """
    grep "whereUnit \[() or ()\] will be pruned for contains useless or condition" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "3"
    Then check result "C" value is "1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where id=1 or age=1 or name=2     | length{(2)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                    |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Execute_SQL  | dn2             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Execute_SQL  | dn3             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Execute_SQL  | dn4             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn2             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn3             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
      | Fetch_result | dn4             | SELECT * FROM sharding_4_t1 WHERE id = 1  OR age = 1  OR name = 2 LIMIT 100  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(() or () or ((sharding_4_t1.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "C" in "dble-1"
    """
    grep "whereUnit \[() or () or ((sharding_4_t1.id = 1))\] will be pruned for contains useless or condition" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "4"
    Then check result "C" value is "1"

    #case Multiple relationship combination
    # where route "where id=1 or id=2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                        | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where (age=1 and id=1)or (id=2 and name=2)     | length{(2)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                               |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where (age=1 and id=1)or (id=2 and name=2)  |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where (age=1 and id=1)or (id=2 and name=2)  |
      | Fetch_result | dn2             | select * from sharding_4_t1 where (age=1 and id=1)or (id=2 and name=2)  |
      | Fetch_result | dn3             | select * from sharding_4_t1 where (age=1 and id=1)or (id=2 and name=2)  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 2)) or ((sharding_4_t1.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=2\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"
    # where route "where id=1 or id=2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                             | expect      | db      |
      | conn_0 | False   |   select * from sharding_4_t1 where age=1 and(id=2 or id=1)     | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                    |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where age=1 and(id=2 or id=1)    |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where age=1 and(id=2 or id=1)    |
      | Fetch_result | dn2             | select * from sharding_4_t1 where age=1 and(id=2 or id=1)    |
      | Fetch_result | dn3             | select * from sharding_4_t1 where age=1 and(id=2 or id=1)    |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 1)) or ((sharding_4_t1.id = 2)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=2\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    # where route "where id=1 or id=2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where age=1 and(name=2 and(pad=1 and(id=2 or id=1)))     | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                        |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where age=1 and(name=2 and(pad=1 and(id=2 or id=1))) |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where age=1 and(name=2 and(pad=1 and(id=2 or id=1))) |
      | Fetch_result | dn2             | select * from sharding_4_t1 where age=1 and(name=2 and(pad=1 and(id=2 or id=1))) |
      | Fetch_result | dn3             | select * from sharding_4_t1 where age=1 and(name=2 and(pad=1 and(id=2 or id=1))) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 1)) or ((sharding_4_t1.id = 2)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=2\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "2"
    Then check result "B" value is "2"

    # where route broadcast
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                  | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where age=1 or (name=2 and(pad=1 and(id=2 or id=1)))     | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                                                         |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Execute_SQL  | dn2             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Execute_SQL  | dn3             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Execute_SQL  | dn4             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Fetch_result | dn2             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Fetch_result | dn3             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
      | Fetch_result | dn4             | SELECT * FROM sharding_4_t1 WHERE age = 1  OR (name = 2   AND (pad = 1    AND (id = 2     OR id = 1))) LIMIT 100  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(() or (((sharding_4_t1.id = 1)) or ((sharding_4_t1.id = 2))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "C" in "dble-1"
    """
    grep "whereUnit \[() or (((sharding_4_t1.id = 1)) or ((sharding_4_t1.id = 2)))\] will be pruned for contains useless or condition" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "5"
    Then check result "C" value is "1"

    # Not simplified
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where (id=1 or id=2) and (id=3 or id=4)     | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                                   |
      | Execute_SQL  | dn1             | SELECT * FROM sharding_4_t1 WHERE (id = 1   OR id = 2)  AND (id = 3   OR id = 4) LIMIT 100  |
      | Fetch_result | dn1             | SELECT * FROM sharding_4_t1 WHERE (id = 1   OR id = 2)  AND (id = 3   OR id = 4) LIMIT 100  |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 2)) or ((sharding_4_t1.id = 1))) and (((sharding_4_t1.id = 4)) or ((sharding_4_t1.id = 3)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=2\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "C" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=4\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=3\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "D" in "dble-1"
    """
    grep "the condition is always false ,route from broadcast to single" /opt/dble/logs/dble.log | wc -l
    """

    Then check result "A" value is "1"
    Then check result "B" value is "2"
    Then check result "C" value is "1"
    Then check result "D" value is "1"

    #case After expansion, merge the same items inside
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                              | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 where (id=1 and age >=1) or (id=2 and name=2) or(id=1 and pad=1)     | length{(2)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | true    | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                                    |
      | Execute_SQL  | dn3             | select * from sharding_4_t1 where (id=1 and age >=1) or (id=2 and name=2) or(id=1 and pad=1) |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 where (id=1 and age >=1) or (id=2 and name=2) or(id=1 and pad=1) |
      | Fetch_result | dn2             | select * from sharding_4_t1 where (id=1 and age >=1) or (id=2 and name=2) or(id=1 and pad=1) |
      | Fetch_result | dn3             | select * from sharding_4_t1 where (id=1 and age >=1) or (id=2 and name=2) or(id=1 and pad=1) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 1)) or ((sharding_4_t1.id = 2)) or ((sharding_4_t1.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=2\]},}{ RouteCalculateUnit 3 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect      | db      |
      | conn_0 | true    | drop table if exists sharding_4_t1      | success     | schema1 |


@skip
  Scenario: Complex query -- one route #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/trace/g
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2                                              | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,aid int,name char(20),age int,pad int)                | success     | schema1 |
      | conn_0 | False   | create table schema2.sharding_4_t2(id int,pad int,name char(20),age int)                | success     | schema1 |
      | conn_0 | true    | insert into sharding_4_t1 values(1,1,1,1,1),(2,2,2,2,2),(3,3,3,3,3),(4,4,4,4,4)         | success     | schema1 |
      | conn_0 | False   | insert into schema2.sharding_4_t2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)         | success     | schema1 |
      | conn_0 | False   | set @@trace=1                                                                           | success     | schema1 |

    #case "join",route one db
      | conn_0 | False   | select * from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where (a.age=1 and b.id=1) or (a.id=5 and b.name=2)      | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                                                           |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where (a.age=1 and b.id=1) or (a.id=5 and b.name=2) |
      | Fetch_result | dn2             | select * from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where (a.age=1 and b.id=1) or (a.id=5 and b.name=2) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (((a.id = 5) and (b.name = 2) and (b.id = 5)) or ((a.age = 1) and (b.id = 1) and (a.id = 1))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=5\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=5\]},}{ RouteCalculateUnit 2 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                             | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where a.age=1 and (a.id=1 or b.id=1)    | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                                            |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (a.id=1 or b.id=1) |
      | Fetch_result | dn2             | select * from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (a.id=1 or b.id=1) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (a.age = 1) and (((b.id = 1) and (a.id = 1)) or ((a.id = 1) and (b.id = 1))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                          | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where a.age=1 and (b.name=2 and (a.pad=1 and (a.id=1 or b.id=1)))    | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0  | SHARDING_NODE-4 | SQL/REF-5                                                                                                                         |
      | Execute_SQL  | dn2             | select * from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (b.name=2 and (a.pad=1 and (a.id=1 or b.id=1))) |
      | Fetch_result | dn2             | select * from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (b.name=2 and (a.pad=1 and (a.id=1 or b.id=1))) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (a.age = 1) and (b.name = 2) and (a.pad = 1) and (((b.id = 1) and (a.id = 1)) or ((a.id = 1) and (b.id = 1))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "2"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                         | expect      | db      |
      | conn_0 | False   | select * from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where (a.id=1 or b.id=5) and (a.id=9 or b.id=13)    | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4   | SQL/REF-5                                                                                                                                                                                                                                                                                                                                      |
      | Execute_SQL   | dn2_0             | select `a`.`id`,`a`.`aid`,`a`.`name`,`a`.`age`,`a`.`pad`,`b`.`id`,`b`.`pad`,`b`.`name`,`b`.`age` from  `sharding_4_t1` `a` join  `sharding_4_t2` `b` on `a`.`id` = `b`.`id` where  (  ( `a`.`id` in (1) OR `b`.`id` in (5)) AND  ( `a`.`id` in (9) OR `b`.`id` in (13))) |
      | Fetch_result  | dn2_0             | select `a`.`id`,`a`.`aid`,`a`.`name`,`a`.`age`,`a`.`pad`,`b`.`id`,`b`.`pad`,`b`.`name`,`b`.`age` from  `sharding_4_t1` `a` join  `sharding_4_t2` `b` on `a`.`id` = `b`.`id` where  (  ( `a`.`id` in (1) OR `b`.`id` in (5)) AND  ( `a`.`id` in (9) OR `b`.`id` in (13))) |
      | MERGE         | merge_1           | dn2_0    |
      | SHUFFLE_FIELD | shuffle_field_1   | merge_1  |

    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (((b.id = 5) and (a.id = 5)) or ((a.id = 1) and (b.id = 1)))) and ((a.id =) and (b.id =) and (((b.id = 13) and (a.id = 13)) or ((a.id = 9) and (b.id = 9))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "A1" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (((b.id IN 5)) or ((a.id IN 1)))) and ((a.id =) and (b.id =) and (((b.id IN 13)) or ((a.id IN 9))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=5\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=5\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B1" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=13\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=13\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=9\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=9\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B2" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value in \[5\]\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value in \[1\]\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B3" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value in \[13\]\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value in \[9\]\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "A1" value is "1"
    Then check result "B" value is "1"
    Then check result "B1" value is "1"
    Then check result "B2" value is "1"
    Then check result "B3" value is "1"


    #case "union",route one db
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                              | expect      | db      |
      | conn_0 | False   | (select id,age,name from sharding_4_t1 where (age=1 and id=1)or (id=1 and name=2)) union (select id,age,name from schema2.sharding_4_t2 where age=1 and id=1)    | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4   | SQL/REF-5                                                                                                                                                                                                                          |
      | Execute_SQL   | dn2_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`age`,`sharding_4_t1`.`name` from  `sharding_4_t1` where  (  ( `sharding_4_t1`.`age` = 1 AND `sharding_4_t1`.`id` = 1) OR  ( `sharding_4_t1`.`id` = 1 AND `sharding_4_t1`.`name` = 2)) |
      | Fetch_result  | dn2_0             | select `sharding_4_t1`.`id`,`sharding_4_t1`.`age`,`sharding_4_t1`.`name` from  `sharding_4_t1` where  (  ( `sharding_4_t1`.`age` = 1 AND `sharding_4_t1`.`id` = 1) OR  ( `sharding_4_t1`.`id` = 1 AND `sharding_4_t1`.`name` = 2)) |
      | Execute_SQL   | dn2_1             | select `sharding_4_t2`.`id` as `id`,`sharding_4_t2`.`age` as `age`,`sharding_4_t2`.`name` as `name` from  `sharding_4_t2` where  ( `sharding_4_t2`.`age` = 1 AND `sharding_4_t2`.`id` = 1)                                         |
      | Fetch_result  | dn2_1             | select `sharding_4_t2`.`id` as `id`,`sharding_4_t2`.`age` as `age`,`sharding_4_t2`.`name` as `name` from  `sharding_4_t2` where  ( `sharding_4_t2`.`age` = 1 AND `sharding_4_t2`.`id` = 1)                                         |
      | MERGE         | merge_1           | dn2_0                             |
      | SHUFFLE_FIELD | shuffle_field_1   | merge_1                           |
      | MERGE         | merge_2           | dn2_1                             |
      | SHUFFLE_FIELD | shuffle_field_3   | merge_2                           |
      | UNION_ALL     | union_all_1       | shuffle_field_1; shuffle_field_3  |
      | DISTINCT      | distinct_1        | union_all_1                       |
      | SHUFFLE_FIELD | shuffle_field_2   | distinct_1                        |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((schema1.sharding_4_t1.id = 1) and (schema1.sharding_4_t1.name = 2)) or ((schema1.sharding_4_t1.age = 1) and (schema1.sharding_4_t1.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "A1" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((schema2.sharding_4_t2.age = 1) and (schema2.sharding_4_t2.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "A2" in "dble-1"
    """
    grep "these conditions will try to pruning:{(() or ()) and (((schema2.sharding_4_t2.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B1" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "A1" value is "1"
    Then check result "A2" value is "1"
    Then check result "B" value is "1"
    Then check result "B1" value is "2"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                        | expect      | db      |
      | conn_0 | False   | (select id,age,name from sharding_4_t1 where age=1 and id=1) union (select id,age,name from schema2.sharding_4_t2 where age=1 and id=1)    | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4 | SQL/REF-5                                                                                                                       |
      | Execute_SQL   | dn2             | (select id,age,name from sharding_4_t1 where age=1 and id=1) union (select id,age,name from sharding_4_t2 where age=1 and id=1) |
      | Fetch_result  | dn2             | (select id,age,name from sharding_4_t1 where age=1 and id=1) union (select id,age,name from sharding_4_t2 where age=1 and id=1) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 1))) and (((schema2.sharding_4_t2.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B1" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "3"
    Then check result "B1" value is "2"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                 | expect      | db      |
      | conn_0 | False   | (select id,age,name from sharding_4_t1 where age=1 and (name=2 and (pad=1 and id=1))) union (select id,age,name from schema2.sharding_4_t2 where age=1 and id=1)    | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4 | SQL/REF-5                                                                                                                                                |
      | Execute_SQL   | dn2             | (select id,age,name from sharding_4_t1 where age=1 and (name=2 and (pad=1 and id=1))) union (select id,age,name from sharding_4_t2 where age=1 and id=1) |
      | Fetch_result  | dn2             | (select id,age,name from sharding_4_t1 where age=1 and (name=2 and (pad=1 and id=1))) union (select id,age,name from sharding_4_t2 where age=1 and id=1) |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{(((sharding_4_t1.id = 1))) and (((schema2.sharding_4_t2.id = 1)))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B1" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "2"
    Then check result "B" value is "4"
    Then check result "B1" value is "3"


    #case has"Subquery",route one db
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                     | expect      | db      |
      | conn_0 | False   | select * from (select a.id,b.age from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where (a.age=1 and b.id=1) or (a.id=5 and b.name=2))m   | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4 | SQL/REF-5                                                                                                                                     |
      | Execute_SQL   | dn2             | select * from (select a.id,b.age from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where (a.age=1 and b.id=1) or (a.id=5 and b.name=2))m |
      | Fetch_result  | dn2             | select * from (select a.id,b.age from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where (a.age=1 and b.id=1) or (a.id=5 and b.name=2))m |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (((a.id = 5) and (b.name = 2) and (b.id = 5)) or ((a.age = 1) and (b.id = 1) and (a.id = 1))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=5\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=5\]},}{ RouteCalculateUnit 2 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "2"
    Then check result "B" value is "2"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                      | expect      | db      |
      | conn_0 | False   | select * from (select a.id,b.age from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where a.age=1 and (a.id=5 or b.id=1))m   | length{(1)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4 | SQL/REF-5                                                                                                                      |
      | Execute_SQL   | dn2             | select * from (select a.id,b.age from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (a.id=5 or b.id=1))m |
      | Fetch_result  | dn2             | select * from (select a.id,b.age from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (a.id=5 or b.id=1))m |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (a.age = 1) and (((b.id = 1) and (a.id = 1)) or ((a.id = 5) and (b.id = 5))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=5\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=5\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "1"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                    | expect      | db      |
      | conn_0 | False   | select * from (select a.id,b.age from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where a.age=1 and (b.name=2 and (a.pad=1 and (a.id=5 or b.id=1))))m    | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | False   | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0   | SHARDING_NODE-4 | SQL/REF-5                                                                                                                                                   |
      | Execute_SQL   | dn2             | select * from (select a.id,b.age from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (b.name=2 and (a.pad=1 and (a.id=5 or b.id=1))))m |
      | Fetch_result  | dn2             | select * from (select a.id,b.age from sharding_4_t1 a join sharding_4_t2 b on a.id=b.id where a.age=1 and (b.name=2 and (a.pad=1 and (a.id=5 or b.id=1))))m |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (a.age = 1) and (b.name = 2) and (a.pad = 1) and (((b.id = 1) and (a.id = 1)) or ((a.id = 5) and (b.id = 5))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=5\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=5\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "1"
    Then check result "B" value is "2"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                    | expect      | db      |
      | conn_0 | False   | select * from (select a.id,b.age from sharding_4_t1 a join schema2.sharding_4_t2 b on a.id=b.id where (a.id=1 or b.id=5) and (a.id=9 or b.id=13))m     | length{(0)} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql          |
      | conn_0 | true    | show trace   |
    Then check resultset "rs_1" has lines with following column values
      | OPERATION-0                | SHARDING_NODE-4              | SQL/REF-5                                                                                                                                                                                         |
      | Execute_SQL                | dn2_0                        | select `a`.`id`,`b`.`age` from  `sharding_4_t1` `a` join  `sharding_4_t2` `b` on `a`.`id` = `b`.`id` where  (  ( `a`.`id` in (1) OR `b`.`id` in (5)) AND  ( `a`.`id` in (9) OR `b`.`id` in (13))) |
      | Fetch_result               | dn2_0                        | select `a`.`id`,`b`.`age` from  `sharding_4_t1` `a` join  `sharding_4_t2` `b` on `a`.`id` = `b`.`id` where  (  ( `a`.`id` in (1) OR `b`.`id` in (5)) AND  ( `a`.`id` in (9) OR `b`.`id` in (13))) |
      | MERGE                      | merge_1                      | dn2_0                             |
      | SHUFFLE_FIELD              | shuffle_field_1              | merge_1                           |
      | RENAME_DERIVED_SUB_QUERY   | rename_derived_sub_query_1   | shuffle_field_1                   |
      | SHUFFLE_FIELD              | shuffle_field_2              | rename_derived_sub_query_1        |
    Then get result of oscmd named "A" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (((b.id = 5) and (a.id = 5)) or ((a.id = 1) and (b.id = 1)))) and ((a.id =) and (b.id =) and (((b.id = 13) and (a.id = 13)) or ((a.id = 9) and (b.id = 9))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "A1" in "dble-1"
    """
    grep "these conditions will try to pruning:{((a.id =) and (b.id =) and (((b.id IN 5)) or ((a.id IN 1)))) and ((a.id =) and (b.id =) and (((b.id IN 13)) or ((a.id IN 9))))}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=5\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=5\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=1\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=1\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B1" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=13\]},{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=13\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value=9\]},{schema:schema2,table:sharding_4_t2,column:ID,value :\[value=9\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B2" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value in \[5\]\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value in \[1\]\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then get result of oscmd named "B3" in "dble-1"
    """
    grep "RouteCalculateUnit 1 :{schema:schema2,table:sharding_4_t2,column:ID,value :\[value in \[13\]\]},}{ RouteCalculateUnit 2 :{schema:schema1,table:sharding_4_t1,column:ID,value :\[value in \[9\]\]},}" /opt/dble/logs/dble.log | wc -l
    """
    Then check result "A" value is "2"
    Then check result "A1" value is "2"
    Then check result "B" value is "2"
    Then check result "B1" value is "2"
    Then check result "B2" value is "2"
    Then check result "B3" value is "2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                      | success     | schema1 |
      | conn_0 | true    | drop table if exists schema2.sharding_4_t2                                              | success     | schema1 |

  @skip_restart
  Scenario:Complex query "where" has one table shardingColumn, 2 routes (after calculating the route for the first time, it is found that it cannot be delivered to a node as a whole,Discard the routing result and calculate the route again in a complex query)
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" shardingNode="dn5">
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config"
    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
      """
      s/debug/trace/g
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                     | expect      | db      |
      | conn_0 | False   | drop table if exists sharding_4_t1                                                      | success     | schema1 |
      | conn_0 | False   | drop table if exists schema2.sharding_4_t2                                              | success     | schema1 |
      | conn_0 | False   | create table sharding_4_t1(id int,aid int,name char(20),age int,pad int)                | success     | schema1 |
      | conn_0 | False   | create table schema2.sharding_4_t2(id int,pad int,name char(20),age int)                | success     | schema1 |
      | conn_0 | true    | insert into sharding_4_t1 values(1,1,1,1,1),(2,2,2,2,2),(3,3,3,3,3),(4,4,4,4,4)         | success     | schema1 |
      | conn_0 | False   | insert into schema2.sharding_4_t2 values(1,1,1,1),(2,2,2,2),(3,3,3,3),(4,4,4,4)         | success     | schema1 |
      | conn_0 | False   | set @@trace=1                                                                           | success     | schema1 |






#    Then execute sql in "dble-1" in "user" mode
#      | conn   | toClose | sql                                                                                                                                        | expect      | db      |
#      | conn_0 | False   | (select id,age,name from sharding_4_t1 where age=1 and id=1) union (select id,age,name from schema2.sharding_4_t2 where age=1 and id=1)    | length{(1)} | schema1 |
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
#      | conn   | toClose | sql          |
#      | conn_0 | False   | show trace   |
#    Then check resultset "rs_1" has lines with following column values
#      | OPERATION-0   | SHARDING_NODE-4 | SQL/REF-5                                                                                                                       |
#      | Execute_SQL   | dn2             | (select id,age,name from sharding_4_t1 where age=1 and id=1) union (select id,age,name from sharding_4_t2 where age=1 and id=1) |
#      | Fetch_result  | dn2             | (select id,age,name from sharding_4_t1 where age=1 and id=1) union (select id,age,name from sharding_4_t2 where age=1 and id=1) |
#    Then get result of oscmd named "A" in "dble-1"
#    """
#    grep " " /opt/dble/logs/dble.log | wc -l
#    """
#    Then get result of oscmd named "B" in "dble-1"
#    """
#    grep " " /opt/dble/logs/dble.log | wc -l
#    """
#    Then check result "A" value is "1"
#    Then check result "B" value is "3"
























#    Given update file content "/opt/dble/conf/log4j2.xml" in "dble-1" with sed cmds
#      """
#      s/debug/trace/g
#      """
#    Given Restart dble in "dble-1" success
#

