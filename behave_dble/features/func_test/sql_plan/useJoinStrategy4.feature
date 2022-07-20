# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/5/10
Feature: check useJoinStrategy

  @delete_mysql_tables
  Scenario: check useJoinStrategy - globalTable + singleTable + shardingTable #1
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2'], 'mysql':['schema1']}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseJoinStrategy=true
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="Employee_1" shardingNode="dn1,dn2,dn3,dn4" />
        <globalTable name="Employee_2" shardingNode="dn2,dn3,dn4" />
        <singleTable name="Dept" shardingNode="dn1" />
        <shardingTable name="Info" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Level" shardingNode="dn1,dn2" function="hash-two" shardingColumn="levelid" />
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
    Then restart dble in "dble-1" success
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1;drop table if exists Employee_2                                                        | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1;drop table if exists Employee_2                                                        | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |

     #ab, ac: singleTable, globalTable same node & left join & left join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                  |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                       |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                      |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                               |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name | schema1 |
    #ab, ac: singleTable, globalTable diff node & left join & left join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      |dn2_0//dn3_0//dn4_0| BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn2_0//dn3_0//dn4_0                                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2           | MERGE           | dn1_0                                                                                                   |
      | join_1            | JOIN            | merge_1; merge_2                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_0//dn2_1      | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0//dn1_1; dn2_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_3                                                                        |
      | order_2           | ORDER           | join_2                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname order by a.name | schema1 |


    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where a => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                        |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` where `a`.`empid` = 3401 order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                                           |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                               |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1 |
    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where b.deptid=2 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 2 order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                                         |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                              |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                             |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                                                      |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where b.deptid=2 order by a.name | schema1 |
    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                   |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                  |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                            |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                      |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                               |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                 |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where c.salary=15000 order by a.name | schema1 |
    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where a,b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` where  ( `b`.`deptid` = 2 AND `a`.`empid` = 3401) order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                                                                    |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                         |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                        |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                                                                                 |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 order by a.name | schema1 |
    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where a,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                        |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` where `a`.`empid` = 3401 order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                                           |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                                                     |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                               |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                                          |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where b.deptid=2 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                   |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 2 order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                                         |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                                                   |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                             |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                                                      |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                                        |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where b.deptid=2 and c.salary=15000 order by a.name | schema1 |
    #ab, ac: singleTable, globalTable same node & left join & left join & no ER & where a,b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` left join  `Dept` `b` on `a`.`name` = `b`.`manager` where  ( `b`.`deptid` = 2 AND `a`.`empid` = 3401) order by `a`.`level` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                                                                                                                                                    |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                                                                              |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                        |
      | join_1            | JOIN            | merge_1; shuffle_field_2                                                                                                                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                                                                   |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 and c.salary=15000 order by a.name | schema1 |


    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a & on and b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL            | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | dn2_0//dn2_1      | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a & on or b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL          | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1           | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | dn2_0//dn2_1    | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | merge_3         | MERGE                 | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4 | SHUFFLE_FIELD         | merge_3                                                                                                                                                          |
      | join_2          | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | shuffle_field_3 | SHUFFLE_FIELD         | join_2                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a & on and c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname and c.salary>10000 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL            | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` > 10000 ORDER BY `c`.`levelname` ASC                                      |
      | dn2_0//dn2_1      | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` > 10000 ORDER BY `c`.`levelname` ASC                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname and c.salary>10000 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a & on or c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname or c.salary>10000 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1            | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL          | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1           | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | dn2_0//dn2_1    | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | merge_3         | MERGE                 | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4 | SHUFFLE_FIELD         | merge_3                                                                                                                                                          |
      | join_2          | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | shuffle_field_3 | SHUFFLE_FIELD         | join_2                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname or c.salary>10000 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a,c & on and b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL            | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                      |
      | dn2_0//dn2_1      | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | order_2           | ORDER                 | where_filter_1                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a,c & on or b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1              | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL            | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | dn2_0//dn2_1      | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | merge_3           | MERGE                 | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_3                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a,c & on and c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname and c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                    |
      | dn2_0//dn3_0//dn4_0 | BASE SQL            | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where  ( `c`.`levelid` > 1 AND `c`.`salary` = 15000) ORDER BY `c`.`levelname` ASC            |
      | dn2_0//dn2_1      | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where  ( `c`.`levelid` > 1 AND `c`.`salary` = 15000) ORDER BY `c`.`levelname` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | order_2           | ORDER                 | where_filter_1                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname and c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a,c & on or c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname or c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0     | TYPE-1              | SQL/REF-2                                                                                                                                                        |
      | dn2_0//dn3_0//dn4_0 | BASE SQL            | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn2_0//dn3_0//dn4_0                                                                                                                                              |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2           | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | dn2_0//dn2_1      | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | merge_3           | MERGE                 | dn1_1; dn2_0//dn1_1; dn2_1                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_3                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname or c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname where a.empid=3401 or c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn2_0//dn3_0//dn4_0 | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn2_0//dn3_0//dn4_0                                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2           | MERGE           | dn1_0                                                                                                   |
      | join_1            | JOIN            | merge_1; merge_2                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_0//dn2_1      | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0//dn1_1; dn2_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_3                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | order_2           | ORDER           | where_filter_1                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname where a.empid=3401 or c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & left join & no ER & where a or b or c => table b,c nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname where a.empid=3401 or b.deptid=2 or c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn2_0//dn3_0//dn4_0 | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn2_0//dn3_0//dn4_0                                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2           | MERGE           | dn1_0                                                                                                   |
      | join_1            | JOIN            | merge_1; merge_2                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_0//dn2_1      | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0//dn1_1; dn2_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_3                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | order_2           | ORDER           | where_filter_1                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname where a.empid=3401 or b.deptid=2 or c.salary=15000 order by a.name | schema1 |


  @delete_mysql_tables
  Scenario: check useJoinStrategy - globalTable + shardingTable + shardingTable #2
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2'], 'mysql':['schema1']}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseJoinStrategy=true
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="Employee_1" shardingNode="dn1,dn2,dn3,dn4" />
        <globalTable name="Employee_2" shardingNode="dn3,dn4" />
        <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Info" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Level" shardingNode="dn1,dn2" function="hash-two" shardingColumn="levelid" />
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
    Then restart dble in "dble-1" success
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1;drop table if exists Employee_2                                                        | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1;drop table if exists Employee_2                                                        | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |

     #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where 1=1  ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where 1=1  ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                              |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                               |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1 |
     #ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0//dn4_0      | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC       |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | order_2           | ORDER           | join_2                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1 |


     #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where a => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `a`.`empid` = 2202 ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `a`.`empid` = 2202 ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                            |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                            |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                            |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 order by a.name | schema1 |
     #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                          |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                          |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                           |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 order by a.name | schema1 |
     #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where c => no nestLoop
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
        | conn   | toClose | sql                                                         | db |
        | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where c.age=35 order by a.name | schema1|
      Then check resultset "rs_1" has lines with following column values
        | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
        | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where 1=1  ORDER BY `b`.`manager` ASC |
        | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where 1=1  ORDER BY `b`.`manager` ASC |
        | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                   |
        | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
        | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                         |
        | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                         |
        | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                   |
        | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                              |
        | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                               |
        | order_1           | ORDER           | join_1                                                                                                                                                                                                         |
        | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                        |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql | db  |
        | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where c.age=35 order by a.name | schema1 |
     #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where a,b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where  ( `a`.`empid` = 2202 AND `b`.`deptid` = 3) ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where  ( `a`.`empid` = 2202 AND `b`.`deptid` = 3) ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                                                     |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                      |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 order by a.name | schema1 |
    #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where a,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `a`.`empid` = 2202 ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `a`.`empid` = 2202 ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                            |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                                       |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                                       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and c.age=35 order by a.name | schema1 |
    #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                          |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                                     |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                           |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 and c.age=35 order by a.name | schema1 |
    #ab, bc: shardingTable, globalTable same node & inner join & inner join & no ER & where a,b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where  ( `a`.`empid` = 2202 AND `b`.`deptid` = 3) ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee_1` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where  ( `a`.`empid` = 2202 AND `b`.`deptid` = 3) ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                                                                |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                                                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                      |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 and c.age=35 order by a.name | schema1 |


    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a & on and c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.age>20 where a.empid=2202 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                              |
      | dn3_0//dn4_0      | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                     |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` > 20 ORDER BY `c`.`name` ASC                                           |
      | dn2_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` > 20 ORDER BY `c`.`name` ASC                                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.age>20 where a.empid=2202 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a & on or c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or c.age>20 where a.empid=2202 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0//dn4_0      | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                     |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                        |
      | dn2_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                        |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or c.age>20 where a.empid=2202 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where b & on and a => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid>1000 where b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                        |
      | dn3_0//dn4_0      | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` > 1000 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                         |
      | order_1           | ORDER           | join_1                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                          |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC                                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid>1000 where b.deptid=3 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a & on or a => table a nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or a.empid>1000 where b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                      |
      | dn2_0             | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                        |
      | nest_loop_1       | NEST_LOOP             | shuffle_field_1                                                                                                                                                          |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                             |
      | join_1            | JOIN                  | nest_loop_1; merge_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                   |
      | dn1_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                |
      | dn2_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                             |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                         |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or a.empid>1000 where b.deptid=3 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where c & on and b => table a nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where c.age=35 order by a.name | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                |
      | dn1_0             | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC                                                      |
      | dn2_0             | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                        |
      | nest_loop_1       | NEST_LOOP             | shuffle_field_1                                                                                                                                                          |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                             |
      | join_1            | JOIN                  | nest_loop_1; merge_1                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                  |
      | dn1_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                   |
      | dn2_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC                                                   |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                             |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                         |
      | order_2           | ORDER                 | join_2                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where c.age=35 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where c & on or b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where c.age=35 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0//dn4_0      | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | join_1                                                                                                  |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35          |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35          |
      | merge_2           | MERGE           | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_2                                                                                                 |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | where_filter_1                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where c.age=35 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a,c & on and b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                        |
      | dn3_0//dn4_0      | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` > 2000 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                         |
      | order_1           | ORDER           | join_1                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                          |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC           |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 ORDER BY `c`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a,c & on or b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0//dn4_0      | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` > 2000 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                     |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35                                                                   |
      | dn2_1             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35                                                                   |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0//dn4_0      | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC       |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | order_2           | ORDER           | where_filter_1                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or c.age=35 order by a.name | schema1 |
    # ab, bc: shardingTable, globalTable diff node & inner join & inner join & no ER & where a or b or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or b.deptid=3 or c.age>20 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0//dn4_0      | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC       |
      | dn2_1             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` ORDER BY `c`.`name` ASC       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | order_2           | ORDER           | where_filter_1                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or b.deptid=3 or c.age>20 order by a.name | schema1 |


  @delete_mysql_tables
  Scenario: check useJoinStrategy - singleTable + shardingTable + shardingTable #3
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2'], 'mysql':['schema1']}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseJoinStrategy=true
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="Employee_1" shardingNode="dn1" />
        <singleTable name="Employee_2" shardingNode="dn3" />
        <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Info" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <shardingTable name="Level" shardingNode="dn1,dn2" function="hash-two" shardingColumn="levelid" />
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
    Then restart dble in "dble-1" success
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1;drop table if exists Employee_2                                                        | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1;drop table if exists Employee_2                                                        | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |

     #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                             |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                   |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_2; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | order_2           | ORDER           | join_2                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |
     #ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                   |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | order_2           | ORDER           | join_2                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |


    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where a => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn1_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_2             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_2; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 order by a.name | schema1 |
    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where b.deptid=2 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` order by `a`.`name` ASC             |
      | merge_1           | MERGE           | dn1_0                                                                                                               |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                            |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                              |
      | order_1           | ORDER           | where_filter_1                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                             |
      | dn1_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                    |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                    |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_2; dn2_1                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                   |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                    |
      | order_2           | ORDER           | join_2                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where b.deptid=2 order by a.name | schema1 |
    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                   |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` order by `a`.`name` ASC                     |
      | merge_1           | MERGE           | dn1_0                                                                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                     |
      | dn1_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_2; dn2_1                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                            |
      | order_2           | ORDER           | join_2                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where c.salary=15000 order by a.name | schema1 |
    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where a,b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                         |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                           |
      | order_1           | ORDER           | where_filter_1                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                          |
      | dn1_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                 |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                 |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_2; dn2_1                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 order by a.name | schema1 |
    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where a,c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn1_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_1             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_1; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_2             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                      |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_2; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where b.deptid=2 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                   |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` order by `a`.`name` ASC                     |
      | merge_1           | MERGE           | dn1_0                                                                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC         |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                    |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                      |
      | order_1           | ORDER           | where_filter_1                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                     |
      | dn1_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_2; dn2_1                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                            |
      | order_2           | ORDER           | join_2                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where b.deptid=2 and c.salary=15000 order by a.name | schema1 |
    #ab, ac: singleTable, shardingTable same node & left join & inner join & no ER & where a,b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                        |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn1_0                                                                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_0                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                         |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                           |
      | order_1           | ORDER           | where_filter_1                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                          |
      | dn1_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC      |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_2; dn2_1                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 and b.deptid=2 and c.salary=15000 order by a.name | schema1 |


    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a & on and b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                        |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                         |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                           |
      | order_1           | ORDER           | where_filter_1                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                          |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                 |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                 |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a & on or b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a & on and c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary>10000 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` > 10000 ORDER BY `c`.`levelname` ASC                                      |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` > 10000 ORDER BY `c`.`levelname` ASC                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary>10000 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a & on or c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or c.salary>10000 where a.empid=3401 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c`                                                                                              |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or c.salary>10000 where a.empid=3401 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a,c & on and b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                        |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                         |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                           |
      | order_1           | ORDER           | where_filter_1                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                          |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC      |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000 ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a,c & on or b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or b.deptid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, globalTable diff node & left join & inner join & no ER & where a,c & on and c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                    |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where  ( `c`.`salary` = 15000 AND `c`.`levelid` > 1) ORDER BY `c`.`levelname` ASC            |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where  ( `c`.`salary` = 15000 AND `c`.`levelid` > 1) ORDER BY `c`.`levelname` ASC            |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | order_2           | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a,c & on or c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                        |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 3401 order by `a`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1       | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                |
      | join_1            | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | dn2_1             | BASE SQL              | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 15000                                                                   |
      | merge_2           | MERGE                 | dn1_1; dn2_1                                                                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                 |
      | where_filter_1    | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname or c.levelid>1 where a.empid=3401 and c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 or c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                   |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | order_2           | ORDER           | where_filter_1                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager left join Level c on a.level=c.levelname where a.empid=3401 or c.salary=15000 order by a.name | schema1 |
    # ab, ac: singleTable, shardingTable diff node & left join & inner join & no ER & where a or b or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 or b.deptid=2 or c.salary=15000 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                   |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                |
      | order_1           | ORDER           | join_1                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn1_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_1             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                       |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                  |
      | order_2           | ORDER           | where_filter_1                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a LEFT JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname where a.empid=3401 or b.deptid=2 or c.salary=15000 order by a.name | schema1 |


  @delete_mysql_tables @skip
  Scenario: check useJoinStrategy - singleTable + singleTable + globalTable #4
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2'], 'mysql-master2': ['db1', 'db2'], 'mysql':['schema1']}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseJoinStrategy=true
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <singleTable name="Employee_1" shardingNode="dn2" />
        <singleTable name="Employee_2" shardingNode="dn3" />
        <singleTable name="Dept" shardingNode="dn1" />
        <globalTable name="Info" shardingNode="dn1,dn2" />
        <globalTable name="Level" shardingNode="dn1,dn2" />
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
    Then restart dble in "dble-1" success
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1; drop table if exists Employee_2                                                      | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | drop table if exists Employee_1; drop table if exists Employee_2                                                       | success | schema1 |
      | conn_0 | False   | drop table if exists Dept;drop table if exists Level;drop table if exists Info                                         | success | schema1 |
      | conn_0 | False   | create table Employee_1 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Employee_2 (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | insert into Employee_1 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Employee_2 values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |

     #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                               |
      | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn2_0                                                                                                   |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2         | MERGE         | dn1_0                                                                                                   |
      | join_1          | JOIN          | merge_1; merge_2                                                                                        |
      | order_1         | ORDER         | join_1                                                                                                  |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                 |
      | dn1_1//dn2_1    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC       |
      | merge_3         | MERGE         | dn1_1//dn2_1                                                                                            |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                |
      | order_2         | ORDER         | join_2                                                                                                  |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1 |
    #ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & no where => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1      | SQL/REF-2                                                                                                 |
      | dn3_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn3_0                                                                                                   |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2         | MERGE         | dn1_0                                                                                                   |
      | join_1          | JOIN          | merge_1; merge_2                                                                                        |
      | order_1         | ORDER         | join_1                                                                                                  |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                 |
      | dn1_1//dn2_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC       |
      | merge_3         | MERGE         | dn1_1//dn2_0                                                                                            |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                |
      | order_2         | ORDER         | join_2                                                                                                  |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name order by a.name | schema1 |


     #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where a => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                 |
      | dn2_0           | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn2_0                                                                                                                                                            |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1         | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1//dn2_1    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                                                |
      | merge_3         | MERGE                 | dn1_1//dn2_1                                                                                                                                                     |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                         |
      | order_2         | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3 | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 order by a.name | schema1 |
     #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where b => table a nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                               |
      | dn1_0           | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC                                                      |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                    |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                                  |
      | dn2_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2         | MERGE                 | dn2_0                                                                                                                                                                    |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                  |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                             |
      | order_1         | ORDER                 | join_1                                                                                                                                                                   |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                  |
      | dn1_1//dn2_1    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                                                        |
      | merge_3         | MERGE                 | dn1_1//dn2_1                                                                                                                                                             |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                                 |
      | order_2         | ORDER                 | join_2                                                                                                                                                                   |
      | shuffle_field_3 | SHUFFLE_FIELD         | order_2                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 order by a.name | schema1 |
     #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where c => no nestLoop
      Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
        | conn   | toClose | sql                                                         | db |
        | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where c.age=35 order by a.name | schema1|
      Then check resultset "rs_1" has lines with following column values
        | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                              |
        | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` order by `a`.`name` ASC                |
        | merge_1         | MERGE         | dn2_0                                                                                                                  |
        | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                           |
        | merge_2         | MERGE         | dn1_0                                                                                                                  |
        | join_1          | JOIN          | merge_1; merge_2                                                                                                       |
        | order_1         | ORDER         | join_1                                                                                                                 |
        | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                                |
        | dn2_1//dn1_1    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 order by `c`.`name` ASC |
        | merge_3         | MERGE         | dn2_1//dn1_1                                                                                                           |
        | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                               |
        | order_2         | ORDER         | join_2                                                                                                                 |
        | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                                |
      Then execute sql in "dble-1" and the result should be consistent with mysql
        | conn    | toClose  | sql | db  |
        | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where c.age=35 order by a.name | schema1 |
     #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where a,b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                        |
      | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn2_0                                                                                                                            |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC              |
      | merge_2         | MERGE         | dn1_0                                                                                                                            |
      | join_1          | JOIN          | merge_1; merge_2                                                                                                                 |
      | order_1         | ORDER         | join_1                                                                                                                           |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                                          |
      | dn2_1//dn1_1    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                |
      | merge_3         | MERGE         | dn2_1//dn1_1                                                                                                                     |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                                         |
      | order_2         | ORDER         | join_2                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 order by a.name | schema1 |
    #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where a,c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn2_0           | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn2_0                                                                                                                                                            |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1         | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn2_1//dn1_1    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 order by `c`.`name` ASC                                           |
      | merge_3         | MERGE                 | dn2_1//dn1_1                                                                                                                                                     |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                         |
      | order_2         | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3 | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and c.age=35 order by a.name | schema1 |
    #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where b,c => table a nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                            |
      | dn1_0           | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC                                                      |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                    |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                                  |
      | dn2_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2         | MERGE                 | dn2_0                                                                                                                                                                    |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                  |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                             |
      | order_1         | ORDER                 | join_1                                                                                                                                                                   |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                  |
      | dn2_1//dn1_1    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 order by `c`.`name` ASC                                                   |
      | merge_3         | MERGE                 | dn2_1//dn1_1                                                                                                                                                             |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                                 |
      | order_2         | ORDER                 | join_2                                                                                                                                                                   |
      | shuffle_field_3 | SHUFFLE_FIELD         | order_2                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where b.deptid=3 and c.age=35 order by a.name | schema1 |
    #ab, bc: singleTable, globalTable same node & inner join & inner join & no ER & where a,b,c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                        |
      | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_1` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn2_0                                                                                                                            |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC              |
      | merge_2         | MERGE         | dn1_0                                                                                                                            |
      | join_1          | JOIN          | merge_1; merge_2                                                                                                                 |
      | order_1         | ORDER         | join_1                                                                                                                           |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                                          |
      | dn1_1//dn2_1    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 order by `c`.`name` ASC           |
      | merge_3         | MERGE         | dn1_1//dn2_1                                                                                                                     |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                                         |
      | order_2         | ORDER         | join_2                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_1 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=2202 and b.deptid=3 and c.age=35 order by a.name | schema1 |


    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a & on and c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.age>20 where a.empid=2202 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                              |
      | dn3_0           | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | order_1         | ORDER                 | join_1                                                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                          |
      | dn1_1//dn2_0    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` > 20 order by `c`.`name` ASC                                           |
      | merge_3         | MERGE                 | dn1_1//dn2_0                                                                                                                                                     |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                         |
      | order_2         | ORDER                 | join_2                                                                                                                                                           |
      | shuffle_field_3 | SHUFFLE_FIELD         | order_2                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.age>20 where a.empid=2202 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a & on or c => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or c.age>20 where a.empid=2202 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0           | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` = 2202 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1//dn2_0    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                        |
      | merge_3         | MERGE                 | dn1_1//dn2_0                                                                                                                                                     |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                         |
      | where_filter_1  | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3 | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or c.age>20 where a.empid=2202 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where b & on and a => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid>1000 where b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                        |
      | dn3_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` > 1000 order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn3_0                                                                                                                            |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC              |
      | merge_2         | MERGE         | dn1_0                                                                                                                            |
      | join_1          | JOIN          | merge_1; merge_2                                                                                                                 |
      | order_1         | ORDER         | join_1                                                                                                                           |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                                          |
      | dn1_1//dn2_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                |
      | merge_3         | MERGE         | dn1_1//dn2_0                                                                                                                     |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                                         |
      | order_2         | ORDER         | join_2                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid>1000 where b.deptid=3 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a & on or a => table a nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or a.empid>1000 where b.deptid=3 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                               |
      | dn1_0           | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC                                                      |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                    |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                                  |
      | dn3_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2         | MERGE                 | dn3_0                                                                                                                                                                    |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                  |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                             |
      | shuffle_field_2 | SHUFFLE_FIELD         | join_1                                                                                                                                                                   |
      | dn1_1//dn2_0    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                |
      | merge_3         | MERGE                 | dn1_1//dn2_0                                                                                                                                                             |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                                 |
      | where_filter_1  | WHERE_FILTER          | join_2                                                                                                                                                                   |
      | shuffle_field_3 | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or a.empid>1000 where b.deptid=3 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where c & on and b => table a nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where c.age=35 order by a.name | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                            |
      | dn1_0           | BASE SQL              | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 order by `b`.`manager` ASC                                                      |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                    |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                                  |
      | dn3_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2         | MERGE                 | dn3_0                                                                                                                                                                    |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                  |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                             |
      | order_1         | ORDER                 | join_1                                                                                                                                                                   |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                  |
      | dn1_1//dn2_0    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 order by `c`.`name` ASC                                                   |
      | merge_3         | MERGE                 | dn1_1//dn2_0                                                                                                                                                             |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                                 |
      | order_2         | ORDER                 | join_2                                                                                                                                                                   |
      | shuffle_field_3 | SHUFFLE_FIELD         | order_2                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where c.age=35 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where c & on or b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where c.age=35 order by a.name | schema1|
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                               |
      | dn3_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn3_0                                                                                                   |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2         | MERGE         | dn1_0                                                                                                   |
      | join_1          | JOIN          | merge_1; merge_2                                                                                        |
      | shuffle_field_1 | SHUFFLE_FIELD | join_1                                                                                                  |
      | dn1_1//dn2_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35          |
      | merge_3         | MERGE         | dn1_1//dn2_0                                                                                            |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                |
      | where_filter_1  | WHERE_FILTER  | join_2                                                                                                  |
      | shuffle_field_2 | SHUFFLE_FIELD | where_filter_1                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where c.age=35 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a,c & on and b => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                        |
      | dn3_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` > 2000 order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn3_0                                                                                                                            |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` > 1 order by `b`.`manager` ASC              |
      | merge_2         | MERGE         | dn1_0                                                                                                                            |
      | join_1          | JOIN          | merge_1; merge_2                                                                                                                 |
      | order_1         | ORDER         | join_1                                                                                                                           |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                                          |
      | dn1_1//dn2_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35 order by `c`.`name` ASC           |
      | merge_3         | MERGE         | dn1_1//dn2_0                                                                                                                     |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                                         |
      | order_2         | ORDER         | join_2                                                                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a,c & on or b => table b nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2                                                                                                                                                        |
      | dn3_0           | BASE SQL              | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` where `a`.`empid` > 2000 order by `a`.`name` ASC                                 |
      | merge_1         | MERGE                 | dn3_0                                                                                                                                                            |
      | nest_loop_1     | NEST_LOOP             | merge_1                                                                                                                                                          |
      | dn1_0           | BASE SQL(May No Need) | nest_loop_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_2         | MERGE                 | dn1_0                                                                                                                                                            |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_2                                                                                                                                                          |
      | join_1          | JOIN                  | nest_loop_1; shuffle_field_1                                                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD         | join_1                                                                                                                                                           |
      | dn1_1//dn2_0    | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`age` = 35                                                                   |
      | merge_3         | MERGE                 | dn1_1//dn2_0                                                                                                                                                     |
      | join_2          | JOIN                  | shuffle_field_2; merge_3                                                                                                                                         |
      | where_filter_1  | WHERE_FILTER          | join_2                                                                                                                                                           |
      | shuffle_field_3 | SHUFFLE_FIELD         | where_filter_1                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name or b.deptid>1 where a.empid>2000 and c.age=35 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or c.age=35 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                               |
      | dn3_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn3_0                                                                                                   |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2         | MERGE         | dn1_0                                                                                                   |
      | join_1          | JOIN          | merge_1; merge_2                                                                                        |
      | order_1         | ORDER         | join_1                                                                                                  |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                 |
      | dn1_1//dn2_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC       |
      | merge_3         | MERGE         | dn1_1//dn2_0                                                                                            |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                |
      | where_filter_1  | WHERE_FILTER  | join_2                                                                                                  |
      | order_2         | ORDER         | where_filter_1                                                                                          |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or c.age=35 order by a.name | schema1 |
    # ab, bc: singleTable, globalTable diff node & inner join & inner join & no ER & where a or b or c => no nestLoop
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                         | db |
      | conn_0 | false   | explain SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or b.deptid=3 or c.age>20 order by a.name | schema1|
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                               |
      | dn3_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee_2` `a` order by `a`.`name` ASC |
      | merge_1         | MERGE         | dn3_0                                                                                                   |
      | dn1_0           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC            |
      | merge_2         | MERGE         | dn1_0                                                                                                   |
      | join_1          | JOIN          | merge_1; merge_2                                                                                        |
      | order_1         | ORDER         | join_1                                                                                                  |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                                 |
      | dn1_1//dn2_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC       |
      | merge_3         | MERGE         | dn1_1//dn2_0                                                                                            |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                                |
      | where_filter_1  | WHERE_FILTER  | join_2                                                                                                  |
      | order_2         | ORDER         | where_filter_1                                                                                          |
      | shuffle_field_2 | SHUFFLE_FIELD | order_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql | db  |
      | conn_0  | true     | SELECT * FROM Employee_2 a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name where a.empid=3401 or b.deptid=3 or c.age>20 order by a.name | schema1 |