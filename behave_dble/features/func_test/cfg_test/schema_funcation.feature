# -*- coding=utf-8 -*-
# Copyright (C) 2016-2023 ActionTech.
# License: https://www.mozilla.org/en-US/MPL/2.0 MPL version 2 or higher.
# Created by caiwei at 2021/9/22

Feature: schema support add function

  Scenario: sharding.xml configuration verification     #1
    #shardingNode's number that schema's function is involved should match with schema's shardingNode's number
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn1,dn2" name="schema2" function="hash-four" sqlMaxLimit="100"/>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect            |
      |conn_1 | False   | reload @@config_all          | Reload Failure    |
    #schema cannot add same shardingNode
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn1,dn1" name="schema3" function="hash-two" sqlMaxLimit="100"/>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect         |
      |conn_1 | False   | reload @@config_all          | Reload Failure |
    #schema's name cannot be duplicated
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn1,dn2" name="schema1" function="hash-two" sqlMaxLimit="100"/>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect         |
      |conn_1 | False   | reload @@config_all          | Reload Failure |

  Scenario: create table with different type of column to test the table's shardingKey be correctly confirmed      #2
    # shardingKey confirmed rules:
    # Determine the priority of the shardingKey：primary key > unique key > normal index > id column > first column
    # shardingKey need to avoid auto_increment column
    # table has only one auto_increment column will be confirmed as shardingKey
    # after create table , then add high priority column and reload @@metadata, shardingColumn should change

    Given delete all backend mysql tables
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100"></schema>
      """
    Given delete the following xml segment
      |file        | parent          | child                     |
      |user.xml    |{'tag':'root'}   | {'tag':'shardingUser'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
        <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """
    Then execute admin cmd "reload @@config_all"
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                         | expect      | db      |
      | conn_0 | False   | drop table if exists test1                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test2                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test3                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test4                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test5                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test6                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test7                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test8                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test9                                                                                                  | success     | schema2 |
      | conn_0 | False   | drop table if exists test10                                                                                                 | success     | schema2 |
      | conn_0 | False   | drop table if exists test11                                                                                                 | success     | schema2 |
      | conn_0 | False   | drop table if exists test12                                                                                                 | success     | schema2 |
      | conn_0 | False   | drop table if exists test13                                                                                                 | success     | schema2 |
      | conn_0 | False   | drop table if exists test14                                                                                                 | success     | schema2 |
      | conn_0 | False   | drop table if exists test15                                                                                                 | success     | schema2 |
      | conn_0 | False   | drop table if exists test16                                                                                                 | success     | schema2 |
      # tetermine the split column according to the priority
      | conn_0 | False   | create table test1(aid int)                                                                                                 | success     | schema2 |
      | conn_0 | False   | create table test2(bid int,id int)                                                                                          | success     | schema2 |
      | conn_0 | False   | create table test3(cid int,id int,did int,index(did))                                                                       | success     | schema2 |
      | conn_0 | False   | create table test4(eid int,id int,fid int,gid int unique,index(fid))                                                        | success     | schema2 |
      | conn_0 | False   | create table test5(hid int,id int,iid int,jid int unique,kid int primary key,index(iid))                                    | success     | schema2 |
      #avoid auto_increment column
      | conn_0 | False   | create table test6(lid int,id int auto_increment,index(id))                                                                 | success     | schema2 |
      | conn_0 | False   | create table test7(mid int,id int,nid int auto_increment,index(nid))                                                        | success     | schema2 |
      | conn_0 | False   | create table test8(oid int,pid int auto_increment,index(pid))                                                               | success     | schema2 |
      | conn_0 | False   | create table test9(qid int,id int,rid int,sid int auto_increment unique,index(rid))                                         | success     | schema2 |
      | conn_0 | False   | create table test10(tid int,id int,uid int auto_increment unique)                                                           | success     | schema2 |
      | conn_0 | False   | create table test11(vid int,wid int auto_increment unique)                                                                  | success     | schema2 |
      | conn_0 | False   | create table test12(xid int,id int,yid int,zid int unique,aa int primary key auto_increment,index(yid))                     | success     | schema2 |
      | conn_0 | False   | create table test13(bb int,id int,cc int,dd int primary key auto_increment,index(cc))                                       | success     | schema2 |
      | conn_0 | False   | create table test14(ee int,id int,ff int primary key auto_increment)                                                        | success     | schema2 |
      | conn_0 | False   | create table test15(gg int,hh int primary key auto_increment)                                                               | success     | schema2 |
      # table has only one auto_increment column will be confirmed as shardingKey
      | conn_0 | False   | create table test16(ii int auto_increment,index(ii))                                                                        | success     | schema2 |
      # sharding column not allow to drop
      | conn_0 | true    | alter table test2 drop column id                                                                                            | The columns may be sharding keys or ER keys, are not allowed to alter sql | schema2 |

    Given execute single sql in "dble-1" in "admin" mode and save resultset in "A"
      | conn   | toClose | sql                                                      | db              |
      | conn_0 | False   | select * from dble_sharding_table                        | dble_information|
    Then check resultset "A" has lines with following column values
      | increment_column-1 | sharding_column-2 | sql_required_sharding-3 | algorithm_name-4 |
      | None               | ID                | false                   | hash-two       |
      | None               | ID                | false                   | hash-four      |
      | None               | AID               | false                   | hash-two       |
      | None               | ID                | false                   | hash-two       |
      | None               | DID               | false                   | hash-two       |
      | None               | GID               | false                   | hash-two       |
      | None               | KID               | false                   | hash-two       |
      | None               | LID               | false                   | hash-two       |
      | None               | ID                | false                   | hash-two       |
      | None               | OID               | false                   | hash-two       |
      | None               | RID               | false                   | hash-two       |
      | None               | ID                | false                   | hash-two       |
      | None               | VID               | false                   | hash-two       |
      | None               | ZID               | false                   | hash-two       |
      | None               | CC                | false                   | hash-two       |
      | None               | ID                | false                   | hash-two       |
      | None               | GG                | false                   | hash-two       |
      | None               | II                | false                   | hash-two       |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "B"
      | conn   | toClose | sql                                                      | db              |
      | conn_0 | False   | select * from dble_schema                                | dble_information|
    Then check resultset "B" has lines with following column values
      | name-0  | sharding_node-1 | function-2 | sql_max_limit-4    |
      | schema1 | dn5             | -          |           100      |
      | schema2 | dn1,dn2         | hash-two   |           100      |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "C"
      | conn   | toClose | sql                                                      | db              |
      | conn_0 | False   | select * from dble_table                                 | dble_information|
    Then check resultset "C" has lines with following column values
       | name-1          | schema-2  | max_limit-3 | type-4     |
       | test            | schema1 |       100 | GLOBAL   |
       | sharding_2_t1   | schema1 |       100 | SHARDING |
       | sharding_4_t1   | schema1 |       100 | SHARDING |
       | test1           | schema2 |       100 | SHARDING |
       | test2           | schema2 |       100 | SHARDING |
       | test3           | schema2 |       100 | SHARDING |
       | test4           | schema2 |       100 | SHARDING |
       | test5           | schema2 |       100 | SHARDING |
       | test6           | schema2 |       100 | SHARDING |
       | test7           | schema2 |       100 | SHARDING |
       | test8           | schema2 |       100 | SHARDING |
       | test9           | schema2 |       100 | SHARDING |
       | test10          | schema2 |       100 | SHARDING |
       | test11          | schema2 |       100 | SHARDING |
       | test12          | schema2 |       100 | SHARDING |
       | test13          | schema2 |       100 | SHARDING |
       | test14          | schema2 |       100 | SHARDING |
       | test15          | schema2 |       100 | SHARDING |
       | test16          | schema2 |       100 | SHARDING |
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                            | expect        | db              |
      | conn_0 | true    | select * from dble_table_sharding_node         | length{(42)}  | dble_information|

    # insert into table created in schema with function, to verify data insert correctly
    # take table test1 and test6 as example
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                           | expect | db     |
      | conn_1 | False   | insert into test1 values(1),(2),(3),(4)       | success| schema2|
      | conn_1 | true    | insert into test6(lid) values(1),(2),(3),(4)  | success| schema2|
    Then execute sql in "mysql-master1" in "mysql" mode
      | conn  | toClose | sql                                           | expect           | db    |
      | conn_1| False   | select * from test1                           | has{(2,),(4,)}   | db1   |
      | conn_1| true    | select * from test6                           | has{(2,1),(4,2)} | db1   |
    Then execute sql in "mysql-master2" in "mysql" mode
      | conn  | toClose | sql                                           | expect           | db    |
      | conn_1| False   | select * from test1                           | has{(1,),(3,)}     | db1   |
      | conn_1| true    | select * from test6                           | has{(1,1),(3,2)} | db1   |

    # after create table, add high priority type of shardingKey, origin sharding column not change, after reload @@metadata, sharding column will change
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                | expect | db     |
      | conn_1 | true    | alter table test2 add (new_ID_a int, index a(new_ID_a))            | success| schema2|
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                  | expect                     | db              |
      | conn_1 | true    | select sharding_column from dble_sharding_table      | hasnot{(('NEW_ID_A',),)}      | dble_information|
    Then execute admin cmd "reload @@metadata"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                  | expect                  | db              |
      | conn_1 | true    | select sharding_column from dble_sharding_table      | has{(('NEW_ID_A',),)}      | dble_information|

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                             | expect | db     |
      | conn_1 | true    | alter table test2 add (new_ID_b int unique)                     | success| schema2|
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                  | expect                     | db              |
      | conn_1 | true    | select sharding_column from dble_sharding_table      | hasnot{(('NEW_ID_B',),)}      | dble_information|
    Then execute admin cmd "reload @@metadata where schema='schema2'"
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                  | expect                  | db              |
      | conn_1 | true    | select sharding_column from dble_sharding_table      | has{(('NEW_ID_B',),)}      | dble_information|

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                     | expect | db     |
      | conn_1 | true    | alter table test2 add column new_ID_C int primary key                   | success| schema2|
    Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                                  | expect                     | db              |
      | conn_1 | true    | select sharding_column from dble_sharding_table      | hasnot{(('NEW_ID_C',),)}      | dble_information|
    Then execute admin cmd "reload @@config_all -r"
    Then execute sql in "dble-1" in "admin" mode
     | conn   | toClose | sql                                                  | expect                     | db              |
     | conn_1 | true    | select sharding_column from dble_sharding_table      | has{(('NEW_ID_C',),)}         | dble_information|

    # column type required by schema function not match with table's column type, table will create success but cannot add data
    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                 | expect                                                              | db            |
      | conn_1 | False   | create table test17(id varchar(10))                                 | success                                                             | schema2       |
      | conn_1 | true    | insert into test17 values('aa')                                     | columnValue:aa Please eliminate any quote and non number within it. | schema2       |

    Then execute sql in "dble-1" in "user" mode
      | conn   | toClose | sql                                                                                                                         | expect      | db      |
      | conn_2 | False   | drop table if exists test1                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test2                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test3                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test4                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test5                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test6                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test7                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test8                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test9                                                                                                  | success     | schema2 |
      | conn_2 | False   | drop table if exists test10                                                                                                 | success     | schema2 |
      | conn_2 | False   | drop table if exists test11                                                                                                 | success     | schema2 |
      | conn_2 | False   | drop table if exists test12                                                                                                 | success     | schema2 |
      | conn_2 | False   | drop table if exists test13                                                                                                 | success     | schema2 |
      | conn_2 | False   | drop table if exists test14                                                                                                 | success     | schema2 |
      | conn_2 | False   | drop table if exists test15                                                                                                 | success     | schema2 |
      | conn_2 | False   | drop table if exists test16                                                                                                 | success     | schema2 |
      | conn_2 | true    | drop table if exists test17                                                                                                 | success     | schema2 |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "D"
      | conn   | toClose | sql                                                      | db              |
      | conn_0 | False   | select * from dble_sharding_table                        | dble_information|
    Then check resultset "D" has lines with following column values
      | increment_column-1 | sharding_column-2 | sql_required_sharding-3 | algorithm_name-4 |
      | None               | ID                | false                   | hash-two         |
      | None               | ID                | false                   | hash-four        |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "E"
      | conn   | toClose | sql                                                      | db              |
      | conn_0 | False   | select * from dble_schema                                | dble_information|
    Then check resultset "E" has lines with following column values
      | name-0  | sharding_node-1 | function-2 | sql_max_limit-4 |
      | schema1 | dn5             | -          | 100             |
      | schema2 | dn1,dn2         | hash-two   | 100             |
    Given execute single sql in "dble-1" in "admin" mode and save resultset in "F"
      | conn   | toClose | sql                                                      | db              |
      | conn_0 | False   | select * from dble_table                                 | dble_information|
    Then check resultset "F" has lines with following column values
       | name-1          | schema-2  | max_limit-3 | type-4   |
       | test            | schema1 |       100     | GLOBAL   |
       | sharding_2_t1   | schema1 |       100     | SHARDING |
       | sharding_4_t1   | schema1 |       100     | SHARDING |
     Then execute sql in "dble-1" in "admin" mode
      | conn   | toClose | sql                                            | expect        | db              |
      | conn_0 | true    | select * from dble_table_sharding_node         | length{(10)}  | dble_information|

  Scenario: Test with custom table under the schema          #3
    # custom table config incorrectly,  reload should fail
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100">
            <shardingTable name="sharding_1" shardingNode="dn3,dn4" />
        </schema>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect         |
      |conn_0 | False   | reload @@config_all          | Reload Failure |
    Given delete the following xml segment
      |file            | parent          | child               |
      |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
            <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>

        <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100">
            <shardingTable name="sharding_1" shardingNode="dn3,dn4" shardingColumn="id"/>
        </schema>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect         |
      |conn_0 | False   | reload @@config_all          | Reload Failure |
    Given delete the following xml segment
      |file            | parent          | child               |
      |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
            <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>

        <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100">
            <shardingTable name="sharding_1" function="hash-two" />
        </schema>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect         |
      |conn_0 | False   | reload @@config_all          | Reload Failure |
    Given delete the following xml segment
      |file            | parent          | child               |
      |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
            <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>

        <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100">
            <shardingTable name="sharding_1" function="hash-two" shardingColumn="id"/>
        </schema>
      """
    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect         |
      |conn_0 | False   | reload @@config_all          | Reload Failure |

    # custom table config correctly, check the correctness of the shards
    Given delete the following xml segment
      |file            | parent          | child               |
      |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
      """
        <schema shardingNode="dn5" name="schema1" sqlMaxLimit="100">
            <globalTable name="test" shardingNode="dn1,dn2,dn3,dn4" />
            <shardingTable name="sharding_2_t1" shardingNode="dn1,dn2" function="hash-two" shardingColumn="id" />
            <shardingTable name="sharding_4_t1" shardingNode="dn1,dn2,dn3,dn4" function="hash-four" shardingColumn="id"/>
        </schema>

        <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100">
            <shardingTable name="sharding_1" function="hash-three" shardingColumn="id" shardingNode="dn2,dn3,dn4"/>
            <singleTable name="single_1" shardingNode="dn1"/>
            <globalTable name="global_1" shardingNode="dn1,dn2,dn3,dn4"/>
        </schema>
      """

    Given delete the following xml segment
      |file        | parent          | child                     |
      |user.xml    |{'tag':'root'}   | {'tag':'shardingUser'}    |
    Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
      """
        <shardingUser name="test" password="111111" schemas="schema1,schema2"/>
      """

    Then execute sql in "dble-1" in "admin" mode
      |conn   | toClose | sql                          | expect           |
      |conn_0 | true    | reload @@config_all          | success          |
    Then execute sql in "dble-1" in "user" mode
      |conn   | toClose | sql                                                   | expect   | db      |
      |conn_0 | False   | drop table if exists sharding_1                       | success  | schema2 |
      |conn_0 | False   | drop table if exists single_1                         | success  | schema2 |
      |conn_0 | False   | drop table if exists global_1                         | success  | schema2 |
      |conn_0 | False   | create table sharding_1(id int, a int)                | success  | schema2 |
      |conn_0 | False   | create table single_1(id int,a int)                   | success  | schema2 |
      |conn_0 | False   | create table global_1(id int,a int)                   | success  | schema2 |
      |conn_0 | False   | insert into sharding_1 values(1,1),(2,2),(3,3),(4,4)  | success  | schema2 |
      |conn_0 | False   | insert into single_1 values(1,1),(2,2),(3,3),(4,4)    | success  | schema2 |
      |conn_0 | true    | insert into global_1 values(1,1),(2,2),(3,3),(4,4)    | success  | schema2 |
    Then execute sql in "mysql-master1" in "mysql" mode
      | conn  | toClose | sql                                           | expect                       | db    |
      | conn_1| False   | select * from sharding_1                      | has{(1,1),(4,4)}             | db2   |
      | conn_2| False   | select * from single_1                        | has{(1,1),(2,2),(3,3),(4,4)} | db1   |
      | conn_2| true    | select * from global_1                        | has{(1,1),(2,2),(3,3),(4,4)} | db1   |
      | conn_1| true    | select * from global_1                        | has{(1,1),(2,2),(3,3),(4,4)} | db2   |
    Then execute sql in "mysql-master2" in "mysql" mode
      | conn  | toClose | sql                                           | expect                       | db    |
      | conn_3| False   | select * from sharding_1                      | has{((3,3),)}                  | db1   |
      | conn_4| False   | select * from sharding_1                      | has{((2,2),)}                  | db2   |
      | conn_3| true    | select * from global_1                        | has{(1,1),(2,2),(3,3),(4,4)} | db1   |
      | conn_4| true    | select * from global_1                        | has{(1,1),(2,2),(3,3),(4,4)} | db2   |
    Then execute sql in "dble-1" in "user" mode
      |conn   | toClose | sql                                                   | expect   | db      |
      |conn_0 | False   | drop table if exists sharding_1                       | success  | schema2 |
      |conn_0 | False   | drop table if exists single_1                         | success  | schema2 |
      |conn_0 | true    | drop table if exists global_1                         | success  | schema2 |

    Scenario: checkTableConsistency=1, Consistency check by  checkTableConsistencyPeriod         #4
      #custom table's shardingNode no one same with schema's shardingNode
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
          <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100"></schema>
        """
     Given delete the following xml segment
        |file        | parent          | child                     |
        |user.xml    |{'tag':'root'}   | {'tag':'shardingUser'}    |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
        """
          <shardingUser name="test" password="111111" schemas="schema2"/>
        """
      Then execute admin cmd "reload @@config_all"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                             | expect   | db      |
        |conn_0 | False   | drop table if exists test1                      | success  | schema2 |
        |conn_0 | False   | drop table if exists test2                      | success  | schema2 |
        |conn_0 | False   | drop table if exists test3                      | success  | schema2 |
        |conn_0 | False   | create table test1(aid int,id int)              | success  | schema2 |
        |conn_0 | False   | create table test2(aid int,id int)              | success  | schema2 |
        |conn_0 | true    | create table test3(aid int,id int)              | success  | schema2 |
      Given delete the following xml segment
        |file            | parent          | child               |
        |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}    |
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
          <schema shardingNode="dn1,dn2" name="schema2" function="hash-two" sqlMaxLimit="100">
              <shardingTable name="test1" function="hash-two" shardingColumn="id" shardingNode="dn3,dn4"/>
              <singleTable name="test2" shardingNode="dn3"/>
              <globalTable name="test3" shardingNode="dn3,dn4,dn5"/>
          </schema>
        """
      Then execute admin cmd "reload @@config_all"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                             | expect                                 | db      |
        |conn_1 | False   | show tables                                     | hasnot{('test1',),('test2',),('test3',)}  | schema2 |
        |conn_1 | False   | create table test1(aid int,id int)              | success                                | schema2 |
        |conn_1 | False   | create table test2(aid int,id int)              | success                                | schema2 |
        |conn_1 | False   | create table test3(aid int,id int)              | success                                | schema2 |
        |conn_1 | False   | show tables                                     | has{('test1',),('test2',),('test3',)}     | schema2 |
        |conn_1 | False   | drop table if exists test1                      | success                                | schema2 |
        |conn_1 | False   | drop table if exists test2                      | success                                | schema2 |
        |conn_1 | true    | drop table if exists test3                      | success                                | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                           | expect              | db    |
        | conn_1| False   | drop table if exists test1                    | success             | db1   |
        | conn_1| False   | drop table if exists test2                    | success             | db1   |
        | conn_1| true    | drop table if exists test3                    | success             | db1   |
      Then execute sql in "mysql-master2" in "mysql" mode
        | conn  | toClose | sql                                           | expect              | db    |
        | conn_1| False   | drop table if exists test1                    | success             | db1   |
        | conn_1| False   | drop table if exists test2                    | success             | db1   |
        | conn_1| true    | drop table if exists test3                    | success             | db1   |

      # custom table shardingNode at least one shardingNode same with schema's shardingNode
      # set checkTableConsistency mode on
      Given update file content "/opt/dble/conf/bootstrap.cnf" in "dble-1" with sed cmds
        """
          $a -DcheckTableConsistency=1
          $a -DcheckTableConsistencyPeriod=2000
        """

      # backend mysql table part lost
      Then Restart dble in "dble-1" success
      Given delete the following xml segment
        |file            | parent          | child                     |
        |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}          |
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
          <schema shardingNode="dn4,dn5" name="schema2" function="hash-two" sqlMaxLimit="100"> </schema>
        """
      Then execute admin cmd "reload @@config_all"

      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                      | expect   | db      |
        |conn_2 | False   | drop table if exists sharding_table_1                    | success  | schema2 |
        |conn_2 | true    | create table sharding_table_1(aid int,id int)            | success  | schema2 |
      Given record current dble log line number in "log_num_1"
      Given delete the following xml segment
        |file            | parent          | child               |
        |sharding.xml    |{'tag':'root'}   | {'tag':'schema'}    |
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
          <schema shardingNode="dn4,dn5" name="schema2" function="hash-two" sqlMaxLimit="100">
              <shardingTable name="sharding_table_1" function="hash-three" shardingColumn="id" shardingNode="dn2,dn3,dn4"/>
          </schema>
        """
      Then execute admin cmd "reload @@config_all"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                             | expect                                      | db      |
        |conn_3 | true    | show tables                                     | has{(('sharding_table_1',),)}               | schema2 |
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_1" in host "dble-1" retry "2,2" times
        """
          Table \[sharding_table_1\] structure are not consistent in different shardingNode
        """
      Given record current dble log line number in "log_num_2"
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                             | expect              | db    |
        | conn_4| true    | create table sharding_table_1(aid int,id int)   | success             | db2   |
      Then execute sql in "mysql-master2" in "mysql" mode
        | conn  | toClose | sql                                             | expect              | db    |
        | conn_4| true    | create table sharding_table_1(aid int,id int)   | success             | db1   |
      #for arriving checkTableConsistencyPeriod time
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_2" in host "dble-1" retry "2,2" times
        """
          Table \[sharding_table_1\] structure of all shardingNodes has been restored to be consistent
        """
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                        | expect   | db      |
        |conn_5 | False   | select * from sharding_table_1                             | success  | schema2 |
        |conn_5 | true    | drop table if exists sharding_table_1                      | success  | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                             | expect              | db    |
        | conn_5| true    | drop table if exists sharding_table_1           | success             | db3   |
      Then execute sql in "mysql-master2" in "mysql" mode
        | conn  | toClose | sql                                             | expect              | db    |
        | conn_5| true    | drop table if exists sharding_table_1           | success             | db2   |

      # backend mysql table structure changed
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                        | expect   | db      |
        |conn_6 | False   | drop table if exists sharding_table_2                      | success  | schema2 |
        |conn_6 | true    | create table sharding_table_2(aid int,id int)              | success  | schema2 |
      Given record current dble log line number in "log_num_3"
      Then execute sql in "mysql-master2" in "mysql" mode
        | conn  | toClose | sql                                                          | expect        | db    |
        | conn_7| False   | alter table sharding_table_2 add column bid int              | success       | db2   |
       #for arriving checkTableConsistencyPeriod time
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_3" in host "dble-1" retry "2,2" times
        """
          Table \[sharding_table_2\] structure are not consistent in different shardingNode
        """
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                                          | expect        | db    |
        | conn_7| true    | alter table sharding_table_2 drop column bid                 | success       | db2   |
       #for arriving checkTableConsistencyPeriod time
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_3" in host "dble-1" retry "2,2" times
        """
         Table \[sharding_table_2\] structure of all shardingNodes has been restored to be consistent
        """
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                        | expect   | db      |
        |conn_8 | False   | select * from sharding_table_2                             | success  | schema2 |
        |conn_8 | true    | drop table if exists sharding_table_2                      | success  | schema2 |

      #backend mysql table all lost，when arrive checkTableConsistencyPeriod time，8066 no data about this table
      Given record current dble log line number in "log_num_4"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                        | expect   | db      |
        |conn_9 | False   | drop table if exists sharding_table_3                      | success  | schema2 |
        |conn_9 | true    | create table sharding_table_3(aid int,id int)              | success  | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                              | expect              | db    |
        | conn_10| true    | drop table if exists sharding_table_3           | success             | db3   |
      Then execute sql in "mysql-master2" in "mysql" mode
        | conn   | toClose | sql                                             | expect              | db    |
        | conn_11| true    | drop table if exists sharding_table_3           | success             | db2   |
      #for arriving checkTableConsistencyPeriod time
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_4" in host "dble-1" retry "2,2" times
        """
          found the table\[schema2.sharding_table_3\] in all defaultNode\[dn4, dn5\] has been lost, will remove his metadata
        """
      Then execute sql in "dble-1" in "user" mode
        |conn    | toClose  | sql                             | expect                         | db      |
        |conn_12 | true     | show tables                     | hasnot{('sharding_table_3',),}  | schema2 |

    Scenario: checkTableConsistency=0, Consistency check by reload          #5

      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
          <schema shardingNode="dn4,dn5" name="schema2" function="hash-two" sqlMaxLimit="100"> </schema>
        """
      Given delete the following xml segment
        |file        | parent          | child                     |
        |user.xml    |{'tag':'root'}   | {'tag':'shardingUser'}    |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
        """
          <shardingUser name="test" password="111111" schemas="schema2"/>
        """
      Then execute admin cmd "reload @@config_all"

      #backend mysql table part lost
      Given record current dble log line number in "log_num_1"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                      | expect   | db      |
        |conn_0 | False   | drop table if exists sharding_table_4                    | success  | schema2 |
        |conn_0 | true    | create table sharding_table_4(aid int,id int)            | success  | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                                     | expect              | db    |
        | conn_1| true    | drop table if exists sharding_table_4                   | success             | db3   |
      Then execute sql in "dble-1" in "admin" mode
        |conn    | toClose   | sql                                                                       | expect   |
        |conn_2  | False     | reload @@metadata                                                         | success  |
        |conn_2  | true      | reload @@metadata where schema='schema2' and table='sharding_table_4'     | success  |
      Then check following text exists in file "/opt/dble/logs/dble.log" after line "log_num_1" in host "dble-1" with "2" times
        """
          Table \[sharding_table_4\] structure are not consistent in different shardingNode
        """
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                                             | expect              | db    |
        | conn_3| true    | create table sharding_table_4(aid int,id int)                   | success             | db3   |
      Then execute admin cmd "reload @@metadata"
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_1" in host "dble-1"
        """
           Table \[sharding_table_4\] structure of all shardingNodes has been restored to be consistent
        """
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                      | expect   | db      |
        |conn_4 | False   | select * from sharding_table_4                           | success  | schema2 |
        |conn_4 | true    | drop table if exists sharding_table_4                    | success  | schema2 |

      #backend mysql table all lost
      Given record current dble log line number in "log_num_2"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                        | expect   | db      |
        |conn_5 | False   | drop table if exists sharding_table_5                      | success  | schema2 |
        |conn_5 | true    | create table sharding_table_5(aid int,id int)              | success  | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                              | expect              | db    |
        | conn_6| true    | drop table if exists sharding_table_5            | success             | db3   |
      Then execute sql in "mysql-master2" in "mysql" mode
        | conn   | toClose | sql                                             | expect              | db    |
        | conn_7 | true    | drop table if exists sharding_table_5           | success             | db2   |
      Then execute sql in "dble-1" in "admin" mode
        |conn    | toClose   | sql                                                                       | expect   |
        |conn_8  | False     | reload @@metadata                                                         | success  |
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_2" in host "dble-1"
        """
          found the table\[schema2.sharding_table_5\] in all defaultNode\[dn4, dn5\] has been lost, will remove his metadata
        """
      Then execute sql in "dble-1" in "user" mode
        |conn    | toClose  | sql                             | expect                         | db      |
        |conn_9  | true     | show tables                     | hasnot{('sharding_table_3',),}  | schema2 |

      #backend mysql table structure changed
      Given record current dble log line number in "log_num_3"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                       | expect   | db      |
        |conn_10 | False   | drop table if exists sharding_table_6                    | success  | schema2 |
        |conn_10 | true    | create table sharding_table_6(aid int,id int)            | success  | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn   | toClose | sql                                                     | expect              | db    |
        | conn_11| true    | alter table sharding_table_6 add column bid int         | success             | db3   |
       Then execute sql in "dble-1" in "admin" mode
        |conn     | toClose   | sql                                                                       | expect   |
        |conn_12  | False     | reload @@metadata                                                         | success  |
        |conn_12  | False     | reload @@metadata where schema='schema2' and table='sharding_table_6'     | success  |
      Then check following text exists in file "/opt/dble/logs/dble.log" after line "log_num_3" in host "dble-1" with "2" times
        """
          Table \[sharding_table_6\] structure are not consistent in different shardingNode
        """
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn   | toClose | sql                                                             | expect              | db    |
        | conn_13| true    | alter table sharding_table_6 drop column bid                    | success             | db3   |
      Then execute admin cmd "reload @@metadata"
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" after line "log_num_3" in host "dble-1"
        """
           Table \[sharding_table_6\] structure of all shardingNodes has been restored to be consistent
        """
      Then execute sql in "dble-1" in "user" mode
        |conn    | toClose | sql                                                      | expect   | db      |
        |conn_14 | False   | select * from sharding_table_6                           | success  | schema2 |
        |conn_14 | true    | drop table if exists sharding_table_6                    | success  | schema2 |

    Scenario: shardingNode table structure not consistent, start dble should have warn log        #6
      Given add xml segment to node with attribute "{'tag':'root'}" in "sharding.xml"
        """
          <schema shardingNode="dn4,dn5" name="schema2" function="hash-two" sqlMaxLimit="100"> </schema>
        """
      Given delete the following xml segment
        |file        | parent          | child                     |
        |user.xml    |{'tag':'root'}   | {'tag':'shardingUser'}    |
      Given add xml segment to node with attribute "{'tag':'root'}" in "user.xml"
        """
          <shardingUser name="test" password="111111" schemas="schema2"/>
        """
      Then execute admin cmd "reload @@config_all"
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                      | expect   | db      |
        |conn_0 | False   | drop table if exists sharding_table_7                    | success  | schema2 |
        |conn_0 | true    | create table sharding_table_7(aid int,id int)            | success  | schema2 |
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                                     | expect              | db    |
        | conn_1| true    | alter table sharding_table_7 add column bid int         | success             | db3   |
      Given Restart dble in "dble-1" success
      Then check following text exist "Y" in file "/opt/dble/logs/dble.log" in host "dble-1"
        """
          Table \[sharding_table_7\] structure are not consistent in different shardingNode
        """
      Then execute sql in "mysql-master1" in "mysql" mode
        | conn  | toClose | sql                                                     | expect              | db    |
        | conn_1| true    | alter table sharding_table_7 drop column bid            | success             | db3   |
      Given Restart dble in "dble-1" success
      Then check following text exist "N" in file "/opt/dble/logs/dble.log" in host "dble-1"
        """
          Table \[sharding_table_7\] structure are not consistent in different shardingNode
        """
      Then execute sql in "dble-1" in "user" mode
        |conn   | toClose | sql                                                      | expect   | db      |
        |conn_2 | true    | drop table if exists sharding_table_7                    | success  | schema2 |
