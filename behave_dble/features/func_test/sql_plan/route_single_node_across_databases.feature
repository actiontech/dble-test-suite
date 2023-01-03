# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yangxiaoliang at 2020/1/9
#2.19.11.0#dble-7875
Feature: two logical databases: declare the database of all tables when querying or declare the database of partial tables when querying

  Scenario: create two logical databases by configuration, declare the database of all tables when querying or declare the database of partial tables when querying #1
    Given add xml segment to node with attribute "{'tag':'user','kv_map':{'name':'test'}}" in "server.xml"
    """
    <property name="schemas">schema1,schema2</property>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
    <schema name="schema1" sqlMaxLimit="100" dataNode="dn5">
    <table name="sharding_2_t1" dataNode="dn1,dn2" rule="hash-two"/>
    <table name="o_dept" dataNode="dn1" />
    <table name="p_sys_user" dataNode="dn1"/>
    <table name="o_org" dataNode="dn1,dn2" type="global"/>
    </schema>
    <schema name="schema2" sqlMaxLimit="100">
    <table name="sharding_2_t2" dataNode="dn1,dn2" rule="hash-two"/>
    </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "rule.xml"
    """
    <function name="two-long" class="Hash">
    <property name="partitionCount">2</property>
    <property name="partitionLength">512</property>
    </function>
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                | expect                                                                                                                    | db      |
      | conn_0 | False   | drop table if exists sharding_2_t1                                                                                 | success                                                                                                                   | schema1 |
      | conn_0 | False   | create table sharding_2_t1(id int, c_flag int, c_decimal float)                                                    | success                                                                                                                   | schema1 |
      | conn_0 | False   | drop table if exists sharding_2_t2                                                                                 | success                                                                                                                   | schema2 |
      | conn_0 | True    | create table sharding_2_t2(id int, c_flag int, c_decimal float)                                                    | success                                                                                                                   | schema2 |
      | conn_0 | True    | explain select * from schema1.sharding_2_t1 a join schema2.sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1 | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} |         |
      | conn_0 | True    | explain select * from schema1.sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1         | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} | schema2 |
      | conn_0 | True    | explain select * from sharding_2_t1 a join schema2.sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1         | hasStr{('dn1', 'BASE SQL', 'select * from sharding_2_t1 a join sharding_2_t2 b on a.id = b.id where a.id =1 and b.id=1')} | schema1 |
#case  check result is corrected https://github.com/actiontech/dble/issues/2042\
      | conn_0 | False   | drop table if exists o_dept                              | success         | schema1 |
      | conn_0 | False   | drop table if exists p_sys_user                          | success         | schema1 |
      | conn_0 | False   | drop table if exists o_org                               | success         | schema1 |
      | conn_0 | False   | CREATE TABLE `o_dept` ( `DEPT_NO` varchar(16) NOT NULL,`ORG_NO` varchar(16) NOT NULL, `NAME` varchar(256) DEFAULT NULL, PRIMARY KEY (`DEPT_NO`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4                                                                                                                                                    | success                         | schema1 |
      | conn_0 | False   | CREATE TABLE `o_org` ( `ORG_NO` varchar(16) NOT NULL,`ORG_NAME` varchar(256) DEFAULT NULL,`P_ORG_NO` varchar(16) DEFAULT NULL, PRIMARY KEY (`ORG_NO`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4                                                                                                                                              | success                         | schema1 |
      | conn_0 | False   | CREATE TABLE `p_sys_user` ( `SYS_USER_NAME` varchar(30) NOT NULL, `DEPT_NO` varchar(16) DEFAULT NULL, `ORG_NO` varchar(16) NOT NULL, `USER_NAME` varchar(64) DEFAULT NULL, `PWD` varchar(256) NOT NULL, `CUR_STATUS_CODE` varchar(8) DEFAULT NULL, `ADMIN_FLAG` decimal(3,0) DEFAULT NULL ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4          | success                         | schema1 |
      | conn_0 | False   | insert into o_dept values ('12','m1','32'),('32','m2','3241'),('42','m3','e43'),('n3','m4','e43')                                                   | success         | schema1 |
      | conn_0 | False   | insert into o_org values ('n1','ew','wew'),('n2','0-1','rr'),('n3','1=a','rfs'),('42','m3','e43')                                                   | success         | schema1 |
      | conn_0 | False   | insert into p_sys_user values ('ew','m1','n1','qwe','ew','a',2),('a2','m4','n2','er','ere','ere',1),('a2','m3','43','er','ere','ere',1)             | success         | schema1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "1"
      | conn   | toClose | sql                          |
      | conn_0 | False   | SELECT a.sys_user_name AS sysUserName, d.org_no AS orgNo, d.org_name AS orgName, c.dept_no AS deptNo, c. NAME AS deptName, a.user_name AS userName, a.cur_status_code AS curStatusCode, a.admin_flag AS adminFlag FROM p_sys_user a LEFT JOIN o_dept c ON a.dept_no = c.dept_no,  o_org d WHERE a.org_no = d.org_no AND a.org_no IN (SELECT org_no FROM o_org) AND ( a.cur_status_code IS NULL OR a.cur_status_code <> '03' )      |
    Then check resultset "1" has lines with following column values
      | sysUserName-0 | orgNo-1 | orgName-2 | deptNo-3 | deptName-4 | userName-5 | curStatusCode-6 | adminFlag-7 |
      | ew            | n1      | ew        | None     | None       | qwe        | a               |           2 |
      | a2            | n2      | 0-1       | None     | None       | er         | ere             |           1 |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "2"
      | conn   | toClose | sql                          |
      | conn_0 | False   | explain  SELECT a.sys_user_name AS sysUserName, d.org_no AS orgNo, d.org_name AS orgName, c.dept_no AS deptNo, c. NAME AS deptName, a.user_name AS userName, a.cur_status_code AS curStatusCode, a.admin_flag AS adminFlag FROM p_sys_user a LEFT JOIN o_dept c ON a.dept_no = c.dept_no,  o_org d WHERE a.org_no = d.org_no AND a.org_no IN (SELECT org_no FROM o_org) AND ( a.cur_status_code IS NULL OR a.cur_status_code <> '03' )       |
    Then check resultset "2" has lines with following column values
      | SHARDING_NODE-0 | TYPE-1     | SQL/REF-2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
      | dn1_0           | BASE SQL   | select `a`.`sys_user_name` as `sysUserName`,`d`.`org_no` as `orgNo`,`d`.`org_name` as `orgName`,`c`.`dept_no` as `deptNo`,`c`.`NAME` as `deptName`,`a`.`user_name` as `userName`,`a`.`cur_status_code` as `curStatusCode`,`a`.`admin_flag` as `adminFlag` from  (  (  `p_sys_user` `a` left join  `o_dept` `c` on `a`.`dept_no` = `c`.`dept_no` )  join  `o_org` `d` )  join (select  distinct `o_org`.`org_no` as `autoalias_scalar` from  `o_org`) autoalias_o_org where `a`.`org_no` = `d`.`org_no` and `a`.`org_no` = `autoalias_o_org`.`autoalias_scalar` and  ( a.cur_status_code IS NULL OR `a`.`cur_status_code` <> '03') |
      | merge_1         | MERGE      | dn1_0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect          | db      |
      | conn_0 | False   | drop table if exists o_dept                              | success         | schema1 |
      | conn_0 | False   | drop table if exists p_sys_user                          | success         | schema1 |
      | conn_0 | False   | drop table if exists o_org                               | success         | schema1 |
      | conn_0 | true    | drop table if exists sharding_2_t1                       | success         | schema1 |
      | conn_0 | true    | drop table if exists sharding_2_t2                       | success         | schema2 |
