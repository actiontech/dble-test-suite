# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/2/10

# DBLE0REQ-1470, DBLE0REQ-1471, DBLE0REQ-1472
Feature: test hint

  @delete_mysql_tables
  Scenario: rule B, C, D -> shardingTable + shardingTable + shardingTable -> inner join & inner join #1
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
        <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
        <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
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
    Given execute admin cmd "reload @@config_all" success
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

    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # (a, b, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (b, a, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=b \| (a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and c
    # (a, b, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # (b, a, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name   | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=b \| (a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # 1 ER ab -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # (a, b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC       |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC       |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (a, b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # (b, a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC       |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC       |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (b, a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      #| dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager`,`b`.`deptid` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      #| dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager`,`b`.`deptid` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=a \| (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end

      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=b \| (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      # http://10.186.18.11/jira/browse/DBLE0REQ-1641 end

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # 1 ER ab -> a INNER JOIN b on a=b INNER JOIN c on a=c and c
    # (a, b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (a, b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # (b, a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`level` ASC                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (b, a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=a \| (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check table b & condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end

      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=b \| (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table b & condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # no ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC   |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC   |
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
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (a & b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # a & (b | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                          |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                          |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (a | b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                                       |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                                       |
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
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=a \| b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                          |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                          |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # a | c | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
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
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC    |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC    |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (a & c) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # a & (c | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                             |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (a | c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                 |
      | dn4_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                             |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # a & c & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # b | a | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC   |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC   |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
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
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (b & a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # b | (a & c)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (b | a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                                       |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                                       |
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
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=b \| a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # b & a & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                                         |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # c | a | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | dn4_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC         |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                          |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                          |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                           |
      | order_1           | ORDER           | join_1                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                    |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC    |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC    |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                          |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (c & a) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # c | (a & b)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (c | a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                         |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                             |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # c & a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                 |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`level` ASC  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=a & (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=a \| (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636
      #| conn_1  | False    | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=b \| (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & condition |

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition |

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # no ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and c
    # a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                     |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                             |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                              |
      | order_1           | ORDER           | join_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                       |
      | dn3_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                              |
      | order_2           | ORDER           | join_2                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (a & b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # a & (b | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                    |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (a | b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                           |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                     |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=a \| b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # a | c | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                    |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                    |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                             |
      | dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                              |
      | order_1           | ORDER           | join_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                       |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (a & c) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # a & (c | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                     |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (a | c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
      | dn4_1             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
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
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # a & c & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                                                 |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # b | a | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                             |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                     |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                              |
      | order_1           | ORDER           | join_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                       |
      | dn3_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                              |
      | order_2           | ORDER           | join_2                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (b & a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # b | (a & c)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (b | a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                           |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                    |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=b \| a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # b & a & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                           |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                          |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                            |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                            |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # c | a | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | dn4_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                             |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                    |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                    |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                              |
      | order_1           | ORDER           | join_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                       |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                              |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                  |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                             |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (c & a) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # c | (a & b)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (c | a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                             |
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
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # c & a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                     |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 ORDER BY `c`.`levelname` ASC                                                                     |
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
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=a & (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=a \| (b, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636
      #| conn_1  | False    | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=b \| (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (a, c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table c & condition |

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name | schema1 | hint explain build failures! check table b & condition |

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and c.salary=10000 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # 2 ER -> a INNER JOIN c on a=c INNER JOIN b on b=c and a
    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    # (b, c, a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    # (c, b, a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=b \| (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |

    # 2 ER -> a INNER JOIN c on a=c INNER JOIN b on b=c and b
    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (b, c, a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (c, b, a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` )  join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=b \| (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |

  # 1 ER bc -> a INNER JOIN c on a=c INNER JOIN b on b=c and a
    # (b, c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `c`.`name` ASC                                          |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `c`.`name` ASC                                          |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    # (b, c) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # (c, b) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `c`.`name` ASC                                          |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `c`.`name` ASC                                          |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    # (c, b) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      #| dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager`,`b`.`deptid` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      #| dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager`,`b`.`deptid` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC |
      #| merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                              |
      #| shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                         |
      #| dn3_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                        |
      #| dn4_1             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` ORDER BY `c`.`levelname` ASC                                                                                                        |
      #| merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                                                                                              |
      #| shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                                                                                         |
      #| join_1            | JOIN            | shuffle_field_1; shuffle_field_3                                                                                                                                                          |
      #| order_1           | ORDER           | join_1                                                                                                                                                                                    |
      #| shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                   |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=b \| (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table b & condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name   | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & condition |
      #| conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end

      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and a.empid=2242 order by a.name  | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |

    # 1 ER bc -> a INNER JOIN c on a=c INNER JOIN b on b=c and b
    # (c, b) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `c`.`name` ASC   |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Info` `c` join  `Dept` `b` on `c`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `c`.`name` ASC   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (c, b) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # (b, c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `c`.`name` ASC   |
      | dn4_0             | BASE SQL              | select `b`.`manager`,`c`.`country`,`c`.`name` from  `Dept` `b` join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `c`.`name` ASC   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (b, c) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=b \| (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |

      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      | conn_1  | False    | /*#dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition |
      | conn_1  | False    | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition |

      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=a \| (c & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 begin
      #| conn_1  | False    | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition |
      #| conn_1  | False    | /*#dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1641 end

      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |

    # no ER -> a INNER JOIN c on a=c INNER JOIN b on b=c and a
    # a | c | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                       |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # a & c & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC                                                         |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC                                                         |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (a & c) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
     # a | (c & b)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs4" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (a | c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC                                                    |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
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
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultsets "join_rs5" and "join_rs51" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # b | c | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                       |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (b & c) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # b | (c & a)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (b | c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # b & c & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                 |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c | a | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                 |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
      | order_1           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (c & a) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # c & (a | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c & a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (c | a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC                                                    |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC                                                    |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                    |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_1           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c & a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c | b | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                 |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                                       |
      | order_1           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (c & b) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # c & (b | a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (c | b) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c & b & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                                       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name   | schema1 | hint explain build failures! check table b & condition |

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=b \| (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table a & condition |

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 | hint explain build failures! check table b & condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |

      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636
      #| conn_1  | False    | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name | schema1 | hint explain build failures! check & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and a.empid=2242 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # no ER -> a INNER JOIN c on a=c INNER JOIN b on b=c and b
    # a | c | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | order_2           | ORDER           | join_2                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # a & c & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                      |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # (a & c) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
     # a | (c & b)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs4" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (a | c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                      |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs5" and "join_rs51" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| c & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # b | c | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | dn4_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | order_2           | ORDER           | join_2                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # (b & c) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # b | (c & a)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=b \| (c & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (b | c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                             |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
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
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # b & c & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                             |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
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
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # c | a | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                  |
      | dn3_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | order_1           | ORDER           | join_2                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # (c & a) | b
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # c & (a | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_1           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c & a \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # (c | a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                      |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_1           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # c & a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_1           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # c | b | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | dn4_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                  |
      | dn3_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn4_2             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                            |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_3                                                                       |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_5                                                        |
      | order_1           | ORDER           | join_2                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # (c & b) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # c & (b | a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_1           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs3" and "join_rs31" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # (c | b) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                             |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2 ORDER BY `b`.`manager` ASC                                                                             |
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
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*#dble:plan=c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs4" and "join_rs41" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # c & b & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | dn4_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                                                                                           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where  ( `b`.`deptid` = 2 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                             |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_1           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 |
    # other
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(a, c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(a, c) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=a \| (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=a & (c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table b & condition |

      | conn_1  | False    | /*#dble:plan=(b, c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(b, c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(b, c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=b \| (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      | conn_1  | False    | /*#dble:plan=b & (c, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & condition |

      | conn_1  | False    | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=(c, a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
      #| conn_1  | False    | /*#dble:plan=(c, a) \| b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #| conn_1  | False    | /*#dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition |
      | conn_1  | False    | /*#dble:plan=c & (a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |

      | conn_1  | False    | /*#dble:plan=(c, b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      | conn_1  | False    | /*#dble:plan=c & (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint. |
      | conn_1  | False    | /*#dble:plan=(c, b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1635
      #| conn_1  | False    | /*#dble:plan=(c, b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition |
      #| conn_1  | False    | /*#dble:plan=c \| (b, a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check & or \| condition |
      #http://10.186.18.11/jira/browse/DBLE0REQ-1636
      #| conn_1  | False    | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name | schema1 | hint explain build failures! check & or \| condition |

      | conn_1  | False    | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it. |
      | conn_1  | False    | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1  | True     | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name INNER JOIN Dept b on b.manager=c.name and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # more join
    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c INNER JOIN d on a=d and d
    # (a, b, c) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b, c) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # (a, c, b) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`a`.`level`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`a`.`level`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # (b, a, c) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a, c) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # (c, a, b) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`a`.`level`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`c`.`country`,`a`.`level`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC                                                               |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # (a, b, c) | d
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a, b, c) \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      #| dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      #| dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      #| merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                        |
      #| shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                   |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a, b, c) \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*!dble:plan=(b, c, a) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1  | True     | /*!dble:plan=(c, b, a) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    #1 ER : ab -> a LEFT JOIN b on a=b LEFT JOIN c on a=c INNER JOIN d on a=d
    # (a, b) & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC            |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # (b, a) & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC            |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # (b, a) & c & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC            |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a) & c & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn    | toClose  | sql                                                                                                                  | db      | expect |
      | conn_1  | False    | /*!dble:plan=(a, b) \| c \|  d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | hint size 2 not equals to plan node size 4. |
      | conn_1  | False    | /*!dble:plan=(a, b) \| c & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name   | schema1 | hint size 3 not equals to plan node size 4. |

   # no ER : ab -> a INNER JOIN b on a=b LEFT JOIN c on a=c LEFT JOIN d on a=d and d
   # a & b | c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC                                                                              |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                               |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                       |
      | dn4_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_5                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                    |
      | shuffle_field_6   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_6                                                                                                                                                                |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                         |
      | dn3_3             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | dn4_3             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | merge_and_order_4 | MERGE_AND_ORDER       | dn3_3; dn4_3                                                                                                                                                                                    |
      | shuffle_field_7   | SHUFFLE_FIELD         | merge_and_order_4                                                                                                                                                                               |
      | join_3            | JOIN                  | shuffle_field_3; shuffle_field_7                                                                                                                                                                |
      | order_2           | ORDER                 | join_3                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # a | b | c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                  |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                   |
      | dn4_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                   |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_5                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                             |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                           |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                       |
      | shuffle_field_6   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                  |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_6                                                                                   |
      | order_1           | ORDER           | join_2                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                            |
      | dn3_3             | BASE SQL        | select `d`.`levelname` from  `Level` `d` where `d`.`levelname` = 'P8' ORDER BY `d`.`levelname` ASC                 |
      | dn4_3             | BASE SQL        | select `d`.`levelname` from  `Level` `d` where `d`.`levelname` = 'P8' ORDER BY `d`.`levelname` ASC                 |
      | merge_and_order_4 | MERGE_AND_ORDER | dn3_3; dn4_3                                                                                                       |
      | shuffle_field_7   | SHUFFLE_FIELD   | merge_and_order_4                                                                                                  |
      | join_3            | JOIN            | shuffle_field_3; shuffle_field_7                                                                                   |
      | order_2           | ORDER           | join_3                                                                                                             |
      | shuffle_field_4   | SHUFFLE_FIELD   | order_2                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # a | b & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC                                                                              |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                               |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
      | dn4_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_5                                                                                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                          |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                    |
      | shuffle_field_6   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_6                                                                                                                                                                |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                         |
      | dn3_3             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | dn4_3             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | merge_and_order_4 | MERGE_AND_ORDER       | dn3_3; dn4_3                                                                                                                                                                                    |
      | shuffle_field_7   | SHUFFLE_FIELD         | merge_and_order_4                                                                                                                                                                               |
      | join_3            | JOIN                  | shuffle_field_3; shuffle_field_7                                                                                                                                                                |
      | order_2           | ORDER                 | join_3                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # b | a | c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                   |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                  |
      | dn3_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC |
      | dn4_1             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_5                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                            |
      | dn3_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                           |
      | dn4_2             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` ORDER BY `c`.`name` ASC                                           |
      | merge_and_order_3 | MERGE_AND_ORDER | dn3_2; dn4_2                                                                                                       |
      | shuffle_field_6   | SHUFFLE_FIELD   | merge_and_order_3                                                                                                  |
      | join_2            | JOIN            | shuffle_field_2; shuffle_field_6                                                                                   |
      | order_2           | ORDER           | join_2                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                            |
      | dn3_3             | BASE SQL        | select `d`.`levelname` from  `Level` `d` where `d`.`levelname` = 'P8' ORDER BY `d`.`levelname` ASC                 |
      | dn4_3             | BASE SQL        | select `d`.`levelname` from  `Level` `d` where `d`.`levelname` = 'P8' ORDER BY `d`.`levelname` ASC                 |
      | merge_and_order_4 | MERGE_AND_ORDER | dn3_3; dn4_3                                                                                                       |
      | shuffle_field_7   | SHUFFLE_FIELD   | merge_and_order_4                                                                                                  |
      | join_3            | JOIN            | shuffle_field_3; shuffle_field_7                                                                                   |
      | order_3           | ORDER           | join_3                                                                                                             |
      | shuffle_field_4   | SHUFFLE_FIELD   | order_3                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |
    # b | a & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                               |
      | dn3_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC                                                                              |
      | dn4_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`level` = 'P8' ORDER BY `a`.`name` ASC                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn3_1; dn4_1                                                                                                                                                                                    |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_5                                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                         |
      | dn3_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_5's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | dn4_2             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_5's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                  |
      | merge_and_order_3 | MERGE_AND_ORDER       | dn3_2; dn4_2                                                                                                                                                                                    |
      | shuffle_field_6   | SHUFFLE_FIELD         | merge_and_order_3                                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_6                                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                         |
      | dn3_3             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_5's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | dn4_3             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_5's RESULTS; select `d`.`levelname` from  `Level` `d` where  ( `d`.`levelname` = 'P8' AND `d`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `d`.`levelname` ASC |
      | merge_and_order_4 | MERGE_AND_ORDER       | dn3_3; dn4_3                                                                                                                                                                                    |
      | shuffle_field_7   | SHUFFLE_FIELD         | merge_and_order_4                                                                                                                                                                               |
      | join_3            | JOIN                  | shuffle_field_3; shuffle_field_7                                                                                                                                                                |
      | order_3           | ORDER                 | join_3                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | order_3                                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

  @delete_mysql_tables
  Scenario: rule B, C, D -> globalTable + globalTable + shardingTable -> inner join & inner join #2
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="Employee" shardingNode="dn1,dn2,dn3,dn4" />
        <globalTable name="Dept" shardingNode="dn3,dn4" />
        <shardingTable name="Info" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
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
    Given execute admin cmd "reload @@config_all" success
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

    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # (a, b, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (b, a, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |
    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 2 ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |

    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and c
    # (a, b, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Employee` `a` join  `Info` `c` on `a`.`deptname` = `c`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # (b, a, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |
    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`c`.`country`,`b`.`manager` from  (  `Info` `c` join  `Employee` `a` on `c`.`deptname` = `a`.`deptname` )  join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `c`.`country` = 'China' ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and c.country='China' order by a.name | schema1 |

  @delete_mysql_tables
  Scenario: rule B, C, D -> globalTable + singleTable + singleTable -> inner join & inner join #3
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="Employee" shardingNode="dn1,dn2,dn3,dn4" />
        <singleTable name="Dept" shardingNode="dn1" />
        <singleTable name="Info" shardingNode="dn3" />
        <singleTable name="Level" shardingNode="dn4" />
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
    Given execute admin cmd "reload @@config_all" success
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
    # 1 ER ab -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # (a, b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2 |
      | dn1_0           | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level` from  `Employee` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where `b`.`deptid` = 2 order by `a`.`level` ASC |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                          |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_1                                                                                                                                                                        |
      | dn4_0           | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC  |
      | merge_2         | MERGE                 | dn4_0                                                                                                                                                                          |
      | shuffle_field_3 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                        |
      | join_1          | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                               |
      | order_1         | ORDER                 | join_1                                                                                                                                                                         |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (a, b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # (b, a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2 |
      | dn1_0           | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level` from  `Dept` `b` join  `Employee` `a` on `b`.`manager` = `a`.`name` where `b`.`deptid` = 2 order by `a`.`level` ASC |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                          |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_1                                                                                                                                                                        |
      | dn4_0           | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC  |
      | merge_2         | MERGE                 | dn4_0                                                                                                                                                                          |
      | shuffle_field_3 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                        |
      | join_1          | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                               |
      | order_1         | ORDER                 | join_1                                                                                                                                                                         |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    # (b, a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end

    # 1 ER ab -> a INNER JOIN b on a=b INNER JOIN c on a=c and c
    # (a, b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1                | SQL/REF-2 |
      | dn1_0           | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level` from  `Employee` `a` join  `Dept` `b` on `a`.`name` = `b`.`manager` where 1=1  order by `a`.`level` ASC                                                    |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                                                      |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                                    |
      | dn4_0           | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_2         | MERGE                 | dn4_0                                                                                                                                                                                                      |
      | shuffle_field_3 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                                    |
      | join_1          | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                           |
      | order_1         | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (a, b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end
    # (b, a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2 |
      | dn1_0           | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`a`.`level` from  `Dept` `b` join  `Employee` `a` on `b`.`manager` = `a`.`name` where 1=1  order by `a`.`level` ASC                                                    |
      | merge_1         | MERGE                 | dn1_0                                                                                                                                                                                                      |
      | shuffle_field_1 | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                                    |
      | dn4_0           | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where  ( `c`.`salary` = 10000 AND `c`.`levelname` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`levelname` ASC |
      | merge_2         | MERGE                 | dn4_0                                                                                                                                                                                                      |
      | shuffle_field_3 | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                                    |
      | join_1          | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                                           |
      | order_1         | ORDER                 | join_1                                                                                                                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    # (b, a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | success | schema1 |
    #Then check resultset "join_rs1" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and c.salary=10000 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1635 end


  @delete_mysql_tables
  Scenario: rule B, C, D -> globalTable + shardingTable + singleTable -> inner join & inner join #4
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given delete the following xml segment
      | file          | parent         | child                  |
      | sharding.xml  | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml  | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="Employee" shardingNode="dn1,dn2" />
        <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
        <singleTable name="Info" shardingNode="dn3" />
        <singleTable name="Level" shardingNode="dn4" />
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
    Given execute admin cmd "reload @@config_all" success
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

    # no ER -> a INNER JOIN b on a=b INNER JOIN c on b=c and a
    # a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn1_0//dn2_0                                                                                           |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                               |
      | merge_2           | MERGE           | dn3_1                                                                                                  |
      | join_2            | JOIN            | shuffle_field_1; merge_2                                                                               |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0//dn2_0      | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC                                                         |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                        |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                          |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_2                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (a & b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
     # a | (b & c)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs4" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (a | b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0//dn2_0      | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC                                                         |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c | b | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                               |
      | merge_1           | MERGE           | dn3_0                                                                                                  |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_1; dn4_0                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC |
      | merge_2           | MERGE           | dn1_0//dn2_0                                                                                           |
      | join_2            | JOIN            | shuffle_field_1; merge_2                                                                               |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (c & b) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c | (b & a)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (c | b) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                       |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                          |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_1; dn4_0                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_1; merge_2                                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # c & b & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                       |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                          |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                        |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_1; dn4_0                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # b | a | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC |
      | merge_1           | MERGE           | dn1_0//dn2_0                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                 |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                               |
      | merge_2           | MERGE           | dn3_1                                                                                                  |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                               |
      | order_1           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (b & a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # b & (a | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                 |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (b | a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn1_0//dn2_0      | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC                                                         |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # b | c | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                               |
      | merge_1           | MERGE           | dn3_1                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                 |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 order by `a`.`name` ASC |
      | merge_2           | MERGE           | dn1_0//dn2_0                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                               |
      | order_1           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (b & c) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # b & (c | a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                 |
      | merge_1           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                                                       |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |
    # (b | c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                       |
      | merge_1           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where  ( `a`.`empid` = 2242 AND `a`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                                                       |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and a.empid=2242 order by a.name | schema1 |

    # no ER -> a INNER JOIN b on a=b INNER JOIN c on b=c and c
    # a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                          |
      | merge_1           | MERGE           | dn1_0//dn2_0                                                                                           |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC |
      | merge_2           | MERGE           | dn3_1                                                                                                  |
      | join_2            | JOIN            | shuffle_field_1; merge_2                                                                               |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0//dn2_0      | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                                                                                                                  |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                        |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                                      |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where  ( `c`.`country` = 'China' AND `c`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # (a & b) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
     # a | (b & c)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    #Then check resultset "join_rs4" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (a | b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn1_0//dn2_0      | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                                                                                                                  |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where  ( `c`.`country` = 'China' AND `c`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=a \| b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # c | b | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                                  |
      | dn3_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_1; dn4_0                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                               |
      | order_1           | ORDER           | join_1                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                          |
      | merge_2           | MERGE           | dn1_0//dn2_0                                                                                           |
      | join_2            | JOIN            | shuffle_field_1; merge_2                                                                               |
      | order_2           | ORDER           | join_2                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # (c & b) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(c & b) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # c | (b & a)
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    #Then check resultset "join_rs3" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=c \| (b & a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # (c | b) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| b) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC                                                              |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | dn3_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_1; dn4_0                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_1; merge_2                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c \| b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # c & b & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs5"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC                                                              |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC           |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_1; dn4_0                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=c & b & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # b | a | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                          |
      | merge_1           | MERGE           | dn1_0//dn2_0                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                 |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC |
      | merge_2           | MERGE           | dn3_1                                                                                                  |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                               |
      | order_1           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # (b & a) | c
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # b & (a | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                            |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where  ( `c`.`country` = 'China' AND `c`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & (a \| c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # (b | a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn1_0//dn2_0      | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                                                                                                                  |
      | merge_1           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where  ( `c`.`country` = 'China' AND `c`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`name` ASC |
      | merge_2           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_2                                                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| a & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # b | c | a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs1"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
      | dn3_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | dn4_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn3_1             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC |
      | merge_1           | MERGE           | dn3_1                                                                                                  |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                 |
      | dn1_0//dn2_0      | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` order by `a`.`name` ASC                          |
      | merge_2           | MERGE           | dn1_0//dn2_0                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                               |
      | order_1           | ORDER           | join_2                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # (b & c) | a
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 begin
    #Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs2"
      #| conn   | toClose | sql                                                                                                                    | expect  | db      |
      #| conn_1 | False   | explain /*!dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    #Then check resultset "join_rs2" has lines with following column values
      #| SHARDING_NODE-0   | TYPE-1          | SQL/REF-2 |
    #Then execute sql in "dble-1" and the result should be consistent with mysql
      #| conn    | toClose  | sql                                                                                                                    | db      |
      #| conn_1  | true     | /*#dble:plan=(b & c) \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    #http://10.186.18.11/jira/browse/DBLE0REQ-1636 end
    # b & (c | a)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs3"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & (c \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                              |
      | dn3_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where  ( `c`.`country` = 'China' AND `c`.`name` in ('{NEED_TO_REPLACE}')) ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_1                                                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                         |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC                            |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                                                       |
      | order_1           | ORDER                 | join_2                                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b & c \| a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
    # (b | c) & a
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs4"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| c) & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | success | schema1 |
    Then check resultset "join_rs4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2 |
      | dn3_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn4_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_1             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC                                                              |
      | merge_1           | MERGE                 | dn3_1                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn1_0//dn2_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_2           | MERGE                 | dn1_0//dn2_0                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; merge_2                                                                                                                                            |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose  | sql                                                                                                                    | db      |
      | conn_1  | true     | /*#dble:plan=b \| c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on b.manager=c.name and c.country='China' order by a.name | schema1 |
