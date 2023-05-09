# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by zhaohongjie at 2019/12/11
Feature: test high-availability related commands
  ha related commands to test:
  dbGroup @@disable name='xxx' [instance='xxx']
  dbGroup @@enable name='xxx' [instance='xxx']
  dbGroup @@switch name='xxx' master='xxx'
  show @@dbinstance

  Scenario: end to end ha switch test
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
     """
     $a -DuseOuterHa=true
    """
    Given Restart dble in "dble-1" success
#   a transaction in processing
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect   | db       |
      | conn_0 | False    | drop table if exists sharding_4_t1         | success  |  schema1 |
      | conn_0 | False    | create table sharding_4_t1(id int)         | success  |  schema1 |
      | conn_0 | False    | begin                                      | success  |  schema1 |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2)    | success  |  schema1 |
    Then execute admin cmd "dbGroup @@disable name='ha_group2'"
#    check transaction is killed forcely
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                         | expect                                                                                                        | db       |
      | conn_0 | true     | select * from sharding_4_t1 | java.io.IOException: the dbInstance[172.100.9.6:3306] is disable. Please check the dbInstance disable status  | schema1  |

    Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM2'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
#    The expect fail msg is tmp,for github issue:#1528
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect              | db        |
      | conn_0 | true     | insert into sharding_4_t1 values(1),(2)    | error totally whack | schema1   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_be_rs"
      | sql            |
      | show @@backend |
    Then check resultset "show_be_rs" has not lines with following column values
    | HOST-3      | PORT-4 |
    | 172.100.9.6 | 3307   |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W    |      0   | true        |
    | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W    |      0   | false       |
    #Given update "bootstrap.cnf" from "dble-1"

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
    """
     <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
       <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true" disabled="true">
        </dbInstance>
        <dbInstance name="slave1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10" disabled="true">
        </dbInstance>
     </dbGroup>
    """
    Then execute admin cmd "reload @@config_all"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4| ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W    |      0   |  true      |
    | ha_group2  | slave1   | 172.100.9.6   | 3307   | R    |      0   |  true       |
    | ha_group1  | hostM1   | 172.100.9.5   | 3306   | W    |      0   |  false      |
    Then execute admin cmd "dbGroup @@switch name='ha_group2' master='slave1'"
    Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'hostM2','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
    Then check exist xml node "{'tag':'dbGroup/dbInstance','kv_map':{'name':'slave1','disabled':'true'}}" in " /opt/dble/conf/db.xml" in host "dble-1"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      0   | true        |
    | ha_group2  | slave1   | 172.100.9.6   | 3307   | W      |      0   | true        |
    Then execute admin cmd "dbGroup @@enable name='ha_group2'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5| DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |     0   | false       |
    | ha_group2  | slave1   | 172.100.9.6   | 3307   | W      |     0   | false       |

#    dble-2 is slave1's server
    Then execute sql in "mysql-slave1"
      | conn   | toClose | sql                             | expect  |
      | conn_0 | False   | set global general_log=on       | success |
      | conn_0 | False   | set global log_output='table'   | success |
      | conn_0 | True    | truncate table mysql.general_log| success |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                        | expect   | db        |
      | conn_0 | False    | insert into sharding_4_t1 values(1),(2)    | success  |  schema1  |
      | conn_0 | True     | select * from sharding_4_t1                | success  |  schema1  |
    Then execute sql in "mysql-slave1"
      | sql                                                                                           | expect      | db  |
      | select count(*) from mysql.general_log where argument like'insert into sharding_4_t1 values%' | length{(1)} | db1 |
    Then execute admin cmd "dbGroup @@disable name='ha_group2' instance='slave1'"
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | R      |      0   | false       |
    | ha_group2  | slave1   | 172.100.9.6   | 3307   | W      |      0   | true        |
    Then execute admin cmd "dbGroup @@switch name='ha_group2' master='hostM2'"
    Given Restart dble in "dble-1" success
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "show_ds_rs"
      | sql               |
      | show @@dbinstance |
    Then check resultset "show_ds_rs" has lines with following column values
    | DB_GROUP-0 | NAME-1   | HOST-2        | PORT-3 | W/R-4  | ACTIVE-5 | DISABLED-10 |
    | ha_group2  | hostM2   | 172.100.9.6   | 3306   | W      |      0   | false       |
    | ha_group2  | slave1   | 172.100.9.6   | 3307   | R      |      0   | true        |



  @btrace
  Scenario: 主从切换后，业务端开启事务，进行rollback，数据应该全部回滚  DBLE0REQ-2213  #2
    Given delete file "/opt/dble/BtracetryExistsCon*" on "dble-1"
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
       """
       $a -DuseOuterHa=true
       /-Dprocessors=/d
       /-DprocessorExecutor=/d
       $a -Dprocessors=8
       $a -DprocessorExecutor=8
       """
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn2" name="schema1" sqlMaxLimit="100">
          <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group2" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10" />
      </dbGroup>
      """
    Given Restart dble in "dble-1" success
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                                        | expect   | db      |
      | conn_1 | False    | drop table if exists test_table;create table test_table(id int)            | success  | schema1 |

    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master='slave1'"

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                      | expect   | db       |
      | conn_1 | False    | set autocommit = 0;insert into test_table values (1)     | success  | schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect       |
      | conn_0 | False    | show @@session   | length{(1)}  |

      #### 这个桩默认20s，作用：session-1执行insert的时候hang住，查看show @@session的连接复用，不会有release slave connection的日志输出
     Given prepare a thread run btrace script "BtracetryExistsCon.java" in "dble-1"
     Given prepare a thread execute sql "insert into test_table values(2)" with "conn_1"
     Then check btrace "BtracetryExistsCon.java" output in "dble-1"
       """
       get into btrace
       """
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect       |
      | conn_0 | False    | show @@session   | length{(1)}  |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      release slave connection,can't be used in trasaction
      """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                                     | expect   | db        |
      | conn_2 | False    | set autocommit = 0;insert into test_table values (3)    | success  |  schema1  |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose  | sql              | expect       |
      | conn_0 | False    | show @@session   | length{(2)}  |

    ##等待桩的退出，session上sql全部完成
    Given sleep "25" seconds
    Given stop btrace script "BtracetryExistsCon.java" in "dble-1"
    Given destroy btrace threads list
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      release slave connection,can't be used in trasaction
      """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect            | db      | timeout |
      | conn_1 | False   | select * from test_table        | has{((1,), (2,))} | schema1 | 5,2     |

      | conn_2 | False   | select * from test_table        | hasStr{3}         | schema1 | 5,2     |

      | conn_1 | False   | rollback                        | success           | schema1 | 5,2     |
      | conn_1 | False   | select * from test_table        | length{(0)}       | schema1 | 5,2     |

      ###commit前后 conn-2的这个session上的 结果都只有3
      | conn_2 | False   | select * from test_table        | hasNoStr{1}       | schema1 | 5,2     |
      | conn_2 | False   | select * from test_table        | hasStr{3}         | schema1 | 5,2     |
      | conn_2 | False   | commit                          | success           | schema1 | 5,2     |
      | conn_2 | False   | select * from test_table        | hasNoStr{1}       | schema1 | 5,2     |
      | conn_2 | False   | select * from test_table        | hasStr{3}         | schema1 | 5,2     |

      | conn_1 | False   | set autocommit = 1              | success           | schema1 | 5,2     |
      | conn_1 | False   | select * from test_table        | hasNoStr{1}       | schema1 | 5,2     |
      | conn_1 | False   | select * from test_table        | hasNoStr{2}       | schema1 | 5,2     |
      | conn_1 | true    | select * from test_table        | hasStr{3}         | schema1 | 5,2     |
      | conn_2 | true    | drop table if exists test_table | success           | schema1 |         |


    Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
      """
      release slave connection,can't be used in trasaction
      unknown error:
      NullPointerException
      """



  Scenario: 读写分离hint 路由正确   #3

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM2" password="111111" url="172.100.9.6:3306" user="test" maxCon="1000" minCon="10" primary="true"/>
        <dbInstance name="slave1" url="172.100.9.6:3307" user="test" password="111111" maxCon="1000" minCon="10" />
      </dbGroup>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Then execute admin cmd "reload @@config"

    Given turn on general log in "mysql-master2"
    Given turn on general log in "mysql-slave1"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                                                 | expect  | db      |
      | rw1  | 111111 | conn_1 | False   | drop table if exists test1;create table test1 (id int);truncate table test1         | success | db1     |
      | rw1  | 111111 | conn_1 | False   | /*!dble:db_type=master */ insert into test1 values(1)         | success | db1     |

    Then check general log in host "mysql-master2" has "insert into test1 values(1)"
    Then check general log in host "mysql-slave1" has not "insert into test1 values(1)"

    Then execute admin cmd "dbGroup @@switch name = 'ha_group3' master='slave1'"

    Then execute sql in "dble-1" in "user" mode
      | user | passwd | conn   | toClose | sql                                                           | expect  | db      |
      | rw1  | 111111 | conn_1 | False   | /*!dble:db_type=master */ insert into test1 values(3)         | success | db1     |

    Then check general log in host "mysql-master2" has not "insert into test1 values(3)"
    Then check general log in host "mysql-slave1" has "insert into test1 values(3)"
    Given turn off general log in "mysql-master2"
    Given turn off general log in "mysql-slave1"


  Scenario: 恢复主从 #4
    Given change the primary instance of mysql group named "group2" to "mysql-master2"
    Then execute admin cmd "dbGroup @@switch name = 'ha_group2' master = 'hostM2'"
