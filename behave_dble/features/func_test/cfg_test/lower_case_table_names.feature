# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2018/10/15
# Modified by wujinling at 2019/09/17
@use.with_mysql_version=5.7
Feature: check collation/lower_case_table_names works right for dble
#  lower_case_table_names=0, case sensitive
#  lower_case_table_names=1, case insensitive
#  lower_case_table_names=1,CHARACTER SET utf8 COLLATE utf8_bin is case sensitive, from issue 1229
#  lower_case_table_names=1,CHARACTER SET utf8 COLLATE latin1_swedish_ci is case insensitive, from issue 1229

  @BLOCKER @restore_mysql_config
  Scenario:set backend mysql lower_case_table_names=1 , dble will deal with queries case sensitive#1
   """
   {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0},'mysql-slave1':{'lower_case_table_names':0},'mysql-slave2':{'lower_case_table_names':0}}}
   """
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
        <schema name="DBTEST" sqlMaxLimit="105">
             <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
             <table name="Uos_Page_ret_inst" dataNode="dn4" />
             <table name="UOS_Tache_def" dataNode="dn3" />
        </schema>

        <dataNode dataHost="ha_group1" database="DB1" name="dn1" />
        <dataNode dataHost="ha_group2" database="DB1" name="dn2" />
        <dataNode dataHost="ha_group1" database="DB2" name="dn3" />
        <dataNode dataHost="ha_group2" database="DB2" name="dn4" />
        <dataNode dataHost="ha_group1" database="DB3" name="dn5" />
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
      | conn   | toClose | sql                                                           | expect              | db     |
      | conn_0 | False   | drop table if exists Test_Table                               | success             | DbTest |
      | conn_0 | False   | create table TEst_Table(id int,name char(10))                 | success             | DbTest |
      | conn_0 | False   | insert into test_table(id) value(1)                           | success             | DbTest |
      | conn_0 | False   | insert into Test_Table(id) value(1)                           | success             | DbTest |
     #case https://github.com/actiontech/dble/issues/1749
      | conn_0 | False   | select count(*) from Test_Table                               | success             | DBTEST  |
      | conn_0 | False   | select test_table.id from Test_Table                          | success             | DbTest |
      | conn_0 | False   | select Test_Table.id from test_table                          | success             | DbTest |
      | conn_0 | False   | select Test_Table.id from test_table                          | success             | DbTest |
      | conn_0 | False   | use dbtest                                                    | success             | DbTest |
      | conn_0 | False   | select dbtest.test_table.id from dbtest.test_table            | success             | DbTest |
      | conn_0 | True    | select DbTest.Test_Table.id from DbTest.Test_Table            | success             | DbTest |
      | conn_1 | False   | drop table if exists Test                                     | success             | schema1 |
      | conn_1 | False   | drop table if exists test                                     | success             | schema1 |
      | conn_1 | False   | create table test(Id int)                                     | success             | schema1 |
      | conn_1 | False   | insert into test(id) value(2)                                 | success             | schema1 |
      | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join Test t2 on t1.id=t2.Id |success | schema1 |
      | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join test t2 on t1.id=t2.Id |success | schema1 |
      | conn_1 | False   | select T1.id from DbTest.Test_Table T1 left join test t2 on T1.id=t2.id |success | schema1 |
      | conn_1 | False   | select distinct(t1.id) from DbTest.Test_Table t1 limit 2                |success | schema1 |
      | conn_1 | False   | select DISTINCT(T1.id) from DbTest.Test_Table t1 limit 2                |success | schema1 |
      | conn_1 | False   | select avg(t1.id),t1.id from DbTest.Test_Table t1,test t2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(t1.id)>(select sum(t1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
      | conn_1 | False   | select avg(T1.id),t1.id from DbTest.Test_Table t1,test T2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(T1.id)>(select sum(T1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
      | conn_1 | False   | select s.id from  DbTest.Test_Table s,test t where s.id = t.Id or s.Id <s.id  or s.id >t.Id |success | schema1 |
      | conn_1 | False   | select s.id from  DbTest.Test_Table S,Test t where s.id = t.id or s.id <s.id  or s.id >t.id |success | schema1 |
      | conn_1 | False   | select s.id from  DbTest.Test_Table S,test t where s.id = t.id or s.id <s.id  or s.id >t.id |success | schema1 |
      | conn_1 | False   | select s.id from DbTest.Test_Table s union (select Id from test)    | success | schema1 |
      | conn_1 | True    | select s.id from DbTest.Test_Table S union (select id from Test)    | success | schema1 |
      | conn_1 | True    | select s.id from DbTest.Test_Table S union (select id from test)    | success | schema1 |
      | conn_1 | True    | select s.id from DbTest.`Test_Table` s where s.name='aa'            | success | schema1 |
      | conn_2 | False   | drop table if exists uos_page_ret_inst                             | success | DbTest  |
      | conn_2 | False   | drop table if exists uos_tache_def                                 | success | DbTest  |
      | conn_2 | False   | create table uos_page_ret_inst(`RET_INST_ID` bigint (20),`TACHE_CODE` varchar (180),`TEST` varchar (300))                                | success     | DbTest |
      | conn_2 | False   | create table uos_tache_def(`ID` bigint (20),`TACHE_CODE` varchar (180),`CREATE_DATE` datetime ,`SHADOW_NAME` varchar (180))              | success     | DbTest |
      | conn_2 | False   | insert into uos_page_ret_inst values('10','AAAA',NULL) ,('36','BBBB',NULL)                                                               | success     | DbTest |
      | conn_2 | False   | insert into uos_tache_def values('1557471076988','BBBB','2019-05-10 14:51:17',NULL), ('1557471086419','aaaa','2019-05-10 14:51:26',NULL) | success     | DbTest |
      | conn_2 | False   | select INST.TACHE_CODE,def.TACHE_CODE from uos_page_ret_inst INST JOIN uos_tache_def def ON def.TACHE_CODE=INST.TACHE_CODE               | length{(2)} | DbTest |
      | conn_2 | False   | drop table if exists uos_page_ret_inst                                                                                                   | success     | DbTest |
      | conn_2 | False   | drop table if exists uos_tache_def                                                                                                       | success     | DbTest |
      | conn_2 | False   | create table uos_page_ret_inst(`RET_INST_ID` bigint (20),`TACHE_CODE` varchar (180),`TEST` varchar (300)) CHARACTER SET utf8 COLLATE utf8_bin                   | success | DbTest |
      | conn_2 | False   | create table uos_tache_def(`ID` bigint (20),`TACHE_CODE` varchar (180),`CREATE_DATE` datetime ,`SHADOW_NAME` varchar (180)) CHARACTER SET utf8 COLLATE utf8_bin | success | DbTest |
      | conn_2 | False   | insert into uos_page_ret_inst values('10','AAAA',NULL) ,('36','BBBB',NULL)                                                                | success     | DbTest |
      | conn_2 | False   | insert into uos_tache_def values('1557471076988','BBBB','2019-05-10 14:51:17',NULL), ('1557471086419','aaaa','2019-05-10 14:51:26',NULL)  | success     | DbTest |
      | conn_2 | True    | select INST.TACHE_CODE,def.TACHE_CODE from uos_page_ret_inst INST JOIN uos_tache_def def ON def.TACHE_CODE=INST.TACHE_CODE                | length{(1)} | DbTest |
      | conn_3 | False   | drop table if exists test_table           | success | DBTEST  |
      | conn_3 | False   | drop table if exists uos_page_ret_inst    | success | DBTEST  |
      | conn_3 | False   | drop table if exists uos_tache_def        | success | DBTEST  |
      | conn_3 | True    | drop table if exists Test                 | success | schema1 |

  @BLOCKER @current
  Scenario: set backend mysql lower_case_table_names=0, dble will deal with queries case insensitive  #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
     <schema name="DBTEST">
         <table name="Test_Table" dataNode="dn1,dn2,dn3,dn4" rule="hash-four" />
     </schema>
    """
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
      | conn   | toClose | sql                                                                     | expect                   | db     |
      |        | True    |                                                                         | Unknown database 'DBTest'| DBTest |
      | conn_0 | False   | drop table if exists Test_Table                                         | success                  | DbTest |
      | conn_0 | False   | create table TEst_Table(id int)                                         | doesn't exist            | DbTest |
      | conn_0 | False   | create table Test_Table(id int,name char(20))                           | success                  | DbTest |
      | conn_0 | False   | insert into test_table(id) value(1)                                     | doesn't exist            | DbTest |
      | conn_0 | False   | insert into Test_Table(id) value(1)                                     | success                  | DbTest |
      | conn_0 | False   | select test_table.id from Test_Table                                    | Unknown column           | DbTest |
      | conn_0 | False   | select Test_Table.id from test_table                                    | doesn't exist            | DbTest |
      | conn_0 | False   | select Test_Table.id from test_table                                    | doesn't exist            | DbTest |
      | conn_0 | False   | use dbtest                                                              | Unknown database         | DbTest |
      | conn_0 | False   | select dbtest.test_table.id from dbtest.test_table                      | doesn't exist            | DbTest |
      | conn_0 | True    | select DbTest.Test_Table.id from DbTest.Test_Table                      | success                  | DbTest |
      | conn_1 | False   | drop table if exists Test                                               | success                  | schema1 |
      | conn_1 | False   | drop table if exists test                                               | success                  | schema1 |
      | conn_1 | False   | create table test(Id int)                                               | success                  | schema1 |
      | conn_1 | False   | insert into test(id) value(2)                                           | success                  | schema1 |
      | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join Test t2 on t1.id=t2.Id |Test doesn't exist        | schema1 |
      | conn_1 | False   | select t1.id from DbTest.Test_Table T1 left join test t2 on t1.id=t2.Id |error totally whack       | schema1 |
      | conn_1 | False   | select T1.id from DbTest.Test_Table T1 left join test t2 on T1.id=t2.id |success                   | schema1 |
      | conn_1 | False   | select distinct(t1.id) from DbTest.Test_Table t1 limit 2                |success                   | schema1 |
      | conn_1 | False   | select DISTINCT(T1.id) from DbTest.Test_Table t1 limit 2                |Unknown column            | schema1 |
      | conn_1 | False   | select avg(t1.id),t1.id from DbTest.Test_Table t1,test t2 where t1.id=t2.id and t1.id = 1 group by t1.id having avg(t1.id)>(select sum(t1.id)/count(t1.id) from DbTest.Test_Table t1) |success | schema1 |
      | conn_1 | False   |select s.id from  DbTest.Test_Table s,test t where s.id = t.Id or s.Id <s.id  or s.id >t.Id |success             | schema1 |
      | conn_1 | False   |select s.id from  DbTest.Test_Table S,Test t where s.id = t.id or s.id <s.id  or s.id >t.id |Test doesn't exist  | schema1 |
      | conn_1 | False   |select s.id from  DbTest.Test_Table S,test t where s.id = t.id or s.id <s.id  or s.id >t.id |error totally whack | schema1 |
      | conn_1 | False   |select s.id from DbTest.Test_Table s union (select Id from test)          |success             | schema1 |
      | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from Test)          |Test doesn't exist  | schema1 |
      | conn_1 | True    |select s.id from DbTest.Test_Table S union (select id from test)          |error totally whack | schema1 |
      | conn_1 | True    |select s.id from DbTest.`Test_Table` s where s.name='aa'                  |success             | schema1 |

  @BLOCKER @restore_mysql_config
  Scenario:set backend mysql lower_case_table_names=1 , dble will deal with queries case sensitive #3
  """
   {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0},'mysql-slave1':{'lower_case_table_names':0},'mysql-slave2':{'lower_case_table_names':0}}}
   """
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema name="schema1" dataNode="dn5" sqlMaxLimit="100">
          <table name="aly_test" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
          <table name="aly_order" dataNode="dn1,dn2,dn3,dn4" rule="hash-four"/>
          <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
      </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "server.xml"
    """
      <user name="test_user">
        <property name="password">111111</property>
        <property name="schemas">SCHEMA1</property>
        <privileges check="true">
          <schema name="SCHEMA1" dml="0000" >
            <table name="Aly_Test" dml="1111"></table>
            <table name="Aly_Order" dml="0010"></table>
          </schema>
        </privileges>
      </user>
    """
    Then execute admin cmd "reload @@config_all"
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user      | passwd | conn   | toClose | sql                                             | expect  |
      | test_user | 111111 | conn_0 | False   | use schema1                                     | success |
      | test_user | 111111 | conn_0 | False   | drop table if exists aly_test                   | success |
      | test_user | 111111 | conn_0 | False   | create table aly_test(id int, name varchar(10)) | success |
      | test_user | 111111 | conn_0 | False   | insert into aly_test value(1,'a')               | success |
      | test_user | 111111 | conn_0 | False   | update aly_test set name='b' where id=1         | success |
      | test_user | 111111 | conn_0 | False   | select * from aly_test                          | success |
      | test_user | 111111 | conn_0 | False   | delete from aly_test                            | success |
      | test_user | 111111 | conn_0 | true    | show create table aly_test                      | success |

  @BLOCKER @restore_mysql_config
  Scenario:set backend mysql lower_case_table_names=1 , dble will deal with queries case sensitive #4
  """
   {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0},'mysql-slave1':{'lower_case_table_names':0},'mysql-slave2':{'lower_case_table_names':0}}}
  """
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "schema.xml"
    """
      <schema dataNode="dn5" name="schema1" sqlMaxLimit="100">
        <table type="global" name="test" dataNode="dn1,dn2,dn3,dn4" />
        <table name="tb_parent" dataNode="dn1,dn2" rule="hash-two">
          <childTable name="Tb_Child1" joinKey="child1_id" parentKey="id">
            <childTable name="Tb_Grandson1" joinKey="grandson1_id" parentKey="child1_id"/>
              <childTable name="Tb_Great_grandson1" joinKey="great_grandson1_id" parentKey="grandson1_id"/>
              <childTable name="tb_grandson2" joinKey="grandson2_id" parentKey="child1_id2"/>
            </childTable>
            <childTable name="tb_child2" joinKey="child2_id" parentKey="id"/>
          <childTable name="tb_child3" joinKey="child3_id" parentKey="id2"/>
        </table>
      </schema>
    """
    Then execute admin cmd "reload @@config_all"
    Then restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                       | expect  |
      | test | 111111 | conn_0 | False   | use schema1                                                               | success |
      | test | 111111 | conn_0 | False   | drop table if exists tb_child1                                            | success |
      | test | 111111 | conn_0 | False   | create table tb_child1(child1_id int, name varchar(10))                   | success |
      | test | 111111 | conn_0 | False   | insert into tb_child1 value(1,'a')                                        | success |
      | test | 111111 | conn_0 | False   | update tb_child1 set name='b' where child1_id=1                           | success |
      | test | 111111 | conn_0 | False   | select * from tb_child1                                                   | success |
      | test | 111111 | conn_0 | False   | delete from tb_child1                                                     | success |
      | test | 111111 | conn_0 | False   | show create table tb_child1                                               | success |
      | test | 111111 | conn_0 | False   | drop table if exists tb_grandson1                                         | success |
      | test | 111111 | conn_0 | False   | create table tb_grandson1 (grandson1_id int, name varchar(10))            | success |
      | test | 111111 | conn_0 | False   | insert into tb_grandson1  value(1,'a')                                    | success |
      | test | 111111 | conn_0 | False   | update tb_grandson1  set name='b' where grandson1_id=1                    | success |
      | test | 111111 | conn_0 | False   | select * from tb_grandson1                                                | success |
      | test | 111111 | conn_0 | False   | delete from tb_grandson1                                                  | success |
      | test | 111111 | conn_0 | true    | show create table tb_grandson1                                            | success |