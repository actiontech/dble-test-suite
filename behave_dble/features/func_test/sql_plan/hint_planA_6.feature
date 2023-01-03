# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by chenhuiming at 2022/2/28
Feature: test with hint plan A with other table type

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  GlobalTable                              #1
  """
    {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql':['schema1']}}
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <shardingTable name="Employee" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
        <shardingTable name="Dept" shardingNode="dn3,dn4" function="func_hashString" shardingColumn="deptname" />
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
     # 1.1 left join & left join & 2 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                    |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  left join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                            |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

    # 1.2 left join & left join & 2 ER  acb
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                               | db      | expect                                          |
      | conn_1 | False   | explain /*!dble:plan= (a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 | hint explain build failures! check ER condition |

    # 1.3 left join & left join & 1 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |


    # 1.4 left join & left join & NO ER  abc \|
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                            | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |

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
      | dn5_0//dn6_0      | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_1           | MERGE           | dn5_0//dn6_0                                                                              |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager LEFT JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |


  # 2. a LEFT JOIN b on a.col=b.col LEFT JOIN c on b.col=c.col
  # 2.1 left join & left join & 2 ER  abc
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


     # 2.2 left join & left join & 1 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                  | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.deptname=b.deptname LEFT JOIN Level c ON b.level=c.levelname ORDER BY a.manager | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`name`,`b`.`deptname`,`b`.`level`,`a`.`manager` from  `Dept` `a` left join  `Employee` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`level` ASC  |
      | dn4_0             | BASE SQL              | select `b`.`name`,`b`.`deptname`,`b`.`level`,`a`.`manager` from  `Dept` `a` left join  `Employee` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`level` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.deptname=b.deptname LEFT JOIN Level c ON b.level=c.levelname ORDER BY a.manager | schema1 |


    # 2.3 left join & left join & NO ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                               | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.manager=b.name LEFT JOIN Level c ON b.level=c.levelname ORDER BY a.manager | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                 |
      | dn3_0             | BASE SQL        | select `a`.`manager` from  `Dept` `a` ORDER BY `a`.`manager` ASC                          |
      | dn4_0             | BASE SQL        | select `a`.`manager` from  `Dept` `a` ORDER BY `a`.`manager` ASC                          |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `b`.`name`,`b`.`deptname`,`b`.`level` from  `Employee` `b` ORDER BY `b`.`name` ASC |
      | dn4_1             | BASE SQL        | select `b`.`name`,`b`.`deptname`,`b`.`level` from  `Employee` `b` ORDER BY `b`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                          |
      | order_1           | ORDER           | join_1                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                   |
      | dn5_0//dn6_0      | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_1           | MERGE           | dn5_0//dn6_0                                                                              |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.manager=b.name LEFT JOIN Level c ON b.level=c.levelname ORDER BY a.manager | schema1 |


  # 3. a LEFT JOIN b on a.col=b.col INNER JOIN c on a.col=c.col
  # 3.1 left join & inner join & 2 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c)  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c)  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |


   # 3.2 left join & inner join & 1 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |


   # 3.3 left join & inner join & NO ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                             | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | success | schema1 |

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
      | dn5_0//dn6_0      | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_1           | MERGE           | dn5_0//dn6_0                                                                              |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a LEFT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name | schema1 |


    # 4. a LEFT JOIN b on a.col=b.col INNER JOIN c on b.col=c.col
    # 4.1  left join & inner join & 2 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                               |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |


    # 4.2 left join & inner join & 1 ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                   | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.deptname=b.deptname INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`name`,`b`.`deptname`,`b`.`level`,`a`.`manager` from  `Dept` `a` left join  `Employee` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`level` ASC  |
      | dn4_0             | BASE SQL              | select `b`.`name`,`b`.`deptname`,`b`.`level`,`a`.`manager` from  `Dept` `a` left join  `Employee` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`level` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.deptname=b.deptname INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | schema1 |


    # 4.3 left join & inner join & NO ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.manager=b.name INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                 |
      | dn3_0             | BASE SQL        | select `a`.`manager` from  `Dept` `a` ORDER BY `a`.`manager` ASC                          |
      | dn4_0             | BASE SQL        | select `a`.`manager` from  `Dept` `a` ORDER BY `a`.`manager` ASC                          |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `b`.`name`,`b`.`deptname`,`b`.`level` from  `Employee` `b` ORDER BY `b`.`name` ASC |
      | dn4_1             | BASE SQL        | select `b`.`name`,`b`.`deptname`,`b`.`level` from  `Employee` `b` ORDER BY `b`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                          |
      | order_1           | ORDER           | join_1                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                   |
      | dn5_0//dn6_0      | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_1           | MERGE           | dn5_0//dn6_0                                                                              |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |


    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a LEFT JOIN Employee b ON a.manager=b.name INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | schema1 |


  # 5. a INNER JOIN b on a.col=b.col INNER JOIN c on a.col=c.col
  # 5.1  inner join & inner join &  2  ER  abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON a.deptname=c.deptname order by a.name | schema1 |

    # 5.2  inner join & inner join & 1  ER  bac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname order by a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | dn4_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`level` ASC       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Level c ON a.level=c.levelname order by a.name | schema1 |

    # 5.3  inner join & inner join & NO  ER
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                              | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname order by a.name | success | schema1 |

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
      | dn5_0//dn6_0      | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_1           | MERGE           | dn5_0//dn6_0                                                                              |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a INNER JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname order by a.name | schema1 |

    # 6. a INNER JOIN b on a.col=b.col INNER JOIN c on b.col=c.col
    # 6.1  INNER JOIN & INNER JOIN 2 ER abc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b,c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                          |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager`,`c`.`country` from  (  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_1 | true    | /*#dble:plan= (a,b,c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b ON a.deptname=b.deptname INNER JOIN Info c ON b.deptname=c.deptname ORDER BY a.name | schema1 |

    # 6.2  INNER JOIN & INNER JOIN 1 er
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                    | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= (a,b) & c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a INNER JOIN Employee b ON a.deptname=b.deptname INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn3_0             | BASE SQL              | select `b`.`name`,`b`.`deptname`,`b`.`level`,`a`.`manager` from  `Dept` `a` join  `Employee` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`level` ASC       |
      | dn4_0             | BASE SQL              | select `b`.`name`,`b`.`deptname`,`b`.`level`,`a`.`manager` from  `Dept` `a` join  `Employee` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `b`.`level` ASC       |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn3_0; dn4_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                            | db      |
      | conn_1 | true    | /*#dble:plan= (a,b) & c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a INNER JOIN Employee b ON a.deptname=b.deptname INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | schema1 |

  #  6.3  INNER JOIN & INNER JOIN NO er
    Given execute single sql in "dble-1" in "user" mode and save resultset in "join_rs"
      | conn   | toClose | sql                                                                                                                                                                                                 | expect  | db      |
      | conn_1 | False   | explain /*!dble:plan= a \| b \| c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a INNER JOIN Employee b ON a.manager=b.name INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | success | schema1 |

    Then check resultset "join_rs" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                 |
      | dn3_0             | BASE SQL        | select `a`.`manager` from  `Dept` `a` ORDER BY `a`.`manager` ASC                          |
      | dn4_0             | BASE SQL        | select `a`.`manager` from  `Dept` `a` ORDER BY `a`.`manager` ASC                          |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn3_1             | BASE SQL        | select `b`.`name`,`b`.`deptname`,`b`.`level` from  `Employee` `b` ORDER BY `b`.`name` ASC |
      | dn4_1             | BASE SQL        | select `b`.`name`,`b`.`deptname`,`b`.`level` from  `Employee` `b` ORDER BY `b`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn3_1; dn4_1                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                         |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                          |
      | order_1           | ORDER           | join_1                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                   |
      | dn5_0//dn6_0      | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_1           | MERGE           | dn5_0//dn6_0                                                                              |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                         | db      |
      | conn_1 | true    | /*#dble:plan= a \| b \| c */ SELECT b.name,b.deptname,a.manager,c.salary FROM Dept a INNER JOIN Employee b ON a.manager=b.name INNER JOIN Level c ON b.level=c.levelname ORDER BY a.manager | schema1 |