# Copyright (C) 2016-2022 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/10/15
# Modified by wujinling at 2019/09/17
Feature: check collation/lower_case_table_names works right for dble
#  lower_case_table_names=0, case sensitive
#  lower_case_table_names=1, case insensitive
#  lower_case_table_names=1,CHARACTER SET utf8 COLLATE utf8_bin is case sensitive, from issue 1229
#  lower_case_table_names=1,CHARACTER SET utf8 COLLATE latin1_swedish_ci is case insensitive, from issue 1229


  @BLOCKER
  Scenario:set backend mysql lower_case_table_names=1 , dble will deal with queries case sensitive#1
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given restart mysql in "mysql-slave1" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given restart mysql in "mysql-slave2" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 1
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema name="DBTEST">
            <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
            <table name="uos_page_ret_inst" dataNode="dn4" />
            <table name="uos_tache_def" dataNode="dn3" />
        </schema>
    """
    Given delete the following xml segment
      |file        | parent           | child          |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
      </user>
      <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1, DbTest</property>
      </user>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                  | expect               | db     |
        | test | 111111 | conn_0 | True    |                                                                       | success              | DBTest |
        | test | 111111 | conn_0 | False   | drop table if exists Test_Table                                  | success             | DbTest |
        | test | 111111 | conn_0 | False   | create table TEst_Table(id int,name char(10))                  | success             | DbTest |
        | test | 111111 | conn_0 | False   | insert into test_table(id) value(1)                             | success             | DbTest |
        | test | 111111 | conn_0 | False   | insert into Test_Table(id) value(1)                             | success             | DbTest |
        | test | 111111 | conn_0 | False   | select test_table.id from Test_Table                            | success             | DbTest |
        | test | 111111 | conn_0 | False   | select Test_Table.id from test_table                            | success             | DbTest |
        | test | 111111 | conn_0 | False   | select Test_Table.id from test_table                            | success             | DbTest |
        | test | 111111 | conn_0 | False   | use dbtest                                                           | success             | DbTest |
        | test | 111111 | conn_0 | False   | select dbtest.test_table.id from dbtest.test_table            | success              | DbTest |
        | test | 111111 | conn_0 | True    | select DbTest.Test_Table.id from DbTest.Test_Table            | success              | DbTest |
        | test | 111111 | conn_1 | False   | drop table if exists Test                                         | success              | schema1 |
        | test | 111111 | conn_1 | False   | drop table if exists test                                         | success              | schema1 |
        | test | 111111 | conn_1 | False   | create table test(Id int)                                         | success              | schema1 |
        | test | 111111 | conn_1 | False   | insert into test(id) value(2)                                     | success             | schema1 |
        | test | 111111 | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join Test t2 on t1.id=t2.Id |success | schema1 |
        | test | 111111 | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join test t2 on t1.id=t2.Id |success| schema1 |
        | test | 111111 | conn_1 | False   | select T1.id from DbTest.Test_Table T1 left join test t2 on T1.id=t2.id |success | schema1 |
        | test | 111111 | conn_1 | False   | select distinct(t1.id) from DbTest.Test_Table t1 limit 2     |success            | schema1 |
        | test | 111111 | conn_1 | False   | select DISTINCT(T1.id) from DbTest.Test_Table t1 limit 2     |success     | schema1 |
        | test | 111111 | conn_1 | False   | select avg(t1.id),t1.id from DbTest.Test_Table t1,test t2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(t1.id)>(select sum(t1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
        | test | 111111 | conn_1 | False   | select avg(T1.id),t1.id from DbTest.Test_Table t1,test T2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(T1.id)>(select sum(T1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table s,test t where s.id = t.Id or s.Id <s.id  or s.id >t.Id |success | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table S,Test t where s.id = t.id or s.id <s.id  or s.id >t.id |success | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table S,test t where s.id = t.id or s.id <s.id  or s.id >t.id |success | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from DbTest.Test_Table s union (select Id from test) |success | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from Test) |success | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from test) |success | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.`Test_Table` s where s.name='aa'            |success | schema1 |
        | test | 111111 | conn_2 | False   | drop table if exists uos_page_ret_inst                                                                                                                  | success     | DbTest |
        | test | 111111 | conn_2 | False   | drop table if exists uos_tache_def                                      | success      | DbTest |
        | test | 111111 | conn_2 | False   | create table uos_page_ret_inst(`RET_INST_ID` bigint (20),`TACHE_CODE` varchar (180),`TEST` varchar (300))                             | success             | DbTest |
        | test | 111111 | conn_2 | False   | create table uos_tache_def(`ID` bigint (20),`TACHE_CODE` varchar (180),`CREATE_DATE` datetime ,`SHADOW_NAME` varchar (180))                  | success     | DbTest |
        | test | 111111 | conn_2 | False   | insert into uos_page_ret_inst values('10','AAAA',NULL) ,('36','BBBB',NULL)                                                                          | success     | DbTest |
        | test | 111111 | conn_2 | False   | insert into uos_tache_def values('1557471076988','BBBB','2019-05-10 14:51:17',NULL), ('1557471086419','aaaa','2019-05-10 14:51:26',NULL)  | success      | DbTest |
        | test | 111111 | conn_2 | False    | select INST.TACHE_CODE,def.TACHE_CODE from uos_page_ret_inst INST JOIN uos_tache_def def ON def.TACHE_CODE=INST.TACHE_CODE                  | length{(2)}       | DbTest |
        | test | 111111 | conn_2 | False   | drop table if exists uos_page_ret_inst                                                                                                                  | success     | DbTest |
        | test | 111111 | conn_2 | False   | drop table if exists uos_tache_def                                      | success      | DbTest |
        | test | 111111 | conn_2 | False   | create table uos_page_ret_inst(`RET_INST_ID` bigint (20),`TACHE_CODE` varchar (180),`TEST` varchar (300)) CHARACTER SET utf8 COLLATE utf8_bin                             | success             | DbTest |
        | test | 111111 | conn_2 | False   | create table uos_tache_def(`ID` bigint (20),`TACHE_CODE` varchar (180),`CREATE_DATE` datetime ,`SHADOW_NAME` varchar (180)) CHARACTER SET utf8 COLLATE utf8_bin                 | success     | DbTest |
        | test | 111111 | conn_2 | False   | insert into uos_page_ret_inst values('10','AAAA',NULL) ,('36','BBBB',NULL)                                                                          | success     | DbTest |
        | test | 111111 | conn_2 | False   | insert into uos_tache_def values('1557471076988','BBBB','2019-05-10 14:51:17',NULL), ('1557471086419','aaaa','2019-05-10 14:51:26',NULL)  | success      | DbTest |
        | test | 111111 | conn_2 | True    | select INST.TACHE_CODE,def.TACHE_CODE from uos_page_ret_inst INST JOIN uos_tache_def def ON def.TACHE_CODE=INST.TACHE_CODE                  | length{(1)}       | DbTest |
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
      """
      /lower_case_table_names/d
      /server-id/a lower_case_table_names = 0
     """
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
     """
      /lower_case_table_names/d
      /server-id/a lower_case_table_names = 0
     """
    Given restart mysql in "mysql-slave1" with sed cmds to update mysql config
     """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 0
     """
    Given restart mysql in "mysql-slave2" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 0
     """

  @BLOCKER
  Scenario: set backend mysql lower_case_table_names=0, dble will deal with queries case insensitive  #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema name="DBTEST">
            <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        </schema>
    """
    Given delete the following xml segment
      |file        | parent           | child          |
      |server.xml  | {'tag':'root'}   | {'tag':'root'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
     """
      <user name="root">
        <property name="password">111111</property>
        <property name="manager">true</property>
      </user>
      <user name="test">
        <property name="password">111111</property>
        <property name="schemas">schema1, DbTest</property>
      </user>
    """
    Then restart dble in "dble-1" failed for
    """
    schema DbTest referred by user test is not exist!
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
        <schema name="DbTest">
            <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
        </schema>
    """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
        | user | passwd | conn   | toClose | sql                                                                              | expect                 | db     |
        | test | 111111 | conn_0 | True    |                                                                                   | Unknown database 'DBTest'     | DBTest |
        | test | 111111 | conn_0 | False   | drop table if exists Test_Table                                              | success               | DbTest |
        | test | 111111 | conn_0 | False   | create table TEst_Table(id int)                                              | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | create table Test_Table(id int,name char(20))                              | success               | DbTest |
        | test | 111111 | conn_0 | False   | insert into test_table(id) value(1)                                         | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | insert into Test_Table(id) value(1)                                         | success               | DbTest |
        | test | 111111 | conn_0 | False   | select test_table.id from Test_Table                                        | Unknown column       | DbTest |
        | test | 111111 | conn_0 | False   | select Test_Table.id from test_table                                        | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | select Test_Table.id from test_table                                        | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | False   | use dbtest                                                                      | Unknown database     | DbTest |
        | test | 111111 | conn_0 | False   | select dbtest.test_table.id from dbtest.test_table                        | doesn't exist        | DbTest |
        | test | 111111 | conn_0 | True    | select DbTest.Test_Table.id from DbTest.Test_Table                        | success                | DbTest |
        | test | 111111 | conn_1 | False   | drop table if exists Test                                                     | success               | schema1 |
        | test | 111111 | conn_1 | False   | drop table if exists test                                                     | success               | schema1 |
        | test | 111111 | conn_1 | False   | create table test(Id int)                                                     | success               | schema1 |
        | test | 111111 | conn_1 | False   | insert into test(id) value(2)                                                 | success              | schema1 |
        | test | 111111 | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join Test t2 on t1.id=t2.Id |Test doesn't exist | schema1 |
        | test | 111111 | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join test t2 on t1.id=t2.Id |column id not found     | schema1 |
        | test | 111111 | conn_1 | False   | select T1.id from DbTest.Test_Table T1 left join test t2 on T1.id=t2.id |success              | schema1 |
        | test | 111111 | conn_1 | False   | select distinct(t1.id) from DbTest.Test_Table t1 limit 2                  |success              | schema1 |
        | test | 111111 | conn_1 | False   | select DISTINCT(T1.id) from DbTest.Test_Table t1 limit 2                  |Unknown column      | schema1 |
        | test | 111111 | conn_1 | False   | select avg(t1.id),t1.id from DbTest.Test_Table t1,test t2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(t1.id)>(select sum(t1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table s,test t where s.id = t.Id or s.Id <s.id  or s.id >t.Id |success               | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table S,Test t where s.id = t.id or s.id <s.id  or s.id >t.id |Test doesn't exist  | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from  DbTest.Test_Table S,test t where s.id = t.id or s.id <s.id  or s.id >t.id |column id not found | schema1 |
        | test | 111111 | conn_1 | False   |select s.id from DbTest.Test_Table s union (select Id from test)          |success               | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from Test)          |Test doesn't exist  | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from test)          |column id not found | schema1 |
        | test | 111111 | conn_1 | True    |select s.id from DbTest.`Test_Table` s where s.name='aa'                   |success               | schema1 |

