# Copyright (C) 2016-2021 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by quexiuping at 2021/1/21
Feature: test online ddl
  #supported:
  ## 1. CREATE INDEX name ON table (col_list) / ALTER TABLE tbl_name ADD INDEX name (col_list)
  ## 2. DROP INDEX name ON table / ALTER TABLE tbl_name DROP INDEX name
  ## 3. ALTER TABLE tbl_name DROP INDEX i1, ADD INDEX i1(key_part,... ) USING BTREE, ALGORITHM=INSTANT
  ## 4. ALTER TABLE tbl_name ALTER COLUMN col SET DEFAULT literal, ALGORITHM=INSTANT
  ## 5. ALTER TABLE tbl ALTER COLUMN col DROP DEFAULT, ALGORITHM=INSTANT

  #unsupporetd (mysql5.6)
  ## rename index


  @skip_restart
  Scenario: prepare env and data    #1
    Given delete the following xml segment
      | file          | parent           | child               |
      | sharding.xml  | {'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
      <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
          <singleTable name="sing" shardingNode="dn1" />
          <globalTable name="global" shardingNode="dn1,dn2,dn3,dn4" />
          <shardingTable name="sharding2" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id"/>
      </schema>

      <schema shardingNode="dn2" name="schema2" sqlMaxLimit="100">
      </schema>
      """
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
      <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                      | expect  | db      |
      | conn_1 | False   | drop table if exists nosharding                                          | success | schema1 |
      | conn_1 | False   | drop table if exists sing                                                | success | schema1 |
      | conn_1 | False   | drop table if exists global                                              | success | schema1 |
      | conn_1 | False   | drop table if exists sharding2                                           | success | schema1 |
      | conn_2 | False   | drop table if exists schema2.ver                                         | success | schema2 |
      | conn_1 | False   | create table nosharding (id int,name char(5),age int)                    | success | schema1 |
      | conn_1 | False   | create table sing (id int,name char(5),age int)                          | success | schema1 |
      | conn_1 | False   | create table global (id int,name char(5),age int)                        | success | schema1 |
      | conn_1 | False   | create table sharding2 (id int,name char(5),age int)                     | success | schema1 |
      | conn_2 | False   | create table schema2.ver (id int,name char(5),age int)                   | success | schema2 |
      | conn_1 | False   | insert into nosharding values (1,1,1),(2,null,null)                      | success | schema1 |
      | conn_1 | False   | insert into sing values (1,1,1),(2,null,null)                            | success | schema1 |
      | conn_1 | False   | insert into global values (1,1,1),(2,null,null)                          | success | schema1 |
      | conn_1 | False   | insert into sharding2 values (1,1,1),(2,null,null),(3,null,null),(4,4,4) | success | schema1 |
      | conn_2 | False   | insert into schema2.ver values (1,1,1),(2,null,null)                     | success | schema2 |
    #prepare more data
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name,age) select id,name,age from nosharding         | success | schema1 |

      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name,age) select id,name,age from sing         | success | schema1 |

      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name,age) select id,name,age from global         | success | schema1 |
      | conn_1 | true    | insert into global(id,name,age) select id,name,age from global         | success | schema1 |

      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |
      | conn_2 | true    | insert into schema2.ver(id,name,age) select id,name,age from schema2.ver         | success | schema2 |

    Then execute sql in "mysql-master1"
      | conn   | toClose | sql                                                                          | expect  | db  |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | true    | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |

    Then execute sql in "mysql-master2"
      | conn   | toClose | sql                                                                          | expect  | db  |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | False   | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |
      | conn_1 | true    | insert into sharding2(id,name,age) select id,name,age from sharding2         | success | db1 |


  @skip_restart
  Scenario: supported CREATE INDEX name ON table (col_list) / ALTER TABLE tbl_name ADD INDEX name (col_list)    #2
    #nosharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                            | db      |
      | conn_1 | false   | alter table nosharding add index nosha(name)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect            | db      |
      | conn_2 | false   | insert into nosharding values (3,'nosh',22)      | success           | schema1 |
      | conn_2 | false   | show index from nosharding                       | hasNoStr{nosha}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect         | db      |
      | conn_1 | false   | show index from nosharding       | hasStr{nosha}  | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #sing table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                    | db      |
      | conn_1 | false   | alter table sing add index sig(name)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect          | db      |
      | conn_2 | false   | insert into sing values (3,'sing',11)      | success         | schema1 |
      | conn_2 | false   | show index from sing                       | hasNoStr{sig}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect        | db      |
      | conn_1 | false   | show index from sing             | hasStr{sig}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #global table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                      | db      |
      | conn_1 | false   | alter table global add index glo(name)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect          | db      |
      | conn_2 | false   | insert into global values (3,'sing',11)      | success         | schema1 |
      | conn_2 | false   | show index from global                       | hasNoStr{glo}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect        | db      |
      | conn_1 | false   | show index from global             | hasStr{glo}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #sharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                         | db      |
      | conn_1 | false   | alter table sharding2 add index sha(name)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect          | db      |
      | conn_2 | false   | insert into sharding2 values (3,'sing',11)      | success         | schema1 |
      | conn_2 | false   | show index from sharding2                       | hasNoStr{sha}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect        | db      |
      | conn_1 | false   | show index from sharding2             | hasStr{sha}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
   #vertical table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                     | db      |
      | conn_3 | false   | alter table ver add index verti(name)   | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect          | db      |
      | conn_4 | false   | insert into ver values (3,'sing',11)      | success         | schema2 |
      | conn_4 | false   | show index from ver                       | hasNoStr{verti} | schema2 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect        | db      |
      | conn_3 | false   | show index from ver             | hasStr{verti} | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #nosharding table
     Given record current dble log line number in "log_linenu"
     Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                      | db      |
      | conn_1 | false   | create index index1 on nosharding(age)   | schema1 |
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect            | db      |
      | conn_2 | false   | insert into nosharding values (3,'nosh',22)      | success           | schema1 |
      | conn_2 | false   | show index from nosharding                       | hasNoStr{index1}  | schema1 |
     Given sleep "10" seconds
     Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect         | db      |
      | conn_1 | false   | show index from nosharding       | hasStr{index1} | schema1 |
     Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #sing table
     Given record current dble log line number in "log_linenu"
     Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                | db      |
      | conn_1 | false   | create index index2 on sing(age)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect           | db      |
      | conn_2 | false   | insert into sing values (3,'sing',11)      | success          | schema1 |
      | conn_2 | false   | show index from sing                       | hasNoStr{index2} | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect        | db      |
      | conn_1 | false   | show index from sing             | hasStr{index2}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #global table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                  | db      |
      | conn_1 | false   | create index index3 on global(age)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect             | db      |
      | conn_2 | false   | insert into global values (3,'sing',11)      | success            | schema1 |
      | conn_2 | false   | show index from global                       | hasNoStr{index3}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect           | db      |
      | conn_1 | false   | show index from global             | hasStr{index3}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #sharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                     | db      |
      | conn_1 | false   | create index index4 on sharding2(age)   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect             | db      |
      | conn_2 | false   | insert into sharding2 values (3,'sing',11)      | success            | schema1 |
      | conn_2 | true    | show index from sharding2                       | hasNoStr{index4}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect           | db      |
      | conn_1 | true    | show index from sharding2             | hasStr{index4}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
   #vertical table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                              | db      |
      | conn_3 | false   |create index index5 on ver(age)   | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect           | db      |
      | conn_4 | false   | insert into ver values (3,'sing',11)      | success          | schema2 |
      | conn_4 | true    | show index from ver                       | hasNoStr{index5} | schema2 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect         | db      |
      | conn_3 | true    | show index from ver             | hasStr{index5} | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """


  @skip_restart
  Scenario: DROP INDEX name ON table / ALTER TABLE tbl_name DROP INDEX name   #3
    #case drop index time is less,don't check dml
    #nosharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                      | db      |
      | conn_1 | false   | alter table nosharding drop index nosha  | schema1 |
      | conn_1 | false   | drop index index1 on nosharding          | schema1 |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect    | db      |
      | conn_2 | false   | insert into nosharding values (3,'nosh',22)      | success   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect           | db      |
      | conn_1 | false   | show index from nosharding       | hasNoStr{nosha}  | schema1 |
      | conn_1 | false   | show index from nosharding       | hasNoStr{index1} | schema1 |

    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #sing table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                    | db      |
      | conn_1 | false   | alter table sing drop index sig        | schema1 |
      | conn_1 | false   | drop index index2 on sing              | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect          | db      |
      | conn_2 | false   | insert into sing values (3,'sing',11)      | success         | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect             | db      |
      | conn_1 | false   | show index from sing             | hasNoStr{sig}      | schema1 |
      | conn_1 | false   | show index from sing             | hasNoStr{index2}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #global table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                      | db      |
      | conn_1 | false   | alter table global drop index glo        | schema1 |
      | conn_1 | false   | drop index index3 on global              | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                          | expect          | db      |
      | conn_2 | false   | insert into global values (3,'sing',11)      | success         | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect             | db      |
      | conn_1 | false   | show index from global             | hasNoStr{glo}      | schema1 |
      | conn_1 | false   | show index from global             | hasNoStr{index3}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
    #sharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                  | db      |
      | conn_1 | false   | alter table sharding2 drop index sha | schema1 |
      | conn_1 | false   | drop index index4 on sharding2       | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect          | db      |
      | conn_2 | false   | insert into sharding2 values (3,'sing',11)      | success         | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect             | db      |
      | conn_1 | false   | show index from sharding2             | hasNoStr{sha}      | schema1 |
      | conn_1 | false   | show index from sharding2             | hasNoStr{index4}   | schema1 |
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """
   #vertical table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                | db      |
      | conn_3 | false   | alter table ver drop index verti   | schema2 |
      | conn_3 | false   | drop index index5 on ver           | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                       | expect          | db      |
      | conn_4 | false   | insert into ver values (3,'sing',11)      | success         | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect           | db      |
      | conn_3 | false   | show index from ver             | hasNoStr{verti}  | schema2 |
      | conn_3 | false   | show index from ver             | hasNoStr{index5} | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """