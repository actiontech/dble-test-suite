# -*- coding=utf-8 -*-
# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwe at 2021/12/10
Feature: test with useNewJoinOptimizer=true

#more information find in confluence: http://10.186.18.11/confluence/pages/viewpage.action?pageId=32064447
                          #jira: http://10.186.18.11/jira/browse/DBLE0REQ-1469

  @skip
  Scenario: shardingTable  + shardingTable  +  shardingTable                              #1

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
        $a  -DuseNewJoinOptimizer=true
      """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
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
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                       | db | expect               |
      | conn_0 | false    | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | schema1  | success|
      | conn_0 | false    | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                              | schema1  | success|
      | conn_0 | false    | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                     | schema1  | success|
      | conn_0 | false    | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8      | schema1  | success|
      | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
      | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                               | schema1 | success|
      | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
      | conn_0 | true     | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | schema1| success|

     #create table used in comparing
     Then execute sql in "mysql" in "mysql" mode
        | conn   | toClose  | sql                       | db | expect               |
        | conn_0 | false    | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | schema1  | success|
        | conn_0 | false    | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                              | schema1  | success|
        | conn_0 | false    | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                     | schema1  | success|
        | conn_0 | false    | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8      | schema1  | success|
        | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
        | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                               | schema1 | success|
        | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
        | conn_0 | true     | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | schema1| success|

    # left join & left join & no ER   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                         | db|
      | conn_0 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on c.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
      | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn4_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                          |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                     |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     |SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on c.DeptName= b.DeptName order by a.name| schema1|

    # left join & left join & one ER   -->  ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                         | db|
      | conn_1 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                                                                                                                            |
      | dn3_0               | BASE SQL          | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0               | BASE SQL          | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1   | MERGE_AND_ORDER   | dn3_0; dn4_0                                                                                                                                                                                                         |
      | shuffle_field_1     | SHUFFLE_FIELD     | merge_and_order_1                                                                                                                                                                                                    |
      | dn1_0               | BASE SQL          | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
      | dn2_0               | BASE SQL          | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
      | dn3_1               | BASE SQL          | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
      | merge_and_order_2   | MERGE_AND_ORDER   | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                  |
      | shuffle_field_3     | SHUFFLE_FIELD     | merge_and_order_2                                                                                                                                                                                                    |
      | join_1              | JOIN              | shuffle_field_1; shuffle_field_3                                                                                                                                                                                     |
      | order_1             | ORDER             | join_1                                                                                                                                                                                                               |
      | shuffle_field_2     | SHUFFLE_FIELD     | order_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_1 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|

    # left join & left join & two ER   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                         | db|
      | conn_2 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name| schema1|
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                                                                                                                                                      |
      | dn3_0               | BASE SQL          | select `a`.`Name`,`a`.`DeptName`,`b`.`Manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  left join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`Name` ASC |
      | dn4_0               | BASE SQL          | select `a`.`Name`,`a`.`DeptName`,`b`.`Manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  left join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`Name` ASC |
      | merge_and_order_1   | MERGE_AND_ORDER   | dn3_0; dn4_0                                                                                                                                                                                                                                 |
      | shuffle_field_1     | SHUFFLE_FIELD     | merge_and_order_1                                                                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_2 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1|

    # left join & left join & no ER   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                         | db|
      | conn_3 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.name| schema1|
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC      |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC      |
      | dn3_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_2                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                     |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_3 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.name | schema1|

    #left join & left join & one ER, and contain subquery, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                         | db|
      | conn_4 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                   |
      | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                    |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                    |
      | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_4 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName order by a.name | schema1|

    #left join & inner join & one ER
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                         | db|
      | conn_5 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |
      | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
      | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                     |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_5 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1|

    #left join & inner join & two ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_G"
      | conn   | toClose | sql                                                         | db|
      | conn_6 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name| schema1|
    Then check resultset "rs_G" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`Name`,`a`.`DeptName`,`b`.`Manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`Name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`Name`,`a`.`DeptName`,`b`.`Manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`Name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_6 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1|

    #left join & inner join & no ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_H"
       | conn   | toClose | sql                                                         | db|
       | conn_7 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name| schema1|
    Then check resultset "rs_H" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC       |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC       |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC       |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                    |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                       |
        | order_1           | ORDER           | join_1                                                                                                 |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                           |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_7 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1|

    #cross join & left join & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_I"
       | conn   | toClose | sql                                                         | db|
       | conn_8 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a cross join Level c LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_I" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                        |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                   |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                                 |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                                 |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                                 |
        | merge_1           | MERGE           | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                 |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                                             |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                    |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_8 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a cross join Level c LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1 |

    #cross join & left join & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_J"
       | conn   | toClose | sql                                                         | db|
       | conn_9 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a cross join Level c LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_I" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                   |
      | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                                 |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                                 |
      | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                                 |
      | merge_1           | MERGE           | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_9 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a cross join Info c LEFT JOIN Dept b on c.DeptName= b.DeptName order by a.name| schema1 |

  @skip @skip_restart
    Scenario: shardingTable  + GlobalTable  +  GlobalTable