# -*- coding=utf-8 -*-
# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhangqian at 2021/12/28
Feature: test with useNewJoinOptimizer=true

#more information find in confluence: http://10.186.18.11/confluence/pages/viewpage.action?pageId=32064447
                        #jira: http://10.186.18.11/jira/browse/DBLE0REQ-1469

  @delete_mysql_tables
  Scenario: shardingTable + singleTable + singleTable  #NO ER
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'], 'mysql': ['schema1']}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
        $a  -DuseNewJoinOptimizer=true
      """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
            <singleTable name="Dept" shardingNode="dn1" />
            <singleTable name="Info" shardingNode="dn2" />
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
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Korean','Human Resources'),('Jessi', 27,'Korean','Finance')                                          | schema1 | success |

     #create table used in comparing
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Korean','Human Resources'),('Jessi', 27,'Korean','Finance')                                          | schema1 | success |

    # left join & left join & ab, ac   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_0 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1           | MERGE           | dn1_1                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                            |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC  |
      | merge_2           | MERGE           | dn2_1                                                                             |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_1           | ORDER           | join_2                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                              | db      |
      | conn_0 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & left join & ab, ac and contain subquery    -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                                            | db      |
      | conn_1 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                                                |
      | merge_1           | MERGE           | dn1_1                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | order_1           | ORDER           | join_2                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                    | db      |
      | conn_1 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & left join & ab, bc   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_2 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |
    Then check resultset "rs_3" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1           | MERGE           | dn1_1                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                          |
      | order_1           | ORDER           | join_1                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                           |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC  |
      | merge_2           | MERGE           | dn2_1                                                                             |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_2           | ORDER           | join_2                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                              | db      |
      | conn_2 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |

    # left join & left join & ab, bc a  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_3 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC              |
      | merge_1           | MERGE           | dn1_1                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                      |
      | order_1           | ORDER           | join_1                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                       |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC              |
      | merge_2           | MERGE           | dn2_1                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_2           | ORDER           | join_2                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_3 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |

    # left join & left join & ab, ac c  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                                                                                                                                             | db      |
      | conn_4 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name | schema1 |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                      |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                   |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                              |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                               |
      | merge_1           | MERGE           | dn1_1                                                                                                          |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                       |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                         |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                          |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                       |
      | order_1           | ORDER           | join_2                                                                                                         |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_4 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name | schema1 |

    # left join & left join & ab, ac b  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_5 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.Name | schema1 |
    Then check resultset "rs_6" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptid`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_1           | MERGE           | dn1_1                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                        |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC              |
      | merge_2           | MERGE           | dn2_1                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_1           | ORDER           | join_2                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                              | db      |
      | conn_5 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.Name | schema1 |

    # left join & left join & ac, ab b  and contain subquery -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                                                                                                                                                    | db      |
      | conn_6 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName and b.deptid=2 order by a.Name | schema1 |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                               |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                                                                                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                        |
      | dn5_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC                                                                                                       |
      | merge_1           | MERGE           | dn5_0                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                 |
      | order_1           | ORDER           | join_1                                                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                  |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from (select `Dept`.`manager`,`Dept`.`deptname` from  `Dept` where `Dept`.`deptid` = 2 order by `Dept`.`deptname` ASC) b order by `b`.`deptname` ASC |
      | merge_2           | MERGE           | dn1_1                                                                                                                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                            | db      |
      | conn_6 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Level c on a.Level=c.levelname LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName and b.deptid=2 order by a.Name | schema1 |

    #left join & left join & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_7 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                     |
      | merge_1           | MERGE           | dn1_1                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                            |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                            |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_7 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & inner join(2nd) & ab bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                                                                                             | db      |
      | conn_8 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1           | MERGE           | dn1_1                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                          |
      | order_1           | ORDER           | join_1                                                                            |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                           |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
      | merge_2           | MERGE           | dn2_1                                                                             |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_2           | ORDER           | join_2                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                     | db      |
      | conn_8 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName order by a.name | schema1 |

    # left join & inner join(1st) & ab ac  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                                                                             | db      |
      | conn_9 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1           | MERGE           | dn1_1                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                            |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
      | merge_2           | MERGE           | dn2_1                                                                             |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_1           | ORDER           | join_2                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                     | db      |
      | conn_9 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & inner join(2nd) & ab ac  -->  inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn    | toClose | sql                                                                                                                                                             | db      |
      | conn_10 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
      | merge_1           | MERGE           | dn2_1                                                                             |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                          |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                            |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_2           | MERGE           | dn1_1                                                                             |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_1           | ORDER           | join_2                                                                            |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                     | db      |
      | conn_10 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |


    # left join & inner join(2nd) & ab ac and contain subquery  -->  inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn    | toClose | sql                                                                                                                                                                             | db      |
      | conn_11 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn2_1                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                                                |
      | merge_2           | MERGE           | dn1_1                                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | order_1           | ORDER           | join_2                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                     | db      |
      | conn_11 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & cross join(2nd) & ab ac   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn    | toClose | sql                                                                                                                                         | db      |
      | conn_12 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c order by a.name | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1           | MERGE           | dn1_1                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0             | BASE SQL        | select `c`.`salary` from  `Level` `c`                                         |
      | merge_2           | MERGE           | dn5_0                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                 | db      |
      | conn_12 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Level c order by a.name | schema1 |

    # left join & cross join(1st) & ac ab   -->  cross join last
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn    | toClose | sql                                                                                                                                         | db      |
      | conn_13 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Level c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1           | MERGE           | dn1_1                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0             | BASE SQL        | select `c`.`salary` from  `Level` `c`                                         |
      | merge_2           | MERGE           | dn5_0                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                 | db      |
      | conn_13 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Level c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |

    # left join & cross join(1st) & ac bc   -->  change root node to c , and cross join last
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn    | toClose | sql                                                                                                                                    | db      |
      | conn_14 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a, Info c LEFT JOIN Dept b on b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                        |
      | dn2_0             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn2_0                                                                            |
      | dn1_0             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_2           | MERGE           | dn1_0                                                                            |
      | join_1            | JOIN            | merge_1; merge_2                                                                 |
      | shuffle_field_1   | SHUFFLE_FIELD   | join_1                                                                           |
      | dn1_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | dn2_1             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_1; dn2_1                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | merge_and_order_1                                                                |
      | join_2            | JOIN            | shuffle_field_1; shuffle_field_3                                                 |
      | order_1           | ORDER           | join_2                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                            | db      |
      | conn_14 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a, Info c LEFT JOIN Dept b on b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & inner join(2nd) & ac a, ab c b  -->  inner join first, and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
      | conn    | toClose | sql                                                                                                                                                                                                                           | db      |
      | conn_15 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=7012 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=20000  and b.deptid=4 order by a.Name | schema1 |
    Then check resultset "rs_16" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`a`.`empid` from  `Employee` `a` ORDER BY `a`.`deptname` ASC     |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level`,`a`.`empid` from  `Employee` `a` ORDER BY `a`.`deptname` ASC     |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 4 order by `b`.`deptname` ASC       |
      | merge_1           | MERGE           | dn1_1                                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                      |
      | order_1           | ORDER           | join_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                       |
      | dn5_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 20000 order by `c`.`levelname` ASC |
      | merge_2           | MERGE           | dn5_0                                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                      |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                        |
      | order_2           | ORDER           | where_filter_1                                                                                                |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                                                   | db      |
      | conn_15 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname and a.empid=7012 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=20000  and b.deptid=4 order by a.Name | schema1 |

    # left join & inner join(2nd) & ab, bc a  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn    | toClose | sql                                                                                                                                                                                        | db      |
      | conn_16 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                           |
      | merge_1           | MERGE           | dn1_1                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                           |
      | merge_2           | MERGE           | dn2_1                                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | order_2           | ORDER           | join_2                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                | db      |
      | conn_16 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |

    # left join & inner join(1st) & ab, bc a  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_18"
      | conn    | toClose | sql                                                                                                                                                                                        | db      |
      | conn_17 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_18" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC              |
      | merge_1           | MERGE           | dn1_1                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                      |
      | order_1           | ORDER           | join_1                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                       |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC              |
      | merge_2           | MERGE           | dn2_1                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_2           | ORDER           | join_2                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                | db      |
      | conn_17 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |

    # left join & inner join(2nd) & ab, ac b  -->  inner join first and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_18 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                            |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                    |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                    |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                         |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                    |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                                                   |
      | merge_1           | MERGE           | dn2_1                                                                                                                |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                             |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                               |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname`,`b`.`deptid` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC |
      | merge_2           | MERGE           | dn1_1                                                                                                                |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                             |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                               |
      | order_1           | ORDER           | where_filter_1                                                                                                       |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                    | db      |
      | conn_18 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # left join & inner join(2nd) & ab, ac c  -->  inner join first and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn    | toClose | sql                                                                                                                                                                                   | db      |
      | conn_19 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                        |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn2_1                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                           |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                 |
      | merge_2           | MERGE           | dn1_1                                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                         |
      | order_1           | ORDER           | join_2                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                           | db      |
      | conn_19 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |

    # left join & inner join(1st) & ab, ac b  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_21"
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_20 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_21" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptid`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_1           | MERGE           | dn1_1                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                        |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                            |
      | merge_2           | MERGE           | dn2_1                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_1           | ORDER           | join_2                                                                                        |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                    | db      |
      | conn_20 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # left join & inner join(1st) & ab, ac c  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_22"
      | conn    | toClose | sql                                                                                                                                                                                   | db      |
      | conn_21 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |
    Then check resultset "rs_22" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                        |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                 |
      | merge_1           | MERGE           | dn1_1                                                                                            |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                         |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                           |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                         |
      | order_1           | ORDER           | join_2                                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                          |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                           | db      |
      | conn_21 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |

    # left join & inner join(2nd) & ab, ac b and contain subquery -->  inner join first and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_23"
      | conn    | toClose | sql                                                                                                                                                                                            | db      |
      | conn_22 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_23" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_1           | MERGE           | dn2_1                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname`,`b`.`deptid` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC            |
      | merge_2           | MERGE           | dn1_1                                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | where_filter_1    | WHERE_FILTER    | join_2                                                                                                                          |
      | order_1           | ORDER           | where_filter_1                                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                    | db      |
      | conn_22 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # left join & cross join(2nd) & ac, ab, c  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_24"
      | conn    | toClose | sql                                                                                                                                                                   | db      |
      | conn_23 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname INNER JOIN Dept b where c.salary=10000  order by a.Name | schema1 |
    Then check resultset "rs_24" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                    |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`level` ASC                    |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                             |
      | dn5_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC |
      | merge_1           | MERGE           | dn5_0                                                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                      |
      | where_filter_1    | WHERE_FILTER    | join_1                                                                                                        |
      | order_1           | ORDER           | where_filter_1                                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b`                                                                         |
      | merge_2           | MERGE           | dn1_1                                                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                           | db      |
      | conn_23 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a LEFT JOIN  Level c on a.Level=c.levelname INNER JOIN Dept b where c.salary=10000  order by a.Name | schema1 |

    # left join & cross join(1st) & ac, ab, c  -->  cross join last
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_25"
      | conn    | toClose | sql                                                                                                                                                       | db      |
      | conn_24 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM (Employee a, Level c) LEFT JOIN Dept b on a.Name=b.Manager where c.salary=10000  order by a.Name | schema1 |
    Then check resultset "rs_25" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1           | MERGE           | dn1_1                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0             | BASE SQL        | select `c`.`salary` from  `Level` `c` where `c`.`salary` = 10000              |
      | merge_2           | MERGE           | dn5_0                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                               | db      |
      | conn_24 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM (Employee a, Level c) LEFT JOIN Dept b on a.Name=b.Manager where c.salary=10000  order by a.Name | schema1 |

    # left join & cross join(1st) & ac, bc a  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_26"
      | conn    | toClose | sql                                                                                                                                                       | db      |
      | conn_25 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Info c) LEFT JOIN Dept b on c.DeptName=b.DeptName and a.level='P7' order by a.Name | schema1 |
    Then check resultset "rs_26" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                        |
      | dn1_0           | BASE SQL      | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                |
      | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                     |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                          |
      | dn2_1           | BASE SQL      | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_2         | MERGE         | dn2_1                                                                            |
      | join_1          | JOIN          | shuffle_field_1; merge_2                                                         |
      | order_1         | ORDER         | join_1                                                                           |
      | shuffle_field_2 | SHUFFLE_FIELD | order_1                                                                          |
      | dn1_1           | BASE SQL      | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_3         | MERGE         | dn1_1                                                                            |
      | join_2          | JOIN          | shuffle_field_2; merge_3                                                         |
      | order_2         | ORDER         | join_2                                                                           |
      | shuffle_field_3 | SHUFFLE_FIELD | order_2                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                               | db      |
      | conn_25 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Info c) LEFT JOIN Dept b on c.DeptName=b.DeptName and a.level='P7' order by a.Name | schema1 |

    # left join & inner join(2nd) & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_27"
      | conn    | toClose | sql                                                                                                                                                                                    | db      |
      | conn_26 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_27" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                            |
      | merge_1           | MERGE           | dn1_1                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_26 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & inner join(1st) & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_28"
      | conn    | toClose | sql                                                                                                                                                                                    | db      |
      | conn_27 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a inner join Dept b on a.name=b.manager left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_28" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                            |
      | merge_1           | MERGE           | dn1_1                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_27 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a inner join Dept b on a.name=b.manager left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & cross join(1st) & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_29"
      | conn    | toClose | sql                                                                                                                                                        | db      |
      | conn_28 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Dept b) left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_29" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                  |
      | dn1_0           | BASE SQL      | select `a`.`name`,`a`.`deptname` from  `Employee` `a`                                                      |
      | dn2_0           | BASE SQL      | select `a`.`name`,`a`.`deptname` from  `Employee` `a`                                                      |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1 | SHUFFLE_FIELD | merge_1                                                                                                    |
      | dn1_1           | BASE SQL      | select `b`.`manager`,`b`.`deptname` from  `Dept` `b`                                                       |
      | merge_2         | MERGE         | dn1_1                                                                                                      |
      | join_1          | JOIN          | shuffle_field_1; merge_2                                                                                   |
      | order_1         | ORDER         | join_1                                                                                                     |
      | shuffle_field_2 | SHUFFLE_FIELD | order_1                                                                                                    |
      | dn2_1           | BASE SQL      | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_3         | MERGE         | dn2_1                                                                                                      |
      | join_2          | JOIN          | shuffle_field_2; merge_3                                                                                   |
      | shuffle_field_3 | SHUFFLE_FIELD | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                | db      |
      | conn_28 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Dept b) left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # inner join & inner join & ab, ac  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_30"
      | conn    | toClose | sql                                                                                                                                                                 | db      |
      | conn_29 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |
    Then check resultset "rs_30" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                 |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                              |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                         |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                          |
      | merge_1           | MERGE           | dn1_1                                                                                     |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                  |
      | order_1           | ORDER           | join_1                                                                                    |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                   |
      | dn5_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` order by `c`.`levelname` ASC        |
      | merge_2           | MERGE           | dn5_0                                                                                     |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                  |
      | order_2           | ORDER           | join_2                                                                                    |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                   |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                         | db      |
      | conn_29 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Level c on a.level=c.levelname order by a.name | schema1 |

    # inner join & inner join & ab, bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_31"
      | conn    | toClose | sql                                                                                                                                                                   | db      |
      | conn_30 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |
    Then check resultset "rs_31" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                        |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                     |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC  |
      | merge_1           | MERGE           | dn1_1                                                                            |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                         |
      | order_1           | ORDER           | join_1                                                                           |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                          |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                            |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                         |
      | order_2           | ORDER           | join_2                                                                           |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                           | db      |
      | conn_30 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |

    # cross join & cross join & ab, bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_32"
      | conn    | toClose | sql                                                                                                                      | db      |
      | conn_31 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Dept b INNER JOIN Level c order by a.name | schema1 |
    Then check resultset "rs_32" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b`                                         |
      | merge_1           | MERGE           | dn1_1                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0             | BASE SQL        | select `c`.`salary` from  `Level` `c`                                         |
      | merge_2           | MERGE           | dn5_0                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                              | db      |
      | conn_31 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Dept b INNER JOIN Level c order by a.name | schema1 |

    # inner join & inner join & ab, ac b  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_33"
      | conn    | toClose | sql                                                                                                                                                                             | db      |
      | conn_32 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_33" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                               |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                       |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC |
      | merge_1           | MERGE           | dn1_1                                                                                                   |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                  |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                                      |
      | merge_2           | MERGE           | dn2_1                                                                                                   |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                |
      | order_1           | ORDER           | join_2                                                                                                  |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                     | db      |
      | conn_32 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # inner join & inner join & ab, ac b and contain subquery -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_34"
      | conn    | toClose | sql                                                                                                                                                                                             | db      |
      | conn_33 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_34" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC                         |
      | merge_1           | MERGE           | dn1_1                                                                                                                           |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                                           |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | order_1           | ORDER           | join_2                                                                                                                          |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                     | db      |
      | conn_33 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # inner join & inner join & ab, bc a  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_35"
      | conn    | toClose | sql                                                                                                                                                                               | db      |
      | conn_34 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_35" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                           |
      | merge_1           | MERGE           | dn1_1                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn2_1             | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                                         |
      | merge_2           | MERGE           | dn2_1                                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | order_2           | ORDER           | join_2                                                                                                     |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                       | db      |
      | conn_34 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName and a.level='P7' order by a.name | schema1 |

      # inner join & inner join & ac a, ab c  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_36"
      | conn    | toClose | sql                                                                                                                                                                                                           | db      |
      | conn_35 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Level c on a.level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name | schema1 |
    Then check resultset "rs_36" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`level` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`level` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                   |
      | dn5_0             | BASE SQL        | select `c`.`salary`,`c`.`levelname` from  `Level` `c` where `c`.`salary` = 10000 order by `c`.`levelname` ASC       |
      | merge_1           | MERGE           | dn5_0                                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                            |
      | order_1           | ORDER           | join_1                                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                                    |
      | merge_2           | MERGE           | dn1_1                                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                            |
      | order_2           | ORDER           | join_2                                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                                   | db      |
      | conn_35 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Level c on a.level=c.levelname and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.salary=10000 order by a.name | schema1 |

    # cross join & cross join & ab, bc, b  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_37"
      | conn    | toClose | sql                                                                                                                                       | db      |
      | conn_36 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Dept b INNER JOIN Level c where b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_37" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2                  |
      | merge_1           | MERGE           | dn1_1                                                                         |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2   | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0             | BASE SQL        | select `c`.`salary` from  `Level` `c`                                         |
      | merge_2           | MERGE           | dn5_0                                                                         |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                               | db      |
      | conn_36 | true    | SELECT a.Name,a.DeptName,b.Manager,c.salary FROM Employee a INNER JOIN Dept b INNER JOIN Level c where b.deptid=2 order by a.name | schema1 |

    # cross join & cross join & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_38"
      | conn    | toClose | sql                                                                                                                                                                                                | db      |
      | conn_37 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name | schema1 |
    Then check resultset "rs_38" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                     |
      | merge_1           | MERGE           | dn1_1                                                                                               |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                            |
      | order_1           | ORDER           | join_1                                                                                              |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                               |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                            |
      | order_2           | ORDER           | join_2                                                                                              |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                        | db      |
      | conn_37 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name | schema1 |

    # cross join & cross join & ab, ac bc and contain subquery -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn    | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_38 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN (select * from Info) c on a.DeptName = c.DeptName and b.Manager=c.Name order by a.Name | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                            |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                            |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                             |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                        |
      | dn1_1             | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                                                                                                                                                         |
      | merge_1           | MERGE           | dn1_1                                                                                                                                                                                                                    |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                 |
      | order_1           | ORDER           | join_1                                                                                                                                                                                                                   |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                  |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from (select `Info`.`country`,`Info`.`deptname`,`Info`.`name` from  `Info` order by `Info`.`deptname` ASC,`Info`.`name` ASC) c order by `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                                                                                                                                    |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                                                                                                                                 |
      | order_2           | ORDER           | join_2                                                                                                                                                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | order_2                                                                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_38 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN (select * from Info) c on a.DeptName = c.DeptName and b.Manager=c.Name order by a.Name | schema1 |

    # cross join & cross join & ab b, ac bc  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_40"
      | conn    | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_39 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager and b.deptid=3 INNER JOIN Info c on a.name = c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_40" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn2_0             | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | dn1_1             | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC     |
      | merge_1           | MERGE           | dn1_1                                                                                                      |
      | join_1            | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1           | ORDER           | join_1                                                                                                     |
      | shuffle_field_2   | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn2_1             | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_2           | MERGE           | dn2_1                                                                                                      |
      | join_2            | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | shuffle_field_3   | SHUFFLE_FIELD   | join_2                                                                                                     |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                              | db      |
      | conn_39 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager and b.deptid=3 INNER JOIN Info c on a.name = c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # cross join & cross join & ab, ac ab  -->  not support
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_"
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_40 | false   | explain select a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName inner join Info c on a.DeptName=c.DeptName and a.name=b.manager | schema1 |

  @delete_mysql_tables
  Scenario: shardingTable  + singleTable  +  globalTable  #NO ER
  """
  {'delete_mysql_tables': {'mysql-master1': ['db1', 'db2', 'db3'], 'mysql-master2': ['db1', 'db2', 'db3'],'mysql': ['schema1']}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
      """
        $a  -DuseNewJoinOptimizer=true
      """
    Given delete the following xml segment
      | file         | parent         | child                  |
      | sharding.xml | {'tag':'root'} | {'tag':'schema'}       |
      | sharding.xml | {'tag':'root'} | {'tag':'shardingNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <shardingTable name="Employee" shardingNode="dn1,dn2" function="func_hashString" shardingColumn="deptname" />
            <globalTable name="Dept" shardingNode="dn3,dn4" />
            <singleTable name="Info" shardingNode="dn5" />
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
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
#      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
#      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Korean','Human Resources'),('Jessi', 27,'Korean','Finance')                                          | schema1 | success |

     #create table used in comparing
    Then execute sql in "mysql" in "mysql" mode
      | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
#      | conn_0 | false   | create table Level(levelname varchar(250) not null,levelid int not null,salary int not null)engine=innodb charset=utf8                                                                                                                                                                                            | schema1 | success |
      | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
#      | conn_0 | false   | insert into Level values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000)                                                                                                                                                                                                                             | schema1 | success |
      | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('George', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Korean','Human Resources'),('Jessi', 27,'Korean','Finance')                                          | schema1 | success |

    # left join & left join & ab, ac   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_1"
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_0 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_1" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                          |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                            |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC  |
      | merge_2            | MERGE           | dn5_0                                                                             |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_1            | ORDER           | join_2                                                                            |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                               | db      |
      | conn_0 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name; | schema1 |

    # left join & left join & ab, ac and contain subquery    -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_2"
      | conn   | toClose | sql                                                                                                                                                                            | db      |
      | conn_1 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_2" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                                                |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                                              |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                                           |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | order_1            | ORDER           | join_2                                                                                                                          |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                    | db      |
      | conn_1 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & left join & ab, bc   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_3"
      | conn   | toClose | sql                                                                                                                                                                      | db      |
      | conn_2 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |
    Then check resultset "rs_3" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                          |
      | order_1            | ORDER           | join_1                                                                            |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                           |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC  |
      | merge_2            | MERGE           | dn5_0                                                                             |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_2            | ORDER           | join_2                                                                            |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                              | db      |
      | conn_2 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |

    # left join & left join & ab, bc a  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_4"
      | conn   | toClose | sql                                                                                                                                                                                       | db      |
      | conn_3 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_4" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC              |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                      |
      | order_1            | ORDER           | join_1                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                       |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC              |
      | merge_2            | MERGE           | dn5_0                                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_2            | ORDER           | join_2                                                                                        |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                               | db      |
      | conn_3 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |

    # left join & left join & ab, ac c  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_5"
      | conn   | toClose | sql                                                                                                                                                                                             | db      |
      | conn_4 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name | schema1 |
    Then check resultset "rs_5" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                      |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                              |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                              |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                   |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                              |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                               |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                                             |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                       |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                         |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                          |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                       |
      | order_1            | ORDER           | join_2                                                                                                         |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                        |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                     | db      |
      | conn_4 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.Name | schema1 |

    # left join & left join & ab, ac b  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_6"
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_5 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.Name | schema1 |
    Then check resultset "rs_6" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptid`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC              |
      | merge_2            | MERGE           | dn5_0                                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_1            | ORDER           | join_2                                                                                        |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                       |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                              | db      |
      | conn_5 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName  LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.Name | schema1 |

    # left join & left join & ac, ab b  and contain subquery -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_7"
      | conn   | toClose | sql                                                                                                                                                                                              | db      |
      | conn_6 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName and b.deptid=2 order by a.Name | schema1 |
    Then check resultset "rs_7" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                                                                                                |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                            |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                            |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                             |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC                                                                                                                 |
      | merge_1            | MERGE           | dn5_0                                                                                                                                                                                    |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                 |
      | order_1            | ORDER           | join_1                                                                                                                                                                                   |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                                                                                                  |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from (select `Dept`.`manager`,`Dept`.`deptname` from  `Dept` where `Dept`.`deptid` = 2 order by `Dept`.`deptname` ASC) b order by `b`.`deptname` ASC |
      | merge_2            | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                       |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                                                                                                 |
      | order_2            | ORDER           | join_2                                                                                                                                                                                   |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                                                                                                                  |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                      | db      |
      | conn_6 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Info c on a.name=c.name LEFT JOIN (select * from Dept) b on a.DeptName= b.DeptName and b.deptid=2 order by a.Name | schema1 |

    #left join & left join & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_8"
      | conn   | toClose | sql                                                                                                                                                                                           | db      |
      | conn_7 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_8" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                           |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                        |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                     |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                  |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                            |
      | order_1            | ORDER           | join_1                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                               |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                            |
      | order_2            | ORDER           | join_2                                                                                              |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                             |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                                                   | db      |
      | conn_7 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.name=b.manager LEFT JOIN Info c on a.DeptName=c.DeptName and b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & inner join(2nd) & ab bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_9"
      | conn   | toClose | sql                                                                                                                                                             | db      |
      | conn_8 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_9" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                          |
      | order_1            | ORDER           | join_1                                                                            |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                           |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
      | merge_2            | MERGE           | dn5_0                                                                             |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_2            | ORDER           | join_2                                                                            |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                           |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                     | db      |
      | conn_8 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName order by a.name | schema1 |

    # left join & inner join(1st) & ab ac  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_10"
      | conn   | toClose | sql                                                                                                                                                             | db      |
      | conn_9 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_10" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                          |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                            |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
      | merge_2            | MERGE           | dn5_0                                                                             |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_1            | ORDER           | join_2                                                                            |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                           |

    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn   | toClose | sql                                                                                                                                                     | db      |
      | conn_9 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & inner join(2nd) & ab ac  -->  inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_11"
      | conn    | toClose | sql                                                                                                                                                             | db      |
      | conn_10 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_11" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                         |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                      |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                 |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                |
      | merge_1            | MERGE           | dn5_0                                                                             |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                          |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                            |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC  |
      | merge_2            | MERGE           | /*AllowDiff*/dn4_0                                                                |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                          |
      | order_1            | ORDER           | join_2                                                                            |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                           |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                     | db      |
      | conn_10 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & inner join(2nd) & ab ac and contain subquery  -->  inner join first
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_12"
      | conn    | toClose | sql                                                                                                                                                                             | db      |
      | conn_11 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |
    Then check resultset "rs_12" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_1            | MERGE           | dn5_0                                                                                                                           |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                                                |
      | merge_2            | MERGE           | /*AllowDiff*/dn4_0                                                                                                              |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | order_1            | ORDER           | join_2                                                                                                                          |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                     | db      |
      | conn_11 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName order by a.name | schema1 |

    # left join & cross join(2nd) & ab ac   -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_13"
      | conn    | toClose | sql                                                                                                                                         | db      |
      | conn_12 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Info c order by a.name | schema1 |
    Then check resultset "rs_13" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country` from  `Info` `c`                                         |
      | merge_2            | MERGE           | dn5_0                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                 | db      |
      | conn_12 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.Name=b.Manager INNER JOIN Info c order by a.name | schema1 |

    # left join & cross join(1st) & ac ab   -->  cross join last
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_14"
      | conn    | toClose | sql                                                                                                                                         | db      |
      | conn_13 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Info c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |
    Then check resultset "rs_14" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country` from  `Info` `c`                                         |
      | merge_2            | MERGE           | dn5_0                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                 | db      |
      | conn_13 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Info c LEFT JOIN Dept b on a.Name=b.Manager order by a.Name | schema1 |

    # left join & cross join(1st) & ac bc   -->  change root node to c , and cross join last
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_15"
      | conn    | toClose | sql                                                                                                                                    | db      |
      | conn_14 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a, Info c LEFT JOIN Dept b on b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_15" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_1            | MERGE           | dn5_0                                                                            |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_2            | MERGE           | /*AllowDiff*/dn3_0                                                               |
      | join_1             | JOIN            | merge_1; merge_2                                                                 |
      | shuffle_field_1    | SHUFFLE_FIELD   | join_1                                                                           |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                     |
      | shuffle_field_3    | SHUFFLE_FIELD   | merge_and_order_1                                                                |
      | join_2             | JOIN            | shuffle_field_1; shuffle_field_3                                                 |
      | order_1            | ORDER           | join_2                                                                           |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                            | db      |
      | conn_14 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a, Info c LEFT JOIN Dept b on b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & inner join(2nd) & ac a, ab c b  -->  inner join first, and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_16"
      | conn    | toClose | sql                                                                                                                                                                                                              | db      |
      | conn_15 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN  Info c on a.name=c.name and a.empid=3415 INNER JOIN Dept b on a.DeptName= b.DeptName and c.age=25 and b.deptid=2 order by a.Name | schema1 |
    Then check resultset "rs_16" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                               |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`empid` from  `Employee` `a` ORDER BY `a`.`deptname` ASC           |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`empid` from  `Employee` `a` ORDER BY `a`.`deptname` ASC           |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                      |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                |
      | order_1            | ORDER           | join_1                                                                                                  |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                 |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`age` from  `Info` `c` where `c`.`age` = 25 order by `c`.`name` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                   |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                |
      | where_filter_1     | WHERE_FILTER    | join_2                                                                                                  |
      | shuffle_field_3    | SHUFFLE_FIELD   | where_filter_1                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_15 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN  Info c on a.name=c.name and a.empid=3415 INNER JOIN Dept b on a.DeptName= b.DeptName and c.age=25 and b.deptid=2 order by a.Name | schema1 |

    # left join & inner join(2nd) & ab, bc a  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_17"
      | conn    | toClose | sql                                                                                                                                                                                        | db      |
      | conn_16 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_17" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                           |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                         |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1            | ORDER           | join_1                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                           |
      | merge_2            | MERGE           | dn5_0                                                                                                      |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | order_2            | ORDER           | join_2                                                                                                     |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                | db      |
      | conn_16 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |

    # left join & inner join(1st) & ab, bc a  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_18"
      | conn    | toClose | sql                                                                                                                                                                                        | db      |
      | conn_17 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_18" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a` ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC              |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                      |
      | order_1            | ORDER           | join_1                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                       |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC              |
      | merge_2            | MERGE           | dn5_0                                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_2            | ORDER           | join_2                                                                                        |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                | db      |
      | conn_17 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on c.DeptName=b.DeptName and a.level='P7' order by a.name | schema1 |

    # left join & inner join(2nd) & ab, ac b  -->  inner join first and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_19"
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_18 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_19" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                            |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                    |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                    |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                         |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                    |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                                                   |
      | merge_1            | MERGE           | dn5_0                                                                                                                |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                             |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                               |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname`,`b`.`deptid` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC |
      | merge_2            | MERGE           | /*AllowDiff*/dn4_0                                                                                                   |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                             |
      | where_filter_1     | WHERE_FILTER    | join_2                                                                                                               |
      | order_1            | ORDER           | where_filter_1                                                                                                       |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                              |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                    | db      |
      | conn_18 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # left join & inner join(2nd) & ab, ac c  -->  inner join first and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_20"
      | conn    | toClose | sql                                                                                                                                                                                   | db      |
      | conn_19 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |
    Then check resultset "rs_20" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                        |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                     |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
      | merge_1            | MERGE           | dn5_0                                                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                         |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                           |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                 |
      | merge_2            | MERGE           | /*AllowDiff*/dn4_0                                                                               |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                         |
      | order_1            | ORDER           | join_2                                                                                           |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                           | db      |
      | conn_19 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |

    # left join & inner join(1st) & ab, ac b  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_21"
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_20 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_21" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC             |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                             |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptid`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                            |
      | merge_2            | MERGE           | dn5_0                                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                      |
      | order_1            | ORDER           | join_2                                                                                        |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                       |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                    | db      |
      | conn_20 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # left join & inner join(1st) & ab, ac c  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_22"
      | conn    | toClose | sql                                                                                                                                                                                   | db      |
      | conn_21 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |
    Then check resultset "rs_22" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                        |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                     |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                 |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                               |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                         |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                           |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                            |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                         |
      | order_1            | ORDER           | join_2                                                                                           |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                           | db      |
      | conn_21 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName LEFT JOIN Info c on a.DeptName=c.DeptName and c.country='China' order by a.name | schema1 |

    # left join & inner join(2nd) & ab, ac b and contain subquery -->  inner join first and on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_23"
      | conn    | toClose | sql                                                                                                                                                                                            | db      |
      | conn_22 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_23" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_1            | MERGE           | dn5_0                                                                                                                           |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname`,`b`.`deptid` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC            |
      | merge_2            | MERGE           | /*AllowDiff*/dn3_0                                                                                                              |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | where_filter_1     | WHERE_FILTER    | join_2                                                                                                                          |
      | order_1            | ORDER           | where_filter_1                                                                                                                  |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                    | db      |
      | conn_22 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a LEFT JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # left join & cross join(2nd) & ac, ab, c  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_24"
      | conn    | toClose | sql                                                                                                                                                                | db      |
      | conn_23 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN  Info c on a.name=c.name INNER JOIN Dept b where c.country='China'  order by a.Name | schema1 |
    Then check resultset "rs_24" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                              |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                          |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                          |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'China' order by `c`.`name` ASC |
      | merge_1            | MERGE           | dn5_0                                                                                                  |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                               |
      | where_filter_1     | WHERE_FILTER    | join_1                                                                                                 |
      | shuffle_field_2    | SHUFFLE_FIELD   | where_filter_1                                                                                         |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b`                                                                  |
      | merge_2            | MERGE           | /*AllowDiff*/dn3_0                                                                                     |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                               |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                        | db      |
      | conn_23 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a LEFT JOIN  Info c on a.name=c.name INNER JOIN Dept b where c.country='China'  order by a.Name | schema1 |

    # left join & cross join(1st) & ac, ab, c  -->  cross join last
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_25"
      | conn    | toClose | sql                                                                                                                                                         | db      |
      | conn_24 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Info c) LEFT JOIN Dept b on a.Name=b.Manager where c.country='China' order by a.Name | schema1 |
    Then check resultset "rs_25" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country` from  `Info` `c` where `c`.`country` = 'China'           |
      | merge_2            | MERGE           | dn5_0                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                 | db      |
      | conn_24 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Info c) LEFT JOIN Dept b on a.Name=b.Manager where c.country='China' order by a.Name | schema1 |

    # left join & cross join(1st) & ac, bc a  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_26"
      | conn    | toClose | sql                                                                                                                                                       | db      |
      | conn_25 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Info c) LEFT JOIN Dept b on c.DeptName=b.DeptName and a.level='P7' order by a.Name | schema1 |
    Then check resultset "rs_26" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1        | SQL/REF-2                                                                        |
      | dn1_0              | BASE SQL      | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                |
      | dn2_0              | BASE SQL      | select `a`.`name`,`a`.`deptname`,`a`.`level` from  `Employee` `a`                |
      | merge_1            | MERGE         | dn1_0; dn2_0                                                                     |
      | shuffle_field_1    | SHUFFLE_FIELD | merge_1                                                                          |
      | dn5_0              | BASE SQL      | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_2            | MERGE         | dn5_0                                                                            |
      | join_1             | JOIN          | shuffle_field_1; merge_2                                                         |
      | order_1            | ORDER         | join_1                                                                           |
      | shuffle_field_2    | SHUFFLE_FIELD | order_1                                                                          |
      | /*AllowDiff*/dn4_0 | BASE SQL      | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC |
      | merge_3            | MERGE         | /*AllowDiff*/dn4_0                                                               |
      | join_2             | JOIN          | shuffle_field_2; merge_3                                                         |
      | order_2            | ORDER         | join_2                                                                           |
      | shuffle_field_3    | SHUFFLE_FIELD | order_2                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                               | db      |
      | conn_25 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Info c) LEFT JOIN Dept b on c.DeptName=b.DeptName and a.level='P7' order by a.Name | schema1 |

    # left join & inner join(2nd) & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_27"
      | conn    | toClose | sql                                                                                                                                                                                    | db      |
      | conn_26 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_27" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                            |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                         |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1            | ORDER           | join_1                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                      |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_26 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a left join Dept b on a.name=b.manager inner join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & inner join(1st) & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_28"
      | conn    | toClose | sql                                                                                                                                                                                    | db      |
      | conn_27 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a inner join Dept b on a.name=b.manager left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_28" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                            |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                                         |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1            | ORDER           | join_1                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                      |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                            | db      |
      | conn_27 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a inner join Dept b on a.name=b.manager left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # left join & cross join(1st) & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_29"
      | conn    | toClose | sql                                                                                                                                                        | db      |
      | conn_28 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Dept b) left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_29" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1        | SQL/REF-2                                                                                                  |
      | dn1_0              | BASE SQL      | select `a`.`name`,`a`.`deptname` from  `Employee` `a`                                                      |
      | dn2_0              | BASE SQL      | select `a`.`name`,`a`.`deptname` from  `Employee` `a`                                                      |
      | merge_1            | MERGE         | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1    | SHUFFLE_FIELD | merge_1                                                                                                    |
      | /*AllowDiff*/dn4_0 | BASE SQL      | select `b`.`manager`,`b`.`deptname` from  `Dept` `b`                                                       |
      | merge_2            | MERGE         | /*AllowDiff*/dn4_0                                                                                         |
      | join_1             | JOIN          | shuffle_field_1; merge_2                                                                                   |
      | order_1            | ORDER         | join_1                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD | order_1                                                                                                    |
      | dn5_0              | BASE SQL      | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_3            | MERGE         | dn5_0                                                                                                      |
      | join_2             | JOIN          | shuffle_field_2; merge_3                                                                                   |
      | shuffle_field_3    | SHUFFLE_FIELD | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                | db      |
      | conn_28 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM (Employee a, Dept b) left join Info c on a.name=c.name and b.DeptName=c.DeptName order by a.Name | schema1 |


    # inner join & inner join & ab, ac  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_30"
      | conn    | toClose | sql                                                                                                                                                           | db      |
      | conn_29 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.name=c.name order by a.name | schema1 |
    Then check resultset "rs_30" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC              |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` order by `c`.`name` ASC      |
      | merge_2            | MERGE           | dn5_0                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                   | db      |
      | conn_29 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on a.name=c.name order by a.name | schema1 |

    # inner join & inner join & ab, bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_31"
      | conn    | toClose | sql                                                                                                                                                                   | db      |
      | conn_30 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |
    Then check resultset "rs_31" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                        |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC    |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                     |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC  |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                               |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                         |
      | order_1            | ORDER           | join_1                                                                           |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                          |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                            |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                         |
      | order_2            | ORDER           | join_2                                                                           |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                          |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                           | db      |
      | conn_30 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN Info c on c.DeptName=b.DeptName order by a.name | schema1 |

    # cross join & cross join & ab, bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_32"
      | conn    | toClose | sql                                                                                                                      | db      |
      | conn_31 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b INNER JOIN Info c order by a.name | schema1 |
    Then check resultset "rs_32" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b`                                         |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country` from  `Info` `c`                                         |
      | merge_2            | MERGE           | dn5_0                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                              | db      |
      | conn_31 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b INNER JOIN Info c order by a.name | schema1 |

    # inner join & inner join & ab, ac b  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_33"
      | conn    | toClose | sql                                                                                                                                                                             | db      |
      | conn_32 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_33" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                               |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                       |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                       |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                            |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                       |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                                      |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                  |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                                      |
      | merge_2            | MERGE           | dn5_0                                                                                                   |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                |
      | order_1            | ORDER           | join_2                                                                                                  |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                 |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                     | db      |
      | conn_32 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # inner join & inner join & ab, ac b and contain subquery -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_34"
      | conn    | toClose | sql                                                                                                                                                                                             | db      |
      | conn_33 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_34" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                                       |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`deptname` ASC                                               |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                               |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 2 order by `b`.`deptname` ASC                         |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                                                              |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                                        |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                                                                          |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from (select `Info`.`deptname` from  `Info` order by `Info`.`deptname` ASC) c order by `c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                                           |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                                        |
      | order_1            | ORDER           | join_2                                                                                                                          |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_1                                                                                                                         |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                     | db      |
      | conn_33 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN (select * from Info) c on a.DeptName=c.DeptName and b.deptid=2 order by a.name | schema1 |

    # inner join & inner join & ab, bc a  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_35"
      | conn    | toClose | sql                                                                                                                                                                               | db      |
      | conn_34 | false   | explain SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName and a.level='P7' order by a.name | schema1 |
    Then check resultset "rs_35" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`level` = 'P7' ORDER BY `a`.`deptname` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                           |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                         |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1            | ORDER           | join_1                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn5_0              | BASE SQL        | select `c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC                                         |
      | merge_2            | MERGE           | dn5_0                                                                                                      |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | order_2            | ORDER           | join_2                                                                                                     |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                                    |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                       | db      |
      | conn_34 | true    | SELECT a.Name,a.DeptName,b.Manager FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName INNER JOIN Info c on b.DeptName=c.DeptName and a.level='P7' order by a.name | schema1 |

      # inner join & inner join & ac a, ab c  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_36"
      | conn    | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_35 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.country='USA' order by a.name | schema1 |
    Then check resultset "rs_36" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                              |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` where `a`.`empid` = 2242 ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                           |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                      |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name` from  `Info` `c` where `c`.`country` = 'USA' order by `c`.`name` ASC   |
      | merge_1            | MERGE           | dn5_0                                                                                                  |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                               |
      | order_1            | ORDER           | join_1                                                                                                 |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`deptname` ASC                       |
      | merge_2            | MERGE           | /*AllowDiff*/dn4_0                                                                                     |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                               |
      | order_2            | ORDER           | join_2                                                                                                 |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                                |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                              | db      |
      | conn_35 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Info c on a.name=c.name and a.empid=2242 INNER JOIN Dept b on a.DeptName= b.DeptName and c.country='USA' order by a.name | schema1 |

    # cross join & cross join & ab, bc, b  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_37"
      | conn    | toClose | sql                                                                                                                                       | db      |
      | conn_36 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b INNER JOIN Info c where b.deptid=2 order by a.name | schema1 |
    Then check resultset "rs_37" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                     |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                  |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                             |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b` where `b`.`deptid` = 2                  |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                            |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                      |
      | shuffle_field_2    | SHUFFLE_FIELD   | join_1                                                                        |
      | dn5_0              | BASE SQL        | select `c`.`country` from  `Info` `c`                                         |
      | merge_2            | MERGE           | dn5_0                                                                         |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                      |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                        |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                               | db      |
      | conn_36 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b INNER JOIN Info c where b.deptid=2 order by a.name | schema1 |

    # cross join & cross join & ab, ac bc  -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_38"
      | conn    | toClose | sql                                                                                                                                                                                                | db      |
      | conn_37 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name | schema1 |
    Then check resultset "rs_38" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                           |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                       |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                        |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                   |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` order by `b`.`manager` ASC                     |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                                  |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                            |
      | order_1            | ORDER           | join_1                                                                                              |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                             |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname` from  `Info` `c` order by `c`.`deptname` ASC,`c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                               |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                            |
      | order_2            | ORDER           | join_2                                                                                              |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                             |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                        | db      |
      | conn_37 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name= b.Manager INNER JOIN  Info c on a.DeptName=c.DeptName  and b.DeptName=c.Deptname order by a.name | schema1 |

    # cross join & cross join & ab, ac bc and contain subquery -->  join order not change
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_39"
      | conn    | toClose | sql                                                                                                                                                                                                          | db      |
      | conn_38 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN (select * from Info) c on a.DeptName = c.DeptName and b.Manager=c.Name order by a.Name | schema1 |
    Then check resultset "rs_39" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                            |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                                                                                                                                            |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                             |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                        |
      | /*AllowDiff*/dn4_0 | BASE SQL        | select `b`.`manager` from  `Dept` `b` order by `b`.`manager` ASC                                                                                                                                                         |
      | merge_1            | MERGE           | /*AllowDiff*/dn4_0                                                                                                                                                                                                       |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                                                                                                                                 |
      | order_1            | ORDER           | join_1                                                                                                                                                                                                                   |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                                                                                                                                  |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`deptname`,`c`.`name` from (select `Info`.`country`,`Info`.`deptname`,`Info`.`name` from  `Info` order by `Info`.`deptname` ASC,`Info`.`name` ASC) c order by `c`.`deptname` ASC,`c`.`name` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                                                                                                                                    |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                                                                                                                                 |
      | order_2            | ORDER           | join_2                                                                                                                                                                                                                   |
      | shuffle_field_3    | SHUFFLE_FIELD   | order_2                                                                                                                                                                                                                  |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                                  | db      |
      | conn_38 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager INNER JOIN (select * from Info) c on a.DeptName = c.DeptName and b.Manager=c.Name order by a.Name | schema1 |

    # cross join & cross join & ab b, ac bc  -->  on->where
    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_40"
      | conn    | toClose | sql                                                                                                                                                                                                      | db      |
      | conn_39 | false   | explain SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager and b.deptid=3 INNER JOIN Info c on a.name = c.name and b.DeptName=c.DeptName order by a.Name | schema1 |
    Then check resultset "rs_40" has lines with following column values
      | SHARDING_NODE-0    | TYPE-1          | SQL/REF-2                                                                                                  |
      | dn1_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | dn2_0              | BASE SQL        | select `a`.`name`,`a`.`deptname` from  `Employee` `a` ORDER BY `a`.`name` ASC                              |
      | merge_and_order_1  | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                               |
      | shuffle_field_1    | SHUFFLE_FIELD   | merge_and_order_1                                                                                          |
      | /*AllowDiff*/dn3_0 | BASE SQL        | select `b`.`manager`,`b`.`deptname` from  `Dept` `b` where `b`.`deptid` = 3 order by `b`.`manager` ASC     |
      | merge_1            | MERGE           | /*AllowDiff*/dn3_0                                                                                         |
      | join_1             | JOIN            | shuffle_field_1; merge_1                                                                                   |
      | order_1            | ORDER           | join_1                                                                                                     |
      | shuffle_field_2    | SHUFFLE_FIELD   | order_1                                                                                                    |
      | dn5_0              | BASE SQL        | select `c`.`country`,`c`.`name`,`c`.`deptname` from  `Info` `c` order by `c`.`name` ASC,`c`.`deptname` ASC |
      | merge_2            | MERGE           | dn5_0                                                                                                      |
      | join_2             | JOIN            | shuffle_field_2; merge_2                                                                                   |
      | shuffle_field_3    | SHUFFLE_FIELD   | join_2                                                                                                     |
    Then execute sql in "dble-1" and the result should be consistent with mysql
      | conn    | toClose | sql                                                                                                                                                                                              | db      |
      | conn_39 | true    | SELECT a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.Name=b.Manager and b.deptid=3 INNER JOIN Info c on a.name = c.name and b.DeptName=c.DeptName order by a.Name | schema1 |

    # cross join & cross join & ab, ac ab  -->  not support
#    Given execute single sql in "dble-1" in "user" mode and save resultset in "rs_"
#      | conn   | toClose | sql                                                                                                                                                                             | db      |
#      | conn_40 | false   | explain select a.Name,a.DeptName,b.Manager,c.country FROM Employee a INNER JOIN Dept b on a.DeptName=b.DeptName inner join Info c on a.DeptName=c.DeptName and a.name=b.manager | schema1 |
