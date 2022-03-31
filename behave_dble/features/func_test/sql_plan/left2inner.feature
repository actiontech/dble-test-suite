# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2022/2/15

  #http://10.186.18.11/jira/browse/DBLE0REQ-1473

Feature: test hint with left2inner/right2inner
  #use two different types of table to test hint with left2inner, reason is in line 180, including Scenario#1 and Scenario#2
  #Sampling some cases combined with other hints for testing, including Scenario#3
  #test with left2inner/right2inner combine with -DuseNewJoinOptimizer Scenario#4

  Scenario: use shardingTale to test part of hint with left2inner/right2inner to achieve left/right join transform to inner join, verify query plan and resultSet   #1

    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Level" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="levelid"/>
        </schema>

        <function name="func_hashString" class="StringHash">
            <property name="partitionCount">2</property>
            <property name="partitionLength">1</property>
            <property name="hashSlice">0:2</property>
        </function>
       """
    Given execute admin cmd "reload @@config_all" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                                        | db       | expect |
      | conn_0 | false    | drop table if exists Employee                                                                                                                              | schema1  | success|
      | conn_0 | false    | drop table if exists Dept                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Info                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Level                                                                                                                                 | schema1  | success|
      | conn_0 | false    | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | schema1  | success|
      | conn_0 | false    | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                              | schema1  | success|
      | conn_0 | false    | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                     | schema1  | success|
      | conn_0 | false    | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8      | schema1  | success|
      | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
      | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success|
      | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
      | conn_0 | true     | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1| success|

    #one left join appeared in main sql transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select b.deptname from Employee a left join Dept b on a.deptname=b.deptname order by a.name | schema1|
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1        | SQL/REF-2                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                            |

    #more than one left join appeared in main sql transform to inner join
    #has known issue:http://10.186.18.11/jira/browse/DBLE0REQ-1691 , but not confluence result
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                                                                                                                     | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select b.deptname from Employee a left join Dept b on a.deptname=b.deptname left join Info c on a.deptname=c.deptname order by a.name | schema1|
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                              |
      | dn3_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                      |

    #right join appeared in main sql transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                                                                               | db     |
      | conn_1 | false   | explain /*!dble:plan=$right2inner*/select b.deptname from Dept b right join Employee a on a.deptname=b.deptname order by a.name   | schema1|
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn3_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                            |

    #left join & inner join appeared in main sql transform to inner join
    #has known issue:http://10.186.18.11/jira/browse/DBLE0REQ-1691 , but not confluence result
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                                                                                                                         | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/SELECT b.deptname FROM Employee a INNER JOIN Info c on a.deptname=c.deptname LEFT JOIN Dept b on a.deptname= b.deptname order by a.name   | schema1|
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1        | SQL/REF-2                                                                                                                                                                                                |
      | dn3_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `b`.`deptname`,`a`.`name` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                      |

    #right join & inner join appeared in main sql transform to inner join
    #has known issue:http://10.186.18.11/jira/browse/DBLE0REQ-1691 , but not confluence result
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                                                                                                                      | db     |
      | conn_1 | false   | explain /*!dble:plan=$right2inner*/SELECT a.name FROM Employee a INNER JOIN Info c on a.deptname=c.deptname RIGHT JOIN Dept b on a.deptname= b.deptname order by a.name  | schema1|
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1        | SQL/REF-2                                                                                                                                                                                 |
      | dn3_0             | BASE SQL        | select `a`.`name` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                       |

    #left join & right join & inner join appeared in main sql transform to inner join
    #has known issue:http://10.186.18.11/jira/browse/DBLE0REQ-1691 , but not confluence result
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                                                                                                                              | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner$right2inner*/ SELECT b.deptname FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname RIGHT JOIN Info d on a.deptname=d.deptname order by a.name  | schema1|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1        | SQL/REF-2                                                                                                                                                                                                             |
      | dn3_0             | BASE SQL        | select `b`.`deptname`,`a`.`level`,`a`.`name` from  (  `Employee` `a` join  `Info` `d` on `a`.`deptname` = `d`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `b`.`deptname`,`a`.`level`,`a`.`name` from  (  `Employee` `a` join  `Info` `d` on `a`.`deptname` = `d`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                   |
      | dn1_0             | BASE SQL        | select `c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                               |
      | dn2_0             | BASE SQL        | select `c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                               |
      | dn3_1             | BASE SQL        | select `c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                                                    |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                             |

    #left join & right join & inner join appeared in main sql  but only left join transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_G"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/ SELECT b.deptname FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname RIGHT JOIN Info d on a.deptname=d.deptname order by a.name   | schema1|
    Then check resultset "rs_G" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1        | SQL/REF-2                                                                                                                                                                                                         |
      | dn3_0             | BASE SQL        | select `d`.`deptname` from  `Info` `d` ORDER BY `d`.`deptname` ASC                                                                                                                                              |
      | dn4_0             | BASE SQL        | select `d`.`deptname` from  `Info` `d` ORDER BY `d`.`deptname` ASC                                                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                               |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                                               |
      | dn1_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
      | dn2_0             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
      | dn3_2             | BASE SQL        | select `c`.`levelname`,`c`.`levelid`,`c`.`salary` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                                |
      | merge_and_order_3 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_2                                                                                                                                                                                             |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                                                                                                               |
      | join_2            | JOIN            | shuffle_field_3; shuffle_field_5                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD   | join_2                                                                                                                                                                                                          |
      | order_2           | ORDER           | shuffle_field_4                                                                                                                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; order_2                                                                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                         |


    #left join appeared in from subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_H"
      | conn   | toClose | sql                                                                                                                                        | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from (select a.name,b.deptname from Employee a left join Dept b on a.deptname=b.deptname) as c  | schema1|
    Then check resultset "rs_H" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                            |
      | dn3_0                      | BASE SQL                 | select `a`.`name`,`b`.`deptname` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  |
      | dn4_0                      | BASE SQL                 | select `a`.`name`,`b`.`deptname` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  |
      | merge_1                    | MERGE                    | dn3_0; dn4_0                                                                                                         |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_1                                                                                                              |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_1                                                                                                      |
      | shuffle_field_2            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                           |

    # make sure result is right after transform to inner join
    Then execute sql in "dble-1" in "user" mode
      | conn     | toClose | sql                                                                                                                                                               | expect      |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select b.deptname from Employee a left join Dept b on a.deptname=b.deptname order by a.name                                             | length{(7)} |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select b.deptname from Employee a left join Dept b on a.deptname=b.deptname left join Info c on a.deptname=c.deptname order by a.name   | length{(13)}|
      | conn_1   | false   | /*!dble:plan=$right2inner*/select b.deptname from Dept b right join Employee a on a.deptname=b.deptname order by a.name                                           | length{(7)} |
      | conn_1   | false   | /*!dble:plan=$left2inner*/SELECT b.deptname FROM Employee a INNER JOIN Info c on a.deptname=c.deptname LEFT JOIN Dept b on a.deptname= b.deptname order by a.name | length{(13)}|
      | conn_1   | false   | /*!dble:plan=$right2inner*/SELECT a.name FROM Employee a INNER JOIN Info c on a.deptname=c.deptname RIGHT JOIN Dept b on a.deptname= b.deptname order by a.name   | length{(13)}|
      | conn_1   | false   | /*!dble:plan=$left2inner$right2inner*/ SELECT b.deptname FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname RIGHT JOIN Info d on a.deptname=d.deptname order by a.name| length{(13)} |
      | conn_1   | false   | /*!dble:plan=$left2inner*/ SELECT b.deptname FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname RIGHT JOIN Info d on a.deptname=d.deptname order by a.name            | length{(15)} |
      | conn_1   | true    | /*!dble:plan=$left2inner*/select * from (select a.name,b.deptname from Employee a left join Dept b on a.deptname=b.deptname) as c                                                                                      |  length{(7)} |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                  | db       | expect |
      | conn_2 | false    | drop table if exists Employee        | schema1  | success|
      | conn_2 | false    | drop table if exists Dept            | schema1  | success|
      | conn_2 | false    | drop table if exists Info            | schema1  | success|
      | conn_2 | true     | drop table if exists Level           | schema1  | success|

    # Why change to use singleTable?
    # Some types of subqueries are inconvenient to know the correctness of the transformation from the query plan and results
    # Use singleTable can make sure all sql sent to one node, and that will be convenient to know the correctness of the transformation from the query plan
  Scenario: use singleTable to test another part of hint with left2inner/right2inner to achieve left/right join transform to inner join, verify query plan and resultSet   #2
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <singleTable name="Employee" shardingNode="dn1"/>
            <singleTable name="Dept" shardingNode="dn1" />
            <singleTable name="Info" shardingNode="dn1" />
            <singleTable name="Level" shardingNode="dn1" />
        </schema>
       """
    Given execute admin cmd "reload @@config_all" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                                        | db       | expect |
      | conn_0 | false    | drop table if exists Employee                                                                                                                              | schema1  | success|
      | conn_0 | false    | drop table if exists Dept                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Info                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Level                                                                                                                                 | schema1  | success|
      | conn_0 | false    | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | schema1  | success|
      | conn_0 | false    | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                              | schema1  | success|
      | conn_0 | false    | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                     | schema1  | success|
      | conn_0 | false    | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8      | schema1  | success|
      | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
      | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success|
      | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
      | conn_0 | true     | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1| success|

    #left join appeared in on subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                                                                                                                                                 | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from Employee a left join Dept b on (select c.deptname from Employee c left join Info d on c.deptname=d.deptname where c.empid=7021)=b.deptname  | schema1|
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1    | SQL/REF-2                                                                                                                                                                                                                                                         |
      | dn1                        | BASE SQL  | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on ( SELECT c.deptname FROM Employee c  INNER JOIN Info d ON c.deptname = d.deptname WHERE c.empid = 7021 ) = b.deptname |

    #left join appeared in in subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                                                                                                             | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select deptname from Employee where deptname in (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) | schema1|
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                     |
      | dn1              | BASE SQL | select `Employee`.`deptname` from  `Employee` where `Employee`.`deptname` in (select  distinct `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname`) |

     #left join appeared in order by subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                                                                                                                | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from Employee order by (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.empid=7012) | schema1|
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                                                 |
      | dn1           | BASE SQL | select `Employee`.`name`,`Employee`.`empid`,`Employee`.`deptname`,`Employee`.`level` from  `Employee` order by (select `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`empid` = 7012 limit 0,2) ASC |

    #left join appeared in group by having subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                                                                                                                                  | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select deptname,count(*) from Employee group by deptname having deptname in (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.empid=1257)  | schema1|
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1              | BASE SQL |  select `Employee`.`deptname`,count(*) as `count(*)` from  `Employee` where `Employee`.`deptname` in (select  distinct `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`empid` = 1257) GROUP BY `Employee`.`deptname` ASC order by `Employee`.`deptname` ASC  |

    #left join appeared in group by subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                                                                                                                                  | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select deptname,count(*) from Employee group by (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.empid=1257)  | schema1|
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1              | BASE SQL | select `Employee`.`deptname`,count(*) from  `Employee` GROUP BY (select `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`empid` = 1257 limit 0,2) ASC |

    #left join appeared in any subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from Employee where Employee.deptname=any(select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) order by Employee.deptname  | schema1|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1              | BASE SQL | select `Employee`.`name`,`Employee`.`empid`,`Employee`.`deptname`,`Employee`.`level` from  `Employee` where `Employee`.`deptname` in (select  distinct `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname`) order by `Employee`.`deptname` ASC |

    #left join appeared in some subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_G"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from Employee where Employee.deptname=some(select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) order by Employee.deptname  | schema1|
    Then check resultset "rs_G" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1           | BASE SQL | select `Employee`.`name`,`Employee`.`empid`,`Employee`.`deptname`,`Employee`.`level` from  `Employee` where `Employee`.`deptname` in (select  distinct `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname`) order by `Employee`.`deptname` ASC |

    #left join appeared in all subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_H"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from Employee where Employee.deptname=all(select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) order by Employee.deptname  | schema1|
    Then check resultset "rs_H" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1              | BASE SQL | select `Employee`.`name`,`Employee`.`empid`,`Employee`.`deptname`,`Employee`.`level` from  `Employee` where `Employee`.`deptname`= all (select `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname`) order by `Employee`.`deptname` ASC |

    #left join appeared in exists subquery transform to inner join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_I"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/select * from Employee where exists (select b.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.name='LiLi')                       | schema1|
    Then check resultset "rs_I" has lines with following column values
      | SHARDING_NODE-0  | TYPE-1   | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1              | BASE SQL | select `Employee`.`name`,`Employee`.`empid`,`Employee`.`deptname`,`Employee`.`level` from  `Employee` where  exists (select `b`.`deptname` as `autoalias_scalar`,1 as `1` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`name` = 'LiLi' limit 0,1) |

    #check result
    Then execute sql in "dble-1" in "user" mode
      | conn     | toClose | sql                                                                                                                                                                                         | expect        |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select * from Employee a left join Dept b on (select c.deptname from Employee c left join Info d on c.deptname=d.deptname where c.empid=7021)=b.deptname          | length{(0)}   |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select deptname from Employee where deptname in (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname)                                     | equal{(('Finance',),('Finance',),('Finance',),('Sales',),('Sales',),('Market',),('Market',))}   |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select * from Employee order by (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.empid=7012)                                  | equal{(('Harry', 3415, 'Finance', 'P7'), ('Sally', 2242, 'Sales', 'P7'), ('George', 3401, 'Finance', 'P8'), ('Harriet', 2202, 'Sales', 'P8'), ('Mary', 1257, 'Human Resources', 'P7'), ('LiLi', 9527, 'Human Resources', 'P9'), ('Tom', 7012, 'Market', 'P9'), ('Tony', 3052, 'Market', 'P10'), ('Jessi', 7948, 'Finance', 'P8'))}   |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select deptname,count(*) from Employee group by deptname having deptname in (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.empid=1257) | length{0}  |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select deptname,count(*) from Employee group by (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.empid=1257)                  | equal{(('Finance', 9),)}|
      | conn_1   | false   | /*!dble:plan=$left2inner*/select * from Employee where Employee.deptname=any(select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) order by Employee.deptname        | equal{(('Harry', 3415, 'Finance', 'P7'), ('Jessi', 7948, 'Finance', 'P8'), ('George', 3401, 'Finance', 'P8'), ('Tony', 3052, 'Market', 'P10'), ('Tom', 7012, 'Market', 'P9'), ('Harriet', 2202, 'Sales', 'P8'), ('Sally', 2242, 'Sales', 'P7'))}|
      | conn_1   | false   | /*!dble:plan=$left2inner*/select * from Employee where Employee.deptname=some(select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) order by Employee.deptname       | equal{(('Harry', 3415, 'Finance', 'P7'), ('Jessi', 7948, 'Finance', 'P8'), ('George', 3401, 'Finance', 'P8'), ('Tony', 3052, 'Market', 'P10'), ('Tom', 7012, 'Market', 'P9'), ('Harriet', 2202, 'Sales', 'P8'), ('Sally', 2242, 'Sales', 'P7'))}|
      | conn_1   | false   | /*!dble:plan=$left2inner*/select * from Employee where Employee.deptname=all(select a.deptname from Employee a left join Dept b on a.deptname=b.deptname) order by Employee.deptname        | length{(0)} |
      | conn_1   | false   | /*!dble:plan=$left2inner*/select * from Employee where exists (select b.deptname from Employee a left join Dept b on a.deptname=b.deptname where a.name='LiLi')                             | length{(0)} |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                 | db       | expect |
      | conn_1 | false    | drop table if exists Employee       | schema1  | success|
      | conn_1 | false    | drop table if exists Dept           | schema1  | success|
      | conn_1 | false    | drop table if exists Info           | schema1  | success|
      | conn_1 | true     | drop table if exists Level          | schema1  | success|


  Scenario: Sampling some cases combined with other hints for testing      #3
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Level" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="levelid"/>
        </schema>

        <function name="func_hashString" class="StringHash">
            <property name="partitionCount">2</property>
            <property name="partitionLength">1</property>
            <property name="hashSlice">0:2</property>
        </function>
       """
    Given execute admin cmd "reload @@config_all" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                                        | db       | expect |
      | conn_0 | false    | drop table if exists Employee                                                                                                                              | schema1  | success|
      | conn_0 | false    | drop table if exists Dept                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Info                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Level                                                                                                                                 | schema1  | success|
      | conn_0 | false    | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | schema1  | success|
      | conn_0 | false    | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                              | schema1  | success|
      | conn_0 | false    | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                     | schema1  | success|
      | conn_0 | false    | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8      | schema1  | success|
      | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
      | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success|
      | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
      | conn_0 | true     | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1| success|

    #left2inner & in2join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   |explain /*!dble:plan=$left2inner$in2join*/select deptname from Employee where deptname in (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname)                        | schema1|
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                                                    |
      | dn3_0                      | BASE SQL                 | select `Employee`.`deptname` from  `Employee` ORDER BY `Employee`.`deptname` ASC                                                         |
      | dn4_0                      | BASE SQL                 | select `Employee`.`deptname` from  `Employee` ORDER BY `Employee`.`deptname` ASC                                                         |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn3_0; dn4_0                                                                                                                             |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                                        |
      | dn3_1                      | BASE SQL                 | select DISTINCT `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  |
      | dn4_1                      | BASE SQL                 | select DISTINCT `a`.`deptname` as `autoalias_scalar` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  |
      | merge_1                    | MERGE                    | dn3_1; dn4_1                                                                                                                             |
      | distinct_1                 | DISTINCT                 | merge_1                                                                                                                                  |
      | shuffle_field_3            | SHUFFLE_FIELD            | distinct_1                                                                                                                               |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                          |
      | order_1                    | ORDER                    | rename_derived_sub_query_1                                                                                                               |
      | shuffle_field_4            | SHUFFLE_FIELD            | order_1                                                                                                                                  |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_4                                                                                                         |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                                   |


    #left2inner & in2join
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                                                                                                                                                                                    | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner$in2join*/select b.deptname from Employee a left join Dept b on a.deptname=b.deptname where b.deptname in (select d.deptname from Employee c left join Info d on c.deptname=d.deptname) order by a.name| schema1|
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                                                            |
      | dn3_0                      | BASE SQL                 | select `b`.`deptname`,`a`.`name` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`deptname` ASC                                |
      | dn4_0                      | BASE SQL                 | select `b`.`deptname`,`a`.`name` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `b`.`deptname` ASC                                |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn3_0; dn4_0                                                                                                                                                         |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                                                                    |
      | dn3_1                      | BASE SQL                 | select DISTINCT `d`.`deptname` as `autoalias_scalar` from  `Employee` `c` join  `Info` `d` on `c`.`deptname` = `d`.`deptname` where 1=1  ORDER BY `d`.`deptname` ASC |
      | dn4_1                      | BASE SQL                 | select DISTINCT `d`.`deptname` as `autoalias_scalar` from  `Employee` `c` join  `Info` `d` on `c`.`deptname` = `d`.`deptname` where 1=1  ORDER BY `d`.`deptname` ASC |
      | merge_and_order_2          | MERGE_AND_ORDER          | dn3_1; dn4_1                                                                                                                                                         |
      | distinct_1                 | DISTINCT                 | merge_and_order_2                                                                                                                                                    |
      | shuffle_field_3            | SHUFFLE_FIELD            | distinct_1                                                                                                                                                           |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                                                      |
      | shuffle_field_4            | SHUFFLE_FIELD            | rename_derived_sub_query_1                                                                                                                                           |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_4                                                                                                                                     |
      | order_1                    | ORDER                    | join_1                                                                                                                                                               |
      | shuffle_field_2            | SHUFFLE_FIELD            | order_1                                                                                                                                                              |


    # left2inner & one ER 【rule A】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                                                                                                                                                  | db     |
      | conn_1 | false   | explain /*!dble:plan=(c,b)&a$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on c.deptname= b.deptname order by a.name   | schema1|
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `c`.`name` ASC               |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `c`.`name` ASC               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |


    #left2inner & three ER 【rule A】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                                                                                                                                                                            | db     |
      | conn_1 | false   | explain /*!dble:plan=(c,a,b)$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name                      | schema1|
    Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |


    #left2inner & no ER 【rule A】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=c&b&a$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name | schema1|
    Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                 |
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


    #left2inner & two ER & and condition is related to the first two tables   【rule B、C、D】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=(b,a,c)$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname  LEFT JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.Name                     | schema1|
    Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                      |
      | dn3_0             | BASE SQL        | select `a`.`Name`,`a`.`deptname`,`b`.`Manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`Name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`Name`,`a`.`deptname`,`b`.`Manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`Name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |


    #left2inner & no ER & and condition is not related to the first two tables 【rule B、C、D】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_G"
      | conn   | toClose | sql                                                                                                                                                                                                                                         | db     |
      | conn_1 | false   | explain /*!dble:plan=(c\|a)&b$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager  LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.Name                     | schema1|
    Then check resultset "rs_G" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn1_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
      | dn2_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0; dn3_0                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_0                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_1                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |


    #left2inner & three ER  【Undirected graph】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_H"
      | conn   | toClose | sql                                                                                                                                                                                                                                                     | db     |
      | conn_1 | false   | explain /*!dble:plan=(a,c,b)$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name                     | schema1|
    Then check resultset "rs_H" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                              |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC//select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` and `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                      |

     #left2inner & no ER   【Undirected graph】
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_I"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db     |
      | conn_1 | false   | explain /*!dble:plan=b&a&c$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name                     | schema1|
    Then check resultset "rs_I" has lines with following column values
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

    #check result
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                                                                                                             |   db   | expect |
      | conn_1 | false    | /*!dble:plan=$left2inner$in2join*/select deptname from Employee where deptname in (select a.deptname from Employee a left join Dept b on a.deptname=b.deptname)                                                                 | schema1| equal{(('Finance',), ('Finance',), ('Finance',), ('Sales',), ('Sales',), ('Market',), ('Market',))}|
      | conn_1 | false    |/*!dble:plan=$left2inner$in2join*/select b.deptname from Employee a left join Dept b on a.deptname=b.deptname where b.deptname in (select d.deptname from Employee c left join Info d on c.deptname=d.deptname ) order by a.name | schema1| equal{(('Finance',), ('Finance',), ('Finance',), ('Sales',), ('Sales',))}|
      | conn_1 | false    | /*!dble:plan=(c,b)&a$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN Dept b on c.deptname= b.deptname order by a.name                                      | schema1| equal{(('George', 'Finance', 'George', 'UK'), ('Harriet', 'Sales', 'Harriet', 'Japan'), ('Harry', 'Finance', 'George', 'China'), ('Jessi', 'Finance', 'George', 'Krean'), ('Sally', 'Sales', 'Harriet', 'USA'))}|
      | conn_1 | false    | /*!dble:plan=(c,a,b)$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name                               | schema1| equal{(('George', 'Finance', 'George', 'Krean'), ('George', 'Finance', 'George', 'UK'), ('George', 'Finance', 'George', 'China'), ('Harriet', 'Sales', 'Harriet', 'USA'), ('Harriet', 'Sales', 'Harriet', 'Japan'), ('Harry', 'Finance', 'George', 'Krean'), ('Harry', 'Finance', 'George', 'UK'), ('Harry', 'Finance', 'George', 'China'), ('Jessi', 'Finance', 'George', 'Krean'), ('Jessi', 'Finance', 'George', 'UK'), ('Jessi', 'Finance', 'George', 'China'), ('Sally', 'Sales', 'Harriet', 'Japan'), ('Sally', 'Sales', 'Harriet', 'USA'))}|
      | conn_1 | false    | /*!dble:plan=c&b&a$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Info c ON b.manager=c.name ORDER BY a.name                                           | schema1| equal{(('George', 'Finance', 'George', 'UK'), ('Harriet', 'Sales', 'Harriet', 'Japan'))}|
      | conn_1 | false    | /*!dble:plan=(b,a,c)$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname  LEFT JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.Name               | schema1| equal{(('George', 'Finance', 'George', 'UK'), ('George', 'Finance', 'George', 'Krean'), ('George', 'Finance', 'George', 'China'), ('Harry', 'Finance', 'George', 'UK'), ('Harry', 'Finance', 'George', 'Krean'), ('Harry', 'Finance', 'George', 'China'), ('Jessi', 'Finance', 'George', 'Krean'), ('Jessi', 'Finance', 'George', 'China'), ('Jessi', 'Finance', 'George', 'UK'))}|
      | conn_1 | false    | /*!dble:plan=(c\|a)&b$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager  LEFT JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.Name                 | schema1| length{0}|
      | conn_1 | false    | /*!dble:plan=(a,c,b)$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.deptname=c.deptname and b.deptname=c.deptname order by a.name     | schema1| equal{(('George', 'Finance', 'George', 'Krean'), ('George', 'Finance', 'George', 'UK'), ('George', 'Finance', 'George', 'China'), ('Harriet', 'Sales', 'Harriet', 'USA'), ('Harriet', 'Sales', 'Harriet', 'Japan'), ('Harry', 'Finance', 'George', 'Krean'), ('Harry', 'Finance', 'George', 'UK'), ('Harry', 'Finance', 'George', 'China'), ('Jessi', 'Finance', 'George', 'Krean'), ('Jessi', 'Finance', 'George', 'UK'), ('Jessi', 'Finance', 'George', 'China'), ('Sally', 'Sales', 'Harriet', 'Japan'), ('Sally', 'Sales', 'Harriet', 'USA'))}|
      | conn_1 | false    | /*!dble:plan=b&a&c$left2inner*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name                         | schema1| equal{(('George', 'Finance', 'George', 'UK'), ('Harriet', 'Sales', 'Harriet', 'Japan'))}|

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                 | db       | expect |
      | conn_1 | false    | drop table if exists Employee       | schema1  | success|
      | conn_1 | false    | drop table if exists Dept           | schema1  | success|
      | conn_1 | false    | drop table if exists Info           | schema1  | success|
      | conn_1 | true     | drop table if exists Level          | schema1  | success|


  Scenario: test with useNewJoinOptimizer=true, left join transform to inner join may lead to other possibilities of query plan  #4

    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
        $a  -DuseNewJoinOptimizer=true
      """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname"/>
            <shardingTable name="Level" shardingNode="dn1,dn2,dn3" function="hash-three" shardingColumn="levelid"/>
        </schema>

        <function name="func_hashString" class="StringHash">
            <property name="partitionCount">2</property>
            <property name="partitionLength">1</property>
            <property name="hashSlice">0:2</property>
        </function>
       """
    Given Restart dble in "dble-1" success

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                                        | db       | expect |
      | conn_0 | false    | drop table if exists Employee                                                                                                                              | schema1  | success|
      | conn_0 | false    | drop table if exists Dept                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Info                                                                                                                                  | schema1  | success|
      | conn_0 | false    | drop table if exists Level                                                                                                                                 | schema1  | success|
      | conn_0 | false    | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8 | schema1  | success|
      | conn_0 | false    | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                              | schema1  | success|
      | conn_0 | false    | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                     | schema1  | success|
      | conn_0 | false    | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8      | schema1  | success|
      | conn_0 | false    | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success|
      | conn_0 | false    | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success|
      | conn_0 | false    | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success|
      | conn_0 | true     | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1| success|

    # base on : rule A
    # left2inner & two ER, query plan not change, without left2inner inner join should execute firstly
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_A"
      | conn   | toClose | sql                                                                                                                                                                                        | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname order by a.name  | schema1|
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                            |
      | dn3_0             | BASE SQL        | select `a`.`Name`,`a`.`deptname`,`b`.`Manager` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`Name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`Name`,`a`.`deptname`,`b`.`Manager` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`Name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                    |

    # base on : rule A
    # left2inner & no ER, query plan not change, without left2inner inner join should execute firstly
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_B"
      | conn   | toClose | sql                                                                                                                                                                                           | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name  | schema1|
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                            |
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
      | dn1_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn2_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | dn3_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC        |
      | merge_and_order_3 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_2                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                         |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                          |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |

    # base on : rule B、C、D
    # left2inner & one ER, ER firstly, without left2inner query plan should not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_C"
      | conn   | toClose | sql                                                                                                                                                                                                                      | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000  order by a.Name   | schema1|
    Then check resultset "rs_C" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                       |
      | dn1_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                           |
      | dn2_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                           |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                        |
      | order_1           | ORDER           | join_1                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                 |

    # base on : rule B、C、D
    # left2inner & one ER, ER firstly and "and" can be can be extrapolated as "where", without left2inner will not extrapolated as "where"
   Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_D"
      | conn   | toClose | sql                                                                                                                                                                                                                 | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.deptname= b.deptname order by a.name| schema1|
   Then check resultset "rs_D" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                     |
      | dn1_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                    |
      | dn2_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                    |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_0; dn2_0; dn3_1                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                      |
      | order_1           | ORDER           | join_1                                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                               |

   #base on : undirected graph
   # left2inner & one ER, ER firstly, without left2inner query plan should not change
   Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_E"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db     |
      | conn_1 | false   | explain /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager left JOIN Info c on a.deptname = c.deptname and b.Manager=c.Name order by a.Name | schema1|
   Then check resultset "rs_E" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`c`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                    |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                                   |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                                   |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                               |

   #base on : undirected graph
   # left2inner & two ER, root node change, without left2inner root node should not change
   Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_F"
      | conn   | toClose | sql                                                                                                                                                                                                                              | db     |
      | conn_1 | false   |explain /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname = b.deptname LEFT JOIN Info c on  a.deptname=c.deptname and b.deptname=c.deptname order by a.Name  | schema1|
   Then check resultset "rs_F" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                              |
      | dn3_0             | BASE SQL        | select `a`.`Name`,`a`.`deptname`,`c`.`country`,`b`.`Manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`Name` ASC// select `a`.`Name`,`a`.`deptname`,`b`.`Manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` and `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`Name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`Name`,`a`.`deptname`,`c`.`country`,`b`.`Manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` and `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`Name` ASC// select `a`.`Name`,`a`.`deptname`,`b`.`Manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` and `c`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`Name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                      |

    #check result
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                                                                                                                      |   db   | expect |
      | conn_1 | false    | /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager FROM Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname order by a.name                                        | schema1|equal{(('George', 'Finance', 'George'), ('George', 'Finance', 'George'), ('George', 'Finance', 'George'), ('Harriet', 'Sales', 'Harriet'), ('Harriet', 'Sales', 'Harriet'), ('Harry', 'Finance', 'George'), ('Harry', 'Finance', 'George'), ('Harry', 'Finance', 'George'), ('Jessi', 'Finance', 'George'), ('Jessi', 'Finance', 'George'), ('Jessi', 'Finance', 'George'), ('Sally', 'Sales', 'Harriet'), ('Sally', 'Sales', 'Harriet'))}|
      | conn_1 | false    | /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name                                     | schema1|equal{(('George', 'Finance', 'George', 15000), ('Harriet', 'Sales', 'Harriet', 15000), ('Tom', 'Market', 'Tom', 20000))}|
      | conn_1 | false    | /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname LEFT JOIN Dept b on a.deptname= b.deptname and c.salary=10000  order by a.Name           | schema1|equal{(('Harry', 'Finance', 'George', 10000), ('Sally', 'Sales', 'Harriet', 10000))}|
      | conn_1 | false    | /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.deptname= b.deptname order by a.name             | schema1|equal{(('Sally', 'Sales', 'Harriet', 10000),)}|
      | conn_1 | false    | /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager left JOIN Info c on a.deptname = c.deptname and b.Manager=c.Name order by a.Name            | schema1|equal{(('George', 'Finance', 'George', 'UK'), ('Harriet', 'Sales', 'Harriet', 'Japan'))}|
      | conn_1 | false    | /*!dble:plan=$left2inner*/SELECT a.Name,a.deptname,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname = b.deptname LEFT JOIN Info c on  a.deptname=c.deptname and b.deptname=c.deptname order by a.Name | schema1|equal{(('George', 'Finance', 'George', 'Krean'), ('George', 'Finance', 'George', 'UK'), ('George', 'Finance', 'George', 'China'), ('Harriet', 'Sales', 'Harriet', 'Japan'), ('Harriet', 'Sales', 'Harriet', 'USA'), ('Harry', 'Finance', 'George', 'Krean'), ('Harry', 'Finance', 'George', 'UK'), ('Harry', 'Finance', 'George', 'China'), ('Jessi', 'Finance', 'George', 'Krean'), ('Jessi', 'Finance', 'George', 'UK'), ('Jessi', 'Finance', 'George', 'China'), ('Sally', 'Sales', 'Harriet', 'USA'), ('Sally', 'Sales', 'Harriet', 'Japan'))}|

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                 | db       | expect |
      | conn_1 | false    | drop table if exists Employee       | schema1  | success|
      | conn_1 | false    | drop table if exists Dept           | schema1  | success|
      | conn_1 | false    | drop table if exists Info           | schema1  | success|
      | conn_1 | true     | drop table if exists Level          | schema1  | success|