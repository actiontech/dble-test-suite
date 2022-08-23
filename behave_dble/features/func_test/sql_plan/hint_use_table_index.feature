# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2022/8/16

# from DBLE0REQ-1501
Feature: test hint => use_table_index

  @delete_mysql_tables
  Scenario: check use_table_index => rule B, C, D -> shardingTable + shardingTable + shardingTable -> inner join & inner join #1
    """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
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

    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # (a, b, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2, 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |

    # (a, c, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 3, 2)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 3, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(a, 3, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |

    # (b, a, c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2, 1, 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=(2, 1, 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |

    # (c, a, b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3, 1, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(3, 1, 2)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3, a, b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 |

    # other
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                            | db      | expect                                                                                         |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (2, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (2, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (2 \| 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (2 & 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 & 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 \| 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 2 & 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition                                   |

      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3) \| 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (3, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (3, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (3 \| 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (3 & 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 & 3) \| 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 \| 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 3 & 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition                                   |

      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| (1, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & (1, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & (1 \| 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| (1 & 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2 & 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2 \| 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 1 & 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| 1 \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition                                   |

      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| (1, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & (1, 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & (1 \| 2) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| (1 & b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3 & 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3 \| 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & 1 & 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table c & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| 1 \| 2 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table c & or \| condition                                   |

      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 3, 1) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 3 & 1 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 2, 1) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| 2 \| 1 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # 1 ER ab -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # (a, b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2) & 3$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
    # DBLE0REQ-1908
#      | conn_1 | False   | /*#dble:plan=(1, 2) & 3 $ use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |
      | conn_1 | False   | /*#dble:plan=(1, 2) & 3 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a, b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      # DBLE0REQ-1908
#      | conn_1 | False   | explain /*!dble:plan=use_table_index $ (1, 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$ (1, 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2) \| 3 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$ (1, 2) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (b, a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
     Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2, 1) & 3 $use_table_index$ */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, a) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (b, a) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2, 1) \| 3 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(b, 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a | c | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 \| 3 \| 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a & c) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1 & 3) \| 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 & 3) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a & (c | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & (3 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & (3 \| 2)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & (c \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (3 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a | c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 \| 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1 \| 3) & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(a \| 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 \| 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a & c & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & 3 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & 3 & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & 3 & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 3 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # c | a | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| 1 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=3 \| 1 \| 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| 1 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (c & a) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 & 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(3 & 1) \| 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 & 1) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3 & 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # c | (a & b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| (1 & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=3 \| (1 & 2)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| (a & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                        | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| (1 & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (c | a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 \| 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(3 \| 1) & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 \| a) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3 \| 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # c & a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
     Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 & 1 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=3 & 1 & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$c & 1 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & 1 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # other
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                          | db      | expect                                                                                         |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (2, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (2, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (2 \| 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (2 & 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 & 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 \| 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 2 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table a & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table a & or \| condition                                   |

      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (3, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (3, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (3 & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition                                         |

      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| (1, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & (1, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & (1 \| 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| (1 & 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2 & 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2 \| 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 1 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check table b & or \| condition                                   |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| 1 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check table b & or \| condition                                   |

      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| (1, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & (1, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & (1 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition                                         |

      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 3, 1) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 3 & 1 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 2, 1) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| 2 \| 1 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # no ER -> a INNER JOIN b on a=b INNER JOIN c on a=c and b
    # a | b | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 \| 2 \| 3$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| b \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a & b) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 & 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1 & 2) \| 3 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 & b) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a & (b | c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & (2 \| 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & (2 \| 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & (2 \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (b \| c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a | b) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 \| 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1 \| 2) & 3$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 \| b) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 \| 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a & b & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
     Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & 2 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & 2 & 3$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$ 1 & b & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$ 1 & 2 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a | c | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| c \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 \| 3 \| 2 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$ 1 \| 3 \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a & c) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a & c) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 & 3) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1 & 3) \| 2 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 & 3) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 3 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a & (c | b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
     Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & (3 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & (3 \| 2)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$ a & (3 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (3 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (a | c) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 \| 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1 \| 3) & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1 \| 3) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # a & c & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & c & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & 3 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & 3 & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & c & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 3 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # b | a | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| 1 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=2 \| 1 \| 3 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$ b \| 1 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| 1 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (b & a) | c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2 & 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2 & 1) \| 3$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2 & 1) \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 1 \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # b | (a & c)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| (a & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| (1 & 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=2 \| (1 & 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| (1 & c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| 1 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (b | a) & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2 \| 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2 \| 1) & 3 $use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2 \| 1) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2 \| 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # b & a & c
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b & a & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 & 1 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=2 & 1 & 3$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 & a & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 1 & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # c | a | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| a \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| 1 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=3 \| 1 \| 2$use_table_index$ */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| 1 \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| 1 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (c & a) | b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c & a) \| b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 & 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(3 & 1) \| 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 & a) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & 1 \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # c | (a & b)
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c \| (a & b) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 \| (1 & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=3 \| (1 & 2)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$c \| (1 & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| (1 & 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # (c | a) & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 \| 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(3 \| 1) & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3 \| a) & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3 \| 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # c & a & b
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=c & a & b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
     Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 & 1 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=3 & 1 & 2$use_table_index */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$3 & a & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & 1 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.level=c.levelname and b.deptid=2 order by a.name | schema1 |

    # other
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                     | db      | expect                                                                                         |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (2, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (2, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (2 & 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & condition                                         |

      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| (3, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (3, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 3 & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check table b & condition                                         |

      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) & 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) \| 3 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| (1, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & (1, 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & (1 \| 3) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table c & condition                                         |

      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1) & 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1) \| 2 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| (1, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | hint explain build failures! check ER condition                                                |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & (1, 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name   | schema1 | The ER relation in the hint currently only supports when it exists in the headmost of hint.    |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 & (1 \| 2) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table b & condition                                         |

      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 3, 1) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 & 3 & 1 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 2, 1) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name    | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=use_table_index$3 \| 2 \| 1 */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Level c on a.Level=c.levelname and b.deptid=2 order by a.name  | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    # more join
    # 2 ER -> a INNER JOIN b on a=b INNER JOIN c on a=c INNER JOIN d on a=d and d
    # (a, b, c) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2, 3) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2, 3) & 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2, 3) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2, 3) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # (a, c, b) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, c, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 3, 2) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 3, 2) & 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, c, b) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 3, 2) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # (b, a, c) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a, c) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1, 3) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2, 1, 3) & 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(b, a, 3) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1, 3) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # (c, a, b) & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(c, a, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3, 1, 2) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(3, 1, 2) & 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(3, 1, b) & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                         | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(3, 1, 2) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # (a, b, c) | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b, c) \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2, 3) \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2, 3) \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2, c) \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                          | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2, 3) \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # other
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                         | db      | expect                                                                                         |
      | conn_1 | False   | /*!dble:plan=use_table_index$(2, 3, 1) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*!dble:plan=use_table_index$(3, 2, 1) & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | You are using wrong hint. please check the node 'b',there are no previous nodes connect to it. |

    #1 ER : ab -> a LEFT JOIN b on a=b LEFT JOIN c on a=c INNER JOIN d on a=d
    # (a, b) & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2) & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2) & 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # (b, a) & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1) & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2, 1) & 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                           | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(b, a) & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                   | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # (b, a) & c & d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(b, a) & c & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, 1) & 3 & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(2, 1) & 3 & 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                          | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(2, a) & 3 & d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                  | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(2, 1) & 3 & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    #(a, b) | c |  d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(a, b) \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(1, 2) \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=(1, 2) \| 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$(a, 2) \| c \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                                     | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2) \| 3 \|  4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    #other
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                   | db      | expect                                                 |
      | conn_1 | False   | /*!dble:plan=use_table_index$(1, 2) \| 3 & 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | hint explain build failures! check table d & condition |

   # no ER : ab -> a INNER JOIN b on a=b LEFT JOIN c on a=c LEFT JOIN d on a=d and d
   # a & b | c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs11"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & b \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs12"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & 2 \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs13"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & 2 \| 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs14"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & 2 \| 3 \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs11" and "join_rs12" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs13" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs11" and "join_rs14" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                              | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & 2 \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # a | b | c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs21"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a \| b \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs22"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| 2 \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs23"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 \| 2 \| 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs24"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 \| 2 \| 3 \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs21" and "join_rs22" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs23" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs21" and "join_rs24" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                               | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 2 \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # a &( b | c | d )
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs31"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=a & (b \| c \| d) */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs32"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$1 & (2 \| 3 \| 4) */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs33"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=1 & (2 \| 3 \| 4)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs34"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$a & (2 \| 3 \| 4) */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs31" and "join_rs32" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs33" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs31" and "join_rs34" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                              | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 & (2 \| 3 \| 4) */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # b | a | c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs41"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a \| c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs42"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| 1 \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs43"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=2 \| 1 \| 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs44"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                       | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| a \| c \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs41" and "join_rs42" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
     Then check resultsets "join_rs41" and "join_rs43" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs41" and "join_rs44" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                               | db      |
      | conn_1 | False   | /*#dble:plan=use_table_index$2 \| 1 \| 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # b | a & c | d
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs51"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=b \| a & c \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs52"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| 1 & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs53"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=2 \| 1 & 3 \| 4$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs54"
      | conn   | toClose | sql                                                                                                                                                                                                                                                                      | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan=use_table_index$2 \| a & 3 \| d */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | success | schema1 |
    Then check resultsets "join_rs51" and "join_rs52" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs53" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then check resultsets "join_rs51" and "join_rs54" are same in following columns
      | column        | column_index |
      | SHARDING_NODE | 0            |
      | TYPE          | 1            |
      | SQL/REF       | 2            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                                                              | db      |
      | conn_1 | false   | /*#dble:plan=use_table_index$2 \| 1 & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 |

    # other
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                              | db      | expect                                                 |
      | conn_1 | false   | /*!dble:plan=use_table_index$1 \| 2 & 3 \| 4 */ SELECT a.name,a.deptname,b.manager,c.country,d.levelname FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name INNER JOIN Level d on a.level=d.levelname and d.levelname='P8' order by a.name | schema1 | hint explain build failures! check table c & condition |

    # other format
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                           | db      | expect                                                       |
      | conn_1 | False   | /*#dble:plan=(1, 2, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name                   | schema1 | no node match the root: 1                                    |
      | conn_1 | False   | /*#dble:plan=(1, 2, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name                   | schema1 | no node match the root: 1                                    |
      | conn_1 | False   | /*#dble:plan=(1, 2, 3)&use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint size 4 not equals to plan node size 3.                  |
      | conn_1 | False   | /*#dble:plan=(1, 2, 3)@use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | hint parse failure                                           |
      | conn_1 | False   | /*#dble:plan=use_table_index$1 \| 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1 & 2 & 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name | schema1 | hint explain build failures! check table a & or \| condition |
      | conn_1 | False   | /*#dble:plan=1 \| $use_table_index 2 \| 3 */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name| schema1 | hint size 2 not equals to plan node size 3.                  |
      | conn_1 | False   | /*#dble:plan=(2, 3, 4)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it. |
      | conn_1 | False   | /*#dble:plan=(2, 5, 4)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | You are using wrong hint.The node '5' doesn't exist.         |
      | conn_1 | False   | /*#dble:plan=(2, b, 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | duplicate alias exist in the hint plan                       |
      | conn_1 | False   | /*#dble:plan=(1, 2, 3)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | success |
      | conn_1 | False   | /*#dble:plan=(1, 2, 3)$use_table_index$ */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name  | schema1 | success |
      | conn_1 | False   | /*#dble:plan=(1, 2, c)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | success |
      | conn_1 | False   | /*#dble:plan=(a, b, c)$use_table_index */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | success |
      | conn_1 | False   | /*#dble:plan=use_table_index$(a, b, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | success |
      | conn_1 | False   | /*#dble:plan=use_table_index$(1, 2, 3) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | success |
      | conn_1 | True    | /*#dble:plan=use_table_index$(1, 2, c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.deptname=c.deptname and b.deptid=2 order by a.name   | schema1 | success |
