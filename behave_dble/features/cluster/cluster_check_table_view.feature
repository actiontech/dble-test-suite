# Copyright (C) 2016-2019 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2020/12/11


Feature: because 3.20.07 version change, the cluster function changes ,from doc: https://github.com/actiontech/dble-docs-cn/blob/master/2.Function/2.08_cluster.md
  # view
  ######case points:
  #  1.create view，alter view，drop view could success on shardingtable
  #  2.ClusterEnable=true && useOuterHa=true && needSyncHa=true,check "dbinstance"


  @btrace
  Scenario: create view，alter view，drop view could success on shardingtable  #1
    Given reset dble registered nodes in zk
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect    | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1               | success   | schema1 |
      | conn_1 | true    | create table sharding_4_t1 (id int,name char(5)) | success   | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayAfterGetLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-1"
    Then execute "user" cmd  in "dble-1" at background
      | conn   | toClose | sql                                                     | db      |
      | conn_1 | True    | create view view_test as select * from sharding_4_t1    | schema1 |
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/view_lock | grep "schema1:view_test" | wc -l
      """
    Then check result "A" value is "1"
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                                     | expect                                                                                  | db      |
      | conn_2 | true    | create view view_test as select * from sharding_4_t1    | other session/dble instance is operating view, try it later or check the cluster lock   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose | sql                                                     | expect                                                                                  | db      |
      | conn_3 | true    | create view view_test as select * from sharding_4_t1    | other session/dble instance is operating view, try it later or check the cluster lock   | schema1 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-1"
    Given destroy btrace threads list
    Given sleep "20" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-1"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/view_lock | grep "schema1:view_test" | wc -l
      """
    Then check result "A" value is "0"
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-1"
      """
      ERROR
      """
    Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                                     | expect                             | db      |
      | conn_2 | false   | create view view_test as select * from sharding_4_t1    | Table 'view_test' already exists   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose | sql                                                    | expect                             | db      |
      | conn_3 | false   | create view view_test as select * from sharding_4_t1   | Table 'view_test' already exists   | schema1 |
    #case check create view
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                         | db      |
      | conn_1 | true    | show create view view_test  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | View-0    | Create View-1                                          | character_set_client-2 | collation_connection-3 |
      | view_test | create view view_test as  select * from sharding_4_t1  | latin1                 | latin1_swedish_ci      |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_B"
      | conn   | toClose | sql                         | db      |
      | conn_2 | true    | show create view view_test  | schema1 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                         | db      |
      | conn_3 | true    | show create view view_test  | schema1 |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | Create View          | 1            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | Create View          | 1            |
      | character_set_client | 2            |
      | collation_connection | 3            |
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect    | db      |
      | conn_1 | true    | insert into sharding_4_t1 values (1,1),(2,null),(3,'a'),(4,'aa')   | success   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose  | sql                                                                | expect       | db      |
      | conn_3 | false    | select * from view_test where id=1                                 | length{(1)}  | schema1 |
      | conn_3 | true     | insert into sharding_4_t1 values (1,1),(2,null),(3,'a'),(4,'aa')   | success      | schema1 |
     Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                                                              | expect        | db      |
      | conn_2 | false   | select * from view_test                                          | length{(8)}   | schema1 |
      | conn_2 | false   | select * from view_test where id=1                               | length{(2)}   | schema1 |
      | conn_2 | true    | alter view view_test as select * from sharding_4_t1 where id =1  | success       | schema1 |
    #case check alter view
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                         | db      |
      | conn_2 | true    | show create view view_test  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | View-0    | Create View-1                                                     | character_set_client-2 | collation_connection-3 |
      | view_test | create view view_test as  select * from sharding_4_t1 where id =1 | latin1                 | latin1_swedish_ci      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_B"
      | conn   | toClose | sql                         | db      |
      | conn_1 | true    | show create view view_test  | schema1 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                         | db      |
      | conn_3 | true    | show create view view_test  | schema1 |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | Create View          | 1            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    #case check drop view
     Then execute sql in "dble-3" in "user" mode
      | conn   | toClose | sql                          | expect                                    | db      |
      | conn_3 | false   | select * from view_test      | length{(2)}                               | schema1 |
      | conn_3 | false   | drop view view_test          | success                                   | schema1 |
      | conn_3 | true    | show create view view_test   | Table 'schema1.view_test' doesn't exist   | schema1 |
     Then execute sql in "dble-2" in "user" mode
      | conn   | toClose | sql                          | expect                                    | db      |
      | conn_2 | true    | show create view view_test   | Table 'schema1.view_test' doesn't exist   | schema1 |
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect                                    | db      |
      | conn_1 | false   | show create view view_test            | Table 'schema1.view_test' doesn't exist   | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1    | success                                   | schema1 |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-1"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-1"


  @btrace
  Scenario: during alter view use btrace on shardingtable,to check has lock   #2
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect    | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1                        | success   | schema1 |
      | conn_1 | false   | create table sharding_4_t1 (id int,name char(5))          | success   | schema1 |
      | conn_1 | false   | insert into sharding_4_t1 values (1,'a'),(2,null)         | success   | schema1 |
      | conn_1 | True    | create view view_view as select * from sharding_4_t1      | success   | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayAfterGetLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-2"
    Then execute "user" cmd  in "dble-2" at background
      | conn   | toClose | sql                                                                | db      |
      | conn_2 | True    | alter view view_view as select * from sharding_4_t1 where id =1    | schema1 |
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/view_lock | grep "schema1:view_view" | wc -l
      """
    Then check result "A" value is "1"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect                                                                                  | db      |
      | conn_1 | true    | alter view view_view as select * from sharding_4_t1 where id =1    | other session/dble instance is operating view, try it later or check the cluster lock   | schema1 |
    Then execute sql in "dble-3" in "user" mode
      | conn   | toClose | sql                                                                 | expect                                                                                  | db      |
      | conn_3 | true    | alter view view_view as select * from sharding_4_t1 where id =1     | other session/dble instance is operating view, try it later or check the cluster lock   | schema1 |
    Given stop btrace script "BtraceClusterDelay.java" in "dble-2"
    Given destroy btrace threads list
    Given sleep "20" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/view_lock | grep "schema1:view_view" | wc -l
      """
    Then check result "A" value is "0"
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-2"
      """
      ERROR
      """
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                         | db      |
      | conn_2 | true    | show create view view_view  | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | View-0    | Create View-1                                                     | character_set_client-2 | collation_connection-3 |
      | view_view | create view view_view as  select * from sharding_4_t1 where id =1 | latin1                 | latin1_swedish_ci      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_B"
      | conn   | toClose | sql                         | db      |
      | conn_1 | true    | show create view view_view  | schema1 |
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                         | db      |
      | conn_3 | true    | show create view view_view  | schema1 |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | Create View          | 1            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-2"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-2"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect      | db      |
      | conn_1 | false   | drop view view_view                   | success     | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1    | success     | schema1 |

  @skip_restart @btrace
  Scenario: during alter view use btrace on shardingtable,to check has lock   #3
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect    | db      |
      | conn_1 | false   | drop table if exists sharding_4_t1                        | success   | schema1 |
      | conn_1 | false   | create table sharding_4_t1 (id int,name char(5))          | success   | schema1 |
      | conn_1 | false   | insert into sharding_4_t1 values (1,'a'),(2,null)         | success   | schema1 |
      | conn_1 | True    | create view view_3 as select * from sharding_4_t1         | success   | schema1 |
    Given update file content "./assets/BtraceClusterDelay.java" in "behave" with sed cmds
      """
      s/Thread.sleep([0-9]*L)/Thread.sleep(1L)/
      /delayAfterGetLock/{:a;n;s/Thread.sleep([0-9]*L)/Thread.sleep(20000L)/;/\}/!ba}
      """
    Given prepare a thread run btrace script "BtraceClusterDelay.java" in "dble-3"
    Then execute "user" cmd  in "dble-3" at background
      | conn   | toClose | sql                                                             | db      |
      | conn_3 | True    | alter view view_3 as select * from sharding_4_t1 where id =2    | schema1 |
    #case check lock on zookeeper values is 1
    Then get result of oscmd named "A" in "dble-2"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/view_lock | grep "schema1:view_3" | wc -l
      """
    Then check result "A" value is "1"
    Then stop dble in "dble-1"
    Given sleep "5" seconds
    Then Start dble in "dble-1"
    Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
    """
    waiting for view finished
    """
    Given stop btrace script "BtraceClusterDelay.java" in "dble-3"
    Given destroy btrace threads list
    Given sleep "20" seconds
    #case check lock on zookeeper values is 0
    Then get result of oscmd named "A" in "dble-3"
      """
      cd /opt/zookeeper/bin && ./zkCli.sh  ls /dble/cluster-1/lock/view_lock | grep "schema1:view_3" | wc -l
      """
    Then check result "A" value is "0"
    Then check following text exist "N" in file "/tmp/dble_user_query.log" in host "dble-3"
      """
      ERROR
      """
    Given execute single sql in "dble-3" in "user" mode and save resultset in "Res_A"
      | conn   | toClose | sql                         | db      |
      | conn_3 | true    | show create view view_3     | schema1 |
    Then check resultset "Res_A" has lines with following column values
      | View-0    | Create View-1                                                  | character_set_client-2 | collation_connection-3 |
      | view_3    | create view view_3 as  select * from sharding_4_t1 where id =2 | latin1                 | latin1_swedish_ci      |
    Given execute single sql in "dble-1" in "user" mode and save resultset in "Res_B"
      | conn   | toClose | sql                         | db      |
      | conn_1 | true    | show create view view_3     | schema1 |
    Given execute single sql in "dble-2" in "user" mode and save resultset in "Res_C"
      | conn   | toClose | sql                         | db      |
      | conn_2 | true    | show create view view_3     | schema1 |
    Then check resultsets "Res_A" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    Then check resultsets "Res_C" and "Res_B" are same in following columns
      | column               | column_index |
      | View                 | 0            |
      | Create View          | 1            |
      | character_set_client | 2            |
      | collation_connection | 3            |
    Given delete file "/opt/dble/BtraceClusterDelay.java" on "dble-3"
    Given delete file "/opt/dble/BtraceClusterDelay.java.log" on "dble-3"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect      | db      |
      | conn_1 | false   | drop view view_3                      | success     | schema1 |
      | conn_1 | true    | drop table if exists sharding_4_t1    | success     | schema1 |