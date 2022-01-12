# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/12/15
# more information find in confluence: http://10.186.18.11/confluence/pages/viewpage.action?pageId=32064447
# jira: http://10.186.18.11/jira/browse/DBLE0REQ-1469

Feature: set useNewJoinOptimizer=true check join order

  @delete_mysql_tables
  Scenario: shardingTable + shardingTable + singleTable #1
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseNewJoinOptimizer=true
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
        <singleTable name="Info" shardingNode="dn4" />
        <singleTable name="Level" shardingNode="dn5" />
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
      | conn_0 | False   | create database if not exists schema1                                                                                  | success | schema1 |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info           | success | schema1 |
      | conn_0 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info           | success | schema1 |
      | conn_1 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |

    # rule A : left join & left join : a left join c & left join er b on ab => er first, a left join er b & left join c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                     |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                         | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # http://10.186.18.11/jira/browse/DBLE0REQ-1532
    # rule A : left join & left join : a left join b & left join single c on ac & no er => single table first, a left join single c & left join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | schema1 |

    # rule A : left join & left join : a left join b & left join single c on bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on c.deptname=b.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                     | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on c.deptname=b.deptname order by a.Name | schema1 |

    # rule A : left join & left join : left join & left join subquery er => er first, left join subquery er & left join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                   |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                                    |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & inner join : a inner join single c & left join er b => er first, left join er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                     |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & inner join : a left join single c & inner join er b => er first, inner join er & left join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & inner join : a left join b & inner join single c on ac & no er => inner join first, a inner join single c & left join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                     | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |

    # rule A : left join & inner join : a inner join b & left join single c on ac & no er => single first, left join single & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                     | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | schema1 |

    # rule A : left join & inner join : a left join b & inner join single c on bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | schema1 |

    # rule A : left join & inner join : inner join & left join subquery er => er first, left join subquery er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                   |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                                    |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                           | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | schema1 |

    # rule A : inner join & inner join : inner join & inner join er => er first, inner join er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                           | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : inner join & inner join : a inner join b & inner join single c on ac & no er => single first, a inner join single c & inner join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |

    # rule A : inner join & inner join : a inner join b & inner join single c on bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                       | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | schema1 |

    # rule A : inner join & inner join : inner join & inner join subquery er => er first, inner join subquery er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                              |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                               |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                       |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | schema1 |

    # rule A : cross join & left join : cross join & left join er => er first, left join er & cross join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.deptname=b.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                   |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                                                           |
      | merge_1           | MERGE           | dn4_0                                                                                                                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                  | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.deptname=b.deptname order by a.Name | schema1 |

    # rule A : cross join & left join : a cross join c & left join b on ab & no er => left join first, a left join b & cross join c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                             |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |

    # rule A : cross join & left join : a cross join c & left join b on bc & no er => c left join b & cross join a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_2                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                  | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on b.deptname=c.deptname order by a.Name | schema1 |

    # rule A : cross join & inner join : cross join & inner join er => er first, inner join er & cross join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                           | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                                                      |
      | merge_1           | MERGE           | dn4_0                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                   | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname order by a.Name | schema1 |

    # rule A : cross join & inner join : a cross join c & inner join b on ab & no er => inner join first, a inner join b & cross join c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                      | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.Name=b.Manager order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                             |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |

    # rule A : cross join & inner join : a cross join c & inner join b on bc & no er => c inner join b & cross join a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                           | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_2                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                   | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on b.deptname=c.deptname order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join c & left join b er and b => a left join b er and b & left join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid =2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                      |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                         | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid =2 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join c & left join b er and c => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join b & left join single c and c & no er => a left join single c where c & left join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC |
      | merge_1           | MERGE           | dn5_0                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                       | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join b & left join single c and b & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC      |
      | merge_1           | MERGE           | dn5_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                   | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join b & left join single c on bc and a & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |

    # rule B C D : left join & left join : a left join single c left join subquery er b and b => a left join subquery er b and b left join single c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname=b.deptname and b.deptid =2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                    |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                                                     |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                                                |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname and b.deptid =2 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a left join single c inner join er b and c => a inner join b left join single c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                     |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                          |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a inner join single c left join er b and c => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a inner join single c left join er b and b => a left join er b and b inner join single c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                      |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                           | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and b.deptid=2 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a left join b inner join c and b & no er => a inner join c left join b where b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                    |
      | merge_1           | MERGE           | dn5_0                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                    |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | where_filter_1                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                    | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : left join & inner join : a inner join b left join c and b & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC      |
      | merge_1           | MERGE           | dn5_0                                                                                                 |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                    | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : left join & inner join : a inner join b left join single c and c => single first, a left join single c and c inner join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC |
      | merge_1           | MERGE           | dn5_0                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |

    # rule B C D : left join & inner join : a left join c inner join subquery er b and c => a inner join subquery er b left join c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                              |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                                                                                    |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                       |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                                                                                         |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                                | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : inner join & inner join : a inner join b inner join single c and b => a inner join single c inner join b where b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                    |
      | merge_1           | MERGE           | dn5_0                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : inner join & inner join : a inner join c inner join er b and c => a inner join er b inner join c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                     |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                 | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.name | schema1 |

    # rule B C D : inner join & inner join : a inner join c inner join er b and b => a inner join er b inner join c where b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                           |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                            |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname= b.deptname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : inner join & inner join : a inner join c inner join subquery er b and c => a inner join subquery er b inner join c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                              |
      | dn5_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                                                                                    |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                       |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                                 | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.name | schema1 |

    # other : inner join & inner join : a inner join c inner join er b and bc => er first,  b inner join a inner join c where bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                                                 |
      | merge_1           | MERGE           | dn4_0                                                                                                                                                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join b inner join c and bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.Name=c.Name and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC            |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                 |
      | order_1           | ORDER           | join_1                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                          |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn4_0                                                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.Name=c.Name and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join c inner join subquery er b and bc => subquery er first, subquery b inner join a inner join c where bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN (select * from Dept) b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                               |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                                                                                                                |
      | merge_1           | MERGE           | dn4_0                                                                                                                                                                                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN (select * from Dept) b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join c inner join er b on ab and bc => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                   |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                   |
      | merge_1           | MERGE           | dn1_0; dn2_0                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_1                                                                                                         |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                       |
      | merge_2           | MERGE           | dn4_0                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_2                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                         |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_1                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                |
      | order_2           | ORDER           | join_2                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join b inner join c on ac and bc => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN  Info c on a.Name=c.Name and b.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                        |
      | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                        |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                                                         |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                              |
      | dn1_1           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                    |
      | dn2_1           | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                    |
      | merge_2         | MERGE         | dn1_1; dn2_1                                                                                                         |
      | shuffle_field_4 | SHUFFLE_FIELD | merge_2                                                                                                              |
      | join_1          | JOIN          | shuffle_field_1; shuffle_field_4                                                                                     |
      | order_1         | ORDER         | join_1                                                                                                               |
      | shuffle_field_2 | SHUFFLE_FIELD | order_1                                                                                                              |
      | dn4_0           | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_3         | MERGE         | dn4_0                                                                                                                |
      | join_2          | JOIN          | shuffle_field_2; merge_3                                                                                             |
      | shuffle_field_3 | SHUFFLE_FIELD | join_2                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN  Info c on a.Name=c.Name and b.deptname=c.deptname order by a.name | schema1 |

    # other : inner join & inner join : a inner join c inner join b on b => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn4_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                             |
      | merge_1           | MERGE           | dn4_0                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2              |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2              |
      | merge_2           | MERGE           | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_2                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on b.deptid=2 order by a.Name | schema1 |

  @delete_mysql_tables
  Scenario: shardingTable + shardingTable + globalTable #2
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    $a -DuseNewJoinOptimizer=true
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
    Then restart dble in "dble-1" success
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_0 | False   | create database if not exists schema1                                                                                  | success | schema1 |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info           | success | schema1 |
      | conn_0 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_0 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info           | success | schema1 |
      | conn_1 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8 | success | schema1 |
      | conn_1 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_1 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                 | success | schema1 |
      | conn_1 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                  | success | schema1 |
      | conn_1 | False   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance') | success | schema1 |

    # rule A : left join & left join : a left join c & left join er b => er first, a left join er b & left join c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                     |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & left join : a left join b & left join global c & no er => global table first, a left join global c & left join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                       | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | schema1 |

    # rule A : left join & left join : a left join b & left join global c on bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on c.deptname=b.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                         | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on c.deptname=b.deptname order by a.Name | schema1 |

    # rule A : left join & left join : left join & left join subquery er => er first, left join subquery er & left join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                   |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                                    |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & inner join : a inner join global c & left join er b => er first, left join er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                     |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & inner join : a left join global c & inner join er b => er first, inner join er & left join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : left join & inner join : a left join b & inner join global c on ac & no er => global first, a inner join global c & left join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |

    # rule A : left join & inner join : a inner join b & left join global c on ac & no er => global first, left join global & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname order by a.Name | schema1 |

    # rule A : left join & inner join : a left join b & inner join global c on bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | schema1 |

    # rule A : left join & inner join : inner join & left join subquery er => er first, left join subquery er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                   |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                                    |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | schema1 |

    # rule A : inner join & inner join : inner join & inner join er => er first, inner join er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname order by a.name | schema1 |

    # rule A : inner join & inner join : a inner join b & inner join global c on ac & no er => global first, a inner join global c & inner join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                         | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |

    # rule A : inner join & inner join : a inner join b & inner join global c on bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                           | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on b.deptname=c.deptname order by a.Name | schema1 |

    # rule A : inner join & inner join : inner join & inner join subquery er => er first, inner join subquery er & inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                              |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                               |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                       |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                               | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname= b.deptname order by a.name | schema1 |

    # rule A : cross join & left join : cross join & left join er => er first, left join er & cross join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.deptname=b.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                   |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                                                           |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.deptname=b.deptname order by a.Name | schema1 |

    # rule A : cross join & left join : a cross join c & left join b on ab & no er => left join first, a left join b & cross join c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                             |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                 | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |

    # rule A : cross join & left join : a cross join c & left join b on bc & no er => c left join b & cross join a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_2                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c LEFT JOIN Dept b on b.deptname=c.deptname order by a.Name | schema1 |

    # rule A : cross join & inner join : cross join & inner join er => er first, inner join er & cross join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                              |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                                                                                                                      |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname order by a.Name | schema1 |

    # rule A : cross join & inner join : a cross join c & inner join b on ab & no er => inner join first, a inner join b & cross join c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.Name=b.Manager order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                             |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                  | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |

    # rule A : cross join & inner join : a cross join c & inner join b on bc & no er => c inner join b & cross join a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on b.deptname=c.deptname order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_2                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                       | db      |
      | conn_1  | true     | SELECT * FROM Employee a CROSS JOIN Info c INNER JOIN Dept b on b.deptname=c.deptname order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join c & left join b er and b => er first, a left join b er and b & left join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid =2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                      |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid =2 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join c & left join b er and c => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join b & left join global c and c & no er => a left join global c where c & left join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                 | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join b & left join single c and b & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                     | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC      |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                             | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.Name | schema1 |

    # rule B C D : left join & left join : a left join b & left join global c on bc and a & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager LEFT JOIN Info c on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |

    # rule B C D : left join & left join : a left join global c left join subquery er b and b => a left join subquery er b and b left join global c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname=b.deptname and b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                    |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                                                                                     |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                                             |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                            | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept) b on a.deptname= b.deptname and b.deptid=2 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a left join global c inner join er b and c => a inner join b left join global c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                     |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                          |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                 | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a inner join global c left join er b and c => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                       |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                 | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a inner join global c left join er b and b => a left join er b where b inner join global c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname=b.deptname and b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and b.deptid = 2 where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                     |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                                      |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                              |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and b.deptid=2 order by a.Name | schema1 |

    # rule B C D : left join & inner join : a left join b inner join global c and b & no er => global first, a inner join c left join b where b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                    |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                    |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | where_filter_1                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                       | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : left join & inner join : a inner join b left join c and b => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC          |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                               |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC      |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                              |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                       | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : left join & inner join : a inner join b left join global c and c => global first, a left join global c where c inner join b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                           |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                     |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                           | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |

    # rule B C D : left join & inner join : a left join c inner join subquery er b and c => a inner join subquery er b left join c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                                        | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                              |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                                                                                    |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                       |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                                                                                                                                                                                         |
      | order_1           | ORDER           | where_filter_1                                                                                                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                                                | db      |
      | conn_1  | true     | SELECT * FROM Employee a LEFT JOIN Level c on a.Level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.Name | schema1 |

    # rule B C D : inner join & inner join : a inner join b inner join global c and b & no er => global first, a inner join global c inner join b where b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                    |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : inner join & inner join : a inner join c inner join er b and c => a inner join er b inner join c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                     |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and c.salary=10000 order by a.name | schema1 |

    # rule B C D : inner join & inner join : a inner join c inner join er b and b => a inner join er b inner join c where b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                           |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                                            |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                          | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=2 order by a.name | schema1 |

    # rule B C D : inner join & inner join : a inner join c inner join subquery er b and c => a inner join subquery er b inner join c where c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                                                         | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                              |
      | /*AllowDiff*/dn5_0| BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC                                                                                                                                                    |
      | merge_1           | MERGE           | /*AllowDiff*/dn5_0                                                                                                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                       |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                              | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Level c on a.level=c.levelname INNER JOIN (select * from Dept) b on a.deptname=b.deptname and c.salary=10000 order by a.name | schema1 |

    # other : inner join & inner join : a inner join c inner join er b and bc => er first,  b inner join a inner join c where bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                                                 |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                         | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join b inner join c and bc & no er => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.Name=c.Name and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC            |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                     |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                 |
      | order_1           | ORDER           | join_1                                                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                          |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                    | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.Name=c.Name and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join c inner join subquery er b and bc => subquery er first, subquery b inner join a inner join c where bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN (select * from Dept) b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager`,`a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from (select `Dept`.`deptname`,`Dept`.`deptid`,`Dept`.`manager` from  `Dept`) b join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                               |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                                                                                                                |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                                                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                                                         | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c on a.Name=c.Name INNER JOIN (select * from Dept) b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join c inner join er b on ab and bc => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                   |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                   |
      | merge_1           | MERGE           | dn1_0; dn2_0                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_1                                                                                                         |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                                       |
      | merge_2           | MERGE           | /*AllowDiff*/dn4_0                                                                                              |
      | join_1            | JOIN            | shuffle_field_1; merge_2                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                         |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_1                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                                |
      | order_2           | ORDER           | join_2                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on a.deptname=b.deptname and b.Manager=c.Name order by a.Name | schema1 |

    # other : inner join & inner join : a inner join b inner join c on ac and bc => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN  Info c on a.Name=c.Name and b.deptname=c.deptname order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0             | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                        |
      | dn2_0             | BASE SQL      | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                                        |
      | merge_1           | MERGE         | dn1_0; dn2_0                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD | merge_1                                                                                                              |
      | dn1_1             | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                    |
      | dn2_1             | BASE SQL      | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b`                                                    |
      | merge_2           | MERGE         | dn1_1; dn2_1                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD | merge_2                                                                                                              |
      | join_1            | JOIN          | shuffle_field_1; shuffle_field_4                                                                                     |
      | order_1           | ORDER         | join_1                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD | order_1                                                                                                              |
      | /*AllowDiff*/dn4_0| BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_3           | MERGE         | /*AllowDiff*/dn4_0                                                                                                   |
      | join_2            | JOIN          | shuffle_field_2; merge_3                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD | join_2                                                                                                               |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                      | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Dept b INNER JOIN  Info c on a.Name=c.Name and b.deptname=c.deptname order by a.name | schema1 |

    # other : inner join & inner join : a inner join c inner join b on b => not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                | expect  | db      |
      | conn_1 | False   | explain SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on b.deptid=2 order by a.Name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | /*AllowDiff*/dn4_0| BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c`                             |
      | merge_1           | MERGE           | /*AllowDiff*/dn4_0                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2              |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2              |
      | merge_2           | MERGE           | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_2                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_4                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                        | db      |
      | conn_1  | true     | SELECT * FROM Employee a INNER JOIN Info c INNER JOIN Dept b on b.deptid=2 order by a.Name | schema1 |
