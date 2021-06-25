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
      | conn_1 | False   | create table nosharding (id int,name char(5),age int DEFAULT 2020)       | success | schema1 |
      | conn_1 | False   | create table sing (id int,name char(5),age int DEFAULT 2020)             | success | schema1 |
      | conn_1 | False   | create table global (id int,name char(5),age int DEFAULT 2020)           | success | schema1 |
      | conn_1 | False   | create table sharding2 (id int,name char(5),age int DEFAULT 2020)        | success | schema1 |
      | conn_2 | False   | create table schema2.ver (id int,name char(5),age int DEFAULT 2020)      | success | schema2 |
      | conn_1 | False   | insert into nosharding(id,name) values (1,1),(2,null)                    | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) values (1,1),(2,null)                          | success | schema1 |
      | conn_1 | False   | insert into global(id,name) values (1,1),(2,null)                        | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) values (1,1),(2,null),(3,null),(4,4)      | success | schema1 |
      | conn_2 | False   | insert into schema2.ver(id,name) values (1,1),(2,null)                   | success | schema2 |
    #prepare more data
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |
      | conn_1 | False   | insert into nosharding(id,name) select id,name from nosharding         | success | schema1 |

      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |
      | conn_1 | False   | insert into sing(id,name) select id,name from sing         | success | schema1 |

      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |
      | conn_1 | False   | insert into global(id,name) select id,name from global         | success | schema1 |

      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |
      | conn_1 | False   | insert into sharding2(id,name) select id,name from sharding2         | success | schema1 |

      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |
      | conn_2 | False   | insert into schema2.ver(id,name) select id,name from schema2.ver         | success | schema2 |


  @skip_restart
  Scenario: supported CREATE INDEX name ON table (col_list) / ALTER TABLE tbl_name ADD INDEX name (col_list)    #2
    #nosharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                             | db      |
      | conn_1 | false   | alter table nosharding add index ceshi1(name)   | schema1 |
      | conn_1 | false   | create index index1 on nosharding(age)          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect             | db      |
      | conn_2 | false   | insert into nosharding(id,name) values (3,'nosh')      | success            | schema1 |
      | conn_2 | false   | show index from nosharding                             | hasNoStr{ceshi1}   | schema1 |
      | conn_2 | false   | show index from nosharding                             | hasNoStr{index1}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect          | db      |
      | conn_1 | false   | show index from nosharding       | hasStr{ceshi1}  | schema1 |
      | conn_1 | false   | show index from nosharding       | hasStr{index1}  | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sing table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                       | db      |
      | conn_1 | false   | alter table sing add index ceshi2(name)   | schema1 |
      | conn_1 | false   | create index index2 on sing(age)          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect             | db      |
      | conn_2 | false   | insert into sing(id,name) values (3,'sing')      | success            | schema1 |
      | conn_2 | false   | show index from sing                             | hasNoStr{ceshi2}   | schema1 |
      | conn_2 | false   | show index from sing                             | hasNoStr{index2} | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect           | db      |
      | conn_1 | false   | show index from sing             | hasStr{ceshi2}   | schema1 |
      | conn_1 | false   | show index from sing             | hasStr{index2}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #global table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                         | db      |
      | conn_1 | false   | alter table global add index ceshi3(name)   | schema1 |
      | conn_1 | false   | create index index3 on global(age)          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                | expect             | db      |
      | conn_2 | false   | insert into global(id,name) values (3,'sing')      | success            | schema1 |
      | conn_2 | false   | show index from global                             | hasNoStr{ceshi3}   | schema1 |
      | conn_2 | false   | show index from global                             | hasNoStr{index3}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect           | db      |
      | conn_1 | false   | show index from global             | hasStr{ceshi3}   | schema1 |
      | conn_1 | false   | show index from global             | hasStr{index3}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sharding table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                            | db      |
      | conn_1 | false   | alter table sharding2 add index ceshi4(name)   | schema1 |
      | conn_1 | false   | create index index4 on sharding2(age)          | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect             | db      |
      | conn_2 | false   | insert into sharding2(id,name) values (3,'sing')      | success            | schema1 |
      | conn_2 | false   | show index from sharding2                             | hasNoStr{ceshi4}   | schema1 |
      | conn_2 | true    | show index from sharding2                             | hasNoStr{index4}   | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect           | db      |
      | conn_1 | false   | show index from sharding2             | hasStr{ceshi4}   | schema1 |
      | conn_1 | true    | show index from sharding2             | hasStr{index4}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

   #vertical table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                      | db      |
      | conn_3 | false   | alter table ver add index ceshi5(name)   | schema2 |
      | conn_3 | false   |create index index5 on ver(age)           | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect           | db      |
      | conn_4 | false   | insert into ver(id,name) values (3,'sing')      | success          | schema2 |
      | conn_4 | false   | show index from ver                             | hasNoStr{ceshi5} | schema2 |
      | conn_4 | true    | show index from ver                             | hasNoStr{index5} | schema2 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect         | db      |
      | conn_3 | false   | show index from ver             | hasStr{ceshi5} | schema2 |
      | conn_3 | true    | show index from ver             | hasStr{index5} | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """


  @skip_restart
  Scenario: ALTER TABLE tbl_name DROP INDEX i1, ADD INDEX i1(key_part,... ) USING BTREE, ALGORITHM=INSTANT    #3
    #nosharding table
    Given record current dble log line number in "log_linenu"
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                                                        | db      |
      | conn_1 | false   | alter table nosharding drop index ceshi1,add index aks1(name) USING HASH   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                    | expect             | db      |
      | conn_2 | false   | insert into nosharding(id,name) values (3,'nosh')      | success            | schema1 |
      | conn_2 | false   | show index from nosharding                             | hasNoStr{aks1}     | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect              | db      |
      | conn_1 | false   | show index from nosharding       | hasStr{aks1}        | schema1 |
      | conn_1 | false   | show create table nosharding     | hasStr{USING HASH}  | schema1 |

    #sing table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                                                  | db      |
      | conn_1 | false   | alter table sing drop index ceshi2,add index aks2(name) USING HASH   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                              | expect             | db      |
      | conn_2 | false   | insert into sing(id,name) values (3,'sing')      | success            | schema1 |
      | conn_2 | false   | show index from sing                             | hasNoStr{aks2}     | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                              | expect           | db      |
      | conn_1 | false   | show index from sing             | hasStr{aks2}     | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #global table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                                                    | db      |
      | conn_1 | false   | alter table global drop index ceshi3,add index aks3(name) USING HASH   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                | expect             | db      |
      | conn_2 | false   | insert into global(id,name) values (3,'sing')      | success            | schema1 |
      | conn_2 | false   | show index from global                             | hasNoStr{aks3}     | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect         | db      |
      | conn_1 | false   | show index from global             | hasStr{aks3}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sharding table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                                                       | db      |
      | conn_1 | false   | alter table sharding2 drop index ceshi4,add index aks4(name) USING HASH   | schema1 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect             | db      |
      | conn_2 | false   | insert into sharding2(id,name) values (3,'sing')      | success            | schema1 |
      | conn_2 | true    | show index from sharding2                             | hasNoStr{aks4}     | schema1 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                   | expect           | db      |
      | conn_1 | true    | show index from sharding2             | hasStr{aks4}     | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

   #vertical table
    Given execute sqls in "dble-1" at background
      | conn   | toClose | sql                                                                 | db      |
      | conn_1 | false   | alter table ver drop index ceshi5,add index aks5(name) USING HASH   | schema2 |
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                             | expect           | db      |
      | conn_4 | false   | insert into ver(id,name) values (3,'sing')      | success          | schema2 |
      | conn_4 | true    | show index from ver                             | hasNoStr{aks5}   | schema2 |
    Given sleep "10" seconds
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                             | expect         | db      |
      | conn_3 | true    | show index from ver             | hasStr{aks5}   | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """


  @skip_restart
  Scenario: DROP INDEX name ON table / ALTER TABLE tbl_name DROP INDEX name   #4
    #case drop index time is less,don't check dml
    #nosharding table
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                      | expect           | db      |
      | conn_1 | false   | alter table nosharding drop index aks1   | success          | schema1 |
      | conn_1 | false   | drop index index1 on nosharding          | success          | schema1 |
      | conn_1 | false   | show index from nosharding               | hasNoStr{aks1}   | schema1 |
      | conn_1 | false   | show index from nosharding               | hasNoStr{index1} | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sing table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                | expect             | db      |
      | conn_1 | false   | alter table sing drop index aks2   | success            | schema1 |
      | conn_1 | false   | drop index index2 on sing          | success            | schema1 |
      | conn_1 | false   | show index from sing               | hasNoStr{aks2}     | schema1 |
      | conn_1 | false   | show index from sing               | hasNoStr{index2}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                  | expect             | db      |
      | conn_1 | false   | alter table global drop index aks3   | success            | schema1 |
      | conn_1 | false   | drop index index3 on global          | success            | schema1 |
      | conn_1 | false   | show index from global               | hasNoStr{aks3}     | schema1 |
      | conn_1 | false   | show index from global               | hasNoStr{index3}   | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                     | expect             | db      |
      | conn_1 | false   | alter table sharding2 drop index aks4   | success            | schema1 |
      | conn_1 | false   | drop index index4 on sharding2          | success            | schema1 |
      | conn_1 | false   | show index from sharding2               | hasNoStr{aks4}     | schema1 |
      | conn_1 | true    | show index from sharding2               | hasNoStr{index4}   | schema1 |
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

   #vertical table
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                               | expect           | db      |
      | conn_3 | false   | alter table ver drop index aks5   | success          | schema2 |
      | conn_3 | false   | drop index index5 on ver          | success          | schema2 |
      | conn_3 | false   | show index from ver               | hasNoStr{aks5}   | schema2 |
      | conn_3 | true    | show index from ver               | hasNoStr{index5} | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """


 Scenario: ALTER TABLE tbl_name ALTER COLUMN col SET DEFAULT literal, ALGORITHM=INSTANT/ ALTER TABLE tbl ALTER COLUMN col DROP DEFAULT, ALGORITHM=INSTANT   #5
    Given record current dble log line number in "log_linenu"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                       | expect           | db      |
      | conn_1 | false   | alter table nosharding alter column age drop default      | success          | schema1 |
      | conn_1 | false   | show create table nosharding                              | hasNoStr{2020}   | schema1 |
      | conn_1 | false   | alter table nosharding alter column age set default 2021  | success          | schema1 |
      | conn_1 | false   | show create table nosharding                              | hasStr{2021}     | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sing table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                 | expect           | db      |
      | conn_1 | false   | alter table sing alter column age drop default      | success          | schema1 |
      | conn_1 | false   | show create table sing                              | hasNoStr{2020}   | schema1 |
      | conn_1 | false   | alter table sing alter column age set default 2021  | success          | schema1 |
      | conn_1 | false   | show create table sing                              | hasStr{2021}     | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #global table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                   | expect           | db      |
      | conn_1 | false   | alter table global alter column age drop default      | success          | schema1 |
      | conn_1 | false   | show create table global                              | hasNoStr{2020}   | schema1 |
      | conn_1 | false   | alter table global alter column age set default 2021  | success          | schema1 |
      | conn_1 | false   | show create table global                              | hasStr{2021}     | schema1 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    #sharding table
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                      | expect           | db      |
      | conn_1 | false   | alter table sharding2 alter column age drop default      | success          | schema1 |
      | conn_1 | false   | show create table sharding2                              | hasNoStr{2020}   | schema1 |
      | conn_1 | false   | alter table sharding2 alter column age set default 2021  | success          | schema1 |
      | conn_1 | true    | show create table sharding2                              | hasStr{2021}     | schema1 |
   Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

   #vertical table
   Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                | expect           | db      |
      | conn_3 | false   | alter table ver alter column age drop default      | success          | schema2 |
      | conn_3 | false   | show create table ver                              | hasNoStr{2020}   | schema2 |
      | conn_3 | false   | alter table ver alter column age set default 2021  | success          | schema2 |
      | conn_3 | true    | show create table ver                              | hasStr{2021}     | schema2 |
    Then check following text exist "N" in file "/opt/dble/logs/dble.log" after line "log_linenu" in host "dble-1"
       """
       stage = LOCK
       """

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                        | expect  | db      |
      | conn_1 | False   | drop table if exists nosharding            | success | schema1 |
      | conn_1 | False   | drop table if exists sing                  | success | schema1 |
      | conn_1 | False   | drop table if exists global                | success | schema1 |
      | conn_1 | true    | drop table if exists sharding2             | success | schema1 |
      | conn_2 | true    | drop table if exists schema2.ver           | success | schema2 |

