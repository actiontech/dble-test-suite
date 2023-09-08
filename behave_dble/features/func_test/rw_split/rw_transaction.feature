# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2023/08/08

Feature: test rwSplitUser transaction

  # DBLE0REQ-1489 & DBLE0REQ-1077
  @restore_global_setting
  Scenario: check read only transaction #1
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
    Given turn on general log in "mysql"
    Given turn on general log in "mysql-slave3"

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                    | expect         | db  |
      | rw1   | 111111 | conn_1 | False   | drop table if exists test1             | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | create table test1 (id int, age int)   | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test1 values (1,20),(2,20) | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | drop table if exists test2             | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | create table test2 (id int, name varchar(10)) | success | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test2 values (1,'a'),(2,'b')      | success | db1 |
      # 只读事务发往从
      | rw1   | 111111 | conn_1 | False   | set session transaction read only      | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | begin                                  | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test1 values (3,30)        | Cannot execute statement in a READ ONLY transaction. | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test1 where id=1         | has{((1,20),)} | db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                 | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | start transaction                      | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test1 where id=2         | has{((2,20),)} | db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                 | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | set autocommit=0                       | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test1 where age=20       | length{(2)}    | db1 |
      | rw1   | 111111 | conn_1 | False   | rollback                               | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | set autocommit=1                       | success        | db1 |
      # 普通事务发往主
      | rw1   | 111111 | conn_1 | False   | set session transaction read write     | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | begin                                  | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test2 values (3,22)        | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2 where id=1         | has{((1,'a'),)}| db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                 | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | start transaction                      | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2 where id=2         | has{((2,'b'),)}| db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                 | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | set autocommit=0                       | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2 where id>0         | length{(3)}    | db1 |
      | rw1   | 111111 | conn_1 | False   | rollback                               | success        | db1 |

    Given sleep "2" seconds

    Then check general log in host "mysql" has not "SET SESSION TRANSACTION READ ONLY"
    Then check general log in host "mysql" has not "insert into test1 values (3,30)"
    Then check general log in host "mysql" has not "from test1 where id=1"
    Then check general log in host "mysql" has not "from test1 where id=2"
    Then check general log in host "mysql" has not "from test1 where age=20"
    Then check general log in host "mysql-slave3" has "SET SESSION TRANSACTION READ ONLY"
    Then check general log in host "mysql-slave3" has "insert into test1 values (3,30)"
    Then check general log in host "mysql-slave3" has "from test1 where id=1"
    Then check general log in host "mysql-slave3" has "from test1 where id=2"
    Then check general log in host "mysql-slave3" has "from test1 where age=20"

     Then check general log in host "mysql" has "insert into test2 values (3,22)"
     Then check general log in host "mysql" has "from test2 where id=1"
     Then check general log in host "mysql" has "from test2 where id=2"
     Then check general log in host "mysql" has "from test2 where id>0"
     Then check general log in host "mysql-slave3" has not "insert into test2 values (3,22)"
     Then check general log in host "mysql-slave3" has not "from test2 where id=1"
     Then check general log in host "mysql-slave3" has not "from test2 where id=2"
     Then check general log in host "mysql-slave3" has not "from test2 where id>0"

    Given turn off general log in "mysql"
    Given turn off general log in "mysql-slave3"

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                    | expect         | db  |
      | rw1   | 111111 | conn_1 | False   | drop table if exists test1             | success        | db1 |
      | rw1   | 111111 | conn_1 | True    | drop table if exists test2             | success        | db1 |

  
  # DBLE0REQ-2329 & DBLE0REQ-2330
  @restore_global_setting
  Scenario: check transaction and hint #2
  """
  {'restore_global_setting':{'mysql':{'general_log':0},'mysql-slave3':{'general_log':0}}}
  """
    Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
    """
    /-DrwStickyTime/d
    $a -DrwStickyTime=0
    /-DsqlExecuteTimeout/d
    $a -DsqlExecuteTimeout=30
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

    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                            | expect         | db  |
      | rw1   | 111111 | conn_1 | False   | drop table if exists test1                                     | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | create table test1 (id int, age int)                           | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | drop table if exists test2                                     | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | create table test2 (id int, name varchar(10))                  | success        | db1 |
      # DBLE0REQ-2330
      | rw1   | 111111 | conn_1 | False   | set autocommit=0                                               | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test1 values (1,20),(2,20)                         | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | commit                                                         | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | insert into test2 values (1,'name1'),(2,'name2')               | success        | db1 |
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_instance_url=172.100.9.4:3306*/ select * from test1 | has{((1, 20), (2, 20))}           | db1 |
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_type=master*/select count(0) from test2             | has{((0,),)}                      | db1 |
      | rw1   | 111111 | conn_1 | False   | /*!dble:db_type=master*/drop table if exists test1             | success                           | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2                                            | has{((1, 'name1'), (2, 'name2'))} | db1 |
      | rw1   | 111111 | conn_1 | False   | rollback                                                       | success                           | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2                                            | length{(0)}                       | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test1                                            | Table 'db1.test1' doesn't exist   | db1 |
      # transaction + master hint ddl
      | rw1   | 111111 | conn_1 | False   | insert into test2 values (3,'name3'),(4,'name4')               | success                 | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2                                            | length{(2)}             | db1 |
      # sql执行hang住（hang的时间为sqlExecuteTimeout）
      | rw1   | 111111 | conn_2 | False   | /*!dble:db_type=master*/ALTER TABLE test2 ADD COLUMN age int   | was closed ,reason is [sql timeout] | db1 |
      | rw1   | 111111 | conn_2 | False   | desc test2                                                     | length{(2)}             | db1 |
      | rw1   | 111111 | conn_1 | False   | select * from test2                                            | length{(2)}             | db1 |
      | rw1   | 111111 | conn_1 | False   | rollback                                                       | success                 | db1 |
      | rw1   | 111111 | conn_1 | True    | select * from test2                                            | length{(0)}             | db1 |
      | rw1   | 111111 | conn_1 | True    | desc test2                                                     | length{(3)}             | db1 |
      # conn_1事务commit/rollback之后，conn_2 hint ddl执行成功的原因：sql timeout是dble导致的超时关闭，实际ddl已经下发给了mysql并阻塞，conn_1事务commit/rollback,hint ddl就不再阻塞，可以执行成功
      # 可在mysql做如下场景复现：conn_1开启事务，conn_2执行ddl hang住，kill -9 conn_2的进程，show processlist可以看到ddl的连接依然存在，conn_1事务commit/rollback后，ddl执行成功

    Given turn on general log in "mysql"
    Given turn on general log in "mysql-slave3"
    # DBLE0REQ-2329
    Then execute sql in "dble-1" in "user" mode
      | user  | passwd | conn   | toClose | sql                                                            | expect                  | db  |
      | rw1   | 111111 | conn_2 | False   | set autocommit=0                                               | success                 | db1 |
      | rw1   | 111111 | conn_2 | False   | insert into test2 values (1,'name1',20),(2,'name2',25)         | success                 | db1 |
      | rw1   | 111111 | conn_2 | False   | commit                                                         | success                 | db1 |
      | rw1   | 111111 | conn_2 | False   | /*!dble:db_instance_url=172.100.9.4:3307*/ select * from test2 | length{(2)}             | db1 |
      | rw1   | 111111 | conn_2 | False   | /*!dble:db_type=slave */select * from test2 where id=2         | has{((2,'name2',25),)}  | db1 |
      | rw1   | 111111 | conn_2 | False   | select * from test2 where id=2 /* slave */                     | has{((2,'name2',25),)}  | db1 |
      | rw1   | 111111 | conn_2 | False   | /*uproxy_dest:172.100.9.4:3307*/select * from test2 where id=1 | has{((1,'name1',20),)}  | db1 |
      | rw1   | 111111 | conn_2 | True    | drop table if exists test2                                     | success                 | db1 |
    Given turn off general log in "mysql"
    Given turn off general log in "mysql-slave3"
     Then check general log in host "mysql" has "drop table if exists test2"
     Then check general log in host "mysql-slave3" has not "drop table if exists test2"
