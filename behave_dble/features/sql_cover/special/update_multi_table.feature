# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/7/29


Feature: test supported  multi_table update   coz:DBLE0REQ-1670


   Scenario: some not supported       #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="t2" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
        <shardingTable name="t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1">
          <privileges check="true">
            <schema name="schema1" dml="1111">
              <table name="t1" dml="1101"/>
              <table name="t2" dml="1010"/>
            </schema>
          </privileges>
      </shardingUser>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                    | expect                                         | db      |
      | conn_0 | False   | drop table if exists t1                                                | success                                        | schema1 |
      | conn_0 | False   | drop table if exists t2                                                | success                                        | schema1 |
      | conn_0 | False   | drop table if exists t3                                                | success                                        | schema1 |
      | conn_0 | False   | create table t1(id int,name char(20),age int)                          | success                                        | schema1 |
      | conn_0 | False   | create table t2(id int,name char(20),age int)                          | success                                        | schema1 |
      | conn_0 | False   | create table t3(id int,name char(20),age int)                          | success                                        | schema1 |
      | conn_0 | False   | insert into t1 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6)  | success                                        | schema1 |
      | conn_0 | False   | insert into t2 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6)  | success                                        | schema1 |
      | conn_0 | False   | insert into t3 values (1,1,1),(2,2,2),(3,3,3),(4,4,4),(5,5,5),(6,6,6)  | success                                        | schema1 |
      ##case: no privilege update and select
      | conn_0 | False   | update t1 a,t2 b set a.age=11 where a.name=b.age                       | The statement DML privilege check is not passe | schema1 |
      | conn_0 | False   | update t2 a,t3 b set a.age=11 where a.name=b.age                       | The statement DML privilege check is not passe | schema1 |
      | conn_0 | true    | update t2 a,(select * from t1) b set a.age=11 where a.name=b.age       | The statement DML privilege check is not passe | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1"/>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                  | expect                                         | db      |
      ##case: 不支持 more than 2 tables,非广播下发
      | conn_0 | False   | update t1 a,t2 b,t3 c set c.age=11 where a.name=b.age                | Update of more than 2 tables is not supported! | schema1 |
      ##case: 不支持 set and where 带有表达式  不支持局限于=、>、>=、<、<=、<>、<=>,likt时左右两边的值存在表达式
      | conn_0 | False   | update t1 a,t2 b set a.age=b.age*1 where a.name=b.age                               | Expression not supported     | schema1 |
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name where a.name=b.age+1                              | Expression not supported     | schema1 |
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name where a.name between 1 and 3                      | success     | schema1 |
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name where a.name like 1                               | success     | schema1 |
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name where 1=1 or a.id = b.name                        | success     | schema1 |
      ##case: 不支持set包含多个表字段
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name,b.id=1 where a.name=b.age                | Update set multiple tables is not supported yet     | schema1 |
      ##case: 不支持 limit and order by
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name where a.name=b.age limit 1               | Incorrect usage of UPDATE and LIMIT                 | schema1 |
      | conn_0 | False   | update t1 a,t2 b set a.age=b.name where a.name=b.age order by a.name       | Incorrect usage of UPDATE and ORDER                 | schema1 |
      ##case: 不支持 left join right join
      | conn_0 | False   | update t1 a left join t2 b on a.name=b.age set a.age=b.name                   | Update multi-table currently only supports join/inner-join/cross-join     | schema1 |
      | conn_0 | False   | update t1 a right join t2 b on a.name=b.age set a.age=b.name                  | Update multi-table currently only supports join/inner-join/cross-join     | schema1 |
      | conn_0 | False   | update t2 a join (select age,id from t3) b on a.age=b.id set b.age=a.id       | Subquery fields are not allowed to be updated  | schema1 |
      | conn_0 | False   | update t2 a,(select age,age2 from t3) b set b.age=a.age where a.age2=b.age2   | Subquery fields are not allowed to be updated | schema1 |
      ##case: 不支持 子查询大于两张表
      | conn_0 | False   | update t2 a,(select c.age from t1 c join t3 e on c.id=e.id limit 3) b set a.age=b.age       | Update of more than 2 tables is not supported! | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                        | expect    | db      |
      | conn_0 | true    | drop table if exists t1;drop table if exists t2;drop table if exists t3    | success   | schema1 |


   Scenario: check queryForUpdateMaxRowsSize parameter #2
    ## default value
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name ="queryForUpdateMaxRowsSize"          | has{(('20000',),)}       | dble_information |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      /-DqueryForUpdateMaxRowsSize/d
      $a -DqueryForUpdateMaxRowsSize=-1
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                   | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name ="queryForUpdateMaxRowsSize"          | has{(('20000',),)}       | dble_information |

    ## illegal value aa
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/DqueryForUpdateMaxRowsSize=-1/DqueryForUpdateMaxRowsSize=aa/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ queryForUpdateMaxRowsSize \] 'aa' data type should be long
      """
    ## illegal value 9.9
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/DqueryForUpdateMaxRowsSize=aa/DqueryForUpdateMaxRowsSize=9.9/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ queryForUpdateMaxRowsSize \] '9.9' data type should be long
      """
    ## illegal value null
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/DqueryForUpdateMaxRowsSize=9.9/DqueryForUpdateMaxRowsSize=null/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ queryForUpdateMaxRowsSize \] 'null' data type should be long
      """
    ## illegal value none
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/DqueryForUpdateMaxRowsSize=null/DqueryForUpdateMaxRowsSize=/g
      """
    Then restart dble in "dble-1" failed for
      """
      property \[ queryForUpdateMaxRowsSize \] '' data type should be long
      """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/DqueryForUpdateMaxRowsSize=/DqueryForUpdateMaxRowsSize=1/g
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect               | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name ="queryForUpdateMaxRowsSize"          | has{(('1',),)}       | dble_information |
    Then check following text exist "N" in file "/opt/dble/conf/bootstrap.dynamic.cnf" in host "dble-1"
      """
      queryForUpdateMaxRowsSize
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="t2" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
      </schema>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                             | expect  | db      |
      | conn_0 | False   | drop table if exists t1;drop table if exists t2                                                 | success | schema1 |
      | conn_0 | False   | create table t1 (id int,name char(20),age int);create table t2 (id int,name char(20),age int)   | success | schema1 |
      | conn_0 | False   | insert into t1 values (1,'aaa',11),(2,'bbb',22),(3,'ccc',33),(4,'aaa',33),(5,'ddd',55)          | success | schema1 |
      | conn_0 | true    | insert into t2 values (1,'aaa',11),(2,'bbb',22),(3,'ccc',33),(4,'aaa',33),(5,'ddd',55)          | success | schema1 |
      | conn_0 | true    | update t1 a,t2 b set b.id=b.age where a.age=b.id         | update involves too many rows in query,the maximum number of rows [queryForUpdateMaxRowsSize in bootstrap.cnf] allowed is 1 | schema1 |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
      s/DqueryForUpdateMaxRowsSize=1/DqueryForUpdateMaxRowsSize=10/g
      """
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                                                 | expect                | db               |
      | conn_0 | true    | select variable_value from dble_variables where variable_name ="queryForUpdateMaxRowsSize"          | has{(('10',),)}       | dble_information |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                           | expect  | db      |
      | conn_1 | true    | update t1 a,t2 b set b.id=a.age where a.age=b.id              | success | schema1 |
      | conn_1 | true    | drop table if exists t1;drop table if exists t2               | success | schema1 |


   Scenario: update multi_table  #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="t2" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
        <shardingTable name="t3" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="er_parent" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id">
            <childTable name="er_child1" joinColumn="id" parentColumn="id"/>
            <childTable name="er_child2" joinColumn="id" parentColumn="id"/>
        </shardingTable>
      </schema>
      <schema shardingNode="dn1" name="schema2" sqlMaxLimit="100">
        <shardingTable name="t4" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="t5" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="id" />
        <shardingTable name="t6" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
      </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists t1                                                                              | success | schema1 |
      | conn_0 | False   | drop table if exists t2                                                                              | success | schema1 |
      | conn_0 | False   | drop table if exists t3                                                                              | success | schema1 |
      | conn_0 | False   | drop table if exists er_parent                                                                       | success | schema1 |
      | conn_0 | False   | drop table if exists er_child1                                                                       | success | schema1 |
      | conn_0 | False   | drop table if exists er_child2                                                                       | success | schema1 |
      | conn_0 | False   | create table t1(id int,name char(20),age int,age2 int)                                               | success | schema1 |
      | conn_0 | False   | create table t2(id int,name char(20),age int,age2 int)                                               | success | schema1 |
      | conn_0 | False   | create table t3(id int,name char(20),age int,age2 int)                                               | success | schema1 |
      | conn_0 | False   | create table er_parent (id int,name char(20),age int)                                                | success | schema1 |
      | conn_0 | False   | create table er_child1 (id int,name char(20),age int)                                                | success | schema1 |
      | conn_0 | False   | create table er_child2 (id int,name char(20),age int)                                                | success | schema1 |
      | conn_0 | False   | insert into t1 values (1,'aaa',11,21),(2,'bbb',22,21),(3,'ccc',33,21),(4,'aaa',33,21),(5,'ddd',55,21),(6,'eee',55,21)        | success | schema1 |
      | conn_0 | False   | insert into t2 values (1,'aaa',11,21),(2,'bbb',22,21),(3,'ccc',33,21),(4,'aaa',33,21),(5,'ddd',55,21),(6,'eee',55,21)        | success | schema1 |
      | conn_0 | False   | insert into t3 values (1,'aaa',11,21),(2,'bbb',22,21),(3,'ccc',33,21),(4,'aaa',33,21),(5,'ddd',55,21),(6,'eee',55,21)        | success | schema1 |
      | conn_0 | False   | insert into er_parent values (1,'aaa',11),(2,'bbb',22),(3,'ccc',33),(4,'aaa',33),(5,'ddd',55),(6,'eee',55)                   | success | schema1 |
      | conn_0 | False   | insert into er_child1 values (1,'aaa',11)                                                             | success | schema1 |
      | conn_0 | False   | insert into er_child2 values (1,'aaa',11)                                                             | success | schema1 |
      | conn_0 | False   | insert into er_child1 values (2,'bbb',22)                                                             | success | schema1 |
      | conn_0 | true    | insert into er_child2 values (2,'bbb',22)                                                             | success | schema1 |

    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                  | expect  | db      |
      | conn_0 | False   | drop table if exists t1                                                                              | success | schema1 |
      | conn_0 | False   | drop table if exists t2                                                                              | success | schema1 |
      | conn_0 | False   | drop table if exists t3                                                                              | success | schema1 |
      | conn_0 | False   | drop table if exists er_parent                                                                       | success | schema1 |
      | conn_0 | False   | drop table if exists er_child1                                                                       | success | schema1 |
      | conn_0 | False   | drop table if exists er_child2                                                                       | success | schema1 |
      | conn_0 | False   | create table t1(id int,name char(20),age int,age2 int)                                               | success | schema1 |
      | conn_0 | False   | create table t2(id int,name char(20),age int,age2 int)                                               | success | schema1 |
      | conn_0 | False   | create table t3(id int,name char(20),age int,age2 int)                                               | success | schema1 |
      | conn_0 | False   | create table er_parent (id int,name char(20),age int)                                                | success | schema1 |
      | conn_0 | False   | create table er_child1 (id int,name char(20),age int)                                                | success | schema1 |
      | conn_0 | False   | create table er_child2 (id int,name char(20),age int)                                                | success | schema1 |
      | conn_0 | False   | insert into t1 values (1,'aaa',11,21),(2,'bbb',22,21),(3,'ccc',33,21),(4,'aaa',33,21),(5,'ddd',55,21),(6,'eee',55,21)        | success | schema1 |
      | conn_0 | False   | insert into t2 values (1,'aaa',11,21),(2,'bbb',22,21),(3,'ccc',33,21),(4,'aaa',33,21),(5,'ddd',55,21),(6,'eee',55,21)        | success | schema1 |
      | conn_0 | False   | insert into t3 values (1,'aaa',11,21),(2,'bbb',22,21),(3,'ccc',33,21),(4,'aaa',33,21),(5,'ddd',55,21),(6,'eee',55,21)        | success | schema1 |
      | conn_0 | False   | insert into er_parent values (1,'aaa',11),(2,'bbb',22),(3,'ccc',33),(4,'aaa',33),(5,'ddd',55),(6,'eee',55)                   | success | schema1 |
      | conn_0 | False   | insert into er_child1 values (1,'aaa',11)                                                             | success | schema1 |
      | conn_0 | False   | insert into er_child2 values (1,'aaa',11)                                                             | success | schema1 |
      | conn_0 | False   | insert into er_child1 values (2,'bbb',22)                                                             | success | schema1 |
      | conn_0 | true    | insert into er_child2 values (2,'bbb',22)                                                             | success | schema1 |


      ##case1: 广播下发是支持大于两张表的
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                  | expect  | db      |
       ## 字段数据类型不一致应报错 DBLE0REQ-2002
      | conn_0 | False   | update er_parent a,er_child1 b,er_child2 c set c.age=b.name where a.id=b.id and c.id=a.id          | Incorrect integer value   | schema1 |
      | conn_0 | False   | update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id            | success | schema1 |
      ### 因为上一行改变了id的值，a.id=b.id and c.id=a.id找不到结果了，所以update影响行数为0
      | conn_0 | False   | update er_parent a,er_child1 b,er_child2 c set c.age=b.name where a.id=b.id and c.id=a.id          | success | schema1 |
      | conn_0 | False   | select sleep(1)                                                                                    | success | schema1 |
      | conn_0 | False   | select * from er_child2                                                                            | has{((11, 'aaa', 11), (22, 'bbb', 22))} | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_1"
      | conn      | toClose | sql                                                                                                 | db      |
      | conn_1    | true    | explain update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id     | schema1 |
    Then check resultset "case_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1   | SQL/REF-2                                                                               |
      | dn1             | BASE SQL | update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id |
      | dn3             | BASE SQL | update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id |
      | dn2             | BASE SQL | update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id |
      | dn4             | BASE SQL | update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                     | db      |
      | conn_1 | true    | update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id | schema1 |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      execute multi node query update er_parent a,er_child1 b,er_child2 c set c.id=b.age where a.id=b.id and c.id=a.id
      1 -> rrsNode\[dn1-false-{schema1.er_parent,schema1.er_child1,schema1.er_child2}.0-{update er_parent a,er_child1 b,er_child2 c set c.age=b.name where a.id=b.id and c.id=a.id}.0\]
      2 -> rrsNode\[dn3-false-{schema1.er_parent,schema1.er_child1,schema1.er_child2}.0-{update er_parent a,er_child1 b,er_child2 c set c.age=b.name where a.id=b.id and c.id=a.id}.0\]
      3 -> rrsNode\[dn2-false-{schema1.er_parent,schema1.er_child1,schema1.er_child2}.0-{update er_parent a,er_child1 b,er_child2 c set c.age=b.name where a.id=b.id and c.id=a.id}.0\]
      4 -> rrsNode\[dn4-false-{schema1.er_parent,schema1.er_child1,schema1.er_child2}.0-{update er_parent a,er_child1 b,er_child2 c set c.age=b.name where a.id=b.id and c.id=a.id}.0\]
      """
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update
      """


      ##case2: 两张表 where 分片键
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                         | expect  | db      |
      | conn_0 | False   | update t1 a,t2 b set a.age=b.age2 where a.id=b.id           | success | schema1 |
      | conn_0 | False   | select sleep(1)                                             | success | schema1 |
      | conn_0 | False   | select age from t1                                          | has{((21,), (21,), (21,), (21,), (21,), (21,))} | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                 | db      |
      | conn_1 | true    | update t1 a,t2 b set a.age=b.age2 where a.id=b.id   | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_2"
      | conn      | toClose | sql                                                            | db      |
      | conn_1    | true    | explain update t1 a,t2 b set a.age=b.age2 where a.id=b.id      | schema1 |
    Then check resultset "case_2" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                                   |
      | dn1_0                                   | BASE SQL                              | select `b`.`age2`,`b`.`id` from  `t2` `b` GROUP BY `b`.`age2`,`b`.`id` ORDER BY `b`.`age2` ASC,`b`.`id` ASC |
      | dn2_0                                   | BASE SQL                              | select `b`.`age2`,`b`.`id` from  `t2` `b` GROUP BY `b`.`age2`,`b`.`id` ORDER BY `b`.`age2` ASC,`b`.`id` ASC |
      | dn3_0                                   | BASE SQL                              | select `b`.`age2`,`b`.`id` from  `t2` `b` GROUP BY `b`.`age2`,`b`.`id` ORDER BY `b`.`age2` ASC,`b`.`id` ASC |
      | merge_and_order_1                       | MERGE_AND_ORDER                       | dn1_0; dn2_0; dn3_0                                                                                         |
      | aggregate_1                             | AGGREGATE                             | merge_and_order_1                                                                                           |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | aggregate_1                                                                                                 |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_1                                                                                             |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t1` `a` set `a`.`age` = '{CHILD}' where `a`.`id` = '{CHILD}'                                 |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t1` `a` set `a`.`age` = '{CHILD}' where `a`.`id` = '{CHILD}'                                 |
      | ------ merge_1                          | ------ MERGE                          | ------ dn1_1; dn2_1                                                                                         |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | merge_1                                                                                                     |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_2                                                                                             |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_update_1                                                                                              |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t1\` \`a\` set \`a\`.\`age\` = 21 where \`a\`.\`id\` = 1
      merge update——update sql:update \`schema1\`.\`t1\` \`a\` set \`a\`.\`age\` = 21 where \`a\`.\`id\` = 2
      merge update——update sql:update \`schema1\`.\`t1\` \`a\` set \`a\`.\`age\` = 21 where \`a\`.\`id\` = 3
      merge update——update sql:update \`schema1\`.\`t1\` \`a\` set \`a\`.\`age\` = 21 where \`a\`.\`id\` = 4
      merge update——update sql:update \`schema1\`.\`t1\` \`a\` set \`a\`.\`age\` = 21 where \`a\`.\`id\` = 5
      merge update——update sql:update \`schema1\`.\`t1\` \`a\` set \`a\`.\`age\` = 21 where \`a\`.\`id\` = 6
      """

      ##case3: set多个字段
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                | expect  | db      |
      | conn_0 | False   | update t1 a,t2 b set b.name='abc',b.age2=a.id where a.id=b.id and a.name='bbb'     | success | schema1 |
      | conn_0 | False   | select sleep(1)                                                                    | success | schema1 |
      | conn_0 | False   | select * from t2 where id=2                                                        | has{((2, 'abc', 22, 2),)} | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                              | db      |
      | conn_1 | true    | update t1 a,t2 b set b.name='abc',b.age2=a.id where a.id=b.id and a.name='bbb'   | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_3"
      | conn      | toClose | sql                                                                                         | db      |
      | conn_1    | true    | explain update t1 a,t2 b set b.name='abc',b.age2=a.id where a.id=b.id and a.name='bbb'      | schema1 |
    Then check resultset "case_3" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                                               |
      | dn1_0                                   | BASE SQL                              | select `a`.`id`,`a`.`name` from  `t1` `a` GROUP BY `a`.`id`,`a`.`name` ORDER BY `a`.`id` ASC,`a`.`name` ASC             |
      | dn2_0                                   | BASE SQL                              | select `a`.`id`,`a`.`name` from  `t1` `a` GROUP BY `a`.`id`,`a`.`name` ORDER BY `a`.`id` ASC,`a`.`name` ASC             |
      | merge_and_order_1                       | MERGE_AND_ORDER                       | dn1_0; dn2_0                                                                                                            |
      | aggregate_1                             | AGGREGATE                             | merge_and_order_1                                                                                                       |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | aggregate_1                                                                                                             |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_1                                                                                                         |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `b` set `b`.`name` = 'abc',`b`.`age2` = '{CHILD}' where ('{CHILD}' = `b`.`id` AND '{CHILD}' = 'bbb') |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `b` set `b`.`name` = 'abc',`b`.`age2` = '{CHILD}' where ('{CHILD}' = `b`.`id` AND '{CHILD}' = 'bbb') |
      | ------ dn3_0                            | ------ BASE SQL(May No Need)          | ------ update `t2` `b` set `b`.`name` = 'abc',`b`.`age2` = '{CHILD}' where ('{CHILD}' = `b`.`id` AND '{CHILD}' = 'bbb') |
      | ------ merge_1                          | ------ MERGE                          | ------ dn1_1; dn2_1; dn3_0                                                                                              |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | merge_1                                                                                                                 |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_2                                                                                                         |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_update_1                                                                                                          |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t2\` \`b\` set \`b\`.\`name\` = 'abc',\`b\`.\`age2\` = 1 where \(1 = \`b\`.\`id\` AND 'aaa' = 'bbb'\)
      merge update——update sql:update \`schema1\`.\`t2\` \`b\` set \`b\`.\`name\` = 'abc',\`b\`.\`age2\` = 2 where \(2 = \`b\`.\`id\` AND 'bbb' = 'bbb'\)
      merge update——update sql:update \`schema1\`.\`t2\` \`b\` set \`b\`.\`name\` = 'abc',\`b\`.\`age2\` = 3 where \(3 = \`b\`.\`id\` AND 'ccc' = 'bbb'\)
      merge update——update sql:update \`schema1\`.\`t2\` \`b\` set \`b\`.\`name\` = 'abc',\`b\`.\`age2\` = 4 where \(4 = \`b\`.\`id\` AND 'aaa' = 'bbb'\)
      merge update——update sql:update \`schema1\`.\`t2\` \`b\` set \`b\`.\`name\` = 'abc',\`b\`.\`age2\` = 5 where \(5 = \`b\`.\`id\` AND 'ddd' = 'bbb'\)
      merge update——update sql:update \`schema1\`.\`t2\` \`b\` set \`b\`.\`name\` = 'abc',\`b\`.\`age2\` = 6 where \(6 = \`b\`.\`id\` AND 'eee' = 'bbb'\)
      """

      #case4:  含有子查询
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                    | expect  | db      |
      | conn_0 | False   | update t2 a,(select age,age2 from t3) b set a.age=b.age where a.age2=b.age2 and 1=1    | success | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                  | db      |
      | conn_1 | true    | update t2 a,(select age,age2 from t3) b set a.age=b.age where a.age2=b.age2 and 1=1  | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_4"
      | conn      | toClose | sql                                                                                              | db      |
      | conn_1    | true    | explain update t2 a,(select age,age2 from t3) b set a.age=b.age where a.age2=b.age2 and 1=1      | schema1 |
    Then check resultset "case_4" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                 |
      | dn1_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`age2` from  `t3`                                                  |
      | dn2_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`age2` from  `t3`                                                  |
      | dn3_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`age2` from  `t3`                                                  |
      | dn4_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`age2` from  `t3`                                                  |
      | merge_1                                 | MERGE                                 | dn1_0; dn2_0; dn3_0; dn4_0                                                                |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | merge_1                                                                                   |
      | rename_derived_sub_query_1              | RENAME_DERIVED_SUB_QUERY              | shuffle_field_1                                                                           |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | rename_derived_sub_query_1                                                                |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_2                                                                           |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` = '{CHILD}' AND 1 = 1) |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` = '{CHILD}' AND 1 = 1) |
      | ------ dn3_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` = '{CHILD}' AND 1 = 1) |
      | ------ merge_2                          | ------ MERGE                          | ------ dn1_1; dn2_1; dn3_1                                                                |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_2                                                                                   |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_3                                                                           |
      | shuffle_field_4                         | SHUFFLE_FIELD                         | merge_update_1                                                                            |
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 33 where \(\`a\`.\`age2\` = 21 AND 1 = 1\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 33 where \(\`a\`.\`age2\` = 21 AND 1 = 1\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 11 where \(\`a\`.\`age2\` = 21 AND 1 = 1\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 55 where \(\`a\`.\`age2\` = 21 AND 1 = 1\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 22 where \(\`a\`.\`age2\` = 21 AND 1 = 1\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 55 where \(\`a\`.\`age2\` = 21 AND 1 = 1\)
      """

    ##case5: inner join
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect  | db      |
      | conn_0 | False   | update t2 a inner join t3 b on a.name=b.name set b.name='zhong'    | success | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                               | db      |
      | conn_1 | true    | update t2 a inner join t3 b on a.name=b.name set b.name='zhong'   | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_5"
      | conn      | toClose | sql                                                                                   | db      |
      | conn_1    | true    | explain update t2 a inner join t3 b on a.name=b.name set b.name='zhong'       | schema1 |
    Then check resultset "case_5" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                                |
      | dn1_0                                   | BASE SQL                              | select `a`.`name` as `autoalias_scalar` from  `t2` `a` GROUP BY `a`.`name` ORDER BY autoalias_scalar ASC |
      | dn2_0                                   | BASE SQL                              | select `a`.`name` as `autoalias_scalar` from  `t2` `a` GROUP BY `a`.`name` ORDER BY autoalias_scalar ASC |
      | dn3_0                                   | BASE SQL                              | select `a`.`name` as `autoalias_scalar` from  `t2` `a` GROUP BY `a`.`name` ORDER BY autoalias_scalar ASC |
      | merge_and_order_1                       | MERGE_AND_ORDER                       | dn1_0; dn2_0; dn3_0                                                                                      |
      | aggregate_1                             | AGGREGATE                             | merge_and_order_1                                                                                        |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | aggregate_1                                                                                              |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_1                                                                                          |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t3` `b` set `b`.`name` = 'zhong' where '{CHILD}' = `b`.`name`                             |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t3` `b` set `b`.`name` = 'zhong' where '{CHILD}' = `b`.`name`                             |
      | ------ dn3_1                            | ------ BASE SQL(May No Need)          | ------ update `t3` `b` set `b`.`name` = 'zhong' where '{CHILD}' = `b`.`name`                             |
      | ------ dn4_0                            | ------ BASE SQL(May No Need)          | ------ update `t3` `b` set `b`.`name` = 'zhong' where '{CHILD}' = `b`.`name`                             |
      | ------ merge_1                          | ------ MERGE                          | ------ dn1_1; dn2_1; dn3_1; dn4_0                                                                        |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | merge_1                                                                                                  |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_2                                                                                          |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_update_1                                                                                           |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t3\` \`b\` set \`b\`.\`name\` = 'zhong' where 'aaa' = \`b\`.\`name\`
      merge update——update sql:update \`schema1\`.\`t3\` \`b\` set \`b\`.\`name\` = 'zhong' where 'abc' = \`b\`.\`name\`
      merge update——update sql:update \`schema1\`.\`t3\` \`b\` set \`b\`.\`name\` = 'zhong' where 'ccc' = \`b\`.\`name\`
      merge update——update sql:update \`schema1\`.\`t3\` \`b\` set \`b\`.\`name\` = 'zhong' where 'ddd' = \`b\`.\`name\`
      merge update——update sql:update \`schema1\`.\`t3\` \`b\` set \`b\`.\`name\` = 'zhong' where 'eee' = \`b\`.\`name\`
      """

      ##case6: join
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                       | expect  | db      |
      | conn_0 | False   | update t2 a join (select age,id from t3) b on a.id=b.id and b.age=22 set a.age=b.id       | success | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                    | db      |
      | conn_1 | true    | update t2 a join (select age,id from t3) b on a.id=b.id and b.age=22 set a.age=b.id    | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_3"
      | conn      | toClose | sql                                                                                              | db      |
      | conn_1    | true    | explain update t2 a join (select age,id from t3) b on a.id=b.id and b.age=22 set a.age=b.id      | schema1 |
    Then check resultset "case_3" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                        |
      | dn1_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`id` from  `t3`                                                           |
      | dn2_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`id` from  `t3`                                                           |
      | dn3_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`id` from  `t3`                                                           |
      | dn4_0                                   | BASE SQL                              | select `t3`.`age`,`t3`.`id` from  `t3`                                                           |
      | merge_1                                 | MERGE                                 | dn1_0; dn2_0; dn3_0; dn4_0                                                                       |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | merge_1                                                                                          |
      | rename_derived_sub_query_1              | RENAME_DERIVED_SUB_QUERY              | shuffle_field_1                                                                                  |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | rename_derived_sub_query_1                                                                       |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_2                                                                                  |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`id` = '{CHILD}' AND '{CHILD}' = 22) |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`id` = '{CHILD}' AND '{CHILD}' = 22) |
      | ------ dn3_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`id` = '{CHILD}' AND '{CHILD}' = 22) |
      | ------ merge_2                          | ------ MERGE                          | ------ dn1_1; dn2_1; dn3_1                                                                       |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_2                                                                                          |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_3                                                                                  |
      | shuffle_field_4                         | SHUFFLE_FIELD                         | merge_update_1                                                                                   |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 1 where \(\`a\`.\`id\` = 1 AND 11 = 22\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 5 where \(\`a\`.\`id\` = 5 AND 55 = 22\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 4 where \(\`a\`.\`id\` = 4 AND 33 = 22\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 3 where \(\`a\`.\`id\` = 3 AND 33 = 22\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 2 where \(\`a\`.\`id\` = 2 AND 22 = 22\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 6 where \(\`a\`.\`id\` = 6 AND 55 = 22\)
      """

      ##case7: where 不限于等于号
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                            | expect  | db      |
      | conn_0 | False   | update t2 a,(select age,age2 from t1 where id!=5 and age<22 group by age) b set a.age=b.age where a.age2 > b.age2 or 1=1       | success | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                         | db      |
      | conn_1 | true    | update t2 a,(select age,age2 from t1 where id!=5 and age<22 group by age) b set a.age=b.age where a.age2 > b.age2 or 1=1    | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_7"
      | conn      | toClose | sql                                                                                                                       | db      |
      | conn_1    | true    | explain update t2 a,(select age,age2 from t1 where id!=5 and age<22) b set a.age=b.age where a.age2 > b.age2 or 1=1       | schema1 |
    Then check resultset "case_7" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                |
      | dn1_0                                   | BASE SQL                              | select `t1`.`age`,`t1`.`age2` from  `t1` where  ( `t1`.`id` <> 5 AND `t1`.`age` < 22)    |
      | dn2_0                                   | BASE SQL                              | select `t1`.`age`,`t1`.`age2` from  `t1` where  ( `t1`.`id` <> 5 AND `t1`.`age` < 22)    |
      | merge_1                                 | MERGE                                 | dn1_0; dn2_0                                                                             |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | merge_1                                                                                  |
      | rename_derived_sub_query_1              | RENAME_DERIVED_SUB_QUERY              | shuffle_field_1                                                                          |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | rename_derived_sub_query_1                                                               |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_2                                                                          |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` > '{CHILD}' OR 1 = 1) |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` > '{CHILD}' OR 1 = 1) |
      | ------ dn3_0                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` > '{CHILD}' OR 1 = 1) |
      | ------ merge_2                          | ------ MERGE                          | ------ dn1_1; dn2_1; dn3_0                                                               |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_2                                                                                  |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_3                                                                          |
      | shuffle_field_4                         | SHUFFLE_FIELD                         | merge_update_1                                                                           |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 21 where \(\`a\`.\`age2\` > 21 OR 1 = 1\)
      """


      ##case8: 子查询不限制limit
    Given execute oscmd ">/opt/dble/logs/dble.log" on "dble-1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                          | expect  | db      |
      | conn_0 | False   | update t2 a,(select * from t3 order by id limit 3) b set a.age=b.age where a.age2 > b.age2 or a.id<b.id      | success | schema1 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                         | db      |
      | conn_1 | true    | update t2 a,(select * from t3 order by id limit 3) b set a.age=b.age where a.age2 > b.age2 or a.id<b.id     | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "case_8"
      | conn      | toClose | sql                                                                                                                    | db      |
      | conn_1    | true    | explain update t2 a,(select * from t3 order by id limit 3) b set a.age=b.age where a.age2 > b.age2 or a.id<b.id        | schema1 |
    Then check resultset "case_8" has lines with following column values
      | SHARDING_NODE-0                         | TYPE-1                                | SQL/REF-2                                                                                               |
      | dn1_0                                   | BASE SQL                              | select `t3`.`id`,`t3`.`name`,`t3`.`age`,`t3`.`age2` from  `t3` ORDER BY `t3`.`id` ASC LIMIT 3           |
      | dn2_0                                   | BASE SQL                              | select `t3`.`id`,`t3`.`name`,`t3`.`age`,`t3`.`age2` from  `t3` ORDER BY `t3`.`id` ASC LIMIT 3           |
      | dn3_0                                   | BASE SQL                              | select `t3`.`id`,`t3`.`name`,`t3`.`age`,`t3`.`age2` from  `t3` ORDER BY `t3`.`id` ASC LIMIT 3           |
      | dn4_0                                   | BASE SQL                              | select `t3`.`id`,`t3`.`name`,`t3`.`age`,`t3`.`age2` from  `t3` ORDER BY `t3`.`id` ASC LIMIT 3           |
      | merge_and_order_1                       | MERGE_AND_ORDER                       | dn1_0; dn2_0; dn3_0; dn4_0                                                                              |
      | limit_1                                 | LIMIT                                 | merge_and_order_1                                                                                       |
      | shuffle_field_1                         | SHUFFLE_FIELD                         | limit_1                                                                                                 |
      | rename_derived_sub_query_1              | RENAME_DERIVED_SUB_QUERY              | shuffle_field_1                                                                                         |
      | shuffle_field_2                         | SHUFFLE_FIELD                         | rename_derived_sub_query_1                                                                              |
      | for child in update_sub_query.results_1 | for CHILD in UPDATE_SUB_QUERY.RESULTS | shuffle_field_2                                                                                         |
      | ------ dn1_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` > '{CHILD}' OR `a`.`id` < '{CHILD}') |
      | ------ dn2_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` > '{CHILD}' OR `a`.`id` < '{CHILD}') |
      | ------ dn3_1                            | ------ BASE SQL(May No Need)          | ------ update `t2` `a` set `a`.`age` = '{CHILD}' where (`a`.`age2` > '{CHILD}' OR `a`.`id` < '{CHILD}') |
      | ------ merge_1                          | ------ MERGE                          | ------ dn1_1; dn2_1; dn3_1                                                                              |
      | shuffle_field_3                         | SHUFFLE_FIELD                         | merge_1                                                                                                 |
      | merge_update_1                          | MERGE_UPDATE                          | shuffle_field_3                                                                                         |
      | shuffle_field_4                         | SHUFFLE_FIELD                         | merge_update_1                                                                                          |

    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 11 where \(\`a\`.\`age2\` > 21 OR \`a\`.\`id\` < 1\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 22 where \(\`a\`.\`age2\` > 21 OR \`a\`.\`id\` < 2\)
      merge update——update sql:update \`schema1\`.\`t2\` \`a\` set \`a\`.\`age\` = 33 where \(\`a\`.\`age2\` > 21 OR \`a\`.\`id\` < 3\)
      """

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      setError
      unknown error:
      caught err:
      NullPointerException
      """