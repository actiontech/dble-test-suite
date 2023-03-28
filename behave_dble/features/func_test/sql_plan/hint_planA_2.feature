# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2022/3/8
Feature: test with hint plan A with other table type

  @delete_mysql_tables
  Scenario: GlobalTable  + Sharding  +  Sharding                              #1
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3','db4'], 'mysql-master2': ['db1', 'db2', 'db3','db4'], 'mysql':['schema1']}}
    """

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
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "mysql"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_0 | False   | create database if not exists schema1                                                                                                                                                                                                                                                                                                               | success | schema1 |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info;drop table if exists FamilyInfo                                                                                                                                                                                                        | success | schema1 |
      | conn_0 | False   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                          | success | schema1 |
      | conn_0 | False   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                                                       | success | schema1 |
      | conn_0 | False   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                                                              | success | schema1 |
      | conn_0 | False   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                               | success | schema1 |
      | conn_0 | false   | create table FamilyInfo(name varchar(25) not null, housetype varchar(250) not null, familynum int not null)engine=innodb charset=utf8                                                                                                                                                                                                               | success | schema1 |
      | conn_0 | true    | insert into FamilyInfo values('Harry', 'department', 3),('George', 'department', 5), ('Harriet', 'villa', 6), ('Mary', 'villa', 8), ('LiLi', 'Self-built house', 10), ('Tom', 'department', 2)                                                                                                                                                      | success | schema1 |
      | conn_0 | False   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8'),('George' ,'9999' ,'Market','P9') | success | schema1 |
      | conn_0 | False   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                                                              | success | schema1 |
      | conn_0 | False   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                                                               | success | schema1 |
      | conn_0 | True    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                                                             | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info;drop table if exists FamilyInfo                                                                                                                                                                                                        | success | schema1 |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                          | success | schema1 |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                                                       | success | schema1 |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                                                              | success | schema1 |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                               | success | schema1 |
      | conn_0 | false   | create table FamilyInfo(name varchar(25) not null, housetype varchar(250) not null, familynum int not null)engine=innodb charset=utf8                                                                                                                                                                                                               | success | schema1 |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8'),('George' ,'9999' ,'Market','P9') | success | schema1 |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                                                              | success | schema1 |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                                                               | success | schema1 |
      | conn_0 | false   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                                                             | success | schema1 |
      | conn_0 | true    | insert into FamilyInfo values('Harry', 'department', 3),('George', 'department', 5), ('Harriet', 'villa', 6), ('Mary', 'villa', 8), ('LiLi', 'Self-built house', 10), ('Tom', 'department', 2)                                                                                                                                                      | success | schema1 |

    # GlobalTable + shardingTable + GlobalTable
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                  | db      |
      | conn_1 | false   | explain /*!dble:plan= c & a & b  */ select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                                                                           |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`levelname`,`b`.`levelid`,`b`.`salary` from  `Level` `b` where `b`.`levelid` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`levelid` ASC     |
      | merge_2           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                                |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= c & a & b  */ select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name | schema1 |


     # GlobalTable + GlobalTable + shardingTable
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                      | db      |
      | conn_1 | false   | explain /*!dble:plan= c & d & b  */ select * from Info c left join Level d on c.age=d.levelid inner join Dept b on c.deptname=b.deptname order by c.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                               |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`age` ASC                                                                                        |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                 |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` where `d`.`levelid` in ('{NEED_TO_REPLACE}') ORDER BY `d`.`levelid` ASC |
      | merge_2           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                            |
      | join_1            | JOIN                  | shuffle_field_1; merge_2                                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                 |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                                        |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                 |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                              | db      |
      | conn_1 | true    | /*#dble:plan= c & d & b  */ select * from Info c left join Level d on c.age=d.levelid inner join Dept b on c.deptname=b.deptname order by c.name | schema1 |



     # GlobalTable + shardingTable + shardingTable \|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                          | db      |
      | conn_1 | false   | explain /*!dble:plan= c \| a \| b  */ select *  from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname order by a.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC     |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                          |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                              |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                               |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= c \| a \| b  */ select *  from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname order by a.name | schema1 |

     # GlobalTable + GlobalTable + GlobalTable
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                       | db      |
      | conn_1 | false   | explain /*!dble:plan= c \| d \| e  */ select *  from Info c left join Level d on c.age=d.levelid inner join FamilyInfo e on c.name=e.name order by c.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                        |
      | dn3_0//dn4_0    | BASE SQL      | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`age` ASC |
      | merge_1         | MERGE         | dn3_0//dn4_0                                                                                     |
      | dn5_0//dn6_0    | BASE SQL      | select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` order by `d`.`levelid` ASC   |
      | merge_2         | MERGE         | dn5_0//dn6_0                                                                                     |
      | join_1          | JOIN          | merge_1; merge_2                                                                                 |
      | order_1         | ORDER         | join_1                                                                                           |
      | shuffle_field_1 | SHUFFLE_FIELD | order_1                                                                                          |
      | dn7_0//dn8_0    | BASE SQL      | select `e`.`name`,`e`.`housetype`,`e`.`familynum` from  `FamilyInfo` `e` order by `e`.`name` ASC |
      | merge_3         | MERGE         | dn7_0//dn8_0                                                                                     |
      | join_2          | JOIN          | shuffle_field_1; merge_3                                                                         |
      | shuffle_field_2 | SHUFFLE_FIELD | join_2                                                                                           |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                               | db      |
      | conn_1 | true    | /*#dble:plan= c \| d \| e  */ select *  from Info c left join Level d on c.age=d.levelid inner join FamilyInfo e on c.name=e.name order by c.name | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema1" sqlMaxLimit="100">
        <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
        <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
        <singleTable name="Info" shardingNode="dn3" />
        <singleTable name="Level" shardingNode="dn4" />
        <singleTable name="FamilyInfo" shardingNode="dn5" />
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
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | expect  | db      |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info;drop table if exists FamilyInfo                                                                                                                                                                      | success | schema1 |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | success | schema1 |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | success | schema1 |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | success | schema1 |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | success | schema1 |
      | conn_0 | false   | create table FamilyInfo(name varchar(25) not null, housetype varchar(250) not null, familynum int not null)engine=innodb charset=utf8                                                                                                                                                                             | success | schema1 |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | success | schema1 |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | success | schema1 |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | success | schema1 |
      | conn_0 | false   | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | success | schema1 |
      | conn_0 | true    | insert into FamilyInfo values('Harry', 'department', 3),('George', 'department', 5), ('Harriet', 'villa', 6), ('Mary', 'villa', 8), ('LiLi', 'Self-built house', 10), ('Tom', 'department', 2)                                                                                                                    | success | schema1 |


    # singleTable + shardingTable + singleTable
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                  | db      |
      | conn_1 | false   | explain /*!dble:plan= c & a & b  */ select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                                                                           |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`levelname`,`b`.`levelid`,`b`.`salary` from  `Level` `b` where `b`.`levelid` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`levelid` ASC     |
      | merge_2           | MERGE                 | dn4_0                                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= c & a & b  */ select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name | schema1 |


     # singleTable + singleTable + shardingTable
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                      | db      |
      | conn_1 | false   | explain /*!dble:plan= c & d & b  */ select * from Info c left join Level d on c.age=d.levelid inner join Dept b on c.deptname=b.deptname order by c.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                               |
      | dn3_0             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`age` ASC                                                                                        |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                 |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname`,`d`.`levelid`,`d`.`salary` from  `Level` `d` where `d`.`levelid` in ('{NEED_TO_REPLACE}') ORDER BY `d`.`levelid` ASC |
      | merge_2           | MERGE                 | dn4_0                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                 |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                        |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                 |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` where `b`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                        |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                 |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                              | db      |
      | conn_1 | true    | /*#dble:plan= c & d & b  */ select * from Info c left join Level d on c.age=d.levelid inner join Dept b on c.deptname=b.deptname order by c.name | schema1 |



     # singleTable + shardingTable + shardingTable \|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                          | db      |
      | conn_1 | false   | explain /*!dble:plan= c \| a \| b  */ select *  from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname order by a.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                             |
      | dn3_0             | BASE SQL        | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC     |
      | merge_1           | MERGE           | dn3_0                                                                                                 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                     |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                              |
      | order_1           | ORDER           | join_1                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                               |
      | dn1_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | dn2_1             | BASE SQL        | select `b`.`deptname`,`b`.`deptid`,`b`.`manager` from  `Dept` `b` ORDER BY `b`.`deptname` ASC         |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                     |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                      |
      | order_2           | ORDER           | join_2                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                               |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                  | db      |
      | conn_1 | true    | /*#dble:plan= c \| a \| b  */ select *  from Info c left join Employee a on c.name=a.name inner join Dept b on c.deptname=b.deptname order by a.name | schema1 |



     # singleTable + singleTable + singleTable
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs"
      | conn   | toClose | sql                                                                                                                                                  | db      |
      | conn_1 | false   | explain /*!dble:plan= c & a & b  */ select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name | schema1 |
    Then check resultset "rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC                                                                                           |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`levelname`,`b`.`levelid`,`b`.`salary` from  `Level` `b` where `b`.`levelid` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`levelid` ASC     |
      | merge_2           | MERGE                 | dn4_0                                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= c & a & b  */ select *  from Info c left join Employee a on c.name=a.name left join Level b on c.age=b.levelid order by a.name | schema1 |