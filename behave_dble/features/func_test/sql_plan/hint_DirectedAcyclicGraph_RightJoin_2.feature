# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhangqian at 2022/03/01
Feature: test hint
# DBLE0REQ-1641/DBLE0REQ-1648/DBLE0REQ-1664
# Affected by the above issue, dble cannot recognize the post-er relationship, so hint does not support the post-er relationship
# So when there is an er relationship with a post-position, currently it can only be written without an er relationship
# After the above issue is repaired, you need to pay attention to the sql of such scenarios and modify the case

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  globalTable  Directed Acyclic Graph && right join   #1
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

    # create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | True    | create database if not exists schema1                                                                                                                                                                                                                                                                             | mysql   | success |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC     |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                      |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                           |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)\|c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;       | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= a &( b \| c)   */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= a &( b \| c)   */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                   |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (a & b) \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;       | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC     |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                      |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                           |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)\|c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                   | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b\|c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a \| c) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c & (a \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&b&a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;  | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;    | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b)&c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b) \|c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                    |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                      |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)\|c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,a)&c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(b,a)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                   | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b\|c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b\|c\|a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c \| a) &b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;  | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

  # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_25"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_25" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_26"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_26" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(a \| b) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_27"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_27" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                   |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(a & b) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                             | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a & (c \| b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c \| a) & b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&b&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;        | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;  | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;    | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_33"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_33" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan=a & b & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_34"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & ( b \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_34" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

#    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_35"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_35" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_36"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_36" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_37"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_37" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_38"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_38" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                             |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                             | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;        | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b\|c\|a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c \| a) &b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;  | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=(b,a)\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                    |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                      |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                                                                 |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=(b,a)\|c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                              |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan=a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                    |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn1_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                             |
      | dn2_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

  # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                        |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                         |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_73"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_73" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                        |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                               |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                          |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                           |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                       |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                  |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                           |
      | order_1           | ORDER           | join_1                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                  |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                   |
      | order_2           | ORDER           | join_2                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

#    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_75"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(c & a) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_75" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                                  |
      | dn2_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(c & a) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

  # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_76"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_76" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                   |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                    |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                   |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan=c & b & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                   |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                               |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                            |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                      | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;          | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & ( a \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                        |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC            |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(b,a)\|c*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                        |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                                  |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(b,a)\|c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                                       |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                                             |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                                                         |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=(a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn1_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                      |
      | dn2_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=(a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

  # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                 |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                         |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                           |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                  |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                                                              |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                         |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                  |
      | order_1           | ORDER           | join_1                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                   |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                         |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                          |
      | order_2           | ORDER           | join_2                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan=c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                   |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                               |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                     |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                     | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;          | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & ( a \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_63"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_63" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_64"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_64" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_65"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| (b & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_65" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC              |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                    |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                             |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_69"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_69" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_70"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_70" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn4_0//dn3_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn4_0//dn3_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=b & ( a \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_71"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_71" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=b \| (a& c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                            |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_73"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_73" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                           |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                            |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                          |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC           |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                       |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                  |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                           |
      | order_1           | ORDER           | join_1                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                  |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_2                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_75"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(c & a) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_75" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                  |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(c & a) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_76"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_76" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                           |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                            |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=c & b & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                           |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                                       |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                         | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |

    # right join & right join & 0 er & ab, ac  --> not support at this version
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                              | expect                                                                                                                                   | db      |
      | conn_0 | False   | explain /*!dble:plan=(c \| b\| a)*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery'. | schema1 |

  # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_78"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=b & a & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_78" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                       |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                        |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=b & a & c*/SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_79"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_79" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn5_0//dn6_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                      |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_80"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_80" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                       |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn5_0//dn6_0      | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC                                                                                              |
      | merge_1           | MERGE                 | dn5_0//dn6_0                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                        |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=b&(a\|c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | hint explain build failures! check table c & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;    | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c\|a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it.  | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c&a)\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|b)&a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_81"
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_81" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC      |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                  |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                      |
      | order_1           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_81"
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan=b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_81" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_2's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                            |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan=b & a & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_82"
      | conn   | toClose | sql                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_82" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                            |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=b & ( a \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_81"
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_81" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_2's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_2's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

  # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_84"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_84" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=(b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_85"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=(b & c) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_85" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0//dn4_0      | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=(b & c) \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

  # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_86"
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| b \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_86" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0//dn4_0      | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC      |
      | merge_1           | MERGE           | dn3_0//dn4_0                                                                  |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                      |
      | order_1           | ORDER           | join_1                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                       |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | order_2           | ORDER           | join_2                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=c \| b \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_87"
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=(c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_87" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                                        |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=(c\| b) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_88"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=(c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_88" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0//dn4_0      | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                  |
      | merge_1           | MERGE                 | dn3_0//dn4_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                   |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=(c & b) \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=c&(b\|a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;    | hint explain build failures! check table a & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b\|a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;    | hint explain build failures! check table a & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| (a& c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | hint explain build failures! check table c & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;       | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;    | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it.  | schema1 |

  @delete_mysql_tables
  Scenario: shardingTable  + shardingTable  +  singleTable  Directed Acyclic Graph && right join   #2
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
            <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
            <shardingTable name="Dept" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname"/>
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

    # create table used in comparing mysql
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | True    | create database if not exists schema1                                                                                                                                                                                                                                                                             | mysql   | success |
      | conn_0 | False   | drop table if exists Employee;drop table if exists Dept;drop table if exists Level;drop table if exists Info                                                                                                                                                                                                      | schema1 | success |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC     |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & left join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                           |
      | merge_1           | MERGE           | dn3_0                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)\|c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                 | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;       | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan= a & b & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan= a & b & c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan= a \| b \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan= a \| b \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan= a &( b \| c)   */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan= a &( b \| c)   */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a \| b) & c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (a \| b) & c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & left join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan= (a & b) \| c  */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                   |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan= (a & b) \| c  */SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;       | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c& (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                 |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC     |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                           |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                           |
      | merge_1           | MERGE           | dn3_0                                                                                                                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)\|c */SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                  | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b\|c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;    | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c\|b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;    | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;    | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&b&a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;       | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a LEFT JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b)&c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan= (a,b) \|c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                    |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                      |
      | merge_1           | MERGE           | dn3_0                                                                                                                                                                        |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)\|c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # left join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan= (b,a)&c  */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(b,a)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                   | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b\|c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;     | hint explain build failures! check table a & or \| condition                                    | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b\|c\|a */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c \| a) &b */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;  | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname LEFT JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

  # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_25"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| b \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_25" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_26"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| b) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_26" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(a \| b) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_27"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & b) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_27" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                   |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                     |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(a & b) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                            | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c\|b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;    | some errors near the node 'b'. Because left join and inner join can't point to same node.       | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;    | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&b&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;       | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=b & c & a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager inner JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;   | can't use '{node=b}' node for root. Because exists some left join relations point to this node. | schema1 |


    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_33"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=a & b & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_33" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                | db      |
      | conn_0 | true    | /*#dble:plan=a & b & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_34"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & ( b \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_34" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_35"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| (b & c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_35" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_36"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| a \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_36" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_37"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| a) & c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_37" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # left join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_38"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(b & a) \| c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_38" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                             |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=(b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                             | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&c&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;        | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b\|c\|a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;      | can't use this hints,because exists some left join relations point to node: {node=c}            | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c \| a) &b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name;  | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=c & (b \| a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a inner JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=(b,a)\|c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                    |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where 1=1  ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                            |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                      |
      | merge_1           | MERGE           | dn3_0                                                                                                                                                                        |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=(b,a)\|c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                              |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan=a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                    |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                            |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn1_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                             |
      | dn2_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

  # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                        |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                         |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_73"
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | false   | explain /*!dble:plan=b & ( c \| a )*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_73" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                            |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                             |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                      |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                    |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | true    | /*#dble:plan=b & ( c \| a )*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                          |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                           |
      | merge_1           | MERGE           | dn3_0                                                                                              |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                  |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                           |
      | order_1           | ORDER           | join_1                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                  |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                   |
      | order_2           | ORDER           | join_2                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_75"
      | conn   | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_0 | false   | explain /*!dble:plan=(c & a) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_75" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                                  |
      | dn2_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | true    | /*#dble:plan=(c & a) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

  # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_76"
      | conn   | toClose | sql                                                                                                                                                                                                                | db      |
      | conn_0 | false   | explain /*!dble:plan=c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_76" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                   |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                    |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                   |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                       | db      |
      | conn_0 | true    | /*#dble:plan=c & b & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                   |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                            |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                      | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;          | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & ( a \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a,b)&c*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Employee` `a` join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                        |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC            |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_3                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a,b)&c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn   | toClose | sql                                                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(b,a)\|c*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`b`.`manager` from  `Dept` `b` join  `Employee` `a` on `b`.`deptname` = `a`.`deptname` where `b`.`deptid` = 3 ORDER BY `a`.`name` ASC,`b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                        |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC                                                                                                  |
      | merge_1           | MERGE           | dn3_0                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(b,a)\|c*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

# inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                                                       |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                                            |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                        |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                                                    |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                                             |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                                                |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                                              |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                                                     |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where  ( `b`.`deptid` = 3 AND `b`.`manager` in ('{NEED_TO_REPLACE}')) ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                                                    |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                                                     |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=(a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                                                  | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn1_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                      |
      | dn2_1             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC                                      |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_2           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                         | db      |
      | conn_0 | true    | /*#dble:plan=(a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

  # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                              |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                 |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                           |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                      |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                         |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                                |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                       |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                 |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                      |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                       |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                 |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 1 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                  |
      | merge_1           | MERGE           | dn3_0                                                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                             |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                         |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                                                                  |
      | order_1           | ORDER           | join_1                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                                                                   |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`deptname` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                                                         |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                                                          |
      | order_2           | ORDER           | join_2                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan=c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                                                 | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                   |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                     |
      | dn2_0             | BASE SQL              | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 ORDER BY `b`.`manager` ASC                                                                                     |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                          |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                                    |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`deptname` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`deptname` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                          |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                           |
      | order_2           | ORDER                 | join_2                                                                                                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                                        | db      |
      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                     | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;          | hint explain build failures! check table a & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b & ( a \| c ) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name; | hint explain build failures! check table b & or \| condition                                | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM  Employee a INNER JOIN Dept b on a.deptname=b.deptname and b.deptid=3 INNER JOIN Info c on a.name=c.name and b.manager=c.name order by a.name;        | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_63"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| b \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_63" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=a \| b \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_64"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=a & ( b \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_64" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=a & ( b \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_65"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=a \| (b & c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_65" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=a \| (b & c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_66"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=a & c & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_66" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC              |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=a & c & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_67"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a \| c) & b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_67" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                   |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                    |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                     |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                     |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                      |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a \| c) & b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_68"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(a & c) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_68" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_0             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | order_1           | ORDER                 | join_1                                                                                                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                             |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(a & c) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_69"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_69" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                               |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                        |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                       |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                            |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                       |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                                        |
      | order_1           | ORDER           | join_1                                                                                  |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                 |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE           | dn3_0                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_70"
      | conn   | toClose | sql                                                                                                                                                                                                               | db      |
      | conn_0 | false   | explain /*!dble:plan=b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_70" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC           |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_0 | true    | /*#dble:plan=b & ( a \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_71"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| (a& c)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_71" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                 |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC,`c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=b \| (a& c)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_72"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_72" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC                     |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                            |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_73"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_73" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                           |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                            |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_74"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| a \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_74" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                          |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC           |
      | merge_1           | MERGE           | dn3_0                                                                              |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC      |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC      |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                  |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                           |
      | order_1           | ORDER           | join_1                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | dn2_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                                  |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_2                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=c \| a \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_75"
      | conn   | toClose | sql                                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=(c & a) \| b*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_75" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                  |
      | dn2_1             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC,`b`.`manager` ASC                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | join_2                                                                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=(c & a) \| b*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

  # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_76"
      | conn   | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=c & b & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_76" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                           |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                            |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC                          |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=c & b & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    # inner join & inner join & 0 er & ab, ac bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_77"
      | conn   | toClose | sql                                                                                                                                                                                                            | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| (b& a)*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_77" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                          |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                           |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                                              |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                   |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                                  |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                                           |
      | order_1           | ORDER                 | join_1                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                                            |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC,`a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                       |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                                  |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                   |
      | order_2           | ORDER                 | join_2                                                                                                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                                            |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_0 | true    | /*#dble:plan=c \| (b& a)*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                         | expect                                                                                      | db      |
      | conn_0 | False   | explain /*!dble:plan=(a,b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(b,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(a,c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&(c,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(a,b) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | The ER relation in the hint currently only supports when it exists in the headmost of hint. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(a,b)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a INNER JOIN Dept b on a.name=b.manager INNER JOIN Info c on a.name=c.name and b.manager=c.name ORDER BY a.name; | hint explain build failures! check ER condition                                             | schema1 |

    # right join & right join & 0 er & ab, ac  --> not support at this version
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | expect                                                                                                                                   | db      |
      | conn_0 | False   | explain /*!dble:plan=c & b & a*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager RIGHT JOIN Level c ON a.level=c.levelname ORDER BY a.name; | we don't support optimize this sql use hints yet. Maybe this sql contains 'multi right join' or 'cartesian with relation' or 'subquery'. | schema1 |

  # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_78"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=b & a & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_78" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                       |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC   |
      | merge_1           | MERGE                 | dn4_0                                                                                                                                                                           |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                                |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=b & a & c*/SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_79"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| a) & c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_79" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                     |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                              |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                     |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                              |
      | order_1           | ORDER                 | join_1                                                                                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                       |
      | dn4_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_4's RESULTS; select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`levelname` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`levelname` ASC |
      | merge_1           | MERGE                 | dn4_0                                                                                                                                                                         |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                                       |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                              |
      | order_2           | ORDER                 | join_2                                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(b \| a) & c*/SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, ac
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_80"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_0 | false   | explain /*!dble:plan=(b & a) \| c*/ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |
    Then check resultset "rs_80" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                                       |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                                |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                               |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                                    |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                                |
      | order_1           | ORDER                 | join_1                                                                                                                                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                                         |
      | dn4_0             | BASE SQL              | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC                                                                                              |
      | merge_1           | MERGE                 | dn4_0                                                                                                                                                                           |
      | join_2            | JOIN                  | shuffle_field_2; merge_1                                                                                                                                                        |
      | order_2           | ORDER                 | join_2                                                                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_0 | true    | /*#dble:plan=(b & a) \| c*/SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=b&(a\|c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | hint explain build failures! check table c & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;    | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name;  | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b&(c\|a) */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | You are using wrong hint. please check the node 'c',there are no previous nodes connect to it.  | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c&a)\|b */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|b)&a */ SELECT a.name,a.deptname,b.manager,c.salary FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Level c ON a.level=c.levelname ORDER BY a.name; | can't use '{node=c}' node for root. Because exists some left join relations point to this node. | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_81"
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=b \| a \| c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_81" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_1            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC      |
      | merge_1           | MERGE           | dn3_0                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_1                                                      |
      | order_1           | ORDER           | join_2                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=b \| a \| c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_81"
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan=b & a & c*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_81" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_2's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan=b & a & c*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_82"
      | conn   | toClose | sql                                                                                                                                                                                             | db      |
      | conn_0 | false   | explain /*!dble:plan=b & ( a \| c )*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_82" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                    | db      |
      | conn_0 | true    | /*#dble:plan=b & ( a \| c )*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

  # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_84"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=(b \| c) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_84" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | join_1            | JOIN                  | shuffle_field_1; merge_1                                                                                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_4                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=(b \| c) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_84"
      | conn   | toClose | sql                                                                                                                                                                                        | db      |
      | conn_0 | false   | explain /*!dble:plan=b & c & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_84" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC      |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                             |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                              |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_2's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_2's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                                    |
      | order_1           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_0 | true    | /*#dble:plan=b & c & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_85"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=(b & c) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_85" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                      |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                              |
      | dn3_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `c`.`name` ASC |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                          |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_1                                                                                                                                                        |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                               |
      | shuffle_field_2   | SHUFFLE_FIELD         | join_1                                                                                                                                                         |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                  |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                   |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                              |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                               |
      | order_1           | ORDER                 | join_2                                                                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_1                                                                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=(b & c) \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

  # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_86"
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=c \| b \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_86" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn3_0             | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC      |
      | merge_1           | MERGE           | dn3_0                                                                         |
      | dn1_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | dn2_0             | BASE SQL        | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | join_1            | JOIN            | merge_1; shuffle_field_3                                                      |
      | order_1           | ORDER           | join_1                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | order_1                                                                       |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                  |
      | shuffle_field_4   | SHUFFLE_FIELD   | merge_and_order_2                                                             |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_4                                              |
      | order_2           | ORDER           | join_2                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_2                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=c \| b \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_87"
      | conn   | toClose | sql                                                                                                                                                                                          | db      |
      | conn_0 | false   | explain /*!dble:plan=(c\| b) & a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_87" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                           |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                            |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                               |
      | dn1_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | dn2_0             | BASE SQL              | select `b`.`manager` from  `Dept` `b` ORDER BY `b`.`manager` ASC                                                                                                    |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                                   |
      | join_1            | JOIN                  | merge_1; shuffle_field_3                                                                                                                                            |
      | order_1           | ORDER                 | join_1                                                                                                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD         | order_1                                                                                                                                                             |
      | dn1_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | dn2_1             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_3's RESULTS; select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`name` in ('{NEED_TO_REPLACE}') ORDER BY `a`.`name` ASC |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                                        |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                                   |
      | join_2            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                                    |
      | order_2           | ORDER                 | join_2                                                                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_2                                                                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                 | db      |
      | conn_0 | true    | /*#dble:plan=(c\| b) & a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    # right join & inner join & 0 er & ab, bc
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_88"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_0 | false   | explain /*!dble:plan=(c & b) \| a*/ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |
    Then check resultset "rs_88" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1                | SQL/REF-2                                                                                                                                                 |
      | dn3_0             | BASE SQL              | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                  |
      | merge_1           | MERGE                 | dn3_0                                                                                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD         | merge_1                                                                                                                                                   |
      | dn1_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | dn2_0             | BASE SQL(May No Need) | HINT_NEST_LOOP - shuffle_field_1's RESULTS; select `b`.`manager` from  `Dept` `b` where `b`.`manager` in ('{NEED_TO_REPLACE}') ORDER BY `b`.`manager` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER       | dn1_0; dn2_0                                                                                                                                              |
      | shuffle_field_4   | SHUFFLE_FIELD         | merge_and_order_1                                                                                                                                         |
      | join_1            | JOIN                  | shuffle_field_1; shuffle_field_4                                                                                                                          |
      | order_1           | ORDER                 | join_1                                                                                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD         | order_1                                                                                                                                                   |
      | dn1_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | dn2_1             | BASE SQL              | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                             |
      | merge_and_order_2 | MERGE_AND_ORDER       | dn1_1; dn2_1                                                                                                                                              |
      | shuffle_field_5   | SHUFFLE_FIELD         | merge_and_order_2                                                                                                                                         |
      | join_2            | JOIN                  | shuffle_field_2; shuffle_field_5                                                                                                                          |
      | order_2           | ORDER                 | join_2                                                                                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD         | order_2                                                                                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                  | db      |
      | conn_0 | true    | /*#dble:plan=(c & b) \| a*/SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                           | expect                                                                                          | db      |
      | conn_0 | False   | explain /*!dble:plan=c&(b\|a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;    | hint explain build failures! check table a & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=c&(b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | The ER relation in the hint currently only supports when it exists in the headmost of hint.     | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(c,b)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a,c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,a)&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=b \| (a& c) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name; | hint explain build failures! check table c & condition                                          | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c,a) */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=(b,c)&a */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | hint explain build failures! check ER condition                                                 | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a&b&c */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;       | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | False   | explain /*!dble:plan=a\|c\|b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;     | can't use '{node=a}' node for root. Because exists some left join relations point to this node. | schema1 |
      | conn_0 | True    | explain /*!dble:plan=(c\|a)&b */ SELECT a.name,a.deptname,b.manager,c.country FROM Employee a RIGHT JOIN Dept b ON a.name=b.manager INNER JOIN Info c ON b.manager=c.name ORDER BY a.name;    | You are using wrong hint. please check the node 'a',there are no previous nodes connect to it.  | schema1 |
