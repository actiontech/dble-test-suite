# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by wangjuan at 2023/06/27

Feature: check mysqldump import and export

  @restore_mysql_config
  Scenario: check mysqldump import and export #1
    """
    {'restore_mysql_config':{'mysql-master3':{'local-infile':1}}}
    """
    Given delete all backend mysql tables
    Given delete file "/opt/dble/logs/mysqldump_export.sql" on "dble-1"
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
       """
       <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
          <singleTable name="sing" shardingNode="dn5" />
          <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
       </schema>

       <schema name="schema2" >
           <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
       </schema>
       """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | db      | expect  |
      | conn_0 | False   | drop table if exists test                                           | schema1 | success |
      | conn_0 | False   | create table test(id int, k varchar(20))                            | schema1 | success |
      | conn_0 | False   | insert into test value (1, repeat('a', 11))                         | schema1 | success |
      | conn_0 | False   | insert into test value (2, repeat('b', 15))                         | schema1 | success |
      | conn_0 | False   | insert into test value (3, repeat('c', 20))                         | schema1 | success |
      | conn_0 | False   | insert into test value (4, repeat('d', 10))                         | schema1 | success |
      | conn_0 | False   | drop table if exists sing                                           | schema1 | success |
      | conn_0 | False   | create table sing(id int,name varchar(10),age int)                  | schema1 | success |
      | conn_0 | False   | insert into sing values (1,'11111',18),(2,'22222',20)               | schema1 | success |
      | conn_0 | False   | drop table if exists sharding_4_t1                                  | schema1 | success |
      | conn_0 | False   | create table sharding_4_t1(id int)                                  | schema1 | success |
      | conn_0 | False   | insert into sharding_4_t1 values (1),(2),(3),(4),(5),(6),(7),(8)    | schema1 | success |
      | conn_0 | False   | drop table if exists no_sharding                                    | schema1 | success |
      | conn_0 | False   | create table no_sharding(id int, code int)                          | schema1 | success |
      | conn_0 | False   | insert into no_sharding values (1,1),(2,2),(3,2),(4,2),(5,1)        | schema1 | success |
      | conn_0 | False   | drop table if exists sharding_2_t1                                  | schema2 | success |
      | conn_0 | False   | create table sharding_2_t1(id int,node varchar(10))                 | schema2 | success |
      | conn_0 | True    | insert into sharding_2_t1 values(1,'abc'),(2,'12'),(3,'dd'),(4,'3') | schema2 | success |

    Given update file content "/etc/my.cnf" in "dble-1" with sed cmds
    """
     /local-infile/d
    """
    Given restart mysql in "mysql-master3" with sed cmds to update mysql config
    """
     /local-infile/d
     """

    # check export sql
    Given execute linux command in "dble-1"
    """
    /root/opt/mysql/5.7.25/bin/mysqldump -P{node:client_port} -u{node:client_user} -h{node:ip} --default-character-set=utf8mb4 --all-databases --set-gtid-purged=OFF > /opt/dble/logs/mysqldump_export.sql
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      | expect      |
      | conn_0 | False   | drop table if exists test          | schema1 | success     |
      | conn_0 | False   | drop table if exists sing          | schema1 | success     |
      | conn_0 | False   | drop table if exists sharding_4_t1 | schema1 | success     |
      | conn_0 | False   | drop table if exists no_sharding   | schema1 | success     |
      | conn_0 | False   | drop table if exists sharding_2_t1 | schema2 | success     |
      | conn_0 | False   | show tables                        | schema1 | length{(0)} |
      | conn_0 | True    | show tables                        | schema2 | length{(0)} |

    # check import sql
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} --default-character-set=utf8mb4 < /opt/dble/logs/mysqldump_export.sql
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | db      | expect                                                                                         |
      | conn_0 | False   | select * from test                 | schema1 | has{((1,'aaaaaaaaaaa'), (2,'bbbbbbbbbbbbbbb'), (3,'cccccccccccccccccccc'), (4,'dddddddddd'),)} |
      | conn_0 | False   | select * from sing                 | schema1 | has{((1,'11111',18),(2,'22222',20),)}                                                          |
      | conn_0 | False   | select * from sharding_4_t1        | schema1 | has{((1,),(2,),(3,),(4,),(5,),(6,),(7,),(8,))}                                                 |
      | conn_0 | False   | select * from no_sharding          | schema1 | has{((1,1),(2,2),(3,2),(4,2),(5,1),)}                                                          |
      | conn_0 | False   | select * from sharding_2_t1        | schema2 | has{((1,'abc'),(2,'12'),(3,'dd'),(4,'3'),)}                                                    |
      | conn_0 | False   | drop table if exists test          | schema1 | success                                                                                        |
      | conn_0 | False   | drop table if exists sing          | schema1 | success                                                                                        |
      | conn_0 | False   | drop table if exists sharding_4_t1 | schema1 | success                                                                                        |
      | conn_0 | False   | drop table if exists no_sharding   | schema1 | success                                                                                        |
      | conn_0 | False   | drop table if exists sharding_2_t1 | schema2 | success                                                                                        |
      | conn_0 | False   | show tables                        | schema1 | length{(0)}                                                                                    |
      | conn_0 | True    | show tables                        | schema2 | length{(0)}                                                                                    |

    # check source sql
    Given execute linux command in "dble-1"
    """
    mysql -P{node:client_port} -u{node:client_user} -h{node:ip} -e "source /opt/dble/logs/mysqldump_export.sql"
    """
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose  | sql                                | db      | expect      |
      | conn_0 | False    | select * from test                 | schema1 | length{(4)} |
      | conn_0 | False    | select * from sing                 | schema1 | length{(2)} |
      | conn_0 | False    | select * from sharding_4_t1        | schema1 | length{(8)} |
      | conn_0 | False    | select * from no_sharding          | schema1 | length{(5)} |
      | conn_0 | False    | select * from sharding_2_t1        | schema2 | length{(4)} |
      | conn_0 | False    | drop table if exists test          | schema1 | success     |
      | conn_0 | False    | drop table if exists sing          | schema1 | success     |
      | conn_0 | False    | drop table if exists sharding_4_t1 | schema1 | success     |
      | conn_0 | False    | drop table if exists no_sharding   | schema1 | success     |
      | conn_0 | True     | drop table if exists sharding_2_t1 | schema2 | success     |
#    Then check "NullPointerException|caught err|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
    Then check "NullPointerException|unknown error|exception occurred when the statistics were recorded|Exception processing" not exist in file "/opt/dble/logs/dble.log" in host "dble-1"
