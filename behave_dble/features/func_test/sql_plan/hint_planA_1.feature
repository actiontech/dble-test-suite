# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2022/2/10
Feature: test with hint plan A
# DBLE0REQ-1641/DBLE0REQ-1648/DBLE0REQ-1664
# Affected by the above issue, dble cannot recognize the post-er relationship, so hint does not support the post-er relationship
# So when there is an er relationship with a post-position, currently it can only be written without an er relationship
# After the above issue is repaired, you need to pay attention to the sql of such scenarios and modify the case

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  shardingTable                              #1
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
     """
     <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
         <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
         <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
         <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
         <shardingTable name="Level" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="levelname" />
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
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | expect  | db      |
      | conn_0 | False   | create database if not exists schema1                                                                                                                                                                                                                                                                             | success | schema1 |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | success | schema1 |
      | conn_0 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | success | schema1 |
      | conn_0 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | success | schema1 |
      | conn_1 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | success | schema1 |
      | conn_1 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | success | schema1 |

     # 1. a LEFT JOIN b on a.col=b.col LEFT JOIN c on a.col=c.col
     # 1.1. left join & left join & 2 ER (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                    |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | schema1 |

     # 1.2. left join & left join & 2 ER (a,c,b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c ,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                    |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | schema1 |

     # 1.3. left join & left join & 2 ER (b,a,c) with wrong root node
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                               | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name; | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

    # 1.4 left join & left join & 1 ER (a,b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.5 left join & left join & 1 ER ：(a,b) |c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                    |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                           |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                      |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

     # 1.6 left join & left join & 1 ER  a,c,b issue-1641
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | db      | expect  |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | success |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                          |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                           |
      | order_1           | ORDER           | join_1                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                    |
      | dn3_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC           |
      | dn4_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                           |
      | order_2           | ORDER           | join_2                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.6 left join & left join & 1 ER  a,c,b issue-1641
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | db      | expect  |
      | conn_1 | False   | explain /*!dble:plan=a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | success |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan=a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

     # 1.7 left join & left join & 1 ER  bac, bca, cab, cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                   | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| a \| b  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

     # 1.8 left join & left join & NO ER ： (a & b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.9 left join & left join & NO ER ： a &(b | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

     # 1.10 left join & left join & NO ER ： a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                          |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                          |
      | order_1           | ORDER           | join_1                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                   |
      | dn3_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn4_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                         |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                          |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.11  left join & left join & NO ER ： (a | b ) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| b ) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a \| b ) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.11-1  left join & left join & NO ER ： a & b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= a & b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

     # 1.12  left join & left join & NO ER ： (a & c ) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

   # 1.13 left join & left join & NO ER ： a & (c | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

     # 1.14 left join & left join & NO ER ： a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                          |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                           |
      | order_1           | ORDER           | join_1                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                    |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                           |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                     |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan= a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.15 left join & left join & NO ER ： (a | c ) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| c ) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a \| c ) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # 1.16 left join & left join & NO ER ： (a | c ) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

     # 1.17 left join & left join & NO ER ： other error
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a \| b & c  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | schema1 | hint explain build failures! check table c & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | hint explain build failures! check table b & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| a \| b  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |


     # 2. a LEFT JOIN b on a.col=b.col LEFT JOIN c on b.col=c.col
     # 2.1. left join & left join & 2 ER (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                    |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

    #  2.2. left join & left join & 2 ER  acb,bac,bca
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                               | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |

     # 2.3 left join & left join & 1 ER  (a,b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 2.4 left join & left join & 1 ER  (a, b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                  |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                           |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 2.5 left join & left join & 1 ER  acb / bac / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                               | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |

     # 2.6 left join & left join & NO ER  a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_1 | true    | /*#dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

      # 2.6 left join & left join & NO ER  (a | b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a  \| b ) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (a  \| b ) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

      # 2.7 left join & left join & NO ER  (a & b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a  & b ) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (a  & b ) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 2.7 left join & left join & NO ER  a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | order_1           | ORDER           | join_1                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                       |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_2           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 2.8 left join & left join & NO ER  a | b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                | db      |
      | conn_1 | true    | /*#dble:plan= a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

   # 2.9 left join & left join & NO ER  acb / bac / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                         | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c & b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name  | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

   # 3、 a LEFT JOIN b on a.col=b.col inner join c on a.col=c.col
   # 3.1 left join & inner join & 2 ER  (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

      # 3.2 left join & inner join & 2 ER  (a,c,b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

     # 3.3 left join & inner join & 2 ER  (c,a,b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

  # 3.4 left join & inner join & 2 ER  bac / bca / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                     | db      | expect                           |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a */ explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | Inner command not route to MySQL |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | Inner command not route to MySQL |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a */ explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | Inner command not route to MySQL |


    # 3.5 left join & inner join & 1 ER  (a,b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.6 left join & inner join & 1 ER  (a,b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                    |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                           |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                      |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 3.7 left join & inner join & 1 ER  a c b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| c \| b */  SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                          |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                           |
      | order_1           | ORDER           | join_1                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                    |
      | dn3_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC           |
      | dn4_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                           |
      | order_2           | ORDER           | join_2                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.8，3.9 left join & inner join & 1 ER  c & (a,b)
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                  | db      | expect                                                                                     |
      | conn_1 | False   | explain /*!dble:plan= c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name  | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint |
      | conn_1 | False   | explain /*!dble:plan= c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | hint explain build failures! check ER condition                                            |

    # 3.10 left join & inner join & 1 ER  bac/bca/cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                  | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it   |


    # 3.11 left join & inner join & NO ER  ( a & b ) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & b ) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a & b ) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 3.12 left join & inner join & NO ER  a & (b | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.13 left join & inner join & NO ER  (a & c) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.14 left join & inner join & NO ER  a & (c | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.14 left join & inner join & NO ER  (c & a) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                      |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                 |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                  |
      | order_1           | ORDER                 | join_1                                                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                           |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                      |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                 |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.15 left join & inner join & NO ER  c | a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.15-1 left join & inner join & NO ER  c | (a & b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.16 left join & inner join & NO ER  c | (a & b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                      |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                 |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                  |
      | order_1           | ORDER                 | join_1                                                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                           |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                      |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                 |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 3.17 left join & inner join & NO ER  bac / bca / cba 报错
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | hint explain build failures! check table c & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= a \| c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name   | schema1 | hint explain build failures! check table b & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | hint explain build failures! check table b & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name  | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name  | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it   |

   # 4 a INNER JOIN b on a.col=b.col LEFT JOIN c on a.col=c.col
   # 4.1 inner join & left join & 2 ER (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

     # 4.2 inner join & left join & 2 ER  (a,c,b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

    # 4.3 inner join & left join & 2 ER  (b,a,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

    # 4.4 inner join & left join & 2 ER  bca / cba / cab  报错
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                  | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= (b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= (c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= (c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

     # 4.5 inner join & left join & 1 ER  (a , b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a , b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= (a , b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 4.6 inner join & left join & 1 ER  (a , b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a , b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                       |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                 |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_1 | true    | /*#dble:plan= (a , b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 4.7 inner join & left join & 1 ER  (b,a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (b,a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

      # 4.8 inner join & left join & 1 ER  (b,a) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                       |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                 |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (b,a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 4.8 inner join & left join & 1 ER   acb
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 4.9 inner join & left join & 1 ER  bca / cba / cab
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                 | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name  | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint    |
      | conn_1 | False   | explain /*!dble:plan= c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint    |

    # 4.10 inner join & left join & NO ER  (a & b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 4.11 inner join & left join & NO ER  a & (b \| c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 4.12 inner join & left join & NO ER  (a & c ) \| b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & c ) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a & c ) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 4.12 inner join & left join & NO ER  (a \| c ) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| c ) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a \| c ) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 4.13 inner join & left join & NO ER  a & (c \| b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 4.14 inner join & left join & NO ER  (b & a) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                       |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                              |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 4.15 inner join & left join  & NO ER  b \| a & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b \| a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= b \| a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 4.15 inner join & left join & NO ER  bca / cba / cab error
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= c \| a \| b  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a  */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

    # 5. a LEFT JOIN b on a.col=b.col INNER JOIN c on b.col=c.col
    # 5.1  left join & inner join & 2 ER (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

  # 5.2 inner join & left join & 2 ER (a,b,c)   acb / bac / bca / cab
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                | db      | expect                                                                                         |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it  |
      | conn_1 | False   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node |
      | conn_1 | False   | explain /*!dble:plan= (b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node |
      | conn_1 | False   | explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node |
      | conn_1 | False   | explain /*!dble:plan= (c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node |

     # 5.3  left join & inner join & 1 ER  (a,b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 5.4  left join & inner join & 1 ER  (a,b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                  |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                           |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

      # 5.5 left join & inner join & 1 ER (a,b)  acb / bac / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                             | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c & (a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint      |
      | conn_1 | False   | explain /*!dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node  |

     # 5.6  left join & inner join & NO ER  a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                | db      |
      | conn_1 | true    | /*#dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 5.7  left join & inner join & NO ER  (a & b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=  (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 5.8  left join & inner join & NO ER  a | b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=  a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan=  a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 5.9  left join & inner join & NO ER  (a \| b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=  (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "L_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan=  (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 5.10 left join & inner join & NO ER  acb / bac / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                        | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=b}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node  |
      | conn_1 | False   | explain /*!dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node  |

    # 6. a INNER JOIN b on a.col=b.col LEFT JOIN c on b.col=c.col
    # 6.1  inner join & left join & 2 ER (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

    # 6.2  inner join & left join & 2 ER (b,a,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan=  (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |


      # 6.3  inner join & left join & 2 ER (b,c,a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

     # 6.4 inner join & left join & 2 ER  acb / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                    | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= (a , c , b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= (c , a , b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= (c , b , a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

    # 6.5 inner join & left join & 1 ER  (a, b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a, b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a, b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.6 inner join & left join & 1 ER  (a, b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                             |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 6.6 inner join & left join & 1 ER  (b, a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b, a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (b, a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.7 inner join & left join & 1 ER  (b, a) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                             |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 6.7 inner join & left join & 1 ER  b & c | a   issue-1641
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b & c \| a  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                                                              |
      | dn4_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= b & c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.8 inner join & left join & 1 ER  acb / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name  | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c & (a ,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint    |
      | conn_1 | False   | explain /*!dble:plan= c & (b ,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint    |

     # 6.9 inner join & left join & NO ER  a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                | db      |
      | conn_1 | true    | /*#dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.10 inner join & left join & NO ER  a \| b \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | order_1           | ORDER           | join_1                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                       |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_2           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.11 inner join & left join & NO ER  (a& b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= (a & b) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

       # 6.9 inner join & left join & NO ER  (a \| b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 6.9 inner join & left join & NO ER  a | b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_1 | true    | /*#dble:plan= a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.10 inner join & left join & NO ER  b \| a  \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_1           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.11 inner join & left join & NO ER  (b \| a)  & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b \| a)  & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (b \| a)  & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.12 inner join & left join & NO ER  (b & a)  \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

   # 6.12 inner join & left join & NO ER  b & a | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b & a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_1 | true    | /*#dble:plan= b & a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.13 inner join & left join & NO ER  b \| c \| a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=  b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_1           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan=  b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.14 inner join & left join & NO ER  (b \| c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= (b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 6.15 inner join & left join & NO ER  (b & c) \| a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn3_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 6.15 inner join & left join & NO ER  b & (c | a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_L_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_L_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 6.16 inner join & left join & NO ER  acb / bca / cab / cba
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | db      | expect                                                                                          |
      | conn_1 | False   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | hint explain build failures! check table c & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | hint explain build failures! check table c & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | hint explain build failures! check table a & condition                                          |
      | conn_1 | False   | explain /*!dble:plan= a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it   |
      | conn_1 | False   | explain /*!dble:plan= c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |
      | conn_1 | False   | explain /*!dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | can't use '{node=c}' node for root. Because exists some left join relations point to this node. |

   # 7. inner join & inner join  & a INNER JOIN b on a.col=b.col INNER JOIN c on a.col=c.col
   # 7.1 inner join & inner join & 2 ER (a,b,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | schema1 |

    # 7.2 inner join & inner join & 2 ER (a,c,b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | schema1 |

     # 7.3 inner join & inner join & 2 ER (b,a,c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | schema1 |

     # 7.4 inner join & inner join & 2 ER (c,a,b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | schema1 |

     # 7.5 inner join & left join & 2 ER  (b,c,a) (c,b,a)
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                 | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= (b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= (c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it |

     # 7.6 inner join & inner join & 1 ER (a,b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.7 inner join & inner join & 1 ER (a,b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                       |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                 |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.7 inner join & inner join & 1 ER a & c | b  issue-1641
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 7.8 inner join & inner join & 1 ER (b,a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (b,a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.9 inner join & inner join & 1 ER (b,a) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                       |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                 |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= (b,a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.10 inner join & inner join & 1 ER   c|a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                         |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                          |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                 |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

      # 7.11 inner join & left join & 1 ER  b,c,a  c,b,a
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                   | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= c & (a,b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.   |
      | conn_1 | False   | explain /*!dble:plan= b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it |

    # 7.13 inner join & inner join & NO ER (a \| b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 7.14 inner join & inner join & NO ER (a & b) \| c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

   # 7.15 inner join & inner join & NO ER a & (b \| c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

     # 7.17 inner join & inner join & NO ER (a & c) \| b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

   # 7.18 inner join & inner join & NO ER  a & (c \| b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

   # 7.19 inner join & inner join & NO ER (a \| c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

   # 7.21 inner join & inner join & NO ER  (b & a) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                       |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn3_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                              |
      | dn4_2             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

   # 7.23 inner join & inner join & NO ER  (b \| a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.24 inner join & inner join & NO ER  b \| (a & c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=  b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan=  b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.25 inner join & inner join & NO ER  (c & a) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                      |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                 |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                  |
      | order_1           | ORDER                 | join_1                                                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                           |
      | dn3_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | dn4_2             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                      |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                 |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.27 inner join & inner join & NO ER  (c \| a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.28 inner join & inner join & NO ER  c | (a & b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |

    # 7.29 inner join & inner join & NO ER  bca cba not support
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                               | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | hint explain build failures! check table c & condition                                        |
      | conn_1 | False   | explain /*!dble:plan= a \| c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name   | schema1 | hint explain build failures! check table b & condition                                        |
      | conn_1 | False   | explain /*!dble:plan= c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 | hint explain build failures! check table b & condition                                        |
      | conn_1 | False   | explain /*!dble:plan= b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it |

   # 8. a INNER JOIN b on a.col=b.col INNER JOIN c on b.col=c.col
   # 8.1 inner join & inner join & 2 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

     # 8.2 inner join & inner join & 2 ER  bca
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

     # 8.3 inner join & inner join & 2 ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

    # 8.4 inner join & inner join & 2 ER  cba
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

    # 8.5 inner join & inner join & 2 ER  acb , cab
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                 | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= (c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |

    # 8.6 inner join & inner join & 1 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 8.7 inner join & inner join & 1 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                             |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

     # 8.8 inner join & inner join & 1 ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= (b,a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.9 inner join & inner join & 1 ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b,a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                             |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (b,a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.10 inner join & inner join & 1 ER  c | b & a   issue-1641
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| b & a  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                             |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                     |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.11 inner join & inner join & 1 ER  b & c | a  issue-1641
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b & c\|a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                                                              |
      | dn4_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                                                              |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan= b & c\|a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.13 inner join & inner join & 1 ER  acb , cab
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | hint explain build failures! check ER condition                                               |
      | conn_1 | False   | explain /*!dble:plan= (a,c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= a \|c  & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name  | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= (c,a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c \| a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name  | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |

  # 8.14 inner join & inner join & NO ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a & b & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= a & b & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

  # 8.15 inner join & inner join & NO ER  abc \|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | order_1           | ORDER           | join_1                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                       |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_2           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.16 inner join & inner join & NO ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a & b) \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.17 inner join & inner join & NO ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.17 inner join & inner join & NO ER  a | b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

   # 8.18 inner join & inner join & NO ER  bca
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_1           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.19 inner join & inner join & NO ER  bca
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b & c ) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn3_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan= (b & c ) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.20 inner join & inner join & NO ER  bca
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

      # 8.21 inner join & inner join & NO ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_1           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

      # 8.22 inner join & inner join & NO ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_2             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.23 inner join & inner join & NO ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.23 inner join & inner join & NO ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.24 inner join & inner join & NO ER  cba
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | order_1           | ORDER           | join_1                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                       |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                              |
      | order_2           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan= c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

      # 8.25 inner join & inner join & NO ER  cba
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_1 | true    | /*#dble:plan= c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.26 inner join & inner join & NO ER  cba
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn4_2             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_1 | true    | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.27 inner join & inner join & NO ER  cba
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= (c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.27 inner join & inner join & NO ER  cba
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I_I_join"
      | conn   | toClose | sql                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | success | schema1 |
    Then check resultset "I_I_join" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 |

    # 8.28 inner join & inner join & 1 ER  acb , cab
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                            | db      | expect                                                                                        |
      | conn_1 | False   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | hint explain build failures! check table c & condition                                        |
      | conn_1 | False   | explain /*!dble:plan= b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | hint explain build failures! check table a & condition                                        |
      | conn_1 | False   | explain /*!dble:plan= b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1 | hint explain build failures! check table c & condition                                        |
      | conn_1 | False   | explain /*!dble:plan= (a,c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= a \|c  & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= (c,a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c \| a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name   | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |
      | conn_1 | False   | explain /*!dble:plan= c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it |