# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhangqian at 2022/02/16
Feature: test hint

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  shardingTable  Directed Acyclic Graph #1
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
  """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Level" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="levelid"/>
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
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

     #create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | true    | create database if not exists schema1                                                                                                                                                                                                                                                                             | mysql   | success |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

    # left join & left join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                        |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan=(a,b,c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                              | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&a&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & left join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan=a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan=a & (b \| c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan=a \| b \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| b) & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=(a \| b) & c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
#      | conn   | toClose | sql                                                                                                                                                                                                                          | db      |
#      | conn_0 | false   | explain /*!dble:plan=(a & b) \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_6" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1 | SQL/REF-2 |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
#      | order_1           | ORDER           | join_1                                                                                              |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
#      | order_2           | ORDER           | join_2                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                    | db      |
#      | conn_0 | true    | /*#dble:plan=(a & b) \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                         | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;  | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;    | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                             |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=a &( b \| c)  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=a &( b \| c)  */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |


    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| b) & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(a \| b) & c  */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & left join & 1 er & ab, ac bc       ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan=(a & b) \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_11" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1 | SQL/REF-2 |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
#      | order_1           | ORDER           | join_1                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan=(a & b) \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;       | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan=a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=a &( b \| c)  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=a &( b \| c)  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c   */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c   */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
#      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c   */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_16" has lines with following column values
#      | SHARDING_NODE-0 | TYPE-1 | SQL/REF-2 |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
#      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
#      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
#      | order_1           | ORDER           | join_1                                                                                  |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                       | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c   */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */   SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                   |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (a,b,c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                               | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&a&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c\|a\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                   |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (a,b,c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                   |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (b,a,c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                               | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&a&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;        | hint explain build failures! check table b & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_21"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_21" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_22"
      | conn   | toClose | sql                                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_22" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_23"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_23" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= a & (b \| c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_24"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_24" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_25"
#      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_25" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
#      | order_1           | ORDER           | join_1                                                                                              |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
#      | order_2           | ORDER           | join_2                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                     | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

  # left join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_26"
#      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_26" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
#      | order_1           | ORDER           | join_1                                                                                              |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
#      | order_2           | ORDER           | join_2                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                     | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                         | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */   SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;    | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_27"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_27" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_28"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_28" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_32"
#      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_32" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_29"
      | conn   | toClose | sql                                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_29" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn3_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn4_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_31"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_31" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= b & (a \| c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_32"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_32" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_32"
#      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_32" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
#      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
#      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                         | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */   SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;   | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name;    | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    #sql change
    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_33"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_33" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_34"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_34" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                             |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_35"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_35" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_36"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_36" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
#      | order_1           | ORDER           | join_1                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_37"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_37" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan= a & (b \| c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_42"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_42" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_43"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_43" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                             |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_44"
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_44" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c ) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |


    # left join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_45"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_45" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
#      | order_1           | ORDER           | join_1                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_46"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_46" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
#      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
#      | order_1           | ORDER           | join_1                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_47"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_47" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_48"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_48" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | dn4_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_49"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_49" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                              |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= b & a & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_50"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_50" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan= b & (a \| c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

#    # left join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_51"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_51" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
#      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
#      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (a & c) */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

#  # left join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_52"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
#    Then check resultset "rs_52" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
#      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
#      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_53"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |
    Then check resultset "rs_53" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */   SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;   | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name;    | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.deptname=c.deptname order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_54"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_54" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_55"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_55" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_56"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_56" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_57"
#      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_57" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
#      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
#      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
#      | order_1           | ORDER           | join_1                                                                                  |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                        | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # left join & inner join & no er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_58"
#      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_58" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
#      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
#      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
#      | order_1           | ORDER           | join_1                                                                                  |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                        | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_59"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_59" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                            | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(a\|c)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;    | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|a\|b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # left join & inner join & no er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_69"
#      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_69" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                        | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # left join & inner join & no er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_70"
#      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_70" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                        | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_71"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_71" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_73"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_73" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= b & a & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= b & (a \| c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= b & (a \| c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # left join & inner join & no er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_75"
#      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_75" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                        | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (a & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_76"
#      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_76" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                        | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & no er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                            | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */   SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;    | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # inner join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_78"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b,c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_78" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                              |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= (a,b,c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_79"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,c,b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_79" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= (a,c,b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_80"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,a,c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_80" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                              |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` and `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` and `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= (b,a,c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |


    # inner join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_81"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,c,a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_81" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` and `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` and `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= (b,c,a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_82"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,a,b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_82" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= (c,a,b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 3 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_83"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,b,a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_83" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` and `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` and `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= (c,b,a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                | expect                                                       | db      |
      | conn_0 | False   | explain /*!dble:plan=a\|b\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check table a & or \| condition | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name;       | hint explain build failures! check table a & or \| condition | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a\|c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name;    | hint explain build failures! check table b & or \| condition | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b\|c)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name;    | hint explain build failures! check table b & or \| condition | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check table b & or \| condition | schema1 |
#         ==> DBLE0REQ-1636   | conn_0 | False   | explain /*!dble:plan=c\|(a&b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name;    | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON  a.deptname=c.deptname and b.deptname=c.deptname ORDER BY a.name; | hint explain build failures! check table c & or \| condition | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_84"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_84" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_85"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_85" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_86"
      | conn   | toClose | sql                                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_86" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_87"
#      | conn   | toClose | sql                                                                                                                                                                                                                                | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_87" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_88"
#      | conn   | toClose | sql                                                                                                                                                                                                                              | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_88" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                      |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_89"
      | conn   | toClose | sql                                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_89" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_90"
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,c,b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_90" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan= (a,c,b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_91"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_91" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn3_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn4_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                    |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                    |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_92"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_92" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= b & a & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_93"
      | conn   | toClose | sql                                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_93" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= b & ( a \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_94"
#      | conn   | toClose | sql                                                                                                                                                                                                                                | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_94" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
#      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                           |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (a& c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_95"
#      | conn   | toClose | sql                                                                                                                                                                                                                              | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_95" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
#      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
#      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_96"
      | conn   | toClose | sql                                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_96" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_97"
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,c,a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_97" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`manager` = `a`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`manager` = `a`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan= (b,c,a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_98"
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,a,b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_98" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan= (c,a,b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_99"
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,b,a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_99" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`manager` = `a`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`manager` = `a`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan= (c,b,a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                             | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */   SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;   | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&c&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;       | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name;    | hint explain build failures! check table c & or \| condition                                | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name= b.manager INNER JOIN  Info c on a.deptname=c.deptname  and b.deptname=c.deptname ORDER BY a.name; | hint explain build failures! check table c & or \| condition                                | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_100"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b,c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_100" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`manager` = `c`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`manager` = `c`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= (a,b,c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_101"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,c,b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_101" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= (a,c,b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_102"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,a,c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_102" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`manager` = `c`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`manager` = `c`.`name` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= (b,a,c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_103"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,a,b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_103" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`name` = `b`.`manager` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= (c,a,b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_104"
      | conn   | toClose | sql                                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| c \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_104" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                            |
      | dn3_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                      |
      | dn4_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                    |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC              |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                     |
      | order_1           | ORDER           | join_1                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                              |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                     |
      | order_2           | ORDER           | join_2                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= b \| c \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_105"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= b & ( c \| a )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_105" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= b & ( c \| a )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_105"
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_105" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= (b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_106"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_106" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                       |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                       |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan= c & b & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

#    # inner join & inner join & 2 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_107"
#      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
#      | conn_0 | false   | explain /*!dble:plan= c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
#    Then check resultset "rs_107" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                      |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                       |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                       |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                      | db      |
#      | conn_0 | true    | /*#dble:plan= c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    # inner join & inner join & 2 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_108"
      | conn   | toClose | sql                                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan= (c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |
    Then check resultset "rs_108" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                      |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`deptname` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan= (c\| b) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                       | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;    | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name;  | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b\|a)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c&(a\|b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname and c.name=b.manager ORDER BY a.name; | hint explain build failures! check table c & or \| condition                                | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_109"
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_109" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                           |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | order_2           | ORDER           | join_2                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_110"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_110" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                            |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                            |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_111"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_111" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1635
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_112"
#      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a,c)\|b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
#    Then check resultset "rs_112" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
#      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                           |
#      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                           |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
#      | order_1           | ORDER           | join_1                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
#      | order_2           | ORDER           | join_2                                                                                                     |
#      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                    |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                 | db      |
#      | conn_0 | true    | /*#dble:plan= (a,c)\|b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_113"
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,c)&b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_113" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC          |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan= (a,c)&b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_114"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_114" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | true    | /*#dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_115"
#      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
#    Then check resultset "rs_115" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                               |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                              |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                 | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (a& c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_116"
#      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
#    Then check resultset "rs_116" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                     |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                               |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                              |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                 | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_117"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_117" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                 |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_118"
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| c \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_118" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                        |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                 |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                 |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC          |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                 |
      | order_1           | ORDER           | join_1                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                          |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                 |
      | order_2           | ORDER           | join_2                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= b \| c \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_119"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan= b & ( c \| a )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_119" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC          |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan= b & ( c \| a )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_119"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_119" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= (b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_120"
#      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (c& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
#    Then check resultset "rs_120" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                       |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                       |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                           |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC          |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC          |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                           |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                           |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                      |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                 | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (c& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_121"
      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,a)&b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_121" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC          |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= (c,a)&b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1635
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_122"
#      | conn   | toClose | sql                                                                                                                                                                                                                 | db      |
#      | conn_0 | false   | explain /*!dble:plan= (c,a)\|b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
#    Then check resultset "rs_122" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                            |
#      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
#      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                         |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                    |
#      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                                   |
#      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                                   |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                         |
#      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                    |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                               |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                 | db      |
#      | conn_0 | true    | /*#dble:plan= (c,a)\|b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_123"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_123" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                              |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | true    | /*#dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_124"
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan= c & ( b \| a )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_124" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan= c & ( b \| a )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_125"
#      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
#      | conn_0 | false   | explain /*!dble:plan= (c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
#    Then check resultset "rs_125" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                  |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                          |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                           |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                 | db      |
#      | conn_0 | true    | /*#dble:plan= (c & b) \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_126"
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | false   | explain /*!dble:plan= (c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_126" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                           |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | true    | /*#dble:plan= (c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name;  | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.deptname=c.deptname and b.manager=c.name order by a.name; | hint explain build failures! check table c & or \| condition                                | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_127"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_127" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC     |
      | dn4_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_128"
      | conn   | toClose | sql                                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_128" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC    |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC    |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_129"
      | conn   | toClose | sql                                                                                                                                                                                                                                    | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_129" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                         |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                 |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                      |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                 |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                  |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                           |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC  |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                      |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                 |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_130"
#      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (b & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_130" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                         |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_131"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_131" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                           |
      | dn4_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_132"
      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_132" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                             |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                         |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                     |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                         |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                               |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                          |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_133"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= a & (c \| b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_133" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                        |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= a & (c \| b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_133a"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_133a" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                              |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= (a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_134"
#      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
#      | conn_0 | false   | explain /*!dble:plan= a \| (c & b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_134" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                         |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                        |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                        |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                         |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                         |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                    |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                               |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= a \| (c & b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_135"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_135" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn3_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC     |
      | dn4_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_136"
      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_136" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                           |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                              |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= b & a & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_137"
#      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_137" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                        |
#      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                           |
#      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                           |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                     |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                              |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                     |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                 |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                           |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                          |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                     |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                 |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                           |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (a& c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_138"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_138" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                    |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                        |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                              |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` where `c`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1635
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_139"
#      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b,c)\|a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_139" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
#      | dn3_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC     |
#      | dn4_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC     |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                               |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
#      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                               |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                          |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                           |
#      | order_1           | ORDER           | join_1                                                                                                     |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
#      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                               |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                          |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                           |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= (b,c)\|a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_140"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,c)&a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_140" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`c`.`name` ASC |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`c`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (b,c)&a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_141"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan= c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_141" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                   |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                   |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                         |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                          |
      | order_1           | ORDER           | join_1                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                   |
      | dn3_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | dn4_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan= c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_142"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= c & (a \| b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_142" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                             |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                     |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                                   |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                                   |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                               |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                          |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= c & (a \| b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_143"
#      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
#      | conn_0 | false   | explain /*!dble:plan= (c & a) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_143" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                             |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                               |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                               |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                          |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                     |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                                   |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                                                   |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                          |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                     |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                      |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                               |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                          |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                     |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                      |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                                |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= (c & a) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_144"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= (c \| a) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_144" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                             |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                     |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                         |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                               |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`deptname` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                                          |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan= (c \| a) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc      ==> DBLE0REQ-1635
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_145"
#      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
#      | conn_0 | false   | explain /*!dble:plan= (c,b)\|a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_145" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                 |
#      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                   |
#      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                   |
#      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                              |
#      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                         |
#      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
#      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
#      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                              |
#      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                         |
#      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                          |
#      | order_1           | ORDER           | join_1                                                                                                                    |
#      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                   |
#      | dn3_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
#      | dn4_2             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                              |
#      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                         |
#      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                          |
#      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                    |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                             | db      |
#      | conn_0 | true    | /*#dble:plan= (c,b)\|a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_146"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= (c,b)&a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |
    Then check resultset "rs_146" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`c`.`name` ASC |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC,`c`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= (c,b)&a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                 | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name; | hint explain build failures! check table c & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&c&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;       | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;     | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(b\|c)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.deptname=c.deptname ORDER BY a.name;    | hint explain build failures! check table b & or \| condition                                | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_147"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_147" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_148"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_148" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan= a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |


#    # inner join & inner join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_149"
#      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_149" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= (a & b) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_150"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_150" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_151"
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_151" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC              |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # inner join & inner join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_152"
#      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= (a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_152" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
#      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
#      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC              |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC              |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                           |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= (a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_153"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_153" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= (a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_154"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_154" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # inner join & inner join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_155"
#      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_155" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_156"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_156" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= b & ( a \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_157"
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_157" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # inner join & inner join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_158"
#      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (c& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_158" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (c& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_159"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_159" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                          |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC           |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                  |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC      |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                  |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                   |
      | order_1           | ORDER           | join_1                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                            |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                  |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_160"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= c & (a \| b)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_160" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC         |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= c & (a \| b)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_161"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (c \| a) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_161" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (c \| a) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_162"
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_162" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_162a"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= (c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_162a" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # inner join & inner join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_163"
#      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_163" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#  # inner join & inner join & 0 er & ab, ac bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_164"
#      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
#      | conn_0 | false   | explain /*!dble:plan= (c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_164" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
#      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
#      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                         | db      |
#      | conn_0 | true    | /*#dble:plan= (c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                         | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | Ture    | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  shardingTable  right join      #2
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
  """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Level" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="levelid"/>
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
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

     #create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | true    | create database if not exists schema1                                                                                                                                                                                                                                                                             | mysql   | success |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

    # right join & right join & 0 er & ab, ac  --> not support at this version
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                               | expect                                                                                                                                  | db      |
      | conn_0 | False   | explain /*!dble:plan= (c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name;        | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name;      | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b\|a)&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name;     | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c\|a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name;     | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c&a)\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name;     | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |

    # right join & right join & 0 er & ab, bc   --> not support at this version
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                            | expect                                                                                                                                  | db      |
      | conn_0 | False   | explain /*!dble:plan= (c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Info c ON b.manager=c.name ORDER BY a.name; | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Info c ON b.manager=c.name ORDER BY a.name;        | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Info c ON b.manager=c.name ORDER BY a.name;      | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b\|a)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Info c ON b.manager=c.name ORDER BY a.name;     | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c\|a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Info c ON b.manager=c.name ORDER BY a.name;     | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c&a)\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Info c ON b.manager=c.name ORDER BY a.name;     | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery' | schema1 |


  # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_167"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_167" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                          |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                          |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                          |
      | order_1           | ORDER           | join_1                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                   |
      | dn1_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn3_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_3 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_2                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                         |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                          |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_168"
      | conn   | toClose | sql                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_168" has lines with following column values
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
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_2                                                                                                                                                             |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= b & a & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_169"
      | conn   | toClose | sql                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_169" has lines with following column values
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
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_2                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

#    # right join & inner join & 0 er & ab, ac      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_170"
#      | conn   | toClose | sql                                                                                                                                                                                               | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_170" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
#      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
#      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_2                                                                                                                                                           |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                       | db      |
#      | conn_0 | true    | /*#dble:plan= b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_170"
#      | conn   | toClose | sql                                                                                                                                                                                              | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
#    Then check resultset "rs_170" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
#      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
#      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                  |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
#      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
#      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
#      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_2                                                                                                                                                           |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                             |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
#      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                      | db      |
#      | conn_0 | true    | /*#dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=b&(a\|c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | hint explain build failures! check table c & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;    | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c\|a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it.  | schema1 |
#         ==> DBLE0REQ-1636   | conn_0 | False   | explain /*!dble:plan=(c&a)\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | hint size 3 not equals to plan node size 2.                                                     | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|b)&a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_171"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= c \| b \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_171" has lines with following column values
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
      | conn_0 | true    | /*#dble:plan= c \| b \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_172"
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_0 | false   | explain /*!dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_172" has lines with following column values
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
      | conn_0 | true    | /*#dble:plan= c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_173"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= (c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_173" has lines with following column values
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
      | conn_0 | true    | /*#dble:plan=(c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

#    # right join & inner join & 0 er & ab, bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_174"
#      | conn   | toClose | sql                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_174" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
#      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
#      | order_1           | ORDER                 | join_1                                                                                                                                                              |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
#      | order_2           | ORDER                 | join_2                                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                  | db      |
#      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_175"
#      | conn   | toClose | sql                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= (c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_175" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
#      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
#      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
#      | order_1           | ORDER                 | join_1                                                                                                                                                              |
#      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
#      | order_2           | ORDER                 | join_2                                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                  | db      |
#      | conn_0 | true    | /*#dble:plan=(c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_176"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_176" has lines with following column values
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
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_177"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_177" has lines with following column values
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
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_178"
      | conn   | toClose | sql                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_178" has lines with following column values
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
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_179"
#      | conn   | toClose | sql                                                                                                                                                                                            | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_179" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
#      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
#      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
#      | order_1           | ORDER                 | join_2                                                                                                                                                         |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                   | db      |
#      | conn_0 | true    | /*#dble:plan=b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_180"
#      | conn   | toClose | sql                                                                                                                                                                                            | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_180" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
#      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
#      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
#      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
#      | order_1           | ORDER                 | join_2                                                                                                                                                         |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                   | db      |
#      | conn_0 | true    | /*#dble:plan=(b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_181"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= b & ( c \| a )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_181" has lines with following column values
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
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=b & ( c \| a )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_182"
      | conn   | toClose | sql                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan= (b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_182" has lines with following column values
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
      | conn_0 | true    | /*#dble:plan=(b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

#    # right join & inner join & 0 er & ab, bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_183"
#      | conn   | toClose | sql                                                                                                                                                                                            | db      |
#      | conn_0 | false   | explain /*!dble:plan= b \| (c& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_183" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
#      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
#      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
#      | order_1           | ORDER                 | join_2                                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                   | db      |
#      | conn_0 | true    | /*#dble:plan=b \| (c& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc      ==> DBLE0REQ-1636
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_184"
#      | conn   | toClose | sql                                                                                                                                                                                           | db      |
#      | conn_0 | false   | explain /*!dble:plan= (b & c) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
#    Then check resultset "rs_184" has lines with following column values
#      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
#      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
#      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
#      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
#      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
#      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
#      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
#      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
#      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
#      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
#      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                        |
#      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                   |
#      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
#      | order_1           | ORDER                 | join_2                                                                                                                                                              |
#      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#      | conn   | toClose | sql                                                                                                                                                                                  | db      |
#      | conn_0 | true    | /*#dble:plan=(b & c) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                        | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=c&(b\|a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | hint explain build failures! check table a & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;    | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;  | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it.  | schema1 |