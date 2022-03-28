# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/12/10
Feature: test with useNewJoinOptimizer=true

#more information find in confluence: http://10.186.18.11/confluence/pages/viewpage.action?pageId=32064447
                          #jira: http://10.186.18.11/jira/browse/DBLE0REQ-1469

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  shardingTable                              #1
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3']}}
    """

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
#    Given delete all backend mysql tables
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

     #create table used in comparing mysql
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

     #rule-A: left join & left join & one ER   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                         | db|
      | conn_0 | false   | explain SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on c.DeptName= b.DeptName order by a.name| schema1|
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
      | conn_0  | true     |SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on c.DeptName= b.DeptName order by a.name| schema1|

    #rule-A: left join & left join & one ER   -->  ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                         | db|
      | conn_1 | false   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
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
      | conn_1 | true    | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|

    #rule-A: left join & left join & two ER   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                         | db|
      | conn_2 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name| schema1|
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  left join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  left join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_2 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1|

    #rule-A: left join & left join & no ER   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                         | db|
      | conn_3 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.name| schema1|
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
      | conn_3 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.name | schema1|

    #rule-A: left join & left join & one ER, and contain subquery, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                         | db|
      | conn_4 | false   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName order by a.name| schema1|
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
      | conn_4 | true    | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName order by a.name | schema1|

    #rule-A: left join & inner join & one ER
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                         | db|
      | conn_5 | false   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
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
      | conn_5 | true    | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1|

    #rule-A: left join & inner join & two ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_G"
      | conn   | toClose | sql                                                         | db|
      | conn_6 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name| schema1|
    Then check resultset "rs_G" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                         | db|
      | conn_6 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1|

    #rule-A: left join & inner join & no ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_H"
       | conn   | toClose | sql                                                         | db|
       | conn_7 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name| schema1|
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
      | conn_7 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1|

    #rule-A: cross join & left join & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_I"
       | conn   | toClose | sql                                                         | db|
       | conn_8 | false   | explain SELECT * FROM Employee a cross join Level c LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
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
      | conn_8 | true    | SELECT * FROM Employee a cross join Level c LEFT JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1 |

    #rule-A: inner join & inner join & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_K"
       | conn    | toClose | sql                                                         | db|
       | conn_10 | false   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_K" has lines with following column values
       | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
       | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
       | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
       | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                    |
       | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
       | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
       | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
       | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
       | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                             |
       | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                               |
       | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                |
       | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
       | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
       | conn   | toClose | sql                                                         | db|
       | conn_10 | true    |SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1 |

    #rule-A: cross join & inner join & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_L"
       | conn    | toClose | sql                                                         | db|
       | conn_11 | false   | explain SELECT * FROM Employee a cross join Level c INNER JOIN Dept b on a.DeptName= b.DeptName order by a.name| schema1|
    Then check resultset "rs_L" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                   |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                            |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                            |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                                                                            |
        | merge_1           | MERGE           | dn1_0; dn2_0; dn3_1                                                                                                                                                                                            |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                               |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                         |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_11| true    | SELECT * FROM Employee a cross join Level c INNER JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1 |

    #rule-B、C、D: left join & left join & one ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_M"
       | conn    | toClose | sql                                                         | db|
       | conn_12 | false   | explain SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on b.DeptName=c.DeptName and a.empid=2242 order by a.name| schema1|
    Then check resultset "rs_M" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
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
        | conn   | toClose | sql                                                         | db|
        | conn_12| true    | SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on b.DeptName=c.DeptName and a.empid=2242 order by a.name | schema1 |

    #rule-B、C、D: left join & left join & one ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_N"
       | conn    | toClose | sql                                                         | db|
       | conn_13 | false   | explain SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000  order by a.Name| schema1|
    Then check resultset "rs_N" has lines with following column values
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
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                           |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
        | order_2           | ORDER           | join_2                                                                                                 |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_13| true    | SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000  order by a.Name  | schema1 |

    #rule-B、C、D: left join & left join & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_O"
       | conn    | toClose | sql                                                         | db|
       | conn_14 | false   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and b.deptid =2 order by a.Name| schema1|
    Then check resultset "rs_O" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                      |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                      |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                      |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                   |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                      |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                                                |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_14| true    | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and b.deptid =2 order by a.Name  | schema1 |

    #rule-B、C、D: left join & left join & two ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_P"
       | conn    | toClose | sql                                                         | db|
       | conn_15 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.Name | schema1|
    Then check resultset "rs_P" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  left join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  left join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                  |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_15| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.Name | schema1 |

    #rule-B、C、D: left join & left join & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_Q"
       | conn    | toClose | sql                                                         | db|
       | conn_16 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager  LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.Name | schema1|
    Then check resultset "rs_Q" has lines with following column values
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
        | conn_16| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager  LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.Name | schema1 |

    #rule-B、C、D: left join & left join & one ER & contain subquery, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_R"
       | conn    | toClose | sql                                                         | db|
       | conn_17 | false   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept)  b on a.DeptName= b.DeptName and b.deptid =2 order by a.Name| schema1|
    Then check resultset "rs_R" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`DeptName` = `b`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`DeptName` = `b`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                         |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                    |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                                     |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                                     |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                                     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                                                                                  |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                                                                    |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                                                                     |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                               |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_17| true    | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept)  b on a.DeptName= b.DeptName and b.deptid =2 order by a.Name | schema1 |

    #rule-B、C、D:left join & inner join & oner ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_S"
       | conn    | toClose | sql                                                         | db|
       | conn_18 | false   | explain SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1|
    Then check resultset "rs_S" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                    |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                             |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                               |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_18| true    | SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName order by a.name | schema1 |

    #rule-B、C、D:left join & inner join & oner ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_T"
       | conn    | toClose | sql                                                         | db|
       | conn_19 | false   | explain SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.Name | schema1|
    Then check resultset "rs_T" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                    |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                             |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                               |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                |
        | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                          |
        | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                  |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_19| true    | SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.Name | schema1 |

    #rule-B、C、D:left join & inner join & oner ER, ER first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_TT"
       | conn    | toClose | sql                                                         | db|
       | conn_20 | false   | explain SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 and b.deptid=2 order by a.Name | schema1|
     Then check resultset "rs_TT" has lines with following column values
       | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                           |
      | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                                 |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                                 |
      | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                            |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                                      |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_20| true    | SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 and b.deptid=2  order by a.Name | schema1 |

    #rule-B、C、D:left join & inner join & oner ER, join order not change
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_U"
       | conn    | toClose | sql                                                         | db|
       | conn_21 | false   | explain SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.Name | schema1|
     Then check resultset "rs_U" has lines with following column values
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
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                           |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
        | order_2           | ORDER           | join_2                                                                                                 |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_21| true    | SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.Name | schema1 |

     #rule-B、C、D:left join & inner join & oner ER, ER first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_V"
       | conn    | toClose | sql                                                         | db|
       | conn_22 | false   | explain SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000  order by a.Name | schema1|
     Then check resultset "rs_V" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                    |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                             |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                               |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                |
        | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                          |
        | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                  |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_22| true    | SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000  order by a.Name | schema1 |

    #rule-B、C、D:left join & inner join & oner ER, ER first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_W"
       | conn    | toClose | sql                                                         | db|
       | conn_23 | false   | explain SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and b.deptid=2 order by a.Name | schema1|
     Then check resultset "rs_W" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` and (b.deptid = 2) where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                      |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                      |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                      |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                   |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                      |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                                                |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                               |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_23| true    | SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName and b.deptid=2 order by a.Name| schema1 |

      #rule-B、C、D:left join & inner join & oner ER, INNER JOIN first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_X"
       | conn    | toClose | sql                                                         | db|
       | conn_24 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1|
     Then check resultset "rs_X" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                        |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                   |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_24| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name| schema1 |

      #rule-B、C、D:left join & inner join & oner ER, INNER JOIN first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_Y"
       | conn    | toClose | sql                                                         | db|
       | conn_25 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1|
     Then check resultset "rs_Y" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` )  left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                               |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                          |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_25| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |


      #rule-B、C、D:left join & inner join & no ER, join order not change
     Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_Z"
       | conn    | toClose | sql                                                         | db|
       | conn_26 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1|
     Then check resultset "rs_Z" has lines with following column values
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
        | conn_26| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

      #rule-B、C、D:left join & inner join & no ER, inner join first
      Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
       | conn    | toClose | sql                                                         | db|
       | conn_27 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name   | schema1|
      Then check resultset "A" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                         |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                            |
        | order_1           | ORDER           | join_1                                                                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                                                |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                           |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                            |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                      |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_27| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |

    # rule-B、C、D: cross join & left join & no ER, left join first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "B"
       | conn    | toClose | sql                                                         | db|
       | conn_28 | false   | explain SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname INNER JOIN Dept b where c.salary=10000  order by a.Name   | schema1|
    Then check resultset "B" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                         |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                            |
        | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                      |
        | order_1           | ORDER           | where_filter_1                                                                                                              |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                           |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                           |
        | merge_1           | MERGE           | dn3_2; dn4_1                                                                                                                |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                                                     |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                            |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_28| true    | SELECT * FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname INNER JOIN Dept b where c.salary=10000  order by a.Name | schema1 |

    #rule-B、C、D: cross join & left join & no ER, left join first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "C"
       | conn    | toClose | sql                                                         | db|
       | conn_29 | false   | explain SELECT * FROM Employee a INNER JOIN Level c LEFT JOIN Dept b on a.name=b.manager where c.salary=10000  order by a.Name  | schema1|
     Then check resultset "C" has lines with following column values
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
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000        |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000        |
        | dn3_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000        |
        | merge_1           | MERGE           | dn1_0; dn2_0; dn3_2                                                                                   |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                               |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
   Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_29| true    | SELECT * FROM Employee a INNER JOIN Level c LEFT JOIN Dept b on a.name=b.manager where c.salary=10000  order by a.Name | schema1 |

    #rule-B、C、D: cross join & left join & one ER, join order not change
     Given execute single sql in "dble-1" in "user" mode and save resultset in "D"
       | conn    | toClose | sql                                                         | db|
       | conn_30 | false   | explain SELECT * FROM Employee a inner join Info c LEFT JOIN Dept b on a.deptname=b.deptname and c.country='China' order by a.name  | schema1|
     Then check resultset "D" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                 |
        | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                 |
        | merge_1           | MERGE           | dn3_1; dn4_1                                                                                              |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_1                                                                                                   |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                          |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                    |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC             |
        | dn4_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC             |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                              |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_2                                                                                         |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                          |
        | order_1           | ORDER           | join_2                                                                                                    |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                   |
   Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_30| true    | SELECT * FROM Employee a inner join Info c LEFT JOIN Dept b on a.deptname=b.deptname and c.country='China' order by a.name  | schema1|

      #rule-B、C、D: cross join & left join & one ER, ER first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "E"
       | conn    | toClose | sql                                                         | db|
       | conn_31 | false   | explain SELECT * FROM Employee a inner join Info c LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid=2 order by a.name  | schema1|
     Then check resultset "E" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and (b.deptid = 2) where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and (b.deptid = 2) where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                         |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                    |
        | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                                                                            |
        | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                                                                            |
        | merge_1           | MERGE           | dn3_1; dn4_1                                                                                                                                                                                                                         |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                                                              |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                     |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_31| true    | SELECT * FROM Employee a inner join Info c LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid=2 order by a.name  | schema1|

     #rule-B、C、D: cross join & left join & no ER, left join first
      Given execute single sql in "dble-1" in "user" mode and save resultset in "F"
       | conn    | toClose | sql                                                         | db|
       | conn_32 | false   | explain SELECT * FROM Employee a inner join Info c LEFT JOIN Dept b on c.name=b.manager and c.country='China'  order by a.Name | schema1|
      Then check resultset "F" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
        | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
        | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
        | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                          |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                     |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
        | order_1           | ORDER           | join_2                                                                                                |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                               |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_32| true    | SELECT * FROM Employee a inner join Info c LEFT JOIN Dept b on b.manager=c.name and c.country='China'  order by a.Name  | schema1|

    #rule-B、C、D: inner join & inner join & one ER, ER first
      Given execute single sql in "dble-1" in "user" mode and save resultset in "G"
       | conn    | toClose | sql                                                         | db|
       | conn_33 | false   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name | schema1|
      Then check resultset "G" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `a`.`empid` = 2242 ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where `a`.`empid` = 2242 ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                  |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                             |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                                   |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                                   |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                                   |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                           |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                             |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                              |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                                        |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                       |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_33| true    | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name  | schema1|

    #rule-B、C、D: inner join & inner join & one ER, ER first
      Given execute single sql in "dble-1" in "user" mode and save resultset in "H"
       | conn    | toClose | sql                                                         | db|
       | conn_34 | false   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name | schema1|
      Then check resultset "H" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                    |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                                     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                             |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                               |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_34| true    | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name  | schema1|

      #rule-B、C、D: inner join & inner join & two ER, join order not change
      Given execute single sql in "dble-1" in "user" mode and save resultset in "I"
       | conn    | toClose | sql                                                         | db|
       | conn_35 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1|
      Then check resultset "I" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_35| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|

      #rule-B、C、D: inner join & inner join & two ER, join order not change
      Given execute single sql in "dble-1" in "user" mode and save resultset in "J"
       | conn    | toClose | sql                                                         | db|
       | conn_36 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1|
      Then check resultset "J" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` )  join  `Info` `c` on `a`.`DeptName` = `c`.`DeptName` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_36| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1|

      #rule-B、C、D: inner join & inner join & no ER, join order not change
      Given execute single sql in "dble-1" in "user" mode and save resultset in "K"
       | conn    | toClose | sql                                                         | db|
       | conn_37 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1|
      Then check resultset "K" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC               |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC               |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                        |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                        |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                   |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                    |
        | order_1           | ORDER           | join_1                                                                                                              |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                             |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                    |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                    |
        | dn3_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                    |
        | merge_and_order_3 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_2                                                                                                 |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                   |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                    |
        | order_2           | ORDER           | join_2                                                                                                              |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                             |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_37| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1|

    #rule-B、C、D: inner join & inner join & no ER, join order not change
      Given execute single sql in "dble-1" in "user" mode and save resultset in "K"
       | conn    | toClose | sql                                                         | db|
       | conn_38 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name  | schema1|
      Then check resultset "K" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                            |
        | order_1           | ORDER           | join_1                                                                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | dn3_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
        | merge_and_order_3 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_2                                                                                                         |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                           |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                            |
        | order_2           | ORDER           | join_2                                                                                                                      |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                     |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_38| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1|

    #rule-B、C、D: cross join & inner join & one ER, ER first
      Given execute single sql in "dble-1" in "user" mode and save resultset in "L"
       | conn    | toClose | sql                                                         | db|
       | conn_39 | false   | explain SELECT * FROM Employee a INNER JOIN Level c INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name   | schema1|
      Then check resultset "L" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                   |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000                                                                                                                 |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000                                                                                                                 |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000                                                                                                                 |
        | merge_1           | MERGE           | dn1_0; dn2_0; dn3_1                                                                                                                                                                                            |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                               |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                         |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_39| true    | SELECT * FROM Employee a INNER JOIN Level c INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name | schema1|

    #rule-B、C、D: cross join & inner join & no ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "M"
         | conn    | toClose | sql                                                         | db|
         | conn_40 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN Level c on a.level=c.levelname and c.salary=1000 order by a.name  | schema1|
    Then check resultset "M" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                     |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                     |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                               |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                          |
        | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 1000 ORDER BY `c`.`levelname` ASC |
        | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 1000 ORDER BY `c`.`levelname` ASC |
        | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 1000 ORDER BY `c`.`levelname` ASC |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                        |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                          |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                           |
        | order_1           | ORDER           | join_1                                                                                                                     |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                    |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                          |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                          |
        | merge_1           | MERGE           | dn3_2; dn4_1                                                                                                               |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                                                    |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                           |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_40| true    | SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1|

    #optimization about undirected graph : inner join & inner join (and) & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "N"
         | conn    | toClose | sql                                                         | db|
         | conn_41 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.DeptName = c.DeptName and b.Manager=c.Name order by a.Name | schema1|
    Then check resultset "N" has lines with following column values
        | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                                                        |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                                                        |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                                                                          |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_41| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.DeptName = c.DeptName and b.Manager=c.Name order by a.Name | schema1|

    #optimization about undirected graph : inner join & inner join (and) & one ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "O"
         | conn    | toClose | sql                                                         | db|
         | conn_42 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager and b.deptid=2 INNER JOIN Info c on a.name = c.name and b.DeptName=c.DeptName and c.country='China' order by a.Name | schema1|
    Then check resultset "O" has lines with following column values
        | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2   |
        | dn3_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` join  `Dept` `b` on `c`.`DeptName` = `b`.`DeptName` where  ( `c`.`country` = 'China' AND `b`.`deptid` = 2) ORDER BY `b`.`manager` ASC,`c`.`name` ASC |
        | dn4_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` join  `Dept` `b` on `c`.`DeptName` = `b`.`DeptName` where  ( `c`.`country` = 'China' AND `b`.`deptid` = 2) ORDER BY `b`.`manager` ASC,`c`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                             |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                        |
        | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC,`a`.`name` ASC                                                                                                                                                     |
        | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC,`a`.`name` ASC                                                                                                                                                     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                                                                                                             |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                                         |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                   |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                  |
  Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_42| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager and b.deptid=2 INNER JOIN Info c on a.name = c.name and b.DeptName=c.DeptName and c.country='China' order by a.Name | schema1|

    #optimization about undirected graph : inner join & inner join (and) & two ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "P"
         | conn    | toClose | sql                                                         | db|
         | conn_43 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name  | schema1|
    Then check resultset "P" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` )  join  `Dept` `b` on `c`.`Deptname` = `b`.`DeptName` and `a`.`Name` = `b`.`Manager` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Info` `c` join  `Dept` `b` on `c`.`Deptname` = `b`.`DeptName` )  join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` and `b`.`Manager` = `a`.`Name` where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` )  join  `Dept` `b` on `c`.`Deptname` = `b`.`DeptName` and `a`.`Name` = `b`.`Manager` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Info` `c` join  `Dept` `b` on `c`.`Deptname` = `b`.`DeptName` )  join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` and `b`.`Manager` = `a`.`Name` where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                      |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_43| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name | schema1|

    #optimization about undirected graph : inner join & inner join (and) & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Q"
         | conn    | toClose | sql                                                         | db|
         | conn_44 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.Name = c.Name and b.Manager=c.Name order by a.Name   | schema1|
    Then check resultset "Q" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC            |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC            |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                     |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                     |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                 |
        | order_1           | ORDER           | join_1                                                                                                           |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                          |
        | dn3_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
        | dn4_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`name` ASC |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                     |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                 |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_44| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.Name = c.Name and b.Manager=c.Name order by a.Name | schema1|

     #optimization about undirected graph : left join & inner join (and) & one ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "R"
         | conn    | toClose | sql                                                         | db|
         | conn_45 | false   | explain SELECT * FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1|
    Then check resultset "R" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                         |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                    |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                         |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                         |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                         |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                    |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                     |
        | order_1           | ORDER           | join_1                                                                                                               |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                              |
        | dn3_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
        | dn4_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                         |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                    |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                     |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_45| true    | SELECT * FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name  | schema1|

    #optimization about undirected graph : left join & inner join (and) & three ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "S"
         | conn    | toClose | sql                                                         | db|
         | conn_46 | false   | explain SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on a.deptname=c.deptname and b.DeptName=c.DeptName order by a.Name | schema1|
    Then check resultset "S" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_46| true    | SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on a.deptname=c.deptname and b.DeptName=c.DeptName order by a.Name  | schema1|

    #optimization about undirected graph : left join & left join (and) & one ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "T"
         | conn    | toClose | sql                                                         | db|
         | conn_47 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1|
    Then check resultset "T" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                         |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                    |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                         |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                         |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                         |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                    |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                     |
        | order_1           | ORDER           | join_1                                                                                                               |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                              |
        | dn3_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
        | dn4_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC,`c`.`deptname` ASC |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                         |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                    |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                     |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_47| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name  | schema1|

    #optimization about undirected graph : left join & left join (and) & two ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "U"
         | conn    | toClose | sql                                                         | db|
         | conn_48 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name | schema1|
    Then check resultset "U" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                             |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                        |
        | dn3_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                             |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                             |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                             |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                         |
        | order_1           | ORDER           | join_1                                                                                                                   |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                  |
        | dn3_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
        | dn4_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                             |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                        |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                                         |
        | order_2           | ORDER           | join_2                                                                                                                   |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_48| true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name  | schema1|

    #see issue : http://10.186.18.11/jira/browse/DBLE0REQ-1705
     #optimization about undirected graph : left join & left join (or) & one ER, join order not change
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "V"
#         | conn    | toClose | sql                                                         | db|
#         | conn_49 | false   | explain SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on a.DeptName= b.DeptName or a.empid=b.deptid order by a.name | schema1|
#    Then check resultset "V" has lines with following column values
#        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
#        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
#        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
#        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
#        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
#        | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
#        | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
#        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
#        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
#        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
#        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
#        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
#        | dn4_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
#        | merge_1           | MERGE           | dn3_2; dn4_2                                                                                          |
#        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                               |
#        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
#        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#        | conn   | toClose | sql                                                         | db|
#        | conn_49| true    | SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on a.DeptName= b.DeptName or a.empid=b.deptid order by a.name  | schema1|

    #optimization about undirected graph : left join & left join (or) & two ER, join order not change
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "W"
#         | conn    | toClose | sql                                                         | db|
#         | conn_50 | false   | explain SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on a.DeptName= b.DeptName or b.DeptName=c.DeptName order by a.name | schema1|
#    Then check resultset "W" has lines with following column values
#        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
#        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
#        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
#        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
#        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
#        | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
#        | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
#        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
#        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
#        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
#        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
#        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
#        | dn4_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
#        | merge_1           | MERGE           | dn3_2; dn4_2                                                                                          |
#        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                               |
#        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
#        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
#    Then execute sql in "dble-1" and the result should be consistent with mysql
#        | conn   | toClose | sql                                                         | db|
#        | conn_50| true    | SELECT * FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on a.DeptName= b.DeptName or b.DeptName=c.DeptName order by a.name  | schema1|

        #optimization about undirected graph : inner join & inner join (or) & one ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "X"
         | conn    | toClose | sql                                                         | db|
         | conn_51 | false   | explain SELECT * FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on a.DeptName= b.DeptName or a.empid=b.deptid order by a.name | schema1|
    Then check resultset "X" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
        | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
        | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
        | dn4_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
        | merge_1           | MERGE           | dn3_2; dn4_2                                                                                          |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                               |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
        | where_filter_1    | WHERE_FILTER    | join_2                                                                                                |
        | shuffle_field_3   | SHUFFLE_FIELD   | where_filter_1                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_51| true    | SELECT * FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on a.DeptName= b.DeptName or a.empid=b.deptid order by a.name  | schema1|

    #optimization about undirected graph : inner join & inner join (or) & two ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Y"
         | conn    | toClose | sql                                                         | db|
         | conn_52 | false   | explain SELECT * FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on a.DeptName= b.DeptName or b.DeptName=c.DeptName order by a.name | schema1|
    Then check resultset "Y" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                          |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
        | dn3_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
        | dn4_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC     |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                          |
        | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
        | dn4_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                     |
        | merge_1           | MERGE           | dn3_2; dn4_2                                                                                          |
        | shuffle_field_5   | SHUFFLE_FIELD   | merge_1                                                                                               |
        | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                      |
        | where_filter_1    | WHERE_FILTER    | join_2                                                                                                |
        | shuffle_field_3   | SHUFFLE_FIELD   | where_filter_1                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_52| true    | SELECT * FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on a.DeptName= b.DeptName or b.DeptName=c.DeptName order by a.name  | schema1|

    #optimization about undirected graph : inner join & inner join & inner join & three ER, ER first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Z"
         | conn    | toClose | sql                                                         | db|
         | conn_53 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName = b.DeptName INNER JOIN Info c on  a.DeptName=c.DeptName and b.DeptName=c.DeptName INNER JOIN Level d on c.age=d.levelid order by a.Name | schema1|
    Then check resultset "Z" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | /*AllowDiff*/select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  (  `info` `c` join  `dept` `b` on `c`.`DeptName` = `b`.`DeptName` )  join  `employee` `a` on `b`.`DeptName` = `a`.`DeptName` and `c`.`DeptName` = `a`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC//select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `info` `c` join  `employee` `a` on `c`.`DeptName` = `a`.`DeptName` )  join  `dept` `b` on `a`.`DeptName` = `b`.`DeptName` and `c`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC |
        | dn4_0             | BASE SQL        | /*AllowDiff*/select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  (  `info` `c` join  `dept` `b` on `c`.`DeptName` = `b`.`DeptName` )  join  `employee` `a` on `b`.`DeptName` = `a`.`DeptName` and `c`.`DeptName` = `a`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC//select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `info` `c` join  `employee` `a` on `c`.`DeptName` = `a`.`DeptName` )  join  `dept` `b` on `a`.`DeptName` = `b`.`DeptName` and `c`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                  |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                             |
        | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelid` ASC                                                                                                                                                                                                                                                                |
        | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelid` ASC                                                                                                                                                                                                                                                                |
        | dn3_1             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelid` ASC                                                                                                                                                                                                                                                               |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                                                                                                                                           |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                                                                                                                             |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                                                                                                                              |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                                                                                        |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_53| true    | SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName = b.DeptName INNER JOIN Info c on  a.DeptName=c.DeptName and b.DeptName=c.DeptName INNER JOIN Level d on c.age=d.levelid order by a.Name  | schema1|


   @delete_mysql_tables
  Scenario: shardingTable  + GlobalTable  +  GlobalTable                     #2
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3']}}
    """

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
            <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
            <globalTable name="Dept" shardingNode="dn1,dn3" />
            <globalTable name="Info" shardingNode="dn3,dn4" />
            <globalTable name="Level" shardingNode="dn5,dn6" />
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


    # rule A: left join & left join & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
         | conn    | toClose | sql                                                         | db|
         | conn_1 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name  | schema1|
    Then check resultset "A" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0               | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0               | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1   | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1     | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn1_1  | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC             |
        | merge_1             | MERGE           | /*AllowDiff*/dn1_1                                                                                        |
        | join_1              | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | shuffle_field_2     | SHUFFLE_FIELD   | join_1                                                                                                    |
        | /*AllowDiff*/dn3_0  | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_2             | MERGE           | /*AllowDiff*/dn4_0                                                                                        |
        | join_2              | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | order_1             | ORDER           | join_2                                                                                                    |
        | shuffle_field_3     | SHUFFLE_FIELD   | order_1                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_1 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name  | schema1|

    #rule A: cross join & left join & no ER, left join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "B"
         | conn    | toClose | sql                                                         | db|
         | conn_2 | false   | explain SELECT * FROM Employee a INNER JOIN Dept b LEFT JOIN Info c on b.deptname=c.deptname order by a.name  | schema1|
    Then check resultset "B" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn3_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Dept` `b` left join  `Info` `c` on `b`.`deptname` = `c`.`deptname` |
        | merge_1           | MERGE           | dn3_0                                                                                                                                                                        |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                        |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                        |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                 |
        | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
        | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                     |
        | order_1           | ORDER           | join_1                                                                                                                                                                       |
        | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_2 | true    | SELECT * FROM Employee a INNER JOIN Dept b LEFT JOIN Info c on b.deptname=c.deptname order by a.name  | schema1|

    #rule A: cross join & left join & no ER, left join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "C"
         | conn    | toClose | sql                                                         | db|
         | conn_3 | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c order by a.name  | schema1|
    Then check resultset "C" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC             |
        | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | order_1           | ORDER           | join_1                                                                                                    |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                   |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                 |
        | merge_2           | MERGE           | /*AllowDiff*/dn4_0                                                                                        |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_3 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c order by a.name | schema1|

    #rule A: inner join & left join & no ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "D"
         | conn    | toClose | sql                                                         | db|
         | conn_4  | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name  | schema1|
    Then check resultset "D" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                    |
        | /*AllowDiff*/dn3_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC             |
        | merge_2           | MERGE           | /*AllowDiff*/dn3_1                                                                                        |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | order_1           | ORDER           | join_2                                                                                                    |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_4 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1|

    #rule A: inner join & left join & no ER & contain subquery, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "E"
         | conn    | toClose | sql                                                         | db|
         | conn_5  | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name  | schema1|
    Then check resultset "E" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                                                                                      |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                                                                                      |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                   |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from (select `Info`.`name`,`Info`.`age`,`Info`.`country`,`Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
        | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                                             |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                       |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                         |
        | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC                                                                                                                  |
        | merge_2           | MERGE           | /*AllowDiff*/dn1_1                                                                                                                                                                                             |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                                                                                                       |
        | order_1           | ORDER           | join_2                                                                                                                                                                                                         |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_5 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name  | schema1|

    #rule A: cross join & inner join & no ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "F"
         | conn    | toClose | sql                                                         | db|
         | conn_6  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN Level c on a.level=c.levelname order by a.name  | schema1|
    Then check resultset "F" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
        | /*AllowDiff*/dn6_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
        | merge_1           | MERGE           | /*AllowDiff*/dn6_0                                                                                     |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
        | order_1           | ORDER           | join_1                                                                                                 |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
        | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                      |
        | merge_2           | MERGE           | /*AllowDiff*/dn1_1                                                                                     |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                               |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_6 | true    | SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN Level c on a.level=c.levelname order by a.name  | schema1|

    #rule B、C、D: LEFT join & LEFT join & no ER, join order not change
      Given execute single sql in "dble-1" in "user" mode and save resultset in "G"
         | conn    | toClose | sql                                                         | db|
         | conn_7  | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name  | schema1|
      Then check resultset "G" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                           |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                           |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                        |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                   |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC                                       |
        | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                                                  |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                            |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                              |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
        | merge_2           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                  |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                            |
        | order_1           | ORDER           | join_2                                                                                                                              |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                             |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_7 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name  | schema1|

     #rule B、C、D: LEFT join & inner join & no ER, inner join first
      Given execute single sql in "dble-1" in "user" mode and save resultset in "H"
         | conn    | toClose | sql                                                         | db|
         | conn_8  | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name   | schema1|
      Then check resultset "H" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                         |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC            |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC            |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                         |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                    |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
        | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                                   |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                             |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                               |
        | /*AllowDiff*/dn3_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC |
        | merge_2           | MERGE           | /*AllowDiff*/dn3_1                                                                                                   |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                             |
        | where_filter_1    | WHERE_FILTER    | join_2                                                                                                               |
        | order_1           | ORDER           | where_filter_1                                                                                                       |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                              |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_8 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|

    #rule B、C、D: LEFT join & inner join & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "I"
         | conn    | toClose | sql                                                         | db|
         | conn_9  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name    | schema1|
    Then check resultset "I" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC             |
        | merge_1           | MERGE           | /*AllowDiff*/dn1_1                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                    |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_2           | MERGE           | /*AllowDiff*/dn4_0                                                                                        |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | order_1           | ORDER           | join_2                                                                                                    |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_9 | true    | SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|

    #rule B、C、D: LEFT join & inner join & no ER, inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "J"
         | conn    | toClose | sql                                                         | db|
         | conn_10  | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name | schema1|
    Then check resultset "J" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                           |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                           |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                        |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                   |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
        | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                  |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                            |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                              |
        | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`deptname` ASC                                       |
        | merge_2           | MERGE           | /*AllowDiff*/dn1_1                                                                                                                  |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                            |
        | order_1           | ORDER           | join_2                                                                                                                              |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_10 | true    | SELECT * FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name  | schema1|

    #rule B、C、D: cross join & left join & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "K"
         | conn    | toClose | sql                                                         | db|
         | conn_11  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|
    Then check resultset "K" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                         |
        | merge_1           | MERGE           | /*AllowDiff*/dn1_1                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                    |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_2           | MERGE           | /*AllowDiff*/dn3_0                                                                                        |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | order_1           | ORDER           | join_2                                                                                                    |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_11 | true    | SELECT * FROM Employee a INNER JOIN Dept b  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|

    #rule B、C、D: cross join & left join & no ER, left join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "L"
         | conn    | toClose | sql                                                         | db|
         | conn_12  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b  LEFT JOIN Info c on a.DeptName=c.DeptName and a.name='Tom' order by a.name  | schema1|
    Then check resultset "L" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_1           | MERGE           |  /*AllowDiff*/dn3_0                                                                                       |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | order_1           | ORDER           | join_1                                                                                                    |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                   |
        | /*AllowDiff*/dn3_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                         |
        | merge_2           | MERGE           |  /*AllowDiff*/dn3_1                                                                                       |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn   | toClose | sql                                                         | db|
        | conn_12 | true    |SELECT * FROM Employee a INNER JOIN Dept b  LEFT JOIN Info c on a.DeptName=c.DeptName and a.name='Tom' order by a.name   | schema1|

     #rule B、C、D: cross join & left join & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "M"
         | conn    | toClose | sql                                                         | db|
         | conn_13  | false   | explain SELECT * FROM Employee a LEFT JOIN Info c on a.DeptName=c.DeptName and a.name='Tom' INNER JOIN Dept b where b.deptid=2 order by a.name  | schema1|
    Then check resultset "M" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_1           | MERGE           |  /*AllowDiff*/dn3_0                                                                                       |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | order_1           | ORDER           | join_1                                                                                                    |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                   |
        | /*AllowDiff*/dn3_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2                  |
        | merge_2           | MERGE           |  /*AllowDiff*/dn3_1                                                                                       |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_13 | true     |SELECT * FROM Employee a LEFT JOIN Info c on a.DeptName=c.DeptName and a.name='Tom' INNER JOIN Dept b where b.deptid=2 order by a.name   | schema1|

    #rule B、C、D: cross join & inner join & no ER,inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "N"
         | conn    | toClose | sql                                                         | db|
         | conn_14  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b  INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|
    Then check resultset "N" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                              |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                         |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC     |
        | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                        |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                  |
        | order_1           | ORDER           | join_1                                                                                                    |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                   |
        | /*AllowDiff*/dn3_0| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2                  |
        | merge_2           | MERGE           | /*AllowDiff*/dn3_0                                                                                        |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                  |
        | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_14 | true     |SELECT * FROM Employee a INNER JOIN Dept b  INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name  | schema1|

     #optimization about undirected graph : inner join & inner join (and) & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "O"
         | conn    | toClose | sql                                                         | db|
         | conn_15  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name  | schema1|
    Then check resultset "O" has lines with following column values
        | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                             |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                        |
        | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                             |
        | merge_1           | MERGE           | /*AllowDiff*/dn1_1                                                                                                       |
        | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                 |
        | order_1           | ORDER           | join_1                                                                                                                   |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                  |
        | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
        | merge_2           | MERGE           | /*AllowDiff*/dn4_0                                                                                                       |
        | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                 |
        | order_2           | ORDER           | join_2                                                                                                                   |
        | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_15 | true     |SELECT * FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name  | schema1|

     #optimization about undirected graph : inner join & left join (and) & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "P"
         | conn    | toClose | sql                                                         | db|
         | conn_16  | false   | explain SELECT * FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name  | schema1|
    Then check resultset "P" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                        |
          | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                |
          | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                         |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                    |
          | /*AllowDiff*/dn3_0| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                         |
          | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                                   |
          | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                             |
          | order_1           | ORDER           | join_1                                                                                                               |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                              |
          | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
          | merge_2           | MERGE           | /*AllowDiff*/dn4_0                                                                                                   |
          | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                             |
          | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_16 | true     | SELECT * FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1|

    #optimization about undirected graph : left join & left join (and) & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Q"
         | conn    | toClose | sql                                                         | db|
         | conn_17  | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name  | schema1|
    Then check resultset "Q" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                            |
          | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
          | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                             |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                        |
          | /*AllowDiff*/dn1_1| BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                             |
          | merge_1           | MERGE           | /*AllowDiff*/dn1_1                                                                                                       |
          | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                 |
          | order_1           | ORDER           | join_1                                                                                                                   |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                  |
          | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
          | merge_2           | MERGE           | /*AllowDiff*/dn3_0                                                                                                       |
          | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                 |
          | order_2           | ORDER           | join_2                                                                                                                   |
          | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_17 | true     |SELECT * FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name   | schema1|

    #optimization about undirected graph : cross join & left join (and) & no ER, join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "R"
         | conn    | toClose | sql                                                         | db|
         | conn_18  | false   | explain SELECT * FROM Employee a INNER JOIN Dept b LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name  | schema1|
    Then check resultset "R" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                        |
          | dn1_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                            |
          | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                            |
          | merge_1         | MERGE         | dn1_0; dn2_0                                                                                                             |
          | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                                  |
          | /*AllowDiff*/dn1_1| BASE SQL    | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                        |
          | merge_2         | MERGE         | /*AllowDiff*/dn1_1                                                                                                       |
          | join_1          | JOIN          | shuffle_field_1; merge_2                                                                                                 |
          | order_1         | ORDER         | join_1                                                                                                                   |
          | shuffle_field_2 | SHUFFLE_FIELD | order_1                                                                                                                  |
          | /*AllowDiff*/dn4_0 | BASE SQL   | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
          | merge_3         | MERGE         | /*AllowDiff*/dn4_0                                                                                                       |
          | join_2          | JOIN          | shuffle_field_2; merge_3                                                                                                 |
          | order_2         | ORDER         | join_2                                                                                                                   |
          | shuffle_field_3 | SHUFFLE_FIELD | order_2                                                                                                                  |
   Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_18 | true     | SELECT * FROM Employee a INNER JOIN Dept b LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name   | schema1|


  # root node is GlobalTable
  @delete_mysql_tables
   Scenario: GlobalTable  + [otherTypeTable]            #3
     """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3', 'db4'], 'mysql-master2': ['db1', 'db2', 'db3', 'db4']}}
    """

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
            <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
            <globalTable name="Info" shardingNode="dn3,dn4" />
            <globalTable name="Level" shardingNode="dn5,dn6" />
            <globalTable name="FamilyInfo" shardingNode="dn7,dn8" />
        </schema>

        <shardingNode dbGroup="ha_group1" database="db1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="db1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="db2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="db2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="db3" name="dn5" />
        <shardingNode dbGroup="ha_group2" database="db3" name="dn6" />
        <shardingNode dbGroup="ha_group1" database="db4" name="dn7" />
        <shardingNode dbGroup="ha_group2" database="db4" name="dn8" />

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
      | conn_0 | false    | create table FamilyInfo(name varchar(25) not null, housetype varchar(250) not null, familynum int not null)engine=innodb charset=utf8                      | schema1  | success|
      | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
      | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                               | schema1 | success|
      | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
      | conn_0 | false    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | schema1| success|
      | conn_0 | true     | insert into FamilyInfo values('Harry', 'department', 3),('George', 'department', 5), ('Harriet', 'villa', 6), ('Mary', 'villa', 8), ('LiLi', 'Self-built house', 10), ('Tom', 'department', 2)                                                                          | schema1| success|

    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose  | sql                       | db | expect               |
      | conn_0 | false    | create table FamilyInfo(name varchar(25) not null, housetype varchar(250) not null, familynum int not null)engine=innodb charset=utf8                      | schema1  | success|
      | conn_0 | true     | insert into FamilyInfo values('Harry', 'department', 3),('George', 'department', 5), ('Harriet', 'villa', 6), ('Mary', 'villa', 8), ('LiLi', 'Self-built house', 10), ('Tom', 'department', 2)                                                                          | schema1| success|

     # GlobalTable + shardingTable + GlobalTable
     #rule A: left join & left join & no ER, GlobalTable first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
         | conn    | toClose | sql                                                         | db|
         | conn_1  | false   | explain  select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name   | schema1|
     Then check resultset "A" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                        |
          | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`age` ASC |
          | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                |
          | /*AllowDiff*/dn5_0| BASE SQL        | select `b`.`levelname`,`b`.`levelid`,`b`.`salary` from  `Level` `b` order by `b`.`levelid` ASC |
          | merge_2           | MERGE           | /*AllowDiff*/dn5_0                                                                |
          | join_1            | JOIN            | merge_1; merge_2                                                                  |
          | order_1           | ORDER           | join_1                                                                            |
          | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                           |
          | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC     |
          | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC     |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
          | join_2            | JOIN            | shuffle_field_1; shuffle_field_3                                                  |
          | order_2           | ORDER           | join_2                                                                            |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_1 | true     | select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name  | schema1|

     # GlobalTable + GlobalTable + shardingTable
      #rule A: left join & inner join & no ER, GlobalTable first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "B"
         | conn    | toClose | sql                                                         | db|
         | conn_2  | false   | explain select * from Info c left join Level d on c.age=d.levelid inner join Dept b on c.deptname=b.deptname order by c.name    | schema1|
     Then check resultset "B" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                    |
          | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`age` ASC |
          | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                               |
          | /*AllowDiff*/dn5_0| BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` order by `d`.`levelid` ASC   |
          | merge_2           | MERGE           | /*AllowDiff*/dn5_0                                                                               |
          | join_1            | JOIN            | merge_1; merge_2                                                                                 |
          | order_1           | ORDER           | join_1                                                                                           |
          | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                          |
          | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC    |
          | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC    |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                     |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                |
          | join_2            | JOIN            | shuffle_field_1; shuffle_field_3                                                                 |
          | order_2           | ORDER           | join_2                                                                                           |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                          |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql                                                         | db|
        | conn_2 | true     | select * from Info c left join Level d on c.age=d.levelid inner join Dept b on c.deptname=b.deptname order by c.name  | schema1|

     # GlobalTable + shardingTable + shardingTable
     #rule A: left join & inner join & no ER, inner join first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "C"
         | conn    | toClose | sql                                                         | db|
         | conn_3  | false   | explain select *  from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname order by a.name     | schema1|
     Then check resultset "C" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                        |
          | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
          | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                       |
          | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC|
          | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC|
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                           |
          | join_1            | JOIN            | merge_1; shuffle_field_3                                                                    |
          | order_1           | ORDER           | join_1                                                                                      |
          | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                     |
          | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC|
          | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC|
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                |
          | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                           |
          | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                            |
          | order_2           | ORDER           | join_2                                                                                      |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                     |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_3  | true      | select *  from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname order by a.name   | schema1|

     # GlobalTable + GlobalTable + GlobalTable
     #rule A: left join & inner join & no ER, inner join first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "D"
         | conn    | toClose | sql                                                         | db|
         | conn_4  | false   | explain select *  from Info c left join Level d on c.age=d.levelid inner join FamilyInfo e on c.name=e.name order by c.name     | schema1|
     Then check resultset "D" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                     |
          | /*AllowDiff*/dn3_0| BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC |
          | merge_1         | MERGE         | /*AllowDiff*/dn3_0                                                                  |
          | /*AllowDiff*/dn8_0| BASE SQL    | select `e`.`name`,`e`.`housetype`,`e`.`familynum` from  `FamilyInfo` `e` order by `e`.`name` ASC    |
          | merge_2         | MERGE         | /*AllowDiff*/dn8_0                                                                  |
          | join_1          | JOIN          | merge_1; merge_2                                                                    |
          | order_1         | ORDER         | join_1                                                                              |
          | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                             |
          | /*AllowDiff*/dn6_0| BASE SQL    | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` order by `d`.`levelid` ASC   |
          | merge_3         | MERGE         | /*AllowDiff*/dn6_0                                                                  |
          | join_2          | JOIN          | shuffle_field_1; merge_3                                                            |
          | order_2         | ORDER         | join_2                                                                              |
          | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_4  | true      | select *  from Info c left join Level d on c.age=d.levelid inner join FamilyInfo e on c.name=e.name order by c.name   | schema1|

     #GlobalTable + shardingTable + shardingTable
     #rule B、C、D: left join & inner join & no ER, inner join first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "E"
         | conn    | toClose | sql                                                         | db|
         | conn_5  | false   | explain select * from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname and c.country='China' order by a.name    | schema1|
     Then check resultset "E" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                     |
          | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
          | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                        |
          | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                             |
          | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC                             |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                              |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                         |
          | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                  |
          | order_1           | ORDER           | join_1                                                                                                                    |
          | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                   |
          | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                     |
          | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                     |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                              |
          | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                         |
          | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                          |
          | order_2           | ORDER           | join_2                                                                                                                    |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_5  | true      | select * from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname and c.country='China' order by a.name   | schema1|


     #GlobalTable + shardingTable + shardingTable
     #rule B、C、D: left join & left join & no ER, join order not change
     Given execute single sql in "dble-1" in "user" mode and save resultset in "F"
         | conn    | toClose | sql                                                         | db|
         | conn_6  | false   | explain select * from Info c left join Employee a on c.name=a.name left join Dept b on c.deptname=b.deptname and c.country='China' order by a.name    | schema1|
     Then check resultset "F" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                     |
          | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC |
          | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                      |
          | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC|
          | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC|
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
          | join_1            | JOIN            | merge_1; shuffle_field_3                                                                |
          | order_1           | ORDER           | join_1                                                                                  |
          | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                 |
          | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC |
          | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
          | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
          | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
          | order_2           | ORDER           | join_2                                                                                  |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                 |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_6  | true      | select * from Info c left join Employee a on c.name=a.name left join Dept b on c.deptname=b.deptname and c.country='China' order by a.name   | schema1|


     #GlobalTable + GlobalTable + GlobalTable
     #rule B、C、D: left join & left join & no ER, join order not change
     Given execute single sql in "dble-1" in "user" mode and save resultset in "G"
         | conn    | toClose | sql                                                         | db|
         | conn_7  | false   | explain select *  from Info c left join Level d on c.age=d.levelid left join FamilyInfo e on c.name=e.name and c.country='China' order by c.name    | schema1|
     Then check resultset "G" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                     |
          | /*AllowDiff*/dn3_0| BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`age` ASC |
          | merge_1         | MERGE         | /*AllowDiff*/dn3_0                                                                               |
          | /*AllowDiff*/dn5_0| BASE SQL    | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` order by `d`.`levelid` ASC   |
          | merge_2         | MERGE         | /*AllowDiff*/dn5_0                                                                               |
          | join_1          | JOIN          | merge_1; merge_2                                                                                 |
          | order_1         | ORDER         | join_1                                                                                           |
          | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                          |
          | /*AllowDiff*/dn8_0| BASE SQL    | select `e`.`name`,`e`.`housetype`,`e`.`familynum` from  `FamilyInfo` `e` order by `e`.`name` ASC |
          | merge_3         | MERGE         | /*AllowDiff*/dn8_0                                                                               |
          | join_2          | JOIN          | shuffle_field_1; merge_3                                                                         |
          | shuffle_field_2 | SHUFFLE_FIELD | join_2                                                                                           |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_7  | true      | select *  from Info c left join Level d on c.age=d.levelid left join FamilyInfo e on c.name=e.name and c.country='China' order by c.name | schema1|

     #GlobalTable + GlobalTable + GlobalTable
     #rule B、C、D: cross join & left join & no ER, left join first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "H"
         | conn    | toClose | sql                                                         | db|
         | conn_8  | false   | explain select *  from Info c inner join Level d left join FamilyInfo e on c.name=e.name and c.country='China' order by c.name    | schema1|
     Then check resultset "H" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                     |
          | /*AllowDiff*/dn4_0| BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC |
          | merge_1         | MERGE         | /*AllowDiff*/dn4_0                                                                      |
          | /*AllowDiff*/dn8_0| BASE SQL      | select `e`.`name`,`e`.`housetype`,`e`.`familynum` from  `FamilyInfo` `e` order by `e`.`name` ASC      |
          | merge_2         | MERGE         | /*AllowDiff*/dn8_0                                                                      |
          | join_1          | JOIN          | merge_1; merge_2                                                                        |
          | shuffle_field_1 | SHUFFLE_FIELD | join_1                                                                                  |
          | /*AllowDiff*/dn6_0| BASE SQL      | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d`                   |
          | merge_3         | MERGE         | /*AllowDiff*/dn6_0                                                                      |
          | join_2          | JOIN          | shuffle_field_1; merge_3                                                                |
          | shuffle_field_2 | SHUFFLE_FIELD | join_2                                                                                  |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_8  | true      | select *  from Info c inner join Level d left join FamilyInfo e on c.name=e.name and c.country='China' order by c.name | schema1|

     #GlobalTable + shardingTable + shardingTable
     #optimization about undirected graph : inner join & inner join (and) & no ER, join order not change
     Given execute single sql in "dble-1" in "user" mode and save resultset in "I"
         | conn    | toClose | sql                                                         | db|
         | conn_9  | false   | explain select * from Info c inner join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname and a.name=b.manager order by a.name     | schema1|
     Then check resultset "I" has lines with following column values
          | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                     |
          |  /*AllowDiff*/dn4_0| BASE SQL        |  select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC|
          | merge_1           | MERGE           |  /*AllowDiff*/dn4_0                                                                                |
          | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC|
          | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC|
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                       |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                  |
          | join_1            | JOIN            | merge_1; shuffle_field_3                                                                           |
          | order_1           | ORDER           | join_1                                                                                             |
          | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                            |
          | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
          | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`deptname` ASC |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                       |
          | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                  |
          | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                   |
          | shuffle_field_2   | SHUFFLE_FIELD   | join_2                                                                                             |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_9  | true      | select * from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname and a.name=b.manager order by a.name | schema1|

     #GlobalTable + shardingTable + shardingTable
     #optimization about undirected graph : inner join & inner join (and) & one ER, ER first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "J"
         | conn    | toClose | sql                                                         | db|
         | conn_10  | false   | explain select * from Info c inner join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname and a.deptname=b.deptname order by a.name     | schema1|
     Then check resultset "J" has lines with following column values
          | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`deptname` ASC |
          | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`deptname` ASC |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                      |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                 |
          | /*AllowDiff*/dn3_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC                                                                                                              |
          | merge_1           | MERGE           | /*AllowDiff*/dn3_0                                                                                                                                                                                                                |
          | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                          |
          | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                            |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_10  | true      | select * from Info c inner join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname and a.deptname=b.deptname order by a.name | schema1|


    #take all shardingTable as example
   @delete_mysql_tables
   Scenario: right join and more complex join sql            #4
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3', 'db4'], 'mysql-master2': ['db1', 'db2', 'db3', 'db4'], 'mysql':['schema1']}}
    """

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
        <shardingNode dbGroup="ha_group1" database="db4" name="dn7" />
        <shardingNode dbGroup="ha_group2" database="db4" name="dn8" />

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
      | conn_0 | false    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | schema1| success|

     Given execute single sql in "dble-1" in "user" mode and save resultset in "A"
         | conn     | toClose  | sql                                                         | db|
         | conn_1   | false   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName UNION SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName | schema1|
     Then check resultset "A" has lines with following column values
          | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC |
          | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                         |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |
          | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
          | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
          | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                  |
          | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                    |
          | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
          | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                               |
          | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC      |
          | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `a`.`level` ASC      |
          | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                                                                                                                                         |
          | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                                                                                                                    |
          | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
          | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
          | dn3_3             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                     |
          | merge_and_order_4 | MERGE_AND_ORDER | dn1_1; dn2_1; dn3_3                                                                                                                                                                                                  |
          | shuffle_field_7   | SHUFFLE_FIELD   | merge_and_order_4                                                                                                                                                                                                    |
          | join_2            | JOIN            | shuffle_field_5; shuffle_field_7                                                                                                                                                                                     |
          | shuffle_field_6   | SHUFFLE_FIELD   | join_2                                                                                                                                                                                                               |
          | union_all_1       | UNION_ALL       | shuffle_field_2; shuffle_field_6                                                                                                                                                                                     |
          | distinct_1        | DISTINCT        | union_all_1                                                                                                                                                                                                          |
          | shuffle_field_3   | SHUFFLE_FIELD   | distinct_1                                                                                                                                                                                                           |
     Then execute sql in "dble-1" and the result should be consistent with mysql
          | conn    | toClose   | sql                                                         | db|
          | conn_1  | true      | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.DeptName= b.DeptName UNION SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.DeptName= b.DeptName  | schema1|

     # more join
     Given execute single sql in "dble-1" in "user" mode and save resultset in "B"
         | conn     | toClose  | sql                                                         | db|
         | conn_2   | false   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Info d on a.deptname=d.deptname order by a.name  | schema1|
     Then check resultset "B" has lines with following column values
          | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`d`.`name`,`d`.`age`,`d`.`country`,`d`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `d` on `a`.`deptname` = `d`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`d`.`name`,`d`.`age`,`d`.`country`,`d`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `d` on `a`.`deptname` = `d`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
          | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                          |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                     |
          | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                                                                      |
          | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                                                                      |
          | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                                                                                                      |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                                                                                                                   |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                                                                                                     |
          | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                                                                                                      |
          | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                                                                |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                                                               |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_2  | true      | SELECT * FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Info d on a.deptname=d.deptname order by a.name  | schema1|

     #more join
     Given execute single sql in "dble-1" in "user" mode and save resultset in "C"
         | conn     | toClose  | sql                                                         | db|
         | conn_3   | false   | explain  SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName = b.DeptName INNER JOIN Info c on  a.DeptName=c.DeptName and b.DeptName=c.DeptName INNER JOIN Level d on c.age=d.levelid order by a.Name   | schema1|
     Then check resultset "C" has lines with following column values
          | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Info` `c` join  `Dept` `b` on `c`.`DeptName` = `b`.`DeptName` )  join  `Employee` `a` on `b`.`DeptName` = `a`.`DeptName` and `c`.`DeptName` = `a`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC//select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` )  join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` and `c`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Info` `c` join  `Dept` `b` on `c`.`DeptName` = `b`.`DeptName` )  join  `Employee` `a` on `b`.`DeptName` = `a`.`DeptName` and `c`.`DeptName` = `a`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC//select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`DeptName` = `a`.`DeptName` )  join  `Dept` `b` on `a`.`DeptName` = `b`.`DeptName` and `c`.`DeptName` = `b`.`DeptName` where 1=1  ORDER BY `c`.`age` ASC |
          | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                  |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                             |
          | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelid` ASC                                                                                                                                                                                                                                                                |
          | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelid` ASC                                                                                                                                                                                                                                                                |
          | dn3_1             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelid` ASC                                                                                                                                                                                                                                                                |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                                                                                                                                                           |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                                                                                                                             |
          | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                                                                                                                              |
          | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                                                                                        |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                                                                                       |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_3  | true      | SELECT * FROM Employee a INNER JOIN Dept b on a.DeptName = b.DeptName INNER JOIN Info c on  a.DeptName=c.DeptName and b.DeptName=c.DeptName INNER JOIN Level d on c.age=d.levelid order by a.Name  | schema1|

     #right join & right join : (ab, ac) & one ER at first
     Given execute single sql in "dble-1" in "user" mode and save resultset in "D"
         | conn     | toClose  | sql                                                         | db|
         | conn_4   | false   | explain select * FROM Employee a right join Dept b on a.DeptName=b.DeptName right join Level c on a.level=c.levelname order by a.name   | schema1|
     Then check resultset "D" has lines with following column values
          | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                            |
          | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                            |
          | dn3_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                            |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0                                                                                                                                                                         |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                           |
          | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` left join  `Employee` `a` on `b`.`DeptName` = `a`.`DeptName` where 1=1  |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` left join  `Employee` `a` on `b`.`DeptName` = `a`.`DeptName` where 1=1  |
          | merge_1           | MERGE           | dn3_1; dn4_0                                                                                                                                                                                |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                     |
          | order_2           | ORDER           | shuffle_field_3                                                                                                                                                                             |
          | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                    |
          | order_1           | ORDER           | join_1                                                                                                                                                                                      |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                     |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_4  | true      | select * FROM Employee a right join Dept b on a.DeptName=b.DeptName right join Level c on a.level=c.levelname order by a.name  | schema1|

     #right join & right join: (ab, ac) & one ER at last
     Given execute single sql in "dble-1" in "user" mode and save resultset in "E"
         | conn     | toClose  | sql                                                         | db|
         | conn_5   | false   | explain  select * FROM Employee a right join Level c on a.level=c.levelname right join Dept b on a.DeptName=b.DeptName order by a.name   | schema1|
     Then check resultset "E" has lines with following column values
          | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn3_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
          | dn4_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
          | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
          | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC       |
          | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC       |
          | dn3_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC       |
          | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                    |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
          | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
          | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
          | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                           |
          | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
          | join_2            | JOIN            | shuffle_field_3; shuffle_field_5                                                                       |
          | shuffle_field_4   | SHUFFLE_FIELD   | join_2                                                                                                 |
          | order_2           | ORDER           | shuffle_field_4                                                                                        |
          | join_1            | JOIN            | shuffle_field_1; order_2                                                                               |
          | order_1           | ORDER           | join_1                                                                                                 |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_5  | true      | select * FROM Employee a right join Level c on a.level=c.levelname right join Dept b on a.DeptName=b.DeptName order by a.name  | schema1|

     #right join & right join: (ab, ac) & two ER           see http://10.186.18.11/jira/browse/DBLE0REQ-1537, can be optimizer but not, may support later and need to change this case
       Given execute single sql in "dble-1" in "user" mode and save resultset in "F"
         | conn     | toClose  | sql                                                         | db|
         | conn_6   | false   | explain select * FROM Employee a right join Dept b on a.deptname=b.deptname right join Info c on a.deptname=c.deptname order by a.name    | schema1|
       Then check resultset "F" has lines with following column values
         | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
        | dn3_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC                                                                                       |
        | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC                                                                                       |
        | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                           |
        | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` left join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  |
        | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` left join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  |
        | merge_1           | MERGE           | dn3_1; dn4_1                                                                                                                                                                                |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                     |
        | order_2           | ORDER           | shuffle_field_3                                                                                                                                                                             |
        | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                    |
        | order_1           | ORDER           | join_1                                                                                                                                                                                      |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                     |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_6  | true      | select * FROM Employee a right join Dept b on a.deptname=b.deptname right join Info c on a.deptname=c.deptname order by a.name   | schema1|

     #right join & left join
       Given execute single sql in "dble-1" in "user" mode and save resultset in "G"
         | conn     | toClose  | sql                                                         | db|
         | conn_7   | false   | explain  select * from Employee a left join Dept b on a.name=b.manager left join Info c on a.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name    | schema1|
       Then check resultset "G" has lines with following column values
         | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                            |
          | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                            |
          | dn3_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                            |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0                                                                                                                                                                                                         |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                           |
          | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
          | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_0                                                                                                                                                                                                                |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                           |
          | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
          | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
          | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                                                                                                                                                |
          | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                                                                                                                           |
          | join_2            | JOIN            | shuffle_field_3; shuffle_field_5                                                                                                                                                                                            |
          | shuffle_field_4   | SHUFFLE_FIELD   | join_2                                                                                                                                                                                                                      |
          | order_2           | ORDER           | shuffle_field_4                                                                                                                                                                                                             |
          | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                                                    |
          | order_1           | ORDER           | join_1                                                                                                                                                                                                                      |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                     |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_7  | true      | select * from Employee a left join Dept b on a.name=b.manager left join Info c on a.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name    | schema1|

     #right join & left join
       Given execute single sql in "dble-1" in "user" mode and save resultset in "H"
         | conn     | toClose  | sql                                                         | db|
         | conn_8   | false   | explain select * from Employee a left join Dept b on a.name=b.manager left join Info c on a.deptname=c.deptname and a.name='Tom' right join Level d on a.level=d.levelname order by a.name    | schema1|
       Then check resultset "H" has lines with following column values
         | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                                               |
          | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                                               |
          | dn3_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                                               |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0                                                                                                                                                                                                                            |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
          | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and (a.name = 'Tom') where 1=1  ORDER BY `a`.`name` ASC |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and (a.name = 'Tom') where 1=1  ORDER BY `a`.`name` ASC |
          | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_0                                                                                                                                                                                                                                   |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                              |
          | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                                   |
          | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                                   |
          | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                                                                                                                                                                   |
          | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                                                                                                                                              |
          | join_2            | JOIN            | shuffle_field_3; shuffle_field_5                                                                                                                                                                                                               |
          | shuffle_field_4   | SHUFFLE_FIELD   | join_2                                                                                                                                                                                                                                         |
          | order_2           | ORDER           | shuffle_field_4                                                                                                                                                                                                                                |
          | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                                                                       |
          | order_1           | ORDER           | join_1                                                                                                                                                                                                                                         |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                        |
     Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_8  | true      | select * from Employee a left join Dept b on a.name=b.manager left join Info c on a.deptname=c.deptname and a.name='Tom' right join Level d on a.level=d.levelname order by a.name     | schema1|

     #right join & inner join
       Given execute single sql in "dble-1" in "user" mode and save resultset in "I"
         | conn     | toClose  | sql                                                         | db|
         | conn_9   | false   | explain select * from Employee a INNER join Dept b on a.name=b.manager INNER join Info c on a.deptname=c.deptname and b.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name    | schema1|
       Then check resultset "I" has lines with following column values
         | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                                                                                                                                  |
          | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                                                                                                                                  |
          | dn3_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                                                                                                                                  |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0                                                                                                                                                                                                                                                                                                               |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                 |
          | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`manager` = `a`.`name` where 1=1//select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`name` = `b`.`manager` where 1=1  |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` and `b`.`manager` = `a`.`name` where 1=1//select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`name` = `b`.`manager` where 1=1  |
          | merge_1           | MERGE           | dn3_1; dn4_0                                                                                                                                                                                                                                                                                                                      |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_1                                                                                                                                                                                                                                                                                                                           |
          | order_2           | ORDER           | shuffle_field_3                                                                                                                                                                                                                                                                                                                   |
          | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                                                                                                                                                          |
          | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                                                            |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                                                           |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_9  | true      | select * from Employee a INNER join Dept b on a.name=b.manager INNER join Info c on a.deptname=c.deptname and b.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name     | schema1|

     #right join & inner join & left join
       Given execute single sql in "dble-1" in "user" mode and save resultset in "J"
         | conn     | toClose  | sql                                                         | db|
         | conn_10   | false   | explain select * from Employee a INNER join Dept b on a.name=b.manager LEFT join Info c on a.deptname=c.deptname and b.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name   | schema1|
       Then check resultset "J" has lines with following column values
         | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
        | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                         |
        | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                         |
        | dn3_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                         |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0                                                                                                      |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                        |
        | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
        | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                    |
        | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_0                                                                                                             |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                        |
        | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                             |
        | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                             |
        | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                                             |
        | shuffle_field_6   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                        |
        | join_2            | JOIN            | shuffle_field_3; shuffle_field_6                                                                                         |
        | order_2           | ORDER           | join_2                                                                                                                   |
        | shuffle_field_4   | SHUFFLE_FIELD   | order_2                                                                                                                  |
        | dn3_3             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
        | dn4_2             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`deptname` ASC,`c`.`deptname` ASC |
        | merge_and_order_4 | MERGE_AND_ORDER | dn3_3; dn4_2                                                                                                             |
        | shuffle_field_7   | SHUFFLE_FIELD   | merge_and_order_4                                                                                                        |
        | join_3            | JOIN            | shuffle_field_4; shuffle_field_7                                                                                         |
        | shuffle_field_5   | SHUFFLE_FIELD   | join_3                                                                                                                   |
        | order_3           | ORDER           | shuffle_field_5                                                                                                          |
        | join_1            | JOIN            | shuffle_field_1; order_3                                                                                                 |
        | order_1           | ORDER           | join_1                                                                                                                   |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                  |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_10  | true      | select * from Employee a INNER join Dept b on a.name=b.manager LEFT join Info c on a.deptname=c.deptname and b.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name    | schema1|

      #right join & inner join & left join
       Given execute single sql in "dble-1" in "user" mode and save resultset in "K"
         | conn     | toClose  | sql                                                         | db|
         | conn_11   | false   | explain select * from Employee a INNER join Dept b on a.name=b.manager LEFT join Info c on a.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name   | schema1|
       Then check resultset "K" has lines with following column values
         | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
          | dn1_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                            |
          | dn2_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                            |
          | dn3_0             | BASE SQL        | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` ORDER BY `d`.`levelname` ASC                                                                                                                            |
          | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_0                                                                                                                                                                                                         |
          | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                           |
          | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
          | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Employee` `a` left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
          | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_0                                                                                                                                                                                                                |
          | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                           |
          | dn3_2             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
          | dn4_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
          | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_1                                                                                                                                                                                                                |
          | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                                                                                                                           |
          | join_2            | JOIN            | shuffle_field_3; shuffle_field_5                                                                                                                                                                                            |
          | shuffle_field_4   | SHUFFLE_FIELD   | join_2                                                                                                                                                                                                                      |
          | order_2           | ORDER           | shuffle_field_4                                                                                                                                                                                                             |
          | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                                                    |
          | order_1           | ORDER           | join_1                                                                                                                                                                                                                      |
          | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                     |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose   | sql                                                         | db|
        | conn_11  | true      | select * from Employee a INNER join Dept b on a.name=b.manager LEFT join Info c on a.deptname=c.deptname and b.deptname=c.deptname right join Level d on a.level=d.levelname order by a.name    | schema1|
