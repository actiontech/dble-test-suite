# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by yexiaoli at 2019/3/5
Feature: show_dbinstance
  @restore_mysql_service
  Scenario: verify manage-cmd show @@dbinstance:requirment from github issue #942 #: result should not display negative number for "ACTIVE" column,github issue #1070 #1
     """
    {'restore_mysql_service':{'mysql-master1':{'start_mysql':1}}}
    """
     Given stop mysql in host "mysql-master1"
     Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs"
       | sql               |
       | show @@dbinstance |
     Then check resultset "sql_rs" has lines with following column values
        | NAME-1 | HOST-2        |  PORT-3 | ACTIVE-5  | IDLE-6  |
        | hostM1 | 172.100.9.5   | 3306    |    0      |    0    |
    Given start mysql in host "mysql-master1"

  Scenario: github issue #1064 #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group1" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM1" password="111111" url="172.100.9.5:3306" user="test" maxCon="1000" minCon="10" primary="true">
        </dbInstance>
     </dbGroup>
    """
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs2"
      | sql               |
      | show @@dbinstance |
    Then check resultset "sql_rs2" has lines with following column values
        | NAME-1 | HOST-2        |  PORT-3  | ACTIVE-5 |
        | hostM1 | 172.100.9.5   | 3306     |    0     |


  @restore_global_setting
  Scenario: check rwSplitUser READ_LOAD and WRITE_LOAD #3
  """
  {'restore_global_setting':{'mysql':{'general_log':0},'mysql-slave3':{'general_log':0}}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DrwStickyTime/d
    $a -DrwStickyTime=0
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="3" name="ha_group3" delayThreshold="5000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS3" password="111111" url="172.100.9.4:3307" user="test" maxCon="1000" minCon="10"  />
      </dbGroup>
      """
    Then restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs1"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs1" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM3 | 172.100.9.4   | 3306   | 0           | 0            |
      | hostS3 | 172.100.9.4   | 3307   | 0           | 0            |

    # debug code start
    Given turn on general log in "mysql"
    Given turn on general log in "mysql-slave3"
    Then execute admin cmd "reload @@general_log_file='/opt/dble/logs/general.log'"
    Then execute admin cmd "enable @@general_log"
    # debug code end

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                      | expect                | db  |
      | rw1   | 111111 | conn_1 | False   | drop table if exists test_tb             | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | create table test_tb (id int, age int)   | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test_tb values (1,20),(2,20) | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | update test_tb set age=25 where id=1     | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | delete from test_tb where id=2           | success               | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | select sleep(3)                          | success               | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | select * from test_tb                    | has{((1,25),)}        | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | show tables                              | has{(('test_tb',),)}  | db1 |
     # DBLE0REQ-2324
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs2"
      | sql               |
      | show @@dbInstance |

    # debug code start
    Then execute admin cmd "disable @@general_log"
    Given execute oscmd in "mysql"
     """
     cat /root/sandboxes/sandbox/master/data/mysql.log
     """
     Given execute oscmd in "mysql-slave3"
     """
     cat /root/sandboxes/sandbox/node1/data/mysql.log
     """
    Given turn off general log in "mysql"
    Given turn off general log in "mysql-slave3"
    # debug code end

     # 读写分离的show强制发master,但统计为read（符合预期）
    Then check resultset "sql_rs2" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM3 | 172.100.9.4   | 3306   | 6           | 0            |
      | hostS3 | 172.100.9.4   | 3307   | 3           | 0            |

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                      | expect                | db  |
      | rw1   | 111111 | conn_1 | False   | begin                                    | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test_tb values (2,20),(3,30) | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test_tb                    | length{(3)}           | db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                   | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | start transaction                        | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | update test_tb set age=35 where id=3     | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test_tb where id=3         | has{((3,35),)}        | db1 |
      | rw1   | 111111 | conn_1 | False   | rollback                                 | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | set autocommit=0                         | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | delete from test_tb where id=2           | success               | db1 |
      | rw1   | 111111 | conn_1 | False   | select count(0) from test_tb             | length{(1)}           | db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                   | success               | db1 |
      # 必须设置autocommit=1，否则会进入缺陷DBLE0REQ-2329
      | rw1   | 111111 | conn_1 | False   | set autocommit=1                         | success               | db1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs3"
      | sql               |
      | show @@dbInstance |
     # 只有set autocommit=0 统计为write
    Then check resultset "sql_rs3" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM3 | 172.100.9.4   | 3306   | 8           | 1            |
      | hostS3 | 172.100.9.4   | 3307   | 3           | 0            |

    # db_instance_url,uproxy_dest未统计，其他2条都统计到了write里
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                    | expect                | db  |
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_type=master*/select age,count(0) from test_tb group by age  | has{((30,1),(25,1))}  | db1 |
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_instance_url=172.100.9.4:3306*/ select * from test_tb       | length{(2)}           | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test_tb where age=30/* master */                         | has{((3,30),)}        | db1 |
      | rw1   | 111111 | conn_1 | False   | /* uproxy_dest:172.100.9.4:3306 */ select * from test_tb where id=1    | has{((1,25),)}        | db1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs4"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs4" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM3 | 172.100.9.4   | 3306   | 8           | 3            |
      | hostS3 | 172.100.9.4   | 3307   | 3           | 0            |

    # 只第一条统计了，后面3条都没统计
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                                    | expect                | db  |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_type=slave*/select age,count(0) from test_tb group by age   | has{((30,1),(25,1))}  | db1 |
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_instance_url=172.100.9.4:3307*/ select * from test_tb       | length{(2)}           | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | select * from test_tb where age=30/* slave */                          | has{((3,30),)}        | db1 |
      | rw1   | 111111 | conn_1 | False   | /* uproxy_dest:172.100.9.4:3307 */ select * from test_tb where id=1    | has{((1,25),)}        | db1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs5"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs5" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM3 | 172.100.9.4   | 3306   | 8           | 3            |
      | hostS3 | 172.100.9.4   | 3307   | 5           | 0            |

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                 | expect                               | db  |
      | rw1   | 111111 | conn_1 | False   | drop table 123                      | illegal name                         | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | select * abc                        | You have an error in your SQL syntax | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | select 123 from abc                 | Table 'db1.abc' doesn't exist        | db1 |
      # hostS3 read+1
      | rw1   | 111111 | conn_1 | False   | select from abc                     | You have an error in your SQL syntax | db1 |
      # hostM3 read+1
      | rw1   | 111111 | conn_1 | False   | selet abc                           | You have an error in your SQL syntax | db1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs5"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs5" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM3 | 172.100.9.4   | 3306   | 9           | 3            |
      | hostS3 | 172.100.9.4   | 3307   | 8           | 0            |
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                           | expect  | db  |
      | rw1   | 111111 | conn_1 | True    | drop table if exists test_tb  | success | db1 |  


  # DBLE0REQ-1445
  Scenario: check shardingUser READ_LOAD and WRITE_LOAD #4
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DrwStickyTime/d
    $a -DrwStickyTime=0
    """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="3" name="ha_group2" delayThreshold="5000" >
        <heartbeat>show slave status</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" />
        <dbInstance name="hostS2" password="111111" url="172.100.9.6:3307" user="test" maxCon="1000" minCon="10"  />
      </dbGroup>
      """
    Then restart dble in "dble-1" success

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs1"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs1" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM1 | 172.100.9.5   | 3306   | 0           | 0            |
      | hostM2 | 172.100.9.6   | 3306   | 0           | 0            |
      | hostS2 | 172.100.9.6   | 3307   | 0           | 0            |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect                      | db      |
      # hostM1 write+2, hostM2 write+2
      | conn_1 | False   | drop table if exists sharding_4_t1             | success                     | schema1 |
      # hostM1 write+2, hostM2 write+2
      | conn_1 | False   | create table sharding_4_t1 (id int, age int)   | success                     | schema1 |
      # hostM1 write+1, hostM2 write+1
      | conn_1 | False   | insert into sharding_4_t1 values (1,20),(2,20) | success                     | schema1 |
      # hostM2 write+1
      | conn_1 | False   | update sharding_4_t1 set age=25 where id=1     | success                     | schema1 |
      # hostM2 write+1
      | conn_1 | False   | delete from sharding_4_t1 where id=1           | success                     | schema1 |
      # hostM1 read+1
      | conn_1 | False   | select sleep(3)                                | success                     | schema1 |
      # hostM1 read+2, hostS2 read+2
      | conn_1 | False   | select * from sharding_4_t1                    | length{(1)}                 | schema1 |
      # hostM1 read+1
      | conn_1 | True    | show tables                                    | has{(('sharding_4_t1',),)}  | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs2"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs2" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM1 | 172.100.9.5   | 3306   | 4           | 5            |
      | hostM2 | 172.100.9.6   | 3306   | 0           | 7            |
      | hostS2 | 172.100.9.6   | 3307   | 2           | 0            |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                            | expect                | db      |
      | conn_1 | False   | begin                                          | success               | schema1 |
      # hostM1 write+1, hostM2 write+1
      | conn_1 | False   | insert into sharding_4_t1 values (2,20),(3,30) | success               | schema1 |
      # hostM1 write+1, hostM2 write+1
      | conn_1 | False   | select * from sharding_4_t1                    | length{(3)}           | schema1 |
      | conn_1 | False   | commit                                         | success               | schema1 |
      | conn_1 | False   | start transaction                              | success               | schema1 |
      # hostM2 write+1
      | conn_1 | False   | update sharding_4_t1 set age=35 where id=3     | success               | schema1 |
      # hostM2 write+1
      | conn_1 | False   | select * from sharding_4_t1 where id=3         | has{((3,35),)}        | schema1 |
      | conn_1 | False   | rollback                                       | success               | schema1 |
      | conn_1 | False   | set autocommit=0                               | success               | schema1 |
      # hostM1 write+1
      | conn_1 | False   | delete from sharding_4_t1 where id=2           | success               | schema1 |
      # hostM1 write+1, hostM2 write+1
      | conn_1 | False   | select count(0) from sharding_4_t1             | has{((1,),)}          | schema1 |
      | conn_1 | True    | commit                                         | success               | schema1 |
      | conn_1 | False   | set autocommit=1                               | success               | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs3"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs3" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM1 | 172.100.9.5   | 3306   | 4           | 9            |
      | hostM2 | 172.100.9.6   | 3306   | 0           | 12           |
      | hostS2 | 172.100.9.6   | 3307   | 2           | 0            |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                          | expect          | db      |
      # DBLE0REQ-2325
      # hostM1 write+2, hostM2 write+2
      | conn_1 | False   | /*!dble:db_type=master*/select age,count(0) from sharding_4_t1 group by age  | has{((30,1),)}  | schema1 |
#      # hostM1 read+2, hostS2 read+2
      | conn_1 | False   | select * from sharding_4_t1 where age=30/* slave */                          | has{((3,30),)}  | schema1 |
#      # hostS2 read+1
      | conn_1 | True   | /*!dble:shardingNode=dn2 */ select * from sharding_4_t1                       | length{(0)}     | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs4"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs4" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM1 | 172.100.9.5   | 3306   | 6           | 11           |
      | hostM2 | 172.100.9.6   | 3306   | 0           | 14           |
      | hostS2 | 172.100.9.6   | 3307   | 5           | 0            |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect                               | db      |
      | conn_1 | False   | drop table 123                      | druid not support sql syntax         | schema1 |
      | conn_1 | False   | select * abc                        | druid not support sql syntax         | schema1 |
      # hostM1 read+1
      | conn_1 | False   | select 123 from abc                 | Table 'db3.abc' doesn't exist        | schema1 |
      # hostM1 read+1
      | conn_1 | False   | select from abc                     | You have an error in your SQL syntax | schema1 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "sql_rs5"
      | sql               |
      | show @@dbInstance |
    Then check resultset "sql_rs5" has lines with following column values
      | NAME-1 | HOST-2        | PORT-3 | READ_LOAD-8 | WRITE_LOAD-9 |
      | hostM1 | 172.100.9.5   | 3306   | 8           | 11           |
      | hostM2 | 172.100.9.6   | 3306   | 0           | 14           |
      | hostS2 | 172.100.9.6   | 3307   | 5           | 0            |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                 | expect      | db      |
      | conn_1 | True    | drop table if exists sharding_4_t1  | success     | schema1 |