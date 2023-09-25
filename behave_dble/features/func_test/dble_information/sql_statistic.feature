# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2021/3/2  quexiuping at 2021/3/18

Feature: sql_statistic_by_frontend_by_backend_by_entry_by_user
         sql_statistic_by_table_by_user_by_entry
         sql_statistic_by_associate_tables_by_entry_by_user
  ### truncate table前的sleep是因为数据写入sql_log是异步的，加sleep是为了数据正常写入并被truncate


  Scenario: simple sql test #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn1" name="schema2" />
    """
   Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <shardingUser name="test1" password="111111" schemas="schema1" readOnly="false"/>
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    <rwSplitUser name="split2" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "enable @@statistic"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_1 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_1 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_1 | False    | insert into sharding_4_t1 values(6,'name6')                                     | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1 where id=1                                          | success | schema1 |
      | conn_1 | False    | select * from sharding_4_t1 where id=15                                         | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='test_name'                                       | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn1' where id=4                                  | success | schema1 |
      | conn_1 | False    | update sharding_4_t1 set name='dn2' where id=9                                  | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=6                                            | success | schema1 |
      | conn_1 | False    | delete from sharding_4_t1 where id=11                                           | success | schema1 |
      | conn_1 | True     | delete from sharding_4_t1                                                       | success | schema1 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 8          | 5         | 1                   | 1                  | 2                   | 1                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 1                   | 1                  | 2                   | 2                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 4         | 1                   | 1                  | 1                   | 1                  | 2                   | 1                  | 2                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 8          | 8         | 2                   | 2                  | 1                   | 2                  | 2                   | 2                  | 1                   | 2                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_4_t1 | 2                  | 5                 | 3                  | 6                 | 3                  | 5                 | 3                  | 6                  |

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose  | sql                                                      | expect  | db      |
      | test1 | 111111 | conn_2 | False    | drop table if exists no_sharding_t1                      | success | schema1 |
      | test1 | 111111 | conn_2 | False    | create table no_sharding_t1(id int, name varchar(20))    | success | schema1 |
      | test1 | 111111 | conn_2 | False    | insert into no_sharding_t1 values(1,'name1'),(2,'name2') | success | schema1 |
      | test1 | 111111 | conn_2 | False    | update no_sharding_t1 set name='test_name'               | success | schema1 |
      | test1 | 111111 | conn_2 | False    | select * from no_sharding_t1                             | success | schema1 |
      | test1 | 111111 | conn_2 | False    | delete from no_sharding_t1                               | success | schema1 |
      | test1 | 111111 | conn_2 | False    | drop table if exists sharding_2_t1                       | success | schema1 |
      | test1 | 111111 | conn_2 | False    | create table sharding_2_t1(id int, name varchar(20))     | success | schema1 |
      | test1 | 111111 | conn_2 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')  | success | schema1 |
      | test1 | 111111 | conn_2 | False    | select * from sharding_2_t1                              | success | schema1 |
      | test1 | 111111 | conn_2 | False    | update sharding_2_t1 set name='test_name'                | success | schema1 |
      | test1 | 111111 | conn_2 | False    | update sharding_2_t1 set name='test_name' where id=5     | success | schema1 |
      | test1 | 111111 | conn_2 | False    | delete from sharding_2_t1 where id=4                     | success | schema1 |
      | test1 | 111111 | conn_2 | True     | truncate table sharding_2_t1                             | success | schema1 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "7" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 8          | 5         | 1                   | 1                  | 2                   | 1                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 1                   | 1                  | 2                   | 2                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 4         | 1                   | 1                  | 1                   | 1                  | 2                   | 1                  | 2                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 8          | 8         | 2                   | 2                  | 1                   | 2                  | 2                   | 2                  | 1                   | 2                  |
      | 3       | test1  | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 3         | 1                   | 1                  | 2                   | 1                  | 0                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 3         | 1                   | 1                  | 1                   | 1                  | 1                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn5             | hostM1        | 6          | 8         | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "3" retry "5" times
      | entry-0 | user-1 | table-2                | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_4_t1  | 2                  | 5                 | 3                  | 6                 | 3                  | 5                 | 3                  | 6                  |
      | 3       | test1  | schema1.no_sharding_t1 | 1                  | 2                 | 1                  | 2                 | 1                  | 2                 | 1                  | 2                  |
      | 3       | test1  | schema1.sharding_2_t1  | 1                  | 2                 | 2                  | 2                 | 1                  | 0                 | 1                  | 2                  |

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                              | expect  | db  |
      | split1 | 111111 | conn_2 | False   | drop table if exists test_table                  | success | db1 |
      | split1 | 111111 | conn_2 | False   | create table test_table(id int,name varchar(20)) | success | db1 |
      | split1 | 111111 | conn_2 | False   | show create table test_table                     | success | db1 |
      | split1 | 111111 | conn_2 | False   | desc test_table                                  | success | db1 |
      | split1 | 111111 | conn_2 | False   | insert into test_table values (1,'1'),(2, '2')   | success | db1 |
      | split1 | 111111 | conn_2 | False   | update test_table set name='name1' where id=1    | success | db1 |
      | split1 | 111111 | conn_2 | False   | select * from test_table                         | success | db1 |
      | split1 | 111111 | conn_2 | False   | delete from test_table where id=2                | success | db1 |
      | split1 | 111111 | conn_2 | False   | truncate test_table                              | success | db1 |
      | split1 | 111111 | conn_2 | True    | select 1                                         | success | db1 |
      | split2 | 111111 | conn_3 | False   | drop table if exists test_table                  | success | db2 |
      | split2 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20)) | success | db2 |
      | split2 | 111111 | conn_3 | False   | show create table test_table                     | success | db2 |
      | split2 | 111111 | conn_3 | False   | desc test_table                                  | success | db2 |
      | split2 | 111111 | conn_3 | False   | insert into test_table values (1,'1'),(2, '2')   | success | db2 |
      | split2 | 111111 | conn_3 | False   | update test_table set name='name1' where id=1    | success | db2 |
      | split2 | 111111 | conn_3 | False   | select * from test_table                         | success | db2 |
      | split2 | 111111 | conn_3 | False   | delete from test_table where id=2                | success | db2 |
      | split2 | 111111 | conn_3 | False   | truncate test_table                              | success | db2 |
      | split2 | 111111 | conn_3 | True    | select 1                                         | success | db2 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "9" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 8          | 5         | 1                   | 1                  | 2                   | 1                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 5         | 1                   | 1                  | 2                   | 2                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 8          | 4         | 1                   | 1                  | 1                   | 1                  | 2                   | 1                  | 2                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 8          | 8         | 2                   | 2                  | 1                   | 2                  | 2                   | 2                  | 1                   | 2                  |
      | 3       | test1  | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 3         | 1                   | 1                  | 2                   | 1                  | 0                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn1             | hostM1        | 7          | 3         | 1                   | 1                  | 1                   | 1                  | 1                   | 0                  | 1                   | 1                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn5             | hostM1        | 6          | 8         | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  | 1                   | 2                  |
      | 4       | split1 | 172.100.9.4    | 3306           | -               | hostM3        | 10         | 7         | 1                   | 2                  | 1                   | 1                  | 1                   | 1                  | 2                   | 3                  |
      | 5       | split2 | 172.100.9.4    | 3306           | -               | hostM3        | 10         | 7         | 1                   | 2                  | 1                   | 1                  | 1                   | 1                  | 2                   | 3                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "7" retry "5" times
      | entry-0 | user-1 | table-2                | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_4_t1  | 2                  | 5                 | 3                  | 6                 | 3                  | 5                 | 3                  | 6                  |
      | 3       | test1  | schema1.sharding_2_t1  | 1                  | 2                 | 2                  | 2                 | 1                  | 0                 | 1                  | 2                  |
      | 3       | test1  | schema1.no_sharding_t1 | 1                  | 2                 | 1                  | 2                 | 1                  | 2                 | 1                  | 2                  |
      | 4       | split1 | null                   | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                  |
      | 4       | split1 | db1.test_table         | 1                  | 2                 | 1                  | 1                 | 1                  | 1                 | 1                  | 2                  |
      | 5       | split2 | null                   | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 1                  |
      | 5       | split2 | db2.test_table         | 1                  | 2                 | 1                  | 1                 | 1                  | 1                 | 1                  | 2                  |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_0 | False   | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_0 | False   | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |


     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect  | db      |
      | conn_1 | False   | drop view if exists view_test                             | success | schema1 |
      | conn_1 | False   | create view view_test as select * from sharding_4_t1      | success | schema1 |
      | conn_1 | False   | select * from view_test                                   | success | schema1 |
      | conn_1 | False   | drop view view_test                                       | success | schema1 |
      | conn_1 | False   | truncate  sharding_4_t1                                   | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user " in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 2          | 0         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 0                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 2          | 0         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 0                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 2          | 0         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 0                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 2          | 0         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 0                  |

    #因为解析的过程中 会把view 对应的 原始sql再解析一遍  ，误认为 此时sql中有两个表了。issue：DBLE0REQ-2332
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                 | expect        | db               | timeout |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user    | length{(1)}   | dble_information | 5       |
    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.view_test     | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 0                  |
      | 2       | test   | schema1.sharding_4_t1 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 0                  |

     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                              | expect  | db      |
      | conn_1 | true     | drop table if exists sharding_4_t1               | success | schema1 |
     Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose  | sql                                                                          | expect  | db      |
      | test1 | 111111 | conn_2 | true     | drop table if exists no_sharding_t1;drop table if exists sharding_2_t1       | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                      | expect  | db  |
      | split1 | 111111 | conn_2 | true    | drop table if exists test_table          | success | db1 |
      | split2 | 111111 | conn_3 | true    | drop table if exists test_table          | success | db2 |

    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | False   | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_0 | False   | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_0 | False   | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                    | expect  | db      |
      | conn_1 | true    | select 1                | success | schema1 |
      | conn_2 | true    | select 5                | success | schema2 |

     Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 1          | 1         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn5             | hostM1        | 1          | 1         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | table-2 | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | null    | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 2                  | 2                  |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: complex sql test #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2" shardingNode="dn5" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>

     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <shardingUser name="test1" password="111111" schemas="schema1,schema2" readOnly="false"/>
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"

    #case mysql 5.7 shrdinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | drop table if exists test                                                       | success | schema1 |
      | conn_0 | False    | drop table if exists schema2.test1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | create table test(id int, name varchar(20))                                     | success | schema1 |
      | conn_0 | False    | create table schema2.test1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |
      | conn_0 | False    | insert into test values(1,'name1'),(2,'name2')                                  | success | schema1 |
      | conn_0 | False    | insert into schema2.test1 values(1,'name1'),(2,'name2')                         | success | schema1 |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                          | expect  | db      |
      | conn_0 | False    | select t1.*,t2.* from sharding_4_t1 t1, sharding_4_t1 t2 where t1.id=t2.id order by t1.id    | success | schema1 |
      | conn_0 | False    | select t1.*, t2.* from sharding_4_t1 t1 join sharding_4_t1 t2 on t1.id=t2.id                 | success | schema1 |
      | conn_0 | False    | select t1.*, t2.* from sharding_4_t1 t1 join sharding_2_t1 t2 on t1.id=t2.id                 | success | schema1 |
      | conn_0 | False    | select * from sharding_2_t1 where id = (select id from sharding_4_t1 where name='name1')     | success | schema1 |
      | conn_0 | False    | update test set name= '4' where name in (select name from schema2.test1 )                    | success | schema1 |
      | conn_0 | False    | update test set name= '3' where name = (select name from schema2.test1 order by id desc limit 1)  | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1(id, name) select id,name from sharding_4_t1                     | success | schema1 |
      | conn_0 | False    | select count(*) from sharding_4_t1 where id > 0                                           | success | schema1 |
      | conn_0 | False    | select max(id) from sharding_2_t1                                                         | success | schema1 |
        ##增加跨库的操作
#      | conn_0 | False    | select * from schema2.test1 where id = (select id from sharding_4_t1 where name='name9')     | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1                                                                 | success | schema1 |
      | conn_0 | False    | delete from sharding_2_t1                                                                 | success | schema1 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 15         | 16        | 1                   | 1                  | 2                   | 2                  | 2                   | 3                  | 10                  | 10                 |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 14         | 14        | 1                   | 1                  | 2                   | 2                  | 2                   | 3                  | 9                   | 8                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 11         | 11        | 1                   | 1                  | 2                   | 2                  | 1                   | 2                  | 7                   | 6                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 11         | 11        | 1                   | 1                  | 2                   | 2                  | 1                   | 2                  | 7                   | 6                  |

#    Given execute single sql in "dble-1" in "admin" mode and save resultset in "resultset_21"
#      | conn   | toClose | sql                                                                 | db               |
#      | conn_1 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry  | dble_information |
#    Then check resultset "resultset_21" has lines with following column values and has "3" lines
    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "3" retry "5" times
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_4_t1 | 1                  | 4                 | 0                  | 0                 | 1                  | 8                 | 5                  | 12                 |
      | 2       | test   | schema1.sharding_2_t1 | 0                  | 0                 | 0                  | 0                 | 1                  | 2                 | 3                  | 4                  |
      | 2       | test   | schema1.test          | 0                  | 0                 | 2                  | 2                 | 0                  | 0                 | 0                  | 0                  |
#      | 2       | test   | schema2.test1         | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 0                  |

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | associate_tables-2                          | sql_select_count-3 | sql_select_rows-4 |
      | 2       | test   | schema1.sharding_2_t1,schema1.sharding_4_t1 | 2                  | 3                 |
      | 2       | test   | schema1.sharding_4_t1,schema1.sharding_4_t1 | 2                  | 8                 |
#      | 2       | test   | schema1.sharding_4_t1,schema2.test1         | 1                  | 0                 |

    #case mysql 8.0 shrdinguser
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                               | expect  | db      |
      | test1 | 111111 | conn_2 | False   | drop table if exists no_sharding_t1                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.no_shar                              | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists sharding_2_t1                                | success | schema1 |
      | test1 | 111111 | conn_2 | False   | drop table if exists schema2.sharding_2                           | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table no_sharding_t1(id int, name varchar(20),age int)     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table sharding_2_t1(id int, name varchar(20),age int)      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table schema2.no_shar(id int, name varchar(20),age int)    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | create table schema2.sharding_2(id int, name varchar(20),age int) | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into no_sharding_t1 values (1,'name1',1),(2,'name2',2)     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into sharding_2_t1 values (1,'name1',1),(2,'name2',2)      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into schema2.no_shar values (1,'name1',1),(2,'name2',2)    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | insert into schema2.sharding_2 values (1,'name1',1),(2,'name2',2) | success | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_1 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                           | expect  | db      |
      | test1 | 111111 | conn_2 | False   | insert into no_sharding_t1(id,name,age) select id,name,age from schema2.no_shar                                               | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update no_sharding_t1 set name='test_name' where id in (select id from schema2.no_shar )                                      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | update no_sharding_t1 set age=age+1 where name != (select name from schema2.no_shar where name ='name1' )                     | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select n.id,s.name from no_sharding_t1 n join schema2.no_shar s on n.id=s.id                                                  | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select * from no_sharding_t1 where age <> (select age from schema2.no_shar where id !=1)                                      | success | schema1 |
      | test1 | 111111 | conn_2 | False   | delete from schema2.no_shar where name in ((select age from (select name,age from no_sharding_t1 order by id desc) as tmp))   | success | schema1 |

      | test1 | 111111 | conn_2 | False   | update sharding_2_t1 a,schema2.sharding_2 b set a.age=b.age+1 where a.id=2 and b.id=2                                         | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select n.id,s.name from sharding_2_t1 n join schema2.sharding_2 s on n.id=s.id                                                | success | schema1 |
      | test1 | 111111 | conn_2 | False   | select * from sharding_2_t1 where age <> (select age from schema2.sharding_2 where id !=1)                                    | success | schema1 |
      | test1 | 111111 | conn_2 | False   | delete schema1.sharding_2_t1 from sharding_2_t1,schema2.sharding_2 where sharding_2_t1.id=1 and schema2.sharding_2.id =1      | success | schema1 |


    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "3" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 3       | test1  | 172.100.9.5    | 3306           | dn1             | hostM1        | 4          | 4         | 0                   | 0                  | 1                   | 1                  | 0                   | 0                  | 3                   | 3                  |
      | 3       | test1  | 172.100.9.6    | 3306           | dn2             | hostM2        | 4          | 3         | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  | 3                   | 2                  |
      | 3       | test1  | 172.100.9.5    | 3306           | dn5             | hostM1        | 6          | 16        | 1                   | 2                  | 2                   | 8                  | 1                   | 0                  | 2                   | 6                  |

    ##update多表的时候 不能区分多表 DBLE0REQ-2331
#    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
#      | entry-0 | user-1 | table-2                | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
#      | 3       | test1  | schema2.sharding_2     | 0                  | 0                 | 1                  | 1                 | 1                  | 1                 | 2                  | 4                  |
#      | 3       | test1  | schema2.no_shar        | 1                  | 2                 | 2                  | 8                 | 1                  | 0                 | 2                  | 6                  |
#      | 3       | test1  | schema1.no_sharding_t1 | 1                  | 2                 | 2                  | 8                 | 1                  | 0                 | 2                  | 6                  |
#      | 3       | test1  | schema1.sharding_2_t1  | 0                  | 0                 | 1                  | 1                 | 1                  | 1                 | 2                  | 4                  |

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | associate_tables-2                       | sql_select_count-3 | sql_select_rows-4 |
      | 3       | test1  | schema1.no_sharding_t1,schema2.no_shar   | 2                  | 6                 |
      | 3       | test1  | schema1.sharding_2_t1,schema2.sharding_2 | 2                  | 4                 |

      # rwSplitUser
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | split1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | split1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | split1 | 111111 | conn_3 | False   | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
      | split1 | 111111 | conn_3 | False   | drop table if exists test_table1                          | success | db1 |
      | split1 | 111111 | conn_3 | False   | create table test_table1(id int,name varchar(20),age int) | success | db1 |
      | split1 | 111111 | conn_3 | False   | insert into test_table1 values (1,'1',1),(2, '2',2)       | success | db1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_1 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                                                                                 | expect  | db      |
      | split1 | 111111 | conn_3 | False   | insert into test_table(id,name,age) select id,name,age from test_table1                                             | success | schema1 |
      | split1 | 111111 | conn_3 | False   | update test_table set name='test_name' where id in (select id from test_table1 )                                    | success | schema1 |
      | split1 | 111111 | conn_3 | False   | update test_table set age=age+1 where name != (select name from test_table1 where name ='name1' )                   | success | schema1 |
      | split1 | 111111 | conn_3 | False   | update test_table a,test_table1 b set a.age=b.age+1 where a.id=2 and b.id=2                                         | success | schema1 |
      | split1 | 111111 | conn_3 | False   | select n.id,s.name from test_table n join test_table1 s on n.id=s.id                                                | success | schema1 |
      | split1 | 111111 | conn_3 | False   | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | success | schema1 |
      | split1 | 111111 | conn_3 | False   | select * from test_table where age <> (select age from test_table1 where id !=1)                                    | success | schema1 |
      | split1 | 111111 | conn_3 | False   | delete test_table from test_table,test_table1 where test_table.id=1 and test_table1.id =1                           | success | schema1 |
      | split1 | 111111 | conn_3 | False   | delete from test_table1 where name in ((select age from (select name,age from test_table order by id desc) as tmp)) | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 4       | split1 | 172.100.9.4    | 3306           | -               | hostM3        | 9          | 22        | 1                  | 2                 | 3                   | 6                  | 2                   | 2                  | 3                   | 12                 |

#    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
#      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
#      | 4       | split1 | db1.test_table1 | 1                  | 2                 | 3                  | 6                 | 2                  | 2                 | 3                  | 12                 |
#      | 4       | split1 | db1.test_table  | 1                  | 2                 | 3                  | 6                 | 2                  | 2                 | 3                  | 12                 |
#      (4, 'split1', 'db1.test_table', 1, 2, 3, 6, 1, 2, 3, 12)
#      (4, 'split1', 'db1.test_table1', 0, 0, 0, 0, 1, 0, 3, 12)

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | associate_tables-2             | sql_select_count-3 | sql_select_rows-4 |
      | 4       | split1 | db1.test_table,db1.test_table1 | 3                  | 12                |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_1 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    ##view
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                      | expect  | db      |
      | conn_0 | False   | replace into no_sharding_t1(id) select a.id from schema2.no_shar a                       | success | schema1 |
      | conn_0 | False   | drop view if exists test_view                                                            | success | schema1 |
      | conn_0 | False   | create view test_view(id,name) AS select * from test union select * from schema2.test1   | success | schema1 |
      | conn_0 | False   | select * from no_sharding_t1 union select * from schema2.no_shar                         | success | schema1 |
      | conn_0 | False   | drop view test_view                                                                      | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 2       | test   | 172.100.9.5    | 3306           | dn5             | hostM1        | 2          | 6         | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 1                   | 6                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | table-2                | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema2.no_shar        | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 6                  |
      | 2       | test   | schema1.no_sharding_t1 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 1                  | 6                  |

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | associate_tables-2                     | sql_select_count-3 | sql_select_rows-4 |
      | 2       | test   | schema1.no_sharding_t1,schema2.no_shar | 1                  | 6                 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                                | expect  | db      |
      | conn_0 | true    | drop table if exists sharding_2_t1;drop table if exists sharding_4_t1;drop table if exists test;drop table if exists schema2.test1 | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                                                                                                   | expect  | db      |
      | test1 | 111111 | conn_2 | true    | drop table if exists no_sharding_t1;drop table if exists schema2.no_shar;drop table if exists sharding_2_t1;drop table if exists schema2.sharding_2   | success | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                              | expect  | db  |
      | split1 | 111111 | conn_3 | true    | drop table if exists test_table;drop table if exists test_table1 | success | db1 |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: sharding user hint sql test #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                       | expect  | db      |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1                                    | success | schema1 |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ insert into sharding_4_t1 values(666, 'name666')               | success | schema1 |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ update sharding_4_t1 set name = 'dn1' where id=666             | success | schema1 |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ delete from sharding_4_t1 where id=666                         | success | schema1 |

    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect         | db               | timeout |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((1,),)}   | dble_information | 5       |
      | conn_1 | False   | select entry,user,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((2, 'test', 'dn1', 'hostM1', 4, 4, 1, 1, 1, 1, 1, 1, 1, 1),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((1,),)}  | dble_information | 5       |
      | conn_1 | False   | select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry   | has{((2, 'test', 'schema1.sharding_4_t1', 1, 1, 1, 1, 1, 1, 1, 1),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                                                     | expect  | db      |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)      | success | schema1 |
      | conn_0 | False    | /*!dble:shardingNode=dn1*/ select n.id,s.name from sharding_2_t1 n join sharding_4_t1 s on n.id=s.id                    | success | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect        | db               | timeout |
      | conn_1 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((1,),)}  | dble_information | 5       |
      | conn_1 | False   | select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user     | has{((2, 'test', 'schema1.sharding_2_t1,schema1.sharding_4_t1', 2, 1),)}   | dble_information | 5       |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | True     | drop table if exists sharding_4_t1;drop table if exists sharding_2_t1           | success | schema1 |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: transaction sql test #4
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |

    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_0 | False    | commit                                                                          | success | schema1 |

      | conn_0 | False    | start transaction                                                               | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1 where id=5                                            | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_0 | True     | commit                                                                          | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | False    | insert into sharding_4_t1 values(5,'name5'),(6,'name6')                         | success | schema1 |
      | conn_2 | False    | delete from sharding_4_t1 where id=6                                            | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |

      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where id=2                                          | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |
      | conn_2 | False    | update sharding_4_t1 set name='dn1' where id=100                                | success | schema1 |
      | conn_2 | False    | rollback                                                                        | success | schema1 |

      | conn_2 | False    | start transaction                                                               | success | schema1 |
      | conn_2 | False    | delete from sharding_2_t1                                                       | success | schema1 |

      | conn_2 | False    | begin                                                                           | success | schema1 |
      | conn_2 | True     | delete from sharding_4_t1                                                       | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_3 | False    | set autocommit=0                                                                | success | schema1 |

      | conn_3 | False    | update sharding_4_t1 set name='test_name'                                       | success | schema1 |
      | conn_3 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_3 | False    | commit                                                                          | success | schema1 |

      | conn_3 | False    | delete from sharding_4_t1 where id in (3, 4)                                    | success | schema1 |
      | conn_3 | False    | insert into sharding_4_t1 values(3,'name3'),(4,'name4')                         | success | schema1 |
      | conn_3 | False    | rollback                                                                        | success | schema1 |

      | conn_3 | True     | delete from sharding_4_t1                                                       | success | schema1 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 7          | 10        | 2                   | 2                  | 2                   | 2                  | 4                   | 4                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 8          | 8         | 1                   | 1                  | 3                   | 1                  | 4                   | 4                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 6          | 8         | 1                   | 1                  | 2                   | 2                  | 3                   | 3                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 6          | 8         | 1                   | 1                  | 1                   | 1                  | 3                   | 3                  | 3                   | 3                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_2_t1 | 0                  | 0                 | 0                  | 0                 | 1                  | 2                 | 0                  | 0                  |
      | 2       | test   | schema1.sharding_4_t1 | 3                  | 5                 | 5                  | 6                 | 5                  | 12                | 3                  | 9                  |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                           | expect  | db      |
      | conn_0 | False    | begin                                                                                         | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |
      | conn_0 | False    | commit                                                                                        | success | schema1 |

      | conn_0 | False    | start transaction                                                                             | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |
      | conn_0 | True     | commit                                                                                        | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                           | expect  | db      |
      | conn_2 | False    | begin                                                                                         | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |
      | conn_2 | False    | rollback                                                                                      | success | schema1 |

      | conn_2 | False    | start transaction                                                                             | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |
      | conn_2 | False    | rollback                                                                                      | success | schema1 |

      | conn_2 | False    | start transaction                                                                             | success | schema1 |
      | conn_2 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |

      | conn_2 | False    | begin                                                                                         | success | schema1 |
      | conn_2 | True     | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                           | expect  | db      |
      | conn_3 | False    | set autocommit=0                                                                              | success | schema1 |

      | conn_3 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |
      | conn_3 | False    | commit                                                                                        | success | schema1 |

      | conn_3 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |
      | conn_3 | False    | rollback                                                                                      | success | schema1 |

      | conn_3 | True     | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)       | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | associate_tables-2                          | sql_select_count-3 | sql_select_rows-4 |
      | 2       | test   | schema1.sharding_2_t1,schema1.sharding_4_t1 | 9                  | 0                 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | True     | drop table if exists sharding_2_t1;drop table if exists sharding_4_t1           | success | schema1 |

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
        <dbInstance name="hostS1" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    #1 more than one rwSplitUsers can use the same dbGroup
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <rwSplitUser name="rwS1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config"
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | rwS1 | 111111 | conn_3 | true    | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |
      | rwS1 | 111111 | conn_4 | False   | drop table if exists test_table1                          | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | create table test_table1(id int,name varchar(20),age int) | success | db2 |
      | rwS1 | 111111 | conn_4 | true    | insert into test_table1 values (1,'1',1),(2, '2',2)       | success | db2 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_1 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_1 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_1 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    #case  begin ... commit
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                              | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | begin                                            | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | select * from test_table                         | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values(5,'name5',5)       | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | commit                                           | success | db1 |

      | rwS1 | 111111 | conn_4 | False   | start transaction                                  | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age =33 where id=1          | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | delete from test_table1 where id=5                 | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age =44 where id=100        | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | commit                                             | success | db2 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 1       | rwS1   | 172.100.9.4    | 3306           | -               | hostM1        | 2          | 4         | 1                  | 1                 | 2                   | 1                  | 1                   | 0                  | 1                   | 2                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 1       | rwS1   | db2.test_table1 | 0                  | 0                 | 2                  | 1                 | 1                  | 0                 | 0                  | 0                  |
      | 1       | rwS1   | db1.test_table  | 1                  | 1                 | 0                  | 0                 | 0                  | 0                 | 1                  | 2                  |

    #case  begin ... rollback
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                      | expect  | db  |
      | rwS1 | 111111 | conn_3 | False   | begin                                                    | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | insert into test_table values(5,'name5',5),(6,'name6',6) | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | delete from test_table where id=6                        | success | db1 |
      | rwS1 | 111111 | conn_3 | False   | rollback                                                 | success | db1 |

      | rwS1 | 111111 | conn_4 | False   | start transaction                                        | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | select * from test_table1 where id=2                     | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age=age+1 where id=1              | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | update test_table1 set age=age*3 where id=2              | success | db2 |
      | rwS1 | 111111 | conn_4 | False   | rollback                                                 | success | db2 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 1       | rwS1   | 172.100.9.4    | 3306           | -               | hostM1        | 4          | 10        | 2                  | 3                 | 4                   | 3                  | 2                   | 1                  | 2                   | 3                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 1       | rwS1   | db2.test_table1 | 0                  | 0                 | 4                  | 3                 | 1                  | 0                 | 1                  | 1                  |
      | 1       | rwS1   | db1.test_table  | 2                  | 3                 | 0                  | 0                 | 1                  | 1                 | 1                  | 2                  |

    #case  begin ... start transaction
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                          | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | start transaction            | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | delete from test_table       | success | db1 |

      | rwS1 | 111111 | conn_31 | False   | begin                        | success | db1 |
      | rwS1 | 111111 | conn_31 | true    | delete from db2.test_table1  | success | db1 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 1       | rwS1   | 172.100.9.4    | 3306           | -               | hostM1        | 7          | 15        | 2                  | 3                 | 4                   | 3                  | 4                   | 6                  | 2                   | 3                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "10" times
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 1       | rwS1   | db2.test_table1 | 0                  | 0                 | 4                  | 3                 | 2                  | 2                 | 1                  | 1                  |
      | 1       | rwS1   | db1.test_table  | 2                  | 3                 | 0                  | 0                 | 2                  | 4                 | 1                  | 2                  |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                                                           | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | set autocommit=0                                              | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | update test_table set name='test_name'                        | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | select * from test_table                                      | success | db1 |
      | rwS1 | 111111 | conn_31 | False   | commit                                                        | success | db1 |

      | rwS1 | 111111 | conn_41 | False   | delete from db2.test_table1 where id in (1, 4)                | success | db2 |
      | rwS1 | 111111 | conn_41 | False   | insert into db2.test_table1 values(3,'name3',3),(4,'name4',4) | success | db2 |
      | rwS1 | 111111 | conn_41 | False   | rollback                                                      | success | db2 |

      | rwS1 | 111111 | conn_41 | False   | delete from db2.test_table1                                   | success | db2 |
    #尝试增加sleep，让结果落盘稳定
    Given sleep "5" seconds
    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 1       | rwS1   | 172.100.9.4    | 3306           | -               | hostM1        | 5          | 6         | 1                  | 2                 | 1                   | 0                  | 2                   | 4                  | 1                   | 0                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry " in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "10" times
      | entry-0 | user-1 | table-2         | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 1       | rwS1   | db2.test_table1 | 1                  | 2                 | 0                  | 0                 | 2                  | 4                 | 0                  | 0                  |
      | 1       | rwS1   | db1.test_table  | 0                  | 0                 | 1                  | 0                 | 0                  | 0                 | 1                  | 0                  |

     Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose  | sql                                                                                           | expect  | db  |
      | rwS1 | 111111 | conn_51 | False    | begin                                                                                         | success | db1 |
      | rwS1 | 111111 | conn_51 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |
      | rwS1 | 111111 | conn_51 | False    | commit                                                                                        | success | db1 |

      | rwS1 | 111111 | conn_51 | False    | start transaction                                                                             | success | db1 |
      | rwS1 | 111111 | conn_51 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |
      | rwS1 | 111111 | conn_51 | False    | commit                                                                                        | success | db1 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose  | sql                                                                                           | expect  | db  |
      | rwS1 | 111111 | conn_32 | False    | begin                                                                                         | success | db1 |
      | rwS1 | 111111 | conn_32 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |
      | rwS1 | 111111 | conn_32 | False    | rollback                                                                                      | success | db1 |

      | rwS1 | 111111 | conn_32 | False    | start transaction                                                                             | success | db1 |
      | rwS1 | 111111 | conn_32 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |
      | rwS1 | 111111 | conn_32 | False    | rollback                                                                                      | success | db1 |

      | rwS1 | 111111 | conn_32 | False    | start transaction                                                                             | success | db1 |
      | rwS1 | 111111 | conn_32 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |

      | rwS1 | 111111 | conn_32 | False    | begin                                                                                         | success | db1 |
      | rwS1 | 111111 | conn_32 | True     | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose  | sql                                                                                           | expect  | db  |
      | rwS1 | 111111 | conn_33 | False    | set autocommit=0                                                                              | success | db1 |

      | rwS1 | 111111 | conn_33 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |
      | rwS1 | 111111 | conn_33 | False    | commit                                                                                        | success | db1 |

      | rwS1 | 111111 | conn_33 | False    | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |
      | rwS1 | 111111 | conn_33 | False    | rollback                                                                                      | success | db1 |

      | rwS1 | 111111 | conn_33 | True     | select * from db2.test_table1 where name <> (select name from test_table where id !=1)        | success | db1 |


    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "10" times
      | entry-0 | user-1 | associate_tables-2              | sql_select_count-3 | sql_select_rows-4 |
      | 1       | rwS1   |  db1.test_table,db2.test_table1 | 9                  | 0                 |

     Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn    | toClose | sql                                 | expect  | db  |
      | rwS1 | 111111 | conn_31 | False   | commit                              | success | db1 |
      | rwS1 | 111111 | conn_31 | true    | drop table if exists test_table     | success | db1 |
      | rwS1 | 111111 | conn_41 | False   | commit                              | success | db2 |
      | rwS1 | 111111 | conn_41 | true    | drop table if exists test_table1    | success | db2 |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: xa transaction sql test #5
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_2_t1                                              | success | schema1 |
      | conn_0 | False    | create table sharding_2_t1(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | insert into sharding_2_t1 values(1,'name1'),(2,'name2')                         | success | schema1 |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | set autocommit=0                                                                | success | schema1 |

      | conn_0 | False    | set xa=on                                                                       | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn2' where id=1                                  | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | commit                                                                          | success | schema1 |

      | conn_0 | False    | insert into sharding_4_t1 values(5,'name5')                                     | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1 where id=4                                            | success | schema1 |
      | conn_0 | False    | rollback                                                                        | success | schema1 |

      | conn_0 | True    | delete from sharding_4_t1                                                        | success | schema1 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 1          | 4         | 1                   | 1                  | 1                   | 1                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 1          | 3         | 0                   | 0                  | 0                   | 0                  | 2                   | 2                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 1          | 2         | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  | 1                   | 1                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 1          | 2         | 0                   | 0                  | 0                   | 0                  | 1                   | 1                  | 1                   | 1                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_4_t1 | 1                  | 1                 | 1                  | 1                 | 2                  | 5                 | 1                  | 4                  |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                               | expect  | db      |
      | conn_0 | False    | set autocommit=0                                                                                  | success | schema1 |
      | conn_0 | False    | set xa=on                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)           | success | schema1 |
      | conn_0 | False    | commit                                                                                            | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_2_t1 where id !=1)           | success | schema1 |
      | conn_0 | False    | rollback                                                                                          | success | schema1 |

      | conn_0 | True    | delete from sharding_4_t1                                                                          | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | associate_tables-2                          | sql_select_count-3 | sql_select_rows-4 |
      | 2       | test   | schema1.sharding_2_t1,schema1.sharding_4_t1 | 2                  | 6                 | 

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | True     | drop table if exists sharding_2_t1;drop table if exists sharding_4_t1           | success | schema1 |
    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario: implict commit test #6
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
        <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
        <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
        <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        <shardingTable name="sharding_4_t2" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
    </schema>
    """
    Then execute admin cmd "reload @@config_all"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | drop table if exists sharding_4_t1                                              | success | schema1 |
      | conn_0 | False    | drop table if exists sharding_4_t2                                              | success | schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int, name varchar(20))                            | success | schema1 |
    Then execute admin cmd "enable @@statistic"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | create table sharding_4_t2(id int, name varchar(20))                            | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | insert into sharding_4_t2 values(1,'name1'),(2,'name2'),(3,'name3'),(4,'name4') | success | schema1 |
      | conn_0 | False    | create index index_name1 on sharding_4_t1 (name)                                | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn1' where id=4                                  | success | schema1 |
      | conn_0 | False    | drop index index_name1 on sharding_4_t1                                         | success | schema1 |

      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | update sharding_4_t1 set name='dn4' where id=3                                  | success | schema1 |

      | conn_0 | False    | start transaction                                                               | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | set autocommit=0                                                                | success | schema1 |
      | conn_0 | False    | select * from sharding_4_t1                                                     | success | schema1 |
      | conn_0 | False    | set autocommit=1                                                                | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1 where id=1                                            | success | schema1 |
      | conn_0 | False    | truncate table sharding_4_t2                                                    | success | schema1 |
      | conn_0 | False    | begin                                                                           | success | schema1 |
      | conn_0 | False    | delete from sharding_4_t1 where id=2                                            | success | schema1 |
      | conn_0 | true     | drop table sharding_4_t2                                                        | success | schema1 |

    Then connect "dble-1" execute sql "select * from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "4" retry "5" times
      | entry-0 | user-1 | backend_host-3 | backend_port-4 | sharding_node-5 | db_instance-6 | tx_count-7 | tx_rows-8 | sql_insert_count-10 | sql_insert_rows-11 | sql_update_count-13 | sql_update_rows-14 | sql_delete_count-16 | sql_delete_rows-17 | sql_select_count-19 | sql_select_rows-20 |
      | 2       | test   | 172.100.9.6    | 3306           | dn2             | hostM2        | 5          | 5         | 2                   | 2                  | 0                   | 0                  | 1                   | 1                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 5          | 5         | 2                   | 2                  | 1                   | 1                  | 0                   | 0                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.6    | 3306           | dn4             | hostM2        | 5          | 5         | 2                   | 2                  | 1                   | 1                  | 0                   | 0                  | 2                   | 2                  |
      | 2       | test   | 172.100.9.5    | 3306           | dn3             | hostM1        | 5          | 5         | 2                   | 2                  | 0                   | 0                  | 1                   | 1                  | 2                   | 2                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "2" retry "5" times
      | entry-0 | user-1 | table-2               | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | schema1.sharding_4_t1 | 1                  | 4                 | 2                  | 2                 | 2                  | 2                 | 2                  | 8                  |
      | 2       | test   | schema1.sharding_4_t2 | 1                  | 4                 | 0                  | 0                 | 0                  | 0                 | 0                  | 0                  |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                             | expect  | db      |
      | conn_0 | False    | create table sharding_4_t2(id int, name varchar(20))                            | success | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                                           | expect  | db      |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | start transaction                                                                             | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |
      | conn_0 | False    | set autocommit=0                                                                              | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | set autocommit=1                                                                              | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |
      | conn_0 | False    | begin                                                                                         | success | schema1 |

      | conn_0 | False    | select * from sharding_4_t1 where name <> (select name from sharding_4_t2 where id !=1)       | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,associate_tables,sql_select_count,sql_select_rows from sql_statistic_by_associate_tables_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | associate_tables-2                          | sql_select_count-3 | sql_select_rows-4 |
      | 2       | test   | schema1.sharding_4_t1,schema1.sharding_4_t2 | 8                  | 0                 |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario:  error sql test #7
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
    """
    <schema name="schema2" sqlMaxLimit="100">
        <globalTable name="test1" shardingNode="dn1,dn2" />
        <shardingTable name="sharding_2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
    </schema>
     """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
    <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
      <heartbeat>select user()</heartbeat>
      <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
      <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="100" minCon="10" primary="false" />
    </dbGroup>
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
    """
    <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
    <shardingUser name="test1" password="111111" schemas="schema1,schema2" readOnly="false"/>
    <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
    """
    Then execute admin cmd "reload @@config_all"
    Given execute oscmd in "dble-1"
      """
      mysql -uroot -p111111 -P9066 -h172.100.9.1 -Ddble_information -e "select concat('drop table if exists ',name,';') as 'select 1;' from dble_table" >/opt/dble/test.sql && \
      mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "source /opt/dble/test.sql" && \
      mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema2 -e "source /opt/dble/test.sql"
      """

   #pre env,for truncate
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect    | db      |
      | conn_1 | False   | drop table if exists test                              | success   | schema1 |
      | conn_1 | False   | create table test (id int,name varchar(20),age int)    | success   | schema1 |
    Then execute admin cmd "enable @@statistic"

    #case Syntax error sql will not be counted --shardinguser
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect    | db      |
      | conn_1 | False   | SELECT DATABASE()                    | success   | schema1 |
      | conn_1 | False   | SELECT USER()                        | success   | schema1 |
      | conn_1 | False   | SELECT 2                             | success   | schema1 |
      | conn_1 | true    | show tables                          | success   | schema1 |
      | conn_1 | False   | use schema1                          | success                               | schema1 |
      | conn_1 | False   | use schema66                         | Unknown database 'schema66'           | schema1 |
      | conn_1 | False   | select user                          | Unknown column 'user' in 'field list' | schema1 |
      | conn_1 | False   | explain select * from test           | success | schema1 |
      | conn_1 | False   | explain2 select * from test          | success | schema1 |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 2       | test   | 172.100.9.5    | 3306           | dn5             | hostM1        | 3          | 0                  | 0                 | 0                   | 0                  | 0                   | 0                  | 2                   | 1                  |

    Then connect "dble-1" execute sql "select entry,user,table,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_table_by_user_by_entry" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | table-2 | sql_insert_count-3 | sql_insert_rows-4 | sql_update_count-5 | sql_update_rows-6 | sql_delete_count-7 | sql_delete_rows-8 | sql_select_count-9 | sql_select_rows-10 |
      | 2       | test   | null    | 0                  | 0                 | 0                  | 0                 | 0                  | 0                 | 3                  | 3                  |

    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_0 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_0 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect                                 | db      |
      #case schema1 has default shardingnode table test100-103 would sent to "dn5",count +1,row +0
      | conn_1 | False   | select * from test100                 | Table 'db3.test100' doesn't exist      | schema1 |
      | conn_1 | False   | insert into test101 values (1)        | Table 'db3.test101' doesn't exist      | schema1 |
      | conn_1 | False   | delete from test102                   | Table 'db3.test102' doesn't exist      | schema1 |
      | conn_1 | true    | update test103 set id =2 where id =1  | Table 'db3.test103' doesn't exist      | schema1 |
      #case schema2 has not default shardingnode ,dont count
      | conn_2 | False   | select * from test1000                | Table 'schema2.test1000' doesn't exist | schema2 |
      | conn_2 | False   | insert into test1001 values (1)       | Table 'schema2.test1001' doesn't exist | schema2 |
      | conn_2 | False   | delete from test1002                  | Table 'schema2.test1002' doesn't exist | schema2 |
      | conn_2 | true    | update test1003 set id =2 where id =1 | Table 'schema2.test1003' doesn't exist | schema2 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 2       | test   | 172.100.9.5    | 3306           | dn5             | hostM1        | 4          | 0         | 1                  | 0                 | 1                   | 0                  | 1                   | 0                  | 1                   | 0                  |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                           | expect  | db      |
      | conn_1 | False   | drop table if exists sharding_2_t1                                            | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.test1                                            | success | schema1 |
      | conn_1 | False   | drop table if exists sharding_4_t1                                            | success | schema1 |
      | conn_1 | False   | drop table if exists schema2.sharding_2                                       | success | schema1 |
      | conn_1 | False   | create table sharding_2_t1 (id int,name varchar(20),age int)                  | success | schema1 |
      | conn_1 | False   | create table schema2.test1 (id int,name varchar(20),age int)                  | success | schema1 |
      | conn_1 | False   | create table sharding_4_t1 (id int,name varchar(20),age int)                  | success | schema1 |
      | conn_1 | False   | create table schema2.sharding_2 (id int,name varchar(20),age int)             | success | schema1 |
      | conn_1 | False   | insert into test values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)               | success | schema1 |
      | conn_1 | False   | insert into sharding_2_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)      | success | schema1 |
      | conn_1 | False   | insert into schema2.test1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)      | success | schema1 |
      | conn_1 | False   | insert into sharding_4_t1 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4)      | success | schema1 |
      | conn_1 | False   | insert into schema2.sharding_2 values (1,'a',1),(2,'b',2),(3,'c',3),(4,'d',4) | success | schema1 |
    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_0 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_0 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

      #complex don't supported sql
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                            | expect                                            | db      |
      | conn_1 | False   | update schema1.test a,schema2.test1 b set a.age=b.age+1,b.name=a.name-1 where a.name=b.name                                    | This `Complex Update Syntax` is not supported!    | schema1 |
      | conn_1 | False   | delete schema1.test,schema2.test1 from schema1.test,schema2.test1 where schema1.test.name=schema2.test1.name                   | This `Complex Delete Syntax` is not supported!    | schema1 |
      | conn_1 | False   | update schema2.sharding_2_t1 a,db1.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1                       | Table `db1`.`single_t2` doesn't exist             | schema1 |
      | conn_1 | False   | update db1.sharding_2_t1 a,schema2.single_t2 b set a.age=b.age+1,b.name=a.name-1 where a.id=2 and b.id=1                       | Table `db1`.`sharding_2_t1` doesn't exist         | schema1 |
      | conn_1 | False   | delete db1.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where schema1.sharding_2_t1.id=2 and schema2.single_t2.id =2 | Table `db1`.`single_t2` doesn't exist             | schema1 |
      | conn_1 | False   | delete schema2.single_t2 from schema1.sharding_2_t1,schema2.single_t2 where db1.sharding_2_t1.id=2 and schema2.single_t2.id =2 | Table `db1`.`sharding_2_t1` doesn't exist         | schema1 |
      | conn_1 | False   | insert into sharding_4_t1(id,name) select s2.id,s2.name from schema2.sharding_2 s2 join test s2g on s2.id=s2g.id               | This `INSERT ... SELECT Syntax` is not supported  | schema1 |
      | conn_1 | False   | replace into test(name) select name from sharding_4_t1                                                                         | This `REPLACE ... SELECT Syntax` is not supported | schema1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect         | db               | timeout |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |


    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                            | expect                                            | db      |
      #case the dble sql error would count,use explain would find send to dn1 tx +1,update +1
      | conn_1 | False   | update sharding_2_t1 a,schema2.sharding_2 b set a.age=b.age+1,b.name=a.name+1 where a.id=2 and b.id=2                          | Truncated incorrect DOUBLE value: 'b'             | schema1 |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect         | db               | timeout |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1 | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 2       | test   | 172.100.9.5    | 3306           | dn1             | hostM1        | 1          | 0         | 0                  | 0                 | 1                   | 0                  | 0                   | 0                  | 0                   | 0                  |

    #case Syntax error sql will not be counted --rwSplitUser
     Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | split1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | split1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | split1 | 111111 | conn_3 | False   | insert into test_table values (1,'1',1),(2, '2',2)        | success | db1 |

    Given sleep "2" seconds
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | true    | truncate sql_statistic_by_frontend_by_backend_by_entry_by_user             | success     | dble_information | 5       |
      | conn_0 | true    | truncate sql_statistic_by_table_by_user_by_entry                           | success     | dble_information | 5       |
      | conn_0 | true    | truncate sql_statistic_by_associate_tables_by_entry_by_user                | success     | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_frontend_by_backend_by_entry_by_user | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

     Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                    | expect                                      | db  |
      | split1 | 111111 | conn_3 | true     | use db11                              | Unknown database 'db11'                     | db1 |
      | split1 | 111111 | conn_3 | False    | delete from test_table2 where id =1   | Table 'db1.test_table2' doesn't exist       | db1 |
      | split1 | 111111 | conn_3 | False    | select * froom test_table where id =1 | error in your SQL syntax                    | db1 |
      | split1 | 111111 | conn_3 | False    | explain select * from test_table      | success                                     | db1 |
      | split1 | 111111 | conn_3 | False    | set user=1                            | Unknown system variable 'user'              | db1 |
      | split1 | 111111 | conn_3 | False    | select * from test_table where a.id=1 | Unknown column 'a.id'                       | db1 |
      | split1 | 111111 | conn_3 | False    | select councat_ws('',id,age) as 'll' from test_table group by ll | FUNCTION db1.councat_ws does not exist                           | db1 |
      | split1 | 111111 | conn_3 | False    | select concat_ws('',id,age) as 'll' from test_table group by ls  | Unknown column 'ls' in 'group statement'                         | db1 |
      | split1 | 111111 | conn_3 | true     | select * from (select s.sno from test_table s where s.id=1)      | Every derived table must have its own alias                      | db1 |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                        | expect      | db               | timeout |
      | conn_0 | False   | select count(*) from sql_statistic_by_table_by_user_by_entry               | has{((0,),)}   | dble_information | 5       |
      | conn_0 | False   | select count(*) from sql_statistic_by_associate_tables_by_entry_by_user    | has{((0,),)}   | dble_information | 5       |

    Then connect "dble-1" execute sql "select entry,user,backend_host,backend_port,sharding_node,db_instance,tx_count,tx_rows,sql_insert_count,sql_insert_rows,sql_update_count,sql_update_rows,sql_delete_count,sql_delete_rows,sql_select_count,sql_select_rows from sql_statistic_by_frontend_by_backend_by_entry_by_user" in mode "admin" use db "dble_information" and user "root" to check has following and length "1" retry "5" times
      | entry-0 | user-1   | backend_host-2 | backend_port-3 | sharding_node-4 | db_instance-5 | tx_count-6 | tx_rows-7 | sql_insert_count-8 | sql_insert_rows-9 | sql_update_count-10 | sql_update_rows-11 | sql_delete_count-12 | sql_delete_rows-13 | sql_select_count-14 | sql_select_rows-15 |
      | 4       | split1   | 172.100.9.4    | 3306           |  -              | hostM3        | 8          | 0         | 0                  | 0                 | 0                   | 0                  | 1                   | 0                  | 5                   | 0                  |

    Given execute oscmd in "dble-1"
      """
      mysql -uroot -p111111 -P9066 -h172.100.9.1 -Ddble_information -e "select concat('drop table if exists ',name,';') as 'select 1;' from dble_table" >/opt/dble/test.sql && \
      mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema1 -e "source /opt/dble/test.sql" && \
      mysql -utest -p111111 -P8066 -h172.100.9.1 -Dschema2 -e "source /opt/dble/test.sql"
      """
     Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | split1 | 111111 | conn_3 | true    | drop table if exists test_table                           | success | db1 |
    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"


  Scenario:  useServerPepStmts=true sql DBLE0REQ-2215  #7

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="100" minCon="10" primary="true" />
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="split1" password="111111" dbGroup="ha_group3" />
      """
    Then execute admin cmd "reload @@config_all"
    Then execute admin cmd "enable @@statistic"
    Then execute admin cmd "reload @@samplingRate=100"

    Then execute sql in "dble-1" in "user" mode
      | user   | passwd | conn   | toClose | sql                                                       | expect  | db  |
      | split1 | 111111 | conn_3 | False   | drop table if exists test_table                           | success | db1 |
      | split1 | 111111 | conn_3 | False   | create table test_table(id int,name varchar(20),age int)  | success | db1 |
      | split1 | 111111 | conn_3 | False   | insert into test_table values (1,'1',1),(2,'2',2)         | success | db1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect    | db      |
      | conn_1 | False   | drop table if exists test                              | success   | schema1 |
      | conn_1 | False   | create table test (id int,name varchar(20),age int)    | success   | schema1 |
      | conn_1 | False   | insert into test values (1,'1',1),(2,'2',2)            | success   | schema1 |

    ##has some issue
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect           | db               | timeout |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user  | length{(5)}      | dble_information | 5       |
#      | conn_0 | False   | select sql_select_count from sql_statistic_by_table_by_user_by_entry | has{((0,),(0,))} | dble_information | 5       |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user     | length{(0)}      | dble_information | 5       |
      | conn_0 | False   | select * from sql_log                                                | length{(6)}      | dble_information | 5       |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user                         | length{(6)}      | dble_information | 5       |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user                     | length{(6)}      | dble_information | 5       |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user                  | length{(6)}      | dble_information | 5       |

    #use server prepare
    Then execute prepared sql "select %s from test where id =%s" with params "(name,1);(id,3)" on db "schema1" and user "test"
    Then execute prepared sql "select %s from test_table where id =%s" with params "(name,1);(id,3)" on db "db1" and user "split1"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                                  | expect           | db               | timeout |
      | conn_0 | False   | select * from sql_statistic_by_frontend_by_backend_by_entry_by_user  | length{(5)}      | dble_information | 5       |
#      | conn_0 | False   | select sql_select_count from sql_statistic_by_table_by_user_by_entry | has{((2,),(2,))} | dble_information | 5       |
      | conn_0 | False   | select * from sql_statistic_by_associate_tables_by_entry_by_user     | length{(0)}      | dble_information | 5       |
      | conn_0 | False   | select * from sql_log                                                | length{(14)}     | dble_information | 5       |
      | conn_0 | False   | select * from sql_log_by_tx_by_entry_by_user                         | length{(12)}     | dble_information | 5       |
      | conn_0 | False   | select * from sql_log_by_digest_by_entry_by_user                     | length{(12)}     | dble_information | 5       |
      | conn_0 | False   | select * from sql_log_by_tx_digest_by_entry_by_user                  | length{(11)}     | dble_information | 5       |

    Then check "NullPointerException|caught err|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      use server prepare
      """