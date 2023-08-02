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
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema name="DBTEST">
             <shardingTable name="Test_Table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
             <singleTable name="Uos_Page_ret_inst" shardingNode="dn4" sqlMaxLimit="105"/>
             <singleTable name="UOS_Tache_def" shardingNode="dn3" sqlMaxLimit="105"/>
        </schema>

        <shardingNode dbGroup="ha_group1" database="DB1" name="dn1" />
        <shardingNode dbGroup="ha_group2" database="DB1" name="dn2" />
        <shardingNode dbGroup="ha_group1" database="DB2" name="dn3" />
        <shardingNode dbGroup="ha_group2" database="DB2" name="dn4" />
        <shardingNode dbGroup="ha_group1" database="DB3" name="dn5" />
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
      <shardingUser name="test" password="111111" schemas="schema1, DbTest" readOnly="false"/>
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
     <schema name="DBTEST">
         <shardingTable name="Test_Table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
     </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
     """
      <shardingUser name="test" password="111111" schemas="schema1, DbTest" readOnly="false"/>
    """
    Then restart dble in "dble-1" failed for
    """
    User\[name:test\]'s schema \[DbTest\] is not exist!
    """

    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="DbTest">
         <shardingTable name="Test_Table" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id" />
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
    Given delete the following xml segment
      | file     | parent         | child                  |
      | user.xml | {'tag':'root'} | {'tag':'shardingUser'} |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
      <schema name="schema1" shardingNode="dn5" sqlMaxLimit="100">
          <shardingTable name="aly_test" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <shardingTable name="aly_order" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
      </schema>
    """
    Given add xml segment to node with attribute "{'tag':'root','prev':'managerUser'}" in "user.xml"
    """
    <shardingUser name="test_user" password="111111" schemas="SCHEMA1">
        <privileges check="true">
            <schema name="SCHEMA1" dml="0000" >
                <table name="Aly_Test" dml="1111"></table>
                <table name="Aly_Order" dml="0010"></table>
            </schema>
        </privileges>
    </shardingUser>
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
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="tb_parent" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id">
            <childTable name="Tb_Child1" joinColumn="child1_id" parentColumn="id" sqlMaxLimit="201">
                <childTable name="Tb_Grandson1" joinColumn="grandson1_id" parentColumn="child1_id"/>
                     <childTable name="Tb_Great_grandson1" joinColumn="great_grandson1_id" parentColumn="grandson1_id"/>
                <childTable name="tb_grandson2" joinColumn="grandson2_id" parentColumn="child1_id2"/>
            </childTable>
            <childTable name="tb_child2" joinColumn="child2_id" parentColumn="id"/>
            <childTable name="tb_child3" joinColumn="child3_id" parentColumn="id2"/>
        </shardingTable>
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

  # DBLE0REQ-2281
  @BLOCKER @restore_mysql_config
  Scenario:set two backend mysql lower_case_table_names=1 , add a backend mysql lower_case_table_names=0, then dryrun/reload/restart dble #5
  """
   {'restore_mysql_config':{'mysql-master1':{'lower_case_table_names':0},'mysql-master2':{'lower_case_table_names':0}}}
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
    Then restart dble in "dble-1" success

    # case1: two mysql lower_case_table_names=1 add a mysql lower_case_table_names=0, dryrun/reload/restart failed
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100">
     <heartbeat>select user()</heartbeat>
     <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
     </dbGroup>
    """
    Then execute admin cmd "dryrun" get the following output
    """
    hasStr{The values of lower_case_table_names for dbInstances are different. These dbInstances's [ha_group1:hostM1,ha_group2:hostM2] value is not 0. And these dbInstances's [ha_group3:hostM3] value is 0.}
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure.The reason is The values of lower_case_table_names for dbInstances are different. These dbInstances's [ha_group1:hostM1,ha_group2:hostM2] value is not 0. And these dbInstances's [ha_group3:hostM3] value is 0.
    """
    Then restart dble in "dble-1" failed for
    """
    The values of lower_case_table_names for dbInstances are different. These dbInstances's \[ha_group1:hostM1,ha_group2:hostM2\] value is not 0. And these dbInstances's \[ha_group3:hostM3\] value is 0.
    """

    Given delete the following xml segment
      | file      | parent                 | child                                           |
      | db.xml    | {'tag':'root'}         | {'tag':'dbGroup','kv_map':{'name':'ha_group3'}} |
    Then restart dble in "dble-1" success

    # case2: two mysql lower_case_table_names=1 add clickhouse disabled=false, dryrun/reload/restart failed
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse" disabled="false"/>
    </dbGroup>
    """
    Then execute admin cmd "dryrun" get the following output
    """
    hasStr{The configuration contains Clickhouse. Since clickhouse is not case sensitive, so the values of lower_case_table_names for all dbInstances must be 0. Current all dbInstances are 1.}
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    Reload Failure.The reason is The configuration contains Clickhouse. Since clickhouse is not case sensitive, so the values of lower_case_table_names for all dbInstances must be 0. Current all dbInstances are 1.
    """
    Then restart dble in "dble-1" failed for
    """
    The configuration contains Clickhouse. Since clickhouse is not case sensitive, so the values of lower_case_table_names for all dbInstances must be 0. Current all dbInstances are 1.
    """

    # case3: two mysql lower_case_table_names=1, clickhouse disabled=true, dryrun/reload/restart success
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse" disabled="true"/>
    </dbGroup>
    """
    Then restart dble in "dble-1" success
    Then execute admin cmd "dryrun"
    Then execute admin cmd "reload @@config_all"

    # case4: mysql-1 lower_case_table_names=0, mysql-2 lower_case_table_names=1, clickhouse disabled=false, dryrun/reload/restart failed
    Given restart mysql in "mysql-master1" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 0
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group4" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM4" password="111111" url="172.100.9.10:9004" user="test" maxCon="1000" minCon="10" primary="true" databaseType="clickhouse" disabled="false"/>
    </dbGroup>
    """
    Then execute admin cmd "dryrun" get the following output
    """
    hasStr{The configuration contains Clickhouse. Since clickhouse is not case sensitive, so the values of lower_case_table_names for dbInstances must be 0. These dbInstances's [ha_group1:hostM1] value is 0. And these dbInstances's [ha_group2:hostM2] value is not 0.}
    """
    Then execute admin cmd "reload @@config_all" get the following output
    """
    The configuration contains Clickhouse. Since clickhouse is not case sensitive, so the values of lower_case_table_names for dbInstances must be 0. These dbInstances's [ha_group1:hostM1] value is 0. And these dbInstances's [ha_group2:hostM2] value is not 0.
    """
    Then restart dble in "dble-1" failed for
    """
    The configuration contains Clickhouse. Since clickhouse is not case sensitive, so the values of lower_case_table_names for dbInstances must be 0. These dbInstances's \[ha_group1:hostM1\] value is 0. And these dbInstances's \[ha_group2:hostM2\] value is not 0.
    """

    # case5: two mysql lower_case_table_names=0, clickhouse disabled=false, dryrun/reload/restart success
    Given restart mysql in "mysql-master2" with sed cmds to update mysql config
    """
     /lower_case_table_names/d
     /server-id/a lower_case_table_names = 0
     """
    Then restart dble in "dble-1" success
    Then execute admin cmd "dryrun"
    Then execute admin cmd "reload @@config_all -r"
