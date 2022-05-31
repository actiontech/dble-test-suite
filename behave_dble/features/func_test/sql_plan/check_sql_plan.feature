# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhangqian at 2022/5/11

Feature: check sql plan

  # DBLE0REQ-1661
  Scenario: 3 ER relationships, A left join B inner join C, the query result is wrong   #1
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <table name="Employee" dataNode="dn3,dn4" rule="hash-string1" />
            <table name="Dept" dataNode="dn3,dn4" rule="hash-string1"/>
            <table name="Info" dataNode="dn3,dn4" rule="hash-string1"/>
        </schema>

        <dataNode dataHost="ha_group1" database="db1" name="dn1" />
        <dataNode dataHost="ha_group2" database="db1" name="dn2" />
        <dataNode dataHost="ha_group1" database="db2" name="dn3" />
        <dataNode dataHost="ha_group2" database="db2" name="dn4" />
        <dataNode dataHost="ha_group1" database="db3" name="dn5" />
        <dataNode dataHost="ha_group2" database="db3" name="dn6" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
      """
        <tableRule name="hash-string1" >
        <rule>
            <columns>deptname</columns>
            <algorithm>hash-into-two</algorithm>
        </rule>
        </tableRule>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                                                                                                                                                               | db      | expect  |
      | test | 111111 | conn_0 | false   | drop table if exists Employee                                                                                                                                                                                                                                                                                     | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists Dept                                                                                                                                                                                                                                                                                         | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists Info                                                                                                                                                                                                                                                                                         | schema1 | success |
      | test | 111111 | conn_0 | false   | create table Employee (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                        | schema1 | success |
      | test | 111111 | conn_0 | false   | create table Dept(deptname varchar(250) not null,deptid int not null,manager varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                                                     | schema1 | success |
      | test | 111111 | conn_0 | false   | create table Info(name varchar(250) not null,age int not null,country varchar(250) not null,deptname varchar(250) not null)engine=innodb charset=utf8                                                                                                                                                             | schema1 | success |
      | test | 111111 | conn_0 | false   | insert into Employee values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8') | schema1 | success |
      | test | 111111 | conn_0 | false   | insert into Dept values('Finance',2,'George'),('Sales',3,'Harriet'),('Market',4,'Tom')                                                                                                                                                                                                                            | schema1 | success |
      | test | 111111 | conn_0 | true    | insert into Info values('Harry', 25, 'China','Finance'),('Sally', 30, 'USA', 'Sales'),('Gerorge', 20, 'UK', 'Finance'),('Harriet', 35, 'Japan', 'Sales'),('Mary', 22, 'China', 'Human Resources'),('LiLi',33,'Krean','Human Resources'),('Jessi', 27,'Krean','Finance')                                           | schema1 | success |

    Then get resultset of user cmd "explain SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on a.deptname=c.deptname and b.DeptName=c.DeptName order by a.Name;" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `a`.`deptname` = `c`.`deptname` and `b`.`DeptName` = `c`.`DeptName` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                   |
    # append sql
    Then get resultset of user cmd "explain SELECT * FROM Employee a left join Dept b on a.deptname=b.deptname inner join Info c on b.deptName=c.deptName and a.deptname=c.deptname order by a.Name;" named "rs_B"
    Then check resultset "rs_B" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                           |
      | dn3_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptName` = `c`.`deptName` and `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | dn4_0             | BASE SQL        | select `a`.`name`,`a`.`empid`,`a`.`deptname`,`a`.`level`,`b`.`deptname`,`b`.`deptid`,`b`.`manager`,`c`.`name`,`c`.`age`,`c`.`country`,`c`.`deptname` from  (  `Employee` `a` left join  `Dept` `b` on `a`.`deptname` = `b`.`deptname` )  join  `Info` `c` on `b`.`deptName` = `c`.`deptName` and `a`.`deptname` = `c`.`deptname` where 1=1  ORDER BY `a`.`name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn3_0; dn4_0                                                                                                                                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                                                                                                                                   |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                           | db      | expect  |
      | test | 111111 | conn_0 | false   | drop table if exists Employee | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists Dept     | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists Info     | schema1 | success |

  # DBLE0REQ-1504
  Scenario: The parentheses of the or condition are missing, thus changing the semantics of the condition and eventually causing duplication of results   #2
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                                                                                                                                                                                                                            | db      | expect  |
      | test | 111111 | conn_0 | false   | drop table if exists test                                                                                                                                                                                                                                                                                      | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists sharding_2_t1                                                                                                                                                                                                                                                                             | schema1 | success |
      | test | 111111 | conn_0 | false   | create table test (name varchar(250) not null,empid int not null,deptname varchar(250) not null,level varchar(250) not null)engine=innodb charset=utf8;                                                                                                                                                        | schema1 | success |
      | test | 111111 | conn_0 | false   | create table sharding_2_t1(levelname varchar(250) not null,id int not null,salary int not null)engine=innodb charset=utf8;                                                                                                                                                                                     | schema1 | success |
      | test | 111111 | conn_0 | false   | insert into test values('Harry',3415,'Finance','P7'),('Sally',2242,'Sales','P7'),('George',3401,'Finance','P8'),('Harriet',2202,'Sales','P8'),('Mary',1257,'Human Resources','P7'),('LiLi',9527,'Human Resources','P9'),('Tom',7012,'Market','P9'),('Tony',3052,'Market','P10'),('Jessi',7948,'Finance','P8'); | schema1 | success |
      | test | 111111 | conn_0 | true    | insert into sharding_2_t1 values('P7',7,10000),('P8',8,15000),('P9',9,20000),('P10',10,25000);                                                                                                                                                                                                                 | schema1 | success |

    Then get resultset of user cmd "explain SELECT a.Name,a.DeptName,c.levelname,c.salary FROM test a inner JOIN sharding_2_t1 c on c.levelname=a.level and (c.levelname='P7' or (c.salary >=10000 and 22000>=c.salary)) order by a.name;" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0   | TYPE-1          | SQL/REF-2                                                                                                                                                                                                                                           |
      | dn1_0             | BASE SQL        | select `a`.`Name`,`a`.`DeptName`,`c`.`levelname`,`c`.`salary` from  `test` `a` join  `sharding_2_t1` `c` on `a`.`level` = `c`.`levelname` and (c.salary >= 10000 AND c.salary <= 22000 OR c.levelname IN ('P7')) where 1=1  ORDER BY `a`.`Name` ASC |
      | dn2_0             | BASE SQL        | select `a`.`Name`,`a`.`DeptName`,`c`.`levelname`,`c`.`salary` from  `test` `a` join  `sharding_2_t1` `c` on `a`.`level` = `c`.`levelname` and (c.salary >= 10000 AND c.salary <= 22000 OR c.levelname IN ('P7')) where 1=1  ORDER BY `a`.`Name` ASC |
      | merge_and_order_1 | MERGE_AND_ORDER | dn1_0; dn2_0                                                                                                                                                                                                                                        |
      | shuffle_field_1   | SHUFFLE_FIELD   | merge_and_order_1                                                                                                                                                                                                                                   |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                | db      | expect  |
      | test | 111111 | conn_0 | false   | drop table if exists test          | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists sharding_2_t1 | schema1 | success |

  Scenario: After migrating from mycat to dble, some sql compatibility issues   #3
    Given delete the following xml segment
      | file       | parent         | child              |
      | schema.xml | {'tag':'root'} | {'tag':'schema'}   |
      | schema.xml | {'tag':'root'} | {'tag':'dataNode'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
      """
        <schema name="schema1" sqlMaxLimit="100">
            <table name="vs_store_company" dataNode="dn1,dn2" rule="hash-string"/>
            <table name="vs_store" dataNode="dn1,dn2" rule="hash-string"/>
            <table name="vs_fin_cash_accinfo" dataNode="dn1,dn2" rule="hash-string"/>
        </schema>

        <dataNode dataHost="ha_group1" database="db1" name="dn1" />
        <dataNode dataHost="ha_group2" database="db1" name="dn2" />
        <dataNode dataHost="ha_group1" database="db2" name="dn3" />
        <dataNode dataHost="ha_group2" database="db2" name="dn4" />
        <dataNode dataHost="ha_group1" database="db3" name="dn5" />
        <dataNode dataHost="ha_group2" database="db3" name="dn6" />
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                                | db      | expect  |
      | test | 111111 | conn_0 | false   | drop table if exists vs_store_company                                                              | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists vs_store                                                                      | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists vs_fin_cash_accinfo                                                           | schema1 | success |
      | test | 111111 | conn_0 | false   | create table vs_store_company(id int not null,pk_id int,remakr int,audit_status int,`status` int); | schema1 | success |
      | test | 111111 | conn_0 | false   | create table vs_store(id int not null,fk_store_comp_id int);                                       | schema1 | success |
      | test | 111111 | conn_0 | false   | create table vs_fin_cash_accinfo(id int not null,fk_store_comp_id int,audit_status int);           | schema1 | success |
      | test | 111111 | conn_0 | false   | insert into vs_store_company values(1,1,3,7,10000),(2,2,5,8,15000),(3,3,10,9,20000),(4,4,99,2,1);  | schema1 | success |
      | test | 111111 | conn_0 | true    | insert into vs_store values(1,2),(2,3),(3,4),(4,5),(5,6);                                          | schema1 | success |
      | test | 111111 | conn_0 | true    | insert into vs_fin_cash_accinfo values(1,1,2),(2,2,8),(3,3,7),(4,4,2),(5,5,2),(6,6,88);            | schema1 | success |

    # DBLE0REQ-1505 "field not found" error in union all statement
    Then get resultset of user cmd "explain SELECT NULL AS ACCOUNTS_ID,t.remakr FROM vs_store_company t WHERE TO_DAYS(NOW())-TO_DAYS(t.pk_id)=1 limit 2 UNION ALL SELECT NULL AS ACCOUNTS_ID,t1.fk_store_comp_id from vs_store t1 where TO_DAYS(NOW())-TO_DAYS(t1.fk_store_comp_id)=1 limit 2;" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1        | SQL/REF-2                                                                                                                        |
      | dn1_0           | BASE SQL      | select `t`.`remakr` from  `vs_store_company` `t` where TO_DAYS(NOW()) - TO_DAYS(t.pk_id) = 1 LIMIT 2                             |
      | dn2_0           | BASE SQL      | select `t`.`remakr` from  `vs_store_company` `t` where TO_DAYS(NOW()) - TO_DAYS(t.pk_id) = 1 LIMIT 2                             |
      | merge_1         | MERGE         | dn1_0; dn2_0                                                                                                                     |
      | limit_1         | LIMIT         | merge_1                                                                                                                          |
      | shuffle_field_1 | SHUFFLE_FIELD | limit_1                                                                                                                          |
      | dn1_1           | BASE SQL      | select `t1`.`fk_store_comp_id` as `remakr` from  `vs_store` `t1` where TO_DAYS(NOW()) - TO_DAYS(t1.fk_store_comp_id) = 1 LIMIT 2 |
      | dn2_1           | BASE SQL      | select `t1`.`fk_store_comp_id` as `remakr` from  `vs_store` `t1` where TO_DAYS(NOW()) - TO_DAYS(t1.fk_store_comp_id) = 1 LIMIT 2 |
      | merge_2         | MERGE         | dn1_1; dn2_1                                                                                                                     |
      | limit_2         | LIMIT         | merge_2                                                                                                                          |
      | shuffle_field_3 | SHUFFLE_FIELD | limit_2                                                                                                                          |
      | union_all_1     | UNION_ALL     | shuffle_field_1; shuffle_field_3                                                                                                 |
      | shuffle_field_2 | SHUFFLE_FIELD | union_all_1                                                                                                                      |

    # DBLE0REQ-1506 "JoinNode cannot be cast to TableNode" error in query statement
    Then get resultset of user cmd "explain SELECT count(0) FROM (SELECT c.pk_id, c.remakr FROM vs_store_company c LEFT JOIN vs_store s ON c.pk_id = s.fk_store_comp_id INNER JOIN vs_fin_cash_accinfo ca ON ca.fk_store_comp_id = c.pk_id WHERE c.`status` = 1 AND ( c.audit_status = 2 OR ca.audit_status = 2 ) )t;" named "rs_A"
    Then check resultset "rs_A" has lines with following column values
      | SHARDING_NODE-0            | TYPE-1                   | SQL/REF-2                                                                                                                       |
      | dn1_0                      | BASE SQL                 | select `c`.`pk_id`,`c`.`remakr`,`c`.`audit_status` from  `vs_store_company` `c` where `c`.`status` = 1 ORDER BY `c`.`pk_id` ASC |
      | dn2_0                      | BASE SQL                 | select `c`.`pk_id`,`c`.`remakr`,`c`.`audit_status` from  `vs_store_company` `c` where `c`.`status` = 1 ORDER BY `c`.`pk_id` ASC |
      | merge_and_order_1          | MERGE_AND_ORDER          | dn1_0; dn2_0                                                                                                                    |
      | shuffle_field_1            | SHUFFLE_FIELD            | merge_and_order_1                                                                                                               |
      | dn1_1                      | BASE SQL                 | select `s`.`fk_store_comp_id` from  `vs_store` `s` ORDER BY `s`.`fk_store_comp_id` ASC                                          |
      | dn2_1                      | BASE SQL                 | select `s`.`fk_store_comp_id` from  `vs_store` `s` ORDER BY `s`.`fk_store_comp_id` ASC                                          |
      | merge_and_order_2          | MERGE_AND_ORDER          | dn1_1; dn2_1                                                                                                                    |
      | shuffle_field_5            | SHUFFLE_FIELD            | merge_and_order_2                                                                                                               |
      | join_1                     | JOIN                     | shuffle_field_1; shuffle_field_5                                                                                                |
      | shuffle_field_2            | SHUFFLE_FIELD            | join_1                                                                                                                          |
      | dn1_2                      | BASE SQL                 | select `ca`.`fk_store_comp_id`,`ca`.`audit_status` from  `vs_fin_cash_accinfo` `ca` ORDER BY `ca`.`fk_store_comp_id` ASC        |
      | dn2_2                      | BASE SQL                 | select `ca`.`fk_store_comp_id`,`ca`.`audit_status` from  `vs_fin_cash_accinfo` `ca` ORDER BY `ca`.`fk_store_comp_id` ASC        |
      | merge_and_order_3          | MERGE_AND_ORDER          | dn1_2; dn2_2                                                                                                                    |
      | shuffle_field_6            | SHUFFLE_FIELD            | merge_and_order_3                                                                                                               |
      | join_2                     | JOIN                     | shuffle_field_2; shuffle_field_6                                                                                                |
      | where_filter_1             | WHERE_FILTER             | join_2                                                                                                                          |
      | shuffle_field_3            | SHUFFLE_FIELD            | where_filter_1                                                                                                                  |
      | rename_derived_sub_query_1 | RENAME_DERIVED_SUB_QUERY | shuffle_field_3                                                                                                                 |
      | aggregate_1                | AGGREGATE                | rename_derived_sub_query_1                                                                                                      |
      | shuffle_field_4            | SHUFFLE_FIELD            | aggregate_1                                                                                                                     |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                      | db      | expect  |
      | test | 111111 | conn_0 | false   | drop table if exists vs_store_company    | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists vs_store            | schema1 | success |
      | test | 111111 | conn_0 | false   | drop table if exists vs_fin_cash_accinfo | schema1 | success |