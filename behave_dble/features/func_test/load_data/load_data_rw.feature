# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2022/12/23

Feature: connect dble rwSplitUser in mysql(172.100.9.4), and execute cmd "load data" with relative path or absolute path


  Scenario: load data with relative path #1
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <managerUser name="root" password="111111"/>
      <shardingUser name="test" password="111111" schemas="schema1"/>
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all"

    Given execute oscmd in "dble-1"
      """
      echo -e '1,1\n2,2\n3,3' > /opt/dble/test.txt
      """
    Given execute oscmd in "mysql"
      """
      echo -e '20,20\n30,30' > /root/sandboxes/sandbox/master/data/test.txt
      """

    Given connect "dble-1" with user "rw1" in "mysql" to execute sql
      """
      drop table if exists db1.test1
      create table db1.test1(id int,c int)
      load data infile './test.txt' into table db1.test1 fields terminated by ',' lines terminated by '\n'
      """
    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                 | expect                     | db    |
     | rw1   | 111111 | conn_1 | False   | select * from test1 | hasStr{(20, 20), (30, 30)} | db1   |

    Given connect "dble-1" with user "rw1" in "mysql" to execute sql
      """
      load data local infile './test.txt' into table db1.test1 fields terminated by ',' lines terminated by '\n'
      """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose | sql                  | expect      | db    |
     | rw1  | 111111 | conn_1 | False   | select * from test1  | length{(4)} | db1   |
     | rw1  | 111111 | conn_1 | true    | truncate table test1 | success     | db1   |

    #coz:DBLE0REQ-2184
    #load data with absolute path #2
    Given connect "dble-1" with user "rw1" in "mysql" to execute sql
    """
    load data local infile '/root/sandboxes/sandbox/master/data/test.txt' into table db1.test1 fields terminated by ',' lines terminated by '\n'
    """
    Then execute sql in "dble-1" in "user" mode
     | user | passwd | conn   | toClose | sql                  | expect                     | db    |
     | rw1  | 111111 | conn_1 | true    | select * from test1  | hasStr{(20, 20), (30, 30)} | db1   |

    Given execute oscmd in "dble-1"
    """
    rm -rf /opt/dble/test.txt
    """
    Given execute oscmd in "mysql"
    """
    rm -rf /root/sandboxes/sandbox/master/data/test.txt
    """

#@skip
  #coz:DBLE0REQ-2184
  Scenario: The value of a column in the data is empty, and the data can be successfully inserted  #2
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <managerUser name="root" password="111111"/>
      <shardingUser name="test" password="111111" schemas="schema1"/>
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """

    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
       """
    Then execute admin cmd "reload @@config_all"

    Given execute oscmd in "mysql"
      """
      echo -e '1,abc\n2,\n3,qwe' > /root/sandboxes/sandbox/master/data/test.txt
      """
    ## rwSplitUser
    Given connect "dble-1" with user "rw1" in "mysql" to execute sql
      """
      drop table if exists db1.test1
      create table db1.test1(id int,c varchar(10))
      load data local infile './test.txt' into table db1.test1 fields terminated by ',' lines terminated by '\n'
      """
    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                 | expect                                    | db    |
     | rw1   | 111111 | conn_1 | true    | select * from test1 | hasStr{((1, 'abc'), (2, ''), (3, 'qwe'))} | db1   |

    Given execute oscmd in "mysql"
      """
      rm -rf /root/sandboxes/sandbox/master/data/test.txt
      """



  Scenario: When load data empty file, there will be error  #3
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <managerUser name="root" password="111111"/>
      <shardingUser name="test" password="111111" schemas="schema1"/>
      <rwSplitUser name="rw1" password="111111" dbGroup="ha_group3" />
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "db.xml"
      """
      <dbGroup rwSplitMode="0" name="ha_group3" delayThreshold="100" >
        <heartbeat>select user()</heartbeat>
        <dbInstance name="hostM3" password="111111" url="172.100.9.4:3306" user="test" maxCon="1000" minCon="10" primary="true" />
      </dbGroup>
      """
    Then execute admin cmd "reload @@config_all"
    Given execute oscmd in "mysql"
      """
      echo -e '' > /root/sandboxes/sandbox/master/data/test.txt
      """

    ## rwSplitUser
    Given connect "dble-1" with user "rw1" in "mysql" to execute sql
      """
      drop table if exists db1.test1
      create table db1.test1(id int,c varchar(10))
      """
    #####区别于分库分表用户，DBLE0REQ-1595 读写分离用户直接下发，不做空值处理
    Given execute linux command in "mysql" and contains exception " Incorrect integer value: '' for column 'id' at row 1"
      """
      cd /root/sandboxes/sandbox/master/data && mysql -h172.100.9.1 -urw1 -p111111 -P8066 -c -e"load data infile './test.txt' into table db1.test1 fields terminated by ',' lines terminated by '\n'"
      """
    Then execute sql in "dble-1" in "user" mode
     | user  | passwd | conn   | toClose | sql                 | expect       | db    |
     | rw1   | 111111 | conn_1 | false   | select * from test1 | length{(0)}  | db1   |
     | rw1   | 111111 | conn_1 | true    | drop table test1    | success      | db1   |
    Given execute oscmd in "mysql"
      """
      rm -rf /root/sandboxes/sandbox/master/data/test.txt
      """