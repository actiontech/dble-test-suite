# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/5/7

Feature: check joinStrategyType and useJoinStrategy

  Scenario: check joinStrategyType and useJoinStrategy value #1
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | false            |
      | joinStrategyType | -1               |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DjoinStrategyType/d
    $a -DjoinStrategyType=false
    /-DuseJoinStrategy/d
    $a -DuseJoinStrategy=1
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ joinStrategyType \] 'false' data type should be int
    Property \[ useJoinStrategy \] '1' data type should be boolean
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseJoinStrategy=abc
    $a -DjoinStrategyType=-2
    """
    Then restart dble in "dble-1" failed for
    """
    Property \[ useJoinStrategy \] 'abc' data type should be boolean
    Property \[ joinStrategyType \] '-2' in bootstrap.cnf is illegal, size must not be less than -1 and not be greater than 2, you may need use the default value -1 replaced
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DjoinStrategyType=2
    $a -DuseJoinStrategy=False
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs2" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | false            |
      | joinStrategyType | 2                |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DjoinStrategyType=0
    $a -DuseJoinStrategy=TRUE
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs3" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | true             |
      | joinStrategyType | 0                |

  @delete_mysql_tables
  Scenario: check sql plan #2
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2']}}
  """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
        <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Level" shardingNode="dn3,dn4" function="hash-two" shardingColumn="levelid" />
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    <function name="func_hashString" class="StringHash">
        <property name="partitionCount">2</property>
        <property name="partitionLength">1</property>
        <property name="hashSlice">0:2</property>
    </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level                                     | success | schema1 |
      | conn_0 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | True    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |

    # use default value: joinStrategyType=-1, useJoinStrategy=false => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                              |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                   |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                   |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                               |
      | order_1           | ORDER           | join_1                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                        |
      | dn3_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                               |
      | dn4_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                               |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                              |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                               |
      | order_2           | ORDER           | join_2                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                        |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseJoinStrategy=true
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_1 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | true             |
      | joinStrategyType | -1               |
    # joinStrategyType=-1, useJoinStrategy=true => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | nest_loop_1       | NEST_LOOP             | shuffle_field_1                                                                                                                                                  |
      | dn1_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_2                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_3; shuffle_field_5                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DjoinStrategyType=0
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_1 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | true             |
      | joinStrategyType | 0                |
    # joinStrategyType=0, useJoinStrategy=true => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                              |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                   |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                   |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                               |
      | order_1           | ORDER           | join_1                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                        |
      | dn3_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                               |
      | dn4_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                               |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                              |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                               |
      | order_2           | ORDER           | join_2                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                        |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DjoinStrategyType=0/-DjoinStrategyType=1/
    s/-DuseJoinStrategy=true/-DuseJoinStrategy=false/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_1 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | false            |
      | joinStrategyType | 1                |
      # joinStrategyType=1, useJoinStrategy=false => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | nest_loop_1       | NEST_LOOP             | shuffle_field_1                                                                                                                                                  |
      | dn1_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_2                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_3; shuffle_field_5                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DuseJoinStrategy/d
    $a -DuseJoinStrategy=true
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_1 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | true             |
      | joinStrategyType | 1                |
    # joinStrategyType=1, useJoinStrategy=true => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | nest_loop_1       | NEST_LOOP             | shuffle_field_1                                                                                                                                                  |
      | dn1_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_2                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_3; shuffle_field_5                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DuseJoinStrategy/d
    $a -DuseJoinStrategy=false
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_1 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | false            |
      | joinStrategyType | 1                |
    # joinStrategyType=1, useJoinStrategy=false => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | nest_loop_1       | NEST_LOOP             | shuffle_field_1                                                                                                                                                  |
      | dn1_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_2                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_3; shuffle_field_5                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DjoinStrategyType=1/-DjoinStrategyType=2/
    """
    Then restart dble in "dble-1" success
        Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                     | db               |
      | conn_1 | True    | select variable_name, variable_value from dble_variables where variable_name in ('joinStrategyType', 'useJoinStrategy') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | useJoinStrategy  | false            |
      | joinStrategyType | 2                |
    # joinStrategyType=2, useJoinStrategy=false => table b,c nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | true    | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                                              |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 3401 ORDER BY `a`.`name` ASC                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC       |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC       |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |

  @delete_mysql_tables
  Scenario: check nestLoopConnSize and nestLoopRowsSize value #3
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2']}}
  """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
        <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Level" shardingNode="dn3,dn4" function="hash-two" shardingColumn="levelid" />
    </schema>
    <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
    <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
    <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
    <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
    <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
    <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
    <function name="func_hashString" class="StringHash">
        <property name="partitionCount">2</property>
        <property name="partitionLength">1</property>
        <property name="hashSlice">0:2</property>
    </function>
    """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level                                     | success | schema1 |
      | conn_0 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | True    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                          | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('nestLoopConnSize', 'nestLoopRowsSize', 'joinStrategyType') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | nestLoopConnSize | 4                |
      | nestLoopRowsSize | 2000             |
      | joinStrategyType | -1               |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect      | db      |
      | conn_1 | True    | SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name | length{(9)} | schema1 |
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DnestLoopConnSize/d
    /-DnestLoopRowsSize/d
    /-DjoinStrategyType/d
    $a -DnestLoopConnSize=1
    $a -DnestLoopRowsSize=1
    $a -DjoinStrategyType=2
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                          | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('nestLoopConnSize', 'nestLoopRowsSize', 'joinStrategyType') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | nestLoopConnSize | 1                |
      | nestLoopRowsSize | 1                |
      | joinStrategyType | 2                |
    # temptable row count > nestLoopConnSize * nestLoopRowsSize
    Given execute linux command in "dble-1" and contains exception "Merge thread error, temptable too much rows,[rows size is 2]"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} -Dschema1 -e "SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name"
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DnestLoopRowsSize=1/-DnestLoopRowsSize=2/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                          | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('nestLoopConnSize', 'nestLoopRowsSize', 'joinStrategyType') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | nestLoopConnSize | 1                |
      | nestLoopRowsSize | 2                |
      | joinStrategyType | 2                |
    # temptable row count > nestLoopConnSize * nestLoopRowsSize
    Given execute linux command in "dble-1" and contains exception "Merge thread error, temptable too much rows,[rows size is 3]"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} -Dschema1 -e "SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name"
    """

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    s/-DnestLoopConnSize=1/-DnestLoopConnSize=3/
    s/-DnestLoopRowsSize=2/-DnestLoopRowsSize=3/
    """
    Then restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                          | db               |
      | conn_0 | True    | select variable_name, variable_value from dble_variables where variable_name in ('nestLoopConnSize', 'nestLoopRowsSize', 'joinStrategyType') | dble_information |
    Then check resultset "join_rs1" has lines with following column values
      | variable_name-0  | variable_value-1 |
      | nestLoopConnSize | 3                |
      | nestLoopRowsSize | 3                |
      | joinStrategyType | 2                |
    # temptable row count < nestLoopConnSize * nestLoopRowsSize
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect      | db      |
      | conn_1 | True    | SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name | length{(9)} | schema1 |